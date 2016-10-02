THREE = Three = require 'three'
{euler,vec3,quat} = require '../../../lib/three_helpers'
EntitySearch = require '../../../lib/ecs/entity_search'
C = require '../components'
T = C.Types
Objects = require '../objects'

Physijs = require '../../../vendor/physijs_wrapper'

PiecesParts = require '../../../spike/pieces_parts'

D = 20

defaultFog = ->
  fog = new Three.Fog(0x001525, 10, 40)
  return fog

defaultDirectionalLight = ->
  color = 0xffffff
  intensity = 1
  position = vec3(D,D,D)
  targetVec = vec3(0,0,0)

  light = new THREE.DirectionalLight(color,intensity)
  light.castShadow = true
  light.position.set(position.x, position.y, position.z)
  light.lookAt = targetVec
  # light.target.position.set(0, 0, 0);
  light.shadow.mapSize.width = 1024
  light.shadow.mapSize.height = 1024
  light.shadow.camera.left = -D
  light.shadow.camera.right = D
  light.shadow.camera.top = D
  light.shadow.camera.bottom = -D
  light.shadow.camera.near = 1 # D
  light.shadow.camera.far = 3*D
  light.shadow.camera.fov = 75
  light.shadow.bias = - 0.001

  #light.shadowDarkness = 0.5
  #light.shadowCameraVisible = true # only for debugging
  return light

defaultAmbientLight = ->
  color = 0x888888
  light = new THREE.AmbientLight(color)
  return light

createFollowCamera = (name,aspect) ->
  fov = 75
  near = 0.1
  far = 1000
  camera = new THREE.PerspectiveCamera(fov,aspect,near,far)
  camera.name = name
  return camera

updateFollowCamera = (camera,cameraEntity) ->
  cameraComp = cameraEntity.get(T.FollowCamera)
  lookAt = cameraComp.lookAt
  camLoc = cameraEntity.get(T.Location)
  pos = camLoc.position
  camera.position.set(pos.x,pos.y,pos.z)
  camera.lookAt(lookAt)
  null

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




CameraSearcher = EntitySearch.prepare([T.FollowCamera])

getCameraEntity = (estore) ->
  CameraSearcher.singleEntity(estore)
  
class SceneWrapper
  constructor: ({@canvas,@width,@height,@address}) ->
    fog = defaultFog()
    @renderer = new THREE.WebGLRenderer(canvas: @canvas)
    @renderer.setSize( @width, @height)
    @renderer.setClearColor fog.color
    @renderer.shadowMap.enabled = true

    @scene = new Physijs.Scene(fixedTimeStep: 1/120)
    @scene.setGravity(vec3(0,-10,0))
    @scene.addEventListener 'update', =>
      # TODO: is this where I should add custom collision detection / event dispatch?  
      # eg, from "Three.Box3.contains{Box,Point} or RayCaster stuff?
#
      @address.send(type: 'scene_update', data: @scene)

    # @scene.addEventListener 'update', =>
    #   @scene.simulate(undefined, 2)

    #PiecesParts.addChair(@scene)
    #PiecesParts.addThinger(@scene)
    # PiecesParts.addPellets(@scene)

    @scene.fog = fog

    @scene.add defaultDirectionalLight()
    @scene.add defaultAmbientLight()

    # axis = new THREE.AxisHelper(5)
    # @scene.add axis

    @scene.simulate(1/60,2)


  updateAndRender: (estore, width, height) ->
    if width != @width or height != @height
      console.log "!! SceneWrapper.update TODO: dimensions changed, but we're not equipped to handle that change yet !!"

    #
    # CAMERA
    #
    if !@camera
      @camera = createFollowCamera("follow_cam", @width/@height)
    cameraEntity = getCameraEntity(estore)
    updateFollowCamera @camera,cameraEntity

    #
    # GAME OBJECTS
    # 
    # updateSceneFromEntities @rootGroup,estore
    updateSceneFromEntities @scene,estore,@address

    #
    # SIMULATE PHYSICS
    #
    # @scene.simulate(undefined, 2)
    @scene.simulate(1/60,2)

    #
    # RENDER
    #
    @renderer.render(@scene, @camera)


module.exports = SceneWrapper

