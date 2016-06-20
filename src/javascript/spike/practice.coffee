React = require 'react'
React3 = require 'react-three-renderer'
THREE = require 'three'
d = 20


Practice = React.createClass
  displayName: 'Simple'

  getInitialState: ->
    @state = {
      cameraPosition: new THREE.Vector3(0, 0, 5)
      cubeRotation: new THREE.Euler()
      lightPosition: new THREE.Vector3(d, d, d)
      lightTarget: new THREE.Vector3(0, 0, 0)
      boxPosition: new THREE.Vector3(-4, 2, 0)
      boxPosition2: new THREE.Vector3(3, -1, 0)
      boxPosition3: new THREE.Vector3(0, 1, 0)
    }

  onAnimate: ->
    @setState
      cubeRotation: new THREE.Euler(
        @state.cubeRotation.x + 0.1
        @state.cubeRotation.y + 0.1
        0
      )

  render: ->
    width = window.innerWidth
    height = window.innerHeight
    d = 20
    return (<React3 mainCamera="camera" width={width} height={height} onAnimate={@onAnimate} >
      <MyScene width={width} height={height} lightPosition={@state.lightPosition} lightTarget={@state.lightTarget} cameraPosition={@state.cameraPosition}>
        <SpinBox rotation={@state.cubeRotation} position={@state.boxPosition} color={0x112277} />
        <SpinBox rotation={@state.cubeRotation} position={@state.boxPosition2} color={0x772211} />
      </MyScene>
    </React3>)
  
MyScene = (props) ->
    d = 20
    console.log props.children
    (<scene>
        <perspectiveCamera
          name="camera"
          fov={75}
          aspect={props.width / props.height}
          near={0.1}
          far={1000}

          position={props.cameraPosition}
        />
        <ambientLight
          color={0xFFFFFF}
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
    <mesh key="3"
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

module.exports = Practice

