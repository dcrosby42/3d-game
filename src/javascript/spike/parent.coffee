React = require 'react'
React3 = require 'react-three-renderer'
Three = require 'three'

{euler,vec3,quat} = require './three_helpers'
pi=Math.PI










Practice = React.createClass
  displayName: 'Simple'

  getInitialState: ->
    d = 20
    @state = {
      # cameraPosition: vec3(0, 3, 5)
      # cameraRotation: euler(-Math.PI/9 ,Math.PI/6,0)
      # cameraRotation: euler(-Math.PI/9 ,0,0)
      cubeRotation: euler()
      lightPosition: vec3(d, d, d)
      lightTarget: vec3(0, 0, 0)
      boxPosition: vec3(-4, 2, 0)
      boxPosition2: vec3(3, -1, 0)
      boxPosition3: vec3(0, 1, 0)
    }

  onAnimate: ->
    # @setState
    #   cubeRotation: euler(
    #     @state.cubeRotation.x + 0.1
    #     @state.cubeRotation.y + 0.1
    #     0
    #   )

  render: ->
    # width = window.innerWidth
    # height = window.innerHeight
    width = 1200
    height = 600


    <React3 mainCamera="camera" width={width} height={height} 
            clearColor={fog.color}
    >
      {resources}
      <MyScene 
        width={width} height={height} 
        lightPosition={@state.lightPosition} lightTarget={@state.lightTarget} 
        >
        <Devcam cam={cam}/>
        <group position={vec3(0,0.5,0)}
        >
          <Marker position={vec3(0,0,0)} color={0x888888}/>
          <Marker position={vec3(1,0,0)} color={0x880000}/>
        </group>

        {ground}
      </MyScene>
    </React3>


cam =
  tilt: 0
  pan: 0
  position: vec3(0,3,5)
  aspect: 1200/600


Devcam = (props) ->
  {cam} = props
  <group position={cam.position} rotation={euler(0,cam.pan,0)}>
    <perspectiveCamera
      name="camera"
      fov={75}
      aspect={cam.aspect}
      near={0.1}
      far={1000}

      rotation={euler(cam.tilt,0,0)}
    />
  </group>


resources =
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
  
groundQuaternion = quat().setFromAxisAngle(vec3(1, 0, 0), -Math.PI / 2)

fog = new Three.Fog(0x001525, 10, 40)
MyScene = (props) ->
    d = 20
    (<scene
      fog={fog}
     >
        <ambientLight
          color={0x888888}
        />
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
        {props.children}
      </scene>)

SpinBox = (props) ->
    <mesh 
        rotation={props.rotation}
        castShadow
        receiveShadow
        position={props.position}
      >
        <boxGeometry
          width={1}
          height={1}
          depth={1}
        />
          <meshLambertMaterial
            color={props.color}
          />
      </mesh>


Marker = (props) ->
  <mesh
    position={props.position}
    rotation={props.rotation}
    castShadow
    receiveShadow
  >
    <geometryResource resourceId="cubeGeo" />
    <meshPhongMaterial
      color={props.color}
    />
  </mesh>

_Marker = (props) ->
    <mesh
        position={props.position}
        rotation={props.rotation}
        castShadow
        receiveShadow
      >
        <boxGeometry
          width={1}
          height={1}
          depth={1}
        />
          <meshPhongMaterial
            color={props.color}
          />
      </mesh>


module.exports = Practice

