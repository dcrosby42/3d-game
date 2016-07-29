React = require 'react'
React3 = require 'react-three-renderer'
Three = require 'three'

pi=Math.PI
{euler,vec3,quat, convertCannonVec3, convertCannonQuat} = require '../../../lib/three_helpers'

EntitySearch = require '../../../lib/ecs/entity_search'
C = require '../components'
T = C.Types

LookCamera = (props) ->
  {cameraInfo,lookAt} = props
  <perspectiveCamera
    name={cameraInfo.name}
    position={cameraInfo.position}
    fov={75}
    aspect={cameraInfo.aspect}
    near={0.1}
    far={1000}
    lookAt={null}
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

PlayerPeiceSearcher = EntitySearch.prepare([{type:T.Tag,name:'player_piece'}])
getPlayerEntity = (estore) ->
  PlayerPeiceSearcher.singleEntity(estore)

createObject = (key,physical,location) ->

  pos = convertCannonVec3(location.position)
  quat = convertCannonQuat(location.quaternion)

  axisHelper = if s = physical.axisHelper?
    <axisHelper 
      scale={vec3(s,s,s)} 
    />
  else
    null

  switch physical.kind
    when 'cube'
      <group key={key}
        position={pos}
        quaternion={quat}
      >
        {axisHelper}
        <mesh
          castShadow
          receiveShadow
        >
          <geometryResource resourceId="cubeGeo" />
          <meshPhongMaterial
            color={physical.data.color}
          />
        </mesh>
      </group>

    when 'plane'
      <group key={key}
          quaternion={quat}
          position={pos}
        >
        {axisHelper}

        <mesh
          castShadow
          receiveShadow
        >
          <planeBufferGeometry
            width={physical.data.width}
            height={physical.data.height}
            widthSegments={100}
            heightSegments={100}
          />
          <meshLambertMaterial
            color={physical.data.color}
          />
        </mesh>
      </group>

    else
      throw new Error("Can't create 3d representation of", physical)

PhysicalSearcher = EntitySearch.prepare([T.Physical,T.Location])

LIGHT_POS = vec3(20, 20, 20) # magic number d
LIGHT_TARGET = vec3(0, 0, 0)

MazeView = React.createClass
  displayName: 'MazeView'
  
  render: ->
    player = getPlayerEntity(@props.estore)
    location = player.get(T.Location)
    playerPos = convertCannonVec3(location.position)

    # camInfo =
    #   name: 'devcam'
    #   position: vec3(0,3,5)
    #   aspect: @props.width / @props.height
    # camera = <LookCamera cameraInfo={camInfo} lookAt={playerPos} />
    aspect = @props.width/@props.height
    camera = <DevCamera aspect={aspect} cameraInfo={@props.camera.data} />
      
    objects = []
    i = 0
    PhysicalSearcher.run @props.estore, (r) ->
      [physical,location] = r.comps
      objects.push createObject(i,physical,location)
      i++

    <React3 mainCamera={@props.camera.data.name}
            width={@props.width} 
            height={@props.height} 
            clearColor={FOG.color}
    >
      {RESOURCES}
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

