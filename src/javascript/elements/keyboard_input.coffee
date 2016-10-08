React = require 'react'

KeyboardController = require '../lib/keyboard/keyboard_controller'

KeyboardInput = React.createClass
  componentDidMount: ->
    address = @props.address.forward (s) =>
      s.map (e) =>
        e.tag = @props.tag
        e

    KeyboardController.bindKeys address, @props.mappings

  shouldComponentUpdate: (nextProps,nextState) ->
    false

  render: ->
    null

module.exports = KeyboardInput
