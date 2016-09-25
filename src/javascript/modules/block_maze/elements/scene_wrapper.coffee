THREE = Three = require 'three'
{euler,vec3,quat} = require '../../../lib/three_helpers'
EntitySearch = require '../../../lib/ecs/entity_search'
C = require '../components'
T = C.Types
Objects = require '../objects'

Physijs = require '../../../vendor/physijs_wrapper'

D = 20

# addAnObject = (scene) ->
#   sphere_geometry = new THREE.SphereGeometry( 1.5, 32, 32 )
#   material = new THREE.MeshLambertMaterial({ opacity: 0, transparent: true })
#   shape = new Physijs.SphereMesh(
#     sphere_geometry,
#     material,
#     undefined,
#     { restitution: Math.random() * 1.5 }
#   )
#
#   shape.material.color.setRGB( Math.random() * 100 / 100, Math.random() * 100 / 100, Math.random() * 100 / 100 )
#   shape.castShadow = true
#   shape.receiveShadow = true
#   
#   shape.position.set(0,1,0)
#   # shape.position.set(
#   #   Math.random() * 30 - 15,
#   #   20,
#   #   Math.random() * 30 - 15
#   # )
#   shape.material.opacity = 1
#   
#   shape.rotation.set(
#     Math.random() * Math.PI,
#     Math.random() * Math.PI,
#     Math.random() * Math.PI
#   )
#   console.log shape
#
#   scene.add(shape)
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

updateSceneFromEntities = (scene,estore) ->
  PhysicalSearcher.run estore, (r) ->
    [physical,location] = r.comps

    shape = scene.getObjectById(physical.viewId)
    if !shape?
      # console.log "SceneWrapper: scene no object w id",physical.viewId
      shape = Objects.create3DShape(physical,location)
      shape.userData.managed = true
      physical.viewId = shape.id
      scene.add shape
      # console.log "Created shape",physical,shape,scene
    # else
    #   console.log "SceneWrapper: scene object ",physical.viewId,shape

    # TODO !1??
    # Events from player control system were previously processed by CannonPhysicsSystem
    # and applied changes to the physics bodies.
    # However, this SceneWrapper is outside the update of game state via ecsMachin in BlockMaze module.
      # @handleEvents r.eid,
      #   localImpulse: ({impulse,point}) =>
      #     body.applyLocalImpulse impulse, point
      #   impulse: ({impulse,point}) =>
      #     body.applyImpulse impulse, point

    Objects.update3DShape(shape, physical,location)
    shape.userData.relevant = true

  # Sweep all 3d objects in the scene and look for irrelevant views:
  markedForDeath = []
  for shape in scene.children
    if shape.userData.managed
      if !shape.userData.relevant
        # console.log "Marking for death:",v
        markedForDeath.push shape
      else
        shape.userData.relevant = false

  # Remove irrelevant views:
  for shape in markedForDeath
    console.log "Removing obsolete shape",shape
    scene.remove shape

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

    @scene = new Physijs.Scene(fixedTimeStep: 1/120)
    @scene.setGravity(vec3(0,-10,0))
    # TODO: @scene.addEventListener('collision', boundCollisionHandlerThatUsesAddressToPumpStuffBackUpToTheTop)
    @scene.addEventListener 'update', => simAddress.send(@scene)
    # @scene.addEventListener 'update', =>
    #   @scene.simulate(undefined, 2)


    @scene.fog = fog

    @scene.add defaultDirectionalLight()
    @scene.add defaultAmbientLight()

    axis = new THREE.AxisHelper(5)
    @scene.add axis

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
    updateSceneFromEntities @scene,estore

    #
    # SIMULATE PHYSICS
    #
    # @scene.simulate(undefined, 2)
    @scene.simulate(1/60)

    #
    # RENDER
    #
    @renderer.render(@scene, @camera)

module.exports = SceneWrapper
