React = require 'react'
THREE = Three = require 'three'
Physijs = require '../vendor/physijs_wrapper'
{euler,vec3,quat} = require '../lib/three_helpers'
PiecesParts = require '../spike/pieces_parts' # FIXME
EntitySearch = require '../lib/ecs/entity_search'

Objects = require './objects'
C = require './components'
T = C.Types

BigScreen = require '../vendor/bigscreen_wrapper'
# SceneWrapper = require './scene_wrapper'

ThreeView = React.createClass
  displayName: 'ThreeView'

  getInitialState: ->
    {
      width: @props.width
      height: @props.height
      address: @props.address
    }
  
  # Called ONCE just before initial render.
  componentWillMount: ->

  # Called ONCE just after initial render. DOM refs of children are available.
  componentDidMount: ->
    # FIXME: see if we can do this based on @props.address etc instead of @state
    width = @state.width
    height = @state.height
    address = @state.address

    fog = new Three.Fog(0x001525, 10, 40) # FIXME
    @renderer = new THREE.WebGLRenderer(canvas: @canvas)
    @renderer.setSize width, height
    @renderer.setClearColor fog.color # FIXME
    @renderer.shadowMap.enabled = true

    @scene = new Physijs.Scene(fixedTimeStep: 1/60)
    @scene.setGravity(vec3(0,-10,0))
    @scene.addEventListener 'update', =>
      detectHits(@scene.children, address)
      address.send(type: 'scene_update', data: @scene)

    @scene.fog = fog # FIXME
    PiecesParts.addDefaultLighting(@scene) # FIXME


  # Called once, just before removal from DOM.
  componentWillUnmount: ->

  componentWillReceiveProps: (nextProps) ->
    if nextProps.width != @state.width or nextProps.height != @state.height
      @setState {
        width: nextProps.width
        height: nextProps.height
        address: nextProps.address
      }

    # GAME OBJECTS -> SCENE
    if !@camera?
      @camera = createFollowCamera("follow_cam", @state.width/@state.height) #FIXME this tagname is hardcoded! Manage cams based on estore state
    updateFollowCamera @camera, nextProps.estore
    updateSceneFromEntities @scene, nextProps.estore, @state.address

    # SIMULATE PHYSICS
    # @scene.simulate(undefined, 2) # ?
    @scene.simulate(1/60,2)

    # RENDER
    @renderer.render(@scene, @camera)

    return null


  # Determine if render and DOM flushing should occur.
  # Not called on initial render.
  shouldComponentUpdate: (nextProps, nextState) ->
    # Since SceneWrapper.updateAndRender handles the updating, this component
    # should only re-render if the shape changes:
    return (nextState.width != @state.width) or (nextState.height != @state.height)

  # Called just before render assuming shouldComponentUpdate returned true.
  # DO NOT CALL setState in here.
  # Not called on initial render.
  componentWillUpdate: (nextProps, nextState) ->

  # Called after render and DOM changes have been flushed
  # Not called on initial render.
  componentDidUpdate: (prevProps, prevState) ->

  goBig: (e) ->
    console.log "goBig!", e
    BigScreen.doTheBigThing @canvas

  render: ->
    <div>
    <canvas 
      width={@state.width} 
      height={@state.height} 
      style={width:@state.width, height:@state.height} 

      ref={(ref) => @canvas = ref} 
    />
    <button onClick={@goBig}>Big</button>
    </div>

#
# CAMERA HELPERS
# 

CameraSearcher = EntitySearch.prepare([T.FollowCamera])

createFollowCamera = (name,aspect) ->
  fov = 75
  near = 0.1
  far = 1000
  camera = new THREE.PerspectiveCamera(fov,aspect,near,far)
  camera.name = name
  return camera

updateFollowCamera = (camera,estore) ->
  cameraEntity = CameraSearcher.singleEntity(estore)
  cameraComp = cameraEntity.get(T.FollowCamera)
  lookAt = cameraComp.lookAt
  camLoc = cameraEntity.get(T.Location)
  pos = camLoc.position
  camera.position.set(pos.x,pos.y,pos.z)
  camera.lookAt(lookAt)
  null

#
# Custom "collision detection" using geometry, not physics
#
class Hit
  constructor: (@this_cid,@this_eid, @other_cid,@other_eid) ->

detectHits = (shapes, address) ->
  hittables = []
  hitters = []
  for shape in shapes
    if shape.userData.hitProfile?
      if shape.userData.hitProfile.canHitOn != 0
        hitters.push shape
      if shape.userData.hitProfile.getHitOn != 0
        hittables.push shape

  return if hitters.length == 0 or hittables.length == 0

  for a in hitters
    for b in hittables
      if a.id != b.id
        if a.userData.hitProfile.canHitOn & b.userData.hitProfile.getHitOn
          aSphere = a.userData.hitProfile.hitSphere
          aSphere.center.set(a.position.x, a.position.y, a.position.z)
          bSphere = b.userData.hitProfile.hitSphere
          bSphere.center.set(b.position.x, b.position.y, b.position.z)
          if aSphere.intersectsSphere(bSphere)
            ahit = new Hit(a.userData.cid, a.userData.eid, b.userData.cid, b.userData.eid)
            address.send(type: 'hit', data: ahit)
            if b.userData.hitProfile.check
              bhit = new Hit(b.userData.cid, b.userData.eid, a.userData.cid, a.userData.eid)
              address.send(type: 'hit', data: bhit)

#
# ENTITY->SCENE FUNCS
#
PhysicalSearcher = EntitySearch.prepare([T.Physical,T.Location])

updateSceneFromEntities = (scene,estore,address) ->
  # For all physical entites, create or update their shapes in scene:
  PhysicalSearcher.run estore, (r) ->
    [physical,location] = r.comps

    shape = scene.getObjectById(physical.shapeId)
    if !shape?
      shape = newShapeFromComponents(physical,location,address)
      scene.add shape

    Objects.update3DShape(shape, physical,location)
    shape.userData.relevant = true

  # Find shapes in scene whose entities have disappeared:
  markedForDeath = []
  for shape in scene.children
    if shape.userData.managed
      if !shape.userData.relevant
        markedForDeath.push shape
      else
        shape.userData.relevant = false

  # Remove shapes from scene whose entities have disappeared:
  for shape in markedForDeath
    scene.remove shape

  null

newShapeFromComponents = (physical,location,address) ->
  shape = Objects.create3DShape(physical,location)
  shape.userData.managed = true
  shape.userData.eid = physical.eid
  shape.userData.cid = physical.cid
  if physical.receiveCollisions
    shape.addEventListener('collision', (other_object, relative_velocity, relative_rotation, contact_normal) ->
      coll =
        this_cid: shape.userData.cid
        this_eid: shape.userData.eid
        other_cid: other_object.userData.cid
        other_eid: other_object.userData.eid
        velocity: relative_velocity
        angularVelocity: relative_rotation
        normal: contact_normal

      address.send(type: 'physics_collision', data: coll)
    )
    # TODO no such thing, but it sure would be helpful: shape.addEventListener('uncollision', (other_object) ->

  physical.shapeId = shape.id

  shape

module.exports = ThreeView

