# ThreeView = require './view'

React = require 'react'
React3 = require 'react-three-renderer'
THREE = require 'three'

# {div,span,table,tbody,td,tr} = React.DOM

class Simple extends React.Component
  constructor: (props, context) ->
    super(props, context)

    # construct the position vector here, because if we use 'new' within render,
    # React will think that things have changed when they have not.
    @cameraPosition = new THREE.Vector3(0, 0, 5)

    @state =
      cubeRotation: new THREE.Euler()

    @_onAnimate = ->
      # we will get this callback every frame

      # pretend cubeRotation is immutable.
      # this helps with updates and pure rendering.
      # React will be sure that the rotation has now updated.
      @setState
        cubeRotation: new THREE.Euler(
          @state.cubeRotation.x + 0.1,
          @state.cubeRotation.y + 0.1,
          0
        )

  render: ->
    width = window.innerWidth
    height = window.innerHeight

    aspect = width/height

    # return (<React3
    #   mainCamera="camera" // this points to the perspectiveCamera which has the name set to "camera" below
    #   width={width}
    #   height={height}
    #
    #   onAnimate={this._onAnimate}
    # >
    React.createElement 'React3', {mainCamera:'camrea',width:width,height:height,onAnimate:@_onAnimate},
      # <scene>
      React.createElement 'scene', {}, [
        # <perspectiveCamera
        #   name="camera"
        #   fov={75}
        #   aspect={width / height}
        #   near={0.1}
        #   far={1000}
        #
        #   position={this.cameraPosition}
        # />
        React.createElement 'perspectiveCamera', {name:'camera', fov:75, aspect:aspect,near:0.1,far:1000, position:@cameraPosition}
        # <mesh
        #   rotation={this.state.cubeRotation}
        # >
        React.createElement 'mesh', {rotation: @state.cubeRotation}, [
          # <boxGeometry
          #   width={1}
          #   height={1}
          #   depth={1}
          # />
          React.createElement 'boxGeometry', {width:1, height:1, depth:1}
          # <meshBasicMaterial
          #   color={0x00ff00}
          # />
          React.createElement 'meshBasicMaterial', {color: 0x00ff00}
        # </mesh>
        ]
      # </scene>
      ]

module.exports = Simple
