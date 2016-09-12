React = require 'react'
Three = require 'three'

pi=Math.PI
{euler,vec3,quat, convertCannonVec3, convertCannonQuat} = require '../../../lib/three_helpers'

EntitySearch = require '../../../lib/ecs/entity_search'
C = require '../components'
T = C.Types

Objects = require '../objects'

LookCamera = (props) ->
  {cameraInfo,lookAt} = props
  <perspectiveCamera
    name={cameraInfo.name}
    position={cameraInfo.position}
    fov={75}
    aspect={cameraInfo.aspect}
    near={0.1}
    far={1000}
    lookAt={lookAt}
  />

DevCamera = (props) ->
  {cameraInfo,aspect} = props
  <group 
    rotation={euler(0,cameraInfo.pan,0)}
    position={cameraInfo.position}
  >
    <perspectiveCamera
      name={cameraInfo.name}
      rotation={euler(cameraInfo.tilt,0,0)}
      fov={75}
      aspect={aspect}
      near={0.1}
      far={1000}
    />
  </group>

FollowCamera = (props) ->
  {name,aspect,cameraEntity} = props

  cam = cameraEntity.get(T.FollowCamera)
  lookAt = convertCannonVec3(cam.lookAt)

  camLoc = cameraEntity.get(T.Location)
  pos = convertCannonVec3(camLoc.position)

  <perspectiveCamera
    position={pos}
    name={name}
    fov={75}
    aspect={aspect}
    near={0.1}
    far={1000}
    lookAt={lookAt}
  />


FOG = new Three.Fog(0x001525, 10, 40)

MyDirLight = (props) ->
  d = 20
  <directionalLight
    color={0xffffff}
    intensity={1.75}

    castShadow

    shadowMapWidth={1024}
    shadowMapHeight={1024}

    shadowCameraLeft={-d}
    shadowCameraRight={d}
    shadowCameraTop={d}
    shadowCameraBottom={-d}

    shadowCameraFar={3 * d}
    shadowCameraNear={d}

    position={props.lightPosition}
    lookAt={props.lightTarget}
  />

# PlayerPeiceSearcher = EntitySearch.prepare([{type:T.Tag,name:'player_piece'}])
# getPlayerEntity = (estore) ->
#   PlayerPeiceSearcher.singleEntity(estore)

CameraSearcher = EntitySearch.prepare([T.FollowCamera])
getCameraEntity = (estore) ->
  CameraSearcher.singleEntity(estore)

PhysicalSearcher = EntitySearch.prepare([T.Physical,T.Location])

LIGHT_POS = vec3(20, 20, 20) # magic number d
LIGHT_TARGET = vec3(0, 0, 0)

MazeView = React.createClass
  displayName: 'MazeView'
  
  render: ->
    # player = getPlayerEntity(@props.estore)
    # location = player.get(T.Location)
    # playerPos = convertCannonVec3(location.position)

    cameraEntity = getCameraEntity(@props.estore)
    cameraLocComp = cameraEntity.get(T.Location)
    cameraPos = convertCannonVec3(cameraLocComp.position)

    # camInfo =
    #   name: 'devcam'
    #   position: vec3(0,3,5)
    #   aspect: @props.width / @props.height
    #camera = <LookCamera cameraInfo={camInfo} lookAt={playerPos} />
    aspect = @props.width/@props.height
    # camera = <DevCamera aspect={aspect} cameraInfo={@props.camera.data} />
    camera = <FollowCamera name="follow_cam" aspect={aspect} cameraEntity={cameraEntity} />
      
    objects = []
    i = 0
    PhysicalSearcher.run @props.estore, (r) ->
      [physical,location] = r.comps
      objects.push Objects.create3d(i,physical,location)
      i++

    <React3 mainCamera="follow_cam"
            width={@props.width} 
            height={@props.height} 
            clearColor={FOG.color}
            shadowMapEnabled
    >
      {Objects.VisualResources}
      <scene fog={FOG}>
        <MyDirLight
          lightPosition={LIGHT_POS} 
          lightTarget={LIGHT_TARGET} 
        />
        <ambientLight color={0x888888} />
        {camera}
        {objects}
      </scene>
    </React3>

module.exports = MazeView

