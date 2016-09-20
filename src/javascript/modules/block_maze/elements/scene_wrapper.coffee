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
  lookAt = convertCannonVec3(cameraComp.lookAt)
  camLoc = cameraEntity.get(T.Location)
  pos = convertCannonVec3(camLoc.position)
  camera.position.set(pos.x,pos.y,pos.z)
  camera.lookAt(lookAt)
  null

updateGameObjectViews = (root,estore) ->
  PhysicalSearcher.run estore, (r) ->
    [physical,location] = r.comps

    shape = root.getObjectById(physical.viewId)
    if !shape?
      # view = Objects.create3DView(physical,location)
      shape = Objects.create3DShape(physical,location)
      physical.viewId = shape.id
      root.add shape
      # console.log "Created view",physical,view

    Objects.update3DShape(shape, physical,location)
    shape.userData.relevant = true

  # Sweep all 3d objects in the root and look for irrelevant views:
  markedForDeath = []
  for shape in root.children
    if !shape.userData.relevant
      # console.log "Marking for death:",v
      markedForDeath.push shape
    else
      shape.userData.relevant = false

  # Remove irrelevant views:
  for shape in markedForDeath
    # console.log "Removing obsolete view",v
    root.remove shape

  null


PhysicalSearcher = EntitySearch.prepare([T.Physical,T.Location])

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

    @scene = new THREE.Scene() # FIXME: Physijs.scene
    # TODO: @scene.addEventListener('collision', boundCollisionHandlerThatUsesAddressToPumpStuffBackUpToTheTop)
    #


    @scene.fog = fog

    @scene.add defaultDirectionalLight()
    @scene.add defaultAmbientLight()

    @rootGroup = new THREE.Group()
    @scene.add @rootGroup
    window.scene = @scene
    window.root = @rootGroup

    axis = new THREE.AxisHelper(5)
    @scene.add axis


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
