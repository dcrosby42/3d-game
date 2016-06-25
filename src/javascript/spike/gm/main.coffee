React = require 'react'
React3 = require 'react-three-renderer'

KeyboardInput = require './keyboard_input'

Action ={}
Action.Time =
  type: 'Time'
  new: (t) ->
    {type: 'Time', time: t}
Action.Input =
  type: 'Input'
  new: (a) ->
    {type: 'Input', inputAction: a}
Action.Mouse =
  type: 'Mouse'
  new: (a) ->
    {type: 'Mouse', mouse: a}

exports.initialState = ->
  {
    time:0
    seconds:0
    controllers: {}
    mouse: {}
  }

exports.update = (model,action) ->
  model.NO_SYNC = false
  switch action.type
    when Action.Time.type
      time = action.time
      model.time = time
      intTime = Math.floor(time/1000)
      if intTime <= model.seconds
        model.NO_SYNC = true
      else
        model.seconds = intTime

      return [model, [{type: 'tick', map: Action.Time.new}]]

    when Action.Input.type
      # model.NO_SYNC = true

      ia = action.inputAction
      console.log "Input: #{ia.tag} #{ia.control} #{ia.state}"
      model.controllers[ia.tag] ?= {}
      model.controllers[ia.tag][ia.control] = ia.state

      return [model, null]

    when Action.Mouse.type
      model.NO_SYNC = true
      console.log "Mouse action",action.mouse
      return [model, null]

    else
      console.log "Main.update unhandled action", action


exports.view = (model,address) ->
  <MainView model={model} address={address} />

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

