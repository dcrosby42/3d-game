# import React from 'react';
# import React3 from 'react-three-renderer';
# import THREE from 'three';
# import ReactDOM from 'react-dom';

React = require 'react'
React3 = require 'react-three-renderer'
THREE = require 'three'

Simple = React.createClass
  displayName: 'Simple'



  getInitialState: ->
    @state = {
      cameraPosition: new THREE.Vector3(0, 0, 5)
      cubeRotation: new THREE.Euler()
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

    return (<React3 mainCamera="camera" width={width} height={height} onAnimate={@onAnimate} >
      <scene>
        <perspectiveCamera
          name="camera"
          fov={75}
          aspect={width / height}
          near={0.1}
          far={1000}

          position={@state.cameraPosition}
        />
        <mesh
          rotation={@state.cubeRotation}
        >
          <boxGeometry
            width={1}
            height={1}
            depth={1}
          />
          <meshBasicMaterial
            color={0xff0000}
          />
        </mesh>
      </scene>
    </React3>)
  

exports.view = -> <Simple/>

