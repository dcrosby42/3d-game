React = require 'react'

KeyboardController = require './keyboard_controller'

KeyboardInput = React.createClass
  componentDidMount: ->
    address = @props.address.forward (s) =>
      s.map (e) =>
        e.tag = @props.tag
        e

    KeyboardController.bindKeys address, @props.mappings

  render: ->
    null

module.exports = KeyboardInput
