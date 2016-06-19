React = require 'react'
React3 = require 'react-three-renderer'
THREE = require 'three'

NonJsx = React.createClass
  displayName: 'NonJsx'

  getInitialState: ->
    {
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
    null

  render: ->
    width = window.innerWidth
    height = window.innerHeight
    return React.createElement(React3, {
      "mainCamera": "camera",
      "width": width,
      "height": height,
      "onAnimate": this.onAnimate
    }, React.createElement("scene", null, React.createElement("perspectiveCamera", {
      "name": "camera",
      "fov": 75.0,
      "aspect": width / height,
      "near": 0.1,
      "far": 1000.0,
      "position": this.state.cameraPosition
    }), React.createElement("mesh", {
      "rotation": this.state.cubeRotation
    }, React.createElement("boxGeometry", {
      "width": 1.0,
      "height": 1.0,
      "depth": 1.0
    }), React.createElement("meshBasicMaterial", {
      "color": 0xccff00
    }))))

module.exports = NonJsx

