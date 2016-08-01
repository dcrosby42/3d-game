React = require 'react'

GamepadApi = require '../lib/gamepad/gamepad_api'

GamepadInput = React.createClass
  componentDidMount: ->
    # forwardingAddress = @props.address.forward (s) =>
    #   s.map (e) =>
    #     e.tag = @props.tag
    #     e
    @setState
      shouldPoll: true
      # ouputAddress: forwardingAddress
      gamepadApi: new GamepadApi()


    requestAnimationFrame @handleTick

    # KeyboardController.bindKeys address, @props.mappings
  componentWillUnmount: ->
    @setState(shouldPoll: false)

  handleTick: (_millis) ->
    return if !@state.shouldPoll

    changes = @state.gamepadApi.update()
    for change in changes
      if change.index == @props.gamepadIndex and change.type == 'valueChanged'
        mappedControl = @props.mappings[change.control]
        if mappedControl?
          @props.address.send {
            tag:     @props.tag
            control: mappedControl
            state:   change.newValue
          }

    requestAnimationFrame @handleTick

    

  render: ->
    null

module.exports = GamepadInput
