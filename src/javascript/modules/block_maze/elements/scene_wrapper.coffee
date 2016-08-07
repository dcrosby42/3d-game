THREE = Three = require 'three'
{euler,vec3,quat, convertCannonVec3, convertCannonQuat} = require '../../../lib/three_helpers'
EntitySearch = require '../../../lib/ecs/entity_search'
C = require '../components'
T = C.Types
Objects = require '../objects'

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
  # light.target.position.set(0, 0, 0);
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
  # camera.aspect = aspect
  # camera.fov = 75
  # camera.near = 0.1
  # camera.far = 1000
  return camera

updateFollowCamera = (camera,cameraEntity) ->
  cameraComp = cameraEntity.get(T.FollowCamera)
  lookAt = convertCannonVec3(cameraComp.lookAt)
  camLoc = cameraEntity.get(T.Location)
  pos = convertCannonVec3(camLoc.position)
  camera.position.set(pos.x,pos.y,pos.z)
  camera.lookAt = lookAt#.set(lookAt.x, lookAt.y, lookAt.z)
  null

updateGameObjectViews = (root,estore) ->
  # pairings = []
  # viewIdsToComps = {}
  PhysicalSearcher.run estore, (r) ->
    [physical,location] = r.comps

    view = root.getObjectById(physical.viewId)
    if !view?
      view = Objects.create3DView(physical,location)
      physical.viewId = view.id
      root.add view
      console.log "Created view",physical,view

    # viewIdsToComps[physical.viewId] = physical

    Objects.update3DView(view, physical,location)

    view.userData.relevant = true
    # console.log view.userData

    # pairings.push [physical,location,view]

  # Sweep all 3d objects in the root and look for irrelevant views:
  markedForDeath = []
  for v in root.children
    if !v.userData.relevant
      console.log "Marking for death:",v
      markedForDeath.push v
    else
      v.userData.relevant = false

  # Remove irrelevant views:
  for v in markedForDeath
    console.log "Removing obsolete view",v
    root.remove v
  null


PhysicalSearcher = EntitySearch.prepare([T.Physical,T.Location])

CameraSearcher = EntitySearch.prepare([T.FollowCamera])

getCameraEntity = (estore) ->
  CameraSearcher.singleEntity(estore)
  
class SceneWrapper
  constructor: ({@canvas,@width,@height}) ->
    fog = defaultFog()
    @renderer = new THREE.WebGLRenderer(canvas: @canvas)
    @renderer.setSize( @width, @height)
    @renderer.setClearColor fog.color
    @renderer.shadowMap.enabled = true

    @scene = new THREE.Scene()
    @scene.fog = fog

    @scene.add defaultDirectionalLight()
    @scene.add defaultAmbientLight()

    @rootGroup = new THREE.Group()
    @scene.add @rootGroup
    window.scene = @scene
    window.root = @rootGroup

    # XXX
    # aspect = @width/@height
    # @camera = new THREE.PerspectiveCamera( 75, aspect, 1, 100 )
    # @camera.position.z = 30

    # geometry = new THREE.IcosahedronGeometry(5, 1 )
    # material =  new THREE.MeshBasicMaterial({
    #                                           color: 0xfff999fff,
    #                                           wireframe: true,
    #                                           wireframeLinewidth:1 })

    # mesh = new THREE.Mesh(geometry, material)
    # @rootGroup.add( mesh )


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
    updateGameObjectViews @rootGroup,estore

    @renderer.render(@scene, @camera)

module.exports = SceneWrapper
