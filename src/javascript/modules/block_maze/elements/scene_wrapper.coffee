THREE = Three = require 'three'
{euler,vec3,quat} = require '../../../lib/three_helpers'
EntitySearch = require '../../../lib/ecs/entity_search'
C = require '../components'
T = C.Types
Objects = require '../objects'

Physijs = require '../../../vendor/physijs_wrapper'

D = 20

addAnObject = (scene) ->
  sphere_geometry = new THREE.SphereGeometry( 1.5, 32, 32 )
  material = new THREE.MeshLambertMaterial({ opacity: 0, transparent: true })
  shape = new Physijs.SphereMesh(
    sphere_geometry,
    material,
    undefined,
    { restitution: Math.random() * 1.5 }
  )

  shape.material.color.setRGB( Math.random() * 100 / 100, Math.random() * 100 / 100, Math.random() * 100 / 100 )
  shape.castShadow = true
  shape.receiveShadow = true
  
  shape.position.set(0,1,0)
  # shape.position.set(
  #   Math.random() * 30 - 15,
  #   20,
  #   Math.random() * 30 - 15
  # )
  shape.material.opacity = 1
  
  shape.rotation.set(
    Math.random() * Math.PI,
    Math.random() * Math.PI,
    Math.random() * Math.PI
  )
  console.log shape

  scene.add(shape)
  # shape.addEventListener( 'ready', createShape )


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
  light.userData.permanent = true
  return light

defaultAmbientLight = ->
  color = 0x888888
  light = new THREE.AmbientLight(color)
  light.userData.permanent = true
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

updateSceneFromEntities = (root,estore) ->
  # console.log root
  PhysicalSearcher.run estore, (r) ->
    [physical,location] = r.comps

    shape = root.getObjectById(physical.viewId)
    if !shape?
      # console.log "SceneWrapper: root no object w id",physical.viewId
      shape = Objects.create3DShape(physical,location)
      physical.viewId = shape.id
      root.add shape
      console.log "Created shape",physical,shape,root
    # else
    #   console.log "SceneWrapper: root object ",physical.viewId,shape


    # TODO Objects.update3DShape(shape, physical,location)
    shape.userData.relevant = true

  # Sweep all 3d objects in the root and look for irrelevant views:
  markedForDeath = []
  for shape in root.children
    unless shape.userData.permanent
      if !shape.userData.relevant
        # console.log "Marking for death:",v
        markedForDeath.push shape
      else
        shape.userData.relevant = false

  # Remove irrelevant views:
  for shape in markedForDeath
    console.log "Removing obsolete shape",shape
    root.remove shape

  null


PhysicalSearcher = EntitySearch.prepare([T.Physical,T.Location])

CameraSearcher = EntitySearch.prepare([T.FollowCamera])

getCameraEntity = (estore) ->
  CameraSearcher.singleEntity(estore)
  
class SceneWrapper
  constructor: ({@canvas,@width,@height,simAddress}) ->
    fog = defaultFog()
    @renderer = new THREE.WebGLRenderer(canvas: @canvas)
    @renderer.setSize( @width, @height)
    @renderer.setClearColor fog.color
    @renderer.shadowMap.enabled = true

    # @scene = new THREE.Scene() # FIXME: Physijs.scene
    @scene = new Physijs.Scene(fixedTimeStep: 1/120)
    @scene.setGravity(vec3(0,-10,0))
    # TODO: @scene.addEventListener('collision', boundCollisionHandlerThatUsesAddressToPumpStuffBackUpToTheTop)
    # @scene.addEventListener 'update', => simAddress.send(@rootGroup)
    # @scene.addEventListener 'update', =>
    #   @scene.simulate(undefined, 2)


    @scene.fog = fog

    @scene.add defaultDirectionalLight()
    @scene.add defaultAmbientLight()


    # @rootGroup = new THREE.Group()
    # @scene.add @rootGroup

    # addAnObject(@scene)


    # window.scene = @scene
    # window.root = @rootGroup

    axis = new THREE.AxisHelper(5)
    axis.userData.permanent = true
    @scene.add axis

    @scene.simulate()


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
    updateSceneFromEntities @scene,estore

    #
    # SIMULATE PHYSICS
    #
    # console.log "Simulute"
    @scene.simulate(undefined, 2)

    #
    # RENDER
    #
    @renderer.render(@scene, @camera)

module.exports = SceneWrapper
