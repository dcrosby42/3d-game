React = require 'react'
React3 = require 'react-three-renderer'

KeyboardInput = require '../../elements/keyboard_input'

MainView = React.createClass
  componentDidMount: ->
    @props.address.send Action.Time.new(42)

  _sendMouseAction: (type,e) ->
    e.stopPropagation()
    e.preventDefault()
    @props.address.send Action.Mouse.new({type:type})

  _getMouseHandlers: ->
    handler = (type) =>
      (e) =>
        @_sendMouseAction type,e

    {
      onMouseEnter: handler('enter')
      onMouseLeave: handler('leave')
      onMouseMove: handler('move')
      onMouseDown: handler('down')
      onMouseUp: handler('up')
      onWheel: handler('wheel')
    }

  # _onMouseEnter: (e) ->
  #   @props.address.send Action.Mouse.new({type:'enter'})
  #   e.stopPropagation()
  #   e.preventDefault()
  #
  # _onMouseLeave: (e) ->
  #   @props.address.send Action.Mouse.new({type:'leave'})
  #   e.stopPropagation()
  #   e.preventDefault()
  #
  # _onMouseMove: (e) ->
  #   # console.log "Client:",e.clientX, e.clientY
  #   # console.log "offset:",e.nativeEvent.offsetX, e.nativeEvent.offsetY
  #   @props.address.send Action.Mouse.new({type:'move'})
  #   e.stopPropagation()
  #   e.preventDefault()
  # _onMouseDown: (e) ->
  #   @props.address.send Action.Mouse.new({type:'down'})
  #   e.stopPropagation()
  #   e.preventDefault()
  # _onMouseUp: (e) ->
  #   @props.address.send Action.Mouse.new({type:'up'})
  #   e.stopPropagation()
  #   e.preventDefault()


  render: ->
    {#<div id="main" ref="main" onMouseEnter={@_onMouseEnter} onMouseLeave={@_onMouseLeave} onMouseMove={@_onMouseMove} onMouseDown={@_onMouseDown} onMouseUp={@_onMouseUp}> #}
    <div id="main" ref="main" {...@_getMouseHandlers()}> 
      <div className="timer">Main View time={@props.model.seconds}</div>
      <div className="controllers">Controllers: {JSON.stringify(@props.model.controllers)}</div>

      <KeyboardInput 
        tag="player1" 
        mappings={{
          "right": 'right'
          "left": 'left'
          "up": 'up'
          "down": 'down'
          "a": 'action2'
          "s": 'action1'
          "enter": 'start'
          "shift": 'select'
        }}
        address={@props.address.forward (s) -> s.map Action.Input.new} 
      />

      <KeyboardInput 
        tag="player2" 
        mappings={{
          "k": 'right'
          "h": 'left'
          "u": 'up'
          "j": 'down'
          "[": 'action2'
          "]": 'action1'
          "-": 'start'
          "=": 'select'
        }}
        address={@props.address.forward (s) -> s.map Action.Input.new} 
      />

    </div>

