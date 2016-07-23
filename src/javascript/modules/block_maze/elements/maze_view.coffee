React = require 'react'
React3 = require 'react-three-renderer'
Three = require 'three'

pi=Math.PI
{euler,vec3,quat, convertCannonVec3, convertCannonQuat} = require '../../../lib/three_helpers'

EntitySearch = require '../../../lib/ecs/entity_search'
C = require '../components'
T = C.Types


WIDTH=800 # width = window.innerWidth
HEIGHT=400 # height = window.innerHeight

CAMERA_INFO =
  name: 'devcam'
  tilt: -pi/6
  pan: -pi/6
  position: vec3(0,3,5)
  aspect: 1200/600

MyCamera = (props) ->
  {cameraInfo} = props
  <group position={cameraInfo.position} rotation={euler(0,cameraInfo.pan,0)}>
    <perspectiveCamera
      name={cameraInfo.name}
      fov={75}
      aspect={cameraInfo.aspect}
      near={0.1}
      far={1000}
      rotation={euler(cameraInfo.tilt,0,0)}
    />
  </group>

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


RESOURCES =
  <resources>
    <boxGeometry
      resourceId="cubeGeo"

      width={1}
      height={1}
      depth={1}

      widthSegments={10}
      heightSegments={10}
    />
    <meshPhongMaterial
      resourceId="cubeMaterial"
      color={0x888888}
    />
  </resources>

groundQuaternion = quat().setFromAxisAngle(vec3(1, 0, 0), -Math.PI / 2)
ground =
  <mesh
    castShadow
    receiveShadow
    quaternion={groundQuaternion}
  >
    <planeBufferGeometry
      width={100}
      height={100}
      widthSegments={1}
      heightSegments={1}
    />
    <meshLambertMaterial
      color={0x777777}
    />
  </mesh>

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

Marker = (props) ->
  <mesh
    position={props.position}
    quaternion={props.quaternion}
    castShadow
    receiveShadow
  >
    <geometryResource resourceId="cubeGeo" />
    <meshPhongMaterial
      color={props.color}
    />
  </mesh>

piecePosSearch = EntitySearch.prepare([{type:T.Tag,name:'player_piece'}, T.Position])
getPlayerPosition = (estore) ->
  pos = null
  piecePosSearch.run estore, (r) ->
    [tag,position] = r.comps
    pos = position
  pos.position.clone()

playerPeiceSearcher = EntitySearch.prepare([{type:T.Tag,name:'player_piece'}])
getPlayerEntity = (estore) ->
  e = null
  playerPeiceSearcher.run estore, (r) ->
    e = r.entity
  e

LIGHT_POS = vec3(20, 20, 20) # magic number d
LIGHT_TARGET = vec3(0, 0, 0)

MazeView = React.createClass
  displayName: 'MazeView'
  
  render: ->
    # position = getPlayerPosition(@props.estore)
    player = getPlayerEntity(@props.estore)
    # position = player.get(T.Position).position.clone()
    # rotation = player.get(T.Rotation).rotation.clone()
    # color = player.get(T.Cube).color
    location = player.get(T.Location)
    playerPos = convertCannonVec3(location.position)
    playerQuat = convertCannonQuat(location.quaternion)
    playerColor = 0x338833
    # rotation = player.get(T.Rotation).rotation.clone()


    <React3 mainCamera={CAMERA_INFO.name}
            width={WIDTH} 
            height={HEIGHT} 
            clearColor={FOG.color}
    >
      {RESOURCES}
      <scene fog={FOG}>
        <MyDirLight
          lightPosition={LIGHT_POS} 
          lightTarget={LIGHT_TARGET} 
        />
        <ambientLight color={0x888888} />
        {#<MyCamera cameraInfo={CAMERA_INFO}/> #}
        <LookCamera cameraInfo={CAMERA_INFO} lookAt={playerPos} />
        {ground}
        <group position={vec3(0,0.5,0)}>
          <Marker position={playerPos} quaternion={playerQuat} color={playerColor}/>
          <axisHelper position={playerPos} scale={vec3(2,2,2)} quaternion={playerQuat}/>
          <Marker position={vec3(-1,0,-1)} color={0x880000}/>
          <Marker position={vec3(20,0,-1)} color={0x880000}/>
          <Marker position={vec3(20,0,10)} color={0x880000}/>
          <Marker position={vec3(-1,0,10)} color={0x880000}/>
        </group>

      </scene>
    </React3>

module.exports = MazeView

