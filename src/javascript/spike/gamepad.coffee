React = require 'react'
ReactDOM = require 'react-dom'
React3 = require 'react-three-renderer'

# Fx = require '../lib/fx'
# PostOffice = require '../lib/flarp/post_office'

module.exports = ->
  gameDiv = document.getElementById('game1')
  renderme = ->
    ReactDOM.render <GamepadDevPanel />, gameDiv
    requestAnimationFrame renderme
  requestAnimationFrame renderme



  # check = ->
  #   gamepads = navigator.getGamepads()
  #   console.log gamepads
  #   setTimeout check, 500
class GamepadConnectedWatcher
  constructor: (@interval=1000)->
    @listeners = []
    @gamepadIds = [null,null,null,null]
    @gamepads = {}
    @numGamepads = @gamepadIds.length

  start: ->
    check = =>
      @check()
      setTimeout check, @interval
    check()

  check: ->
    gamepads = navigator.getGamepads()
    i = 0
    changed = false
    while i < @numGamepads
      gp = gamepads[i]
      if gp?
        if gp.id != @gamepadIds[i]
          @gamepadIds[i] = gp.id
          @gamepads[i] = gp
          changed = true
      else
        @gamepadIds[i] = null
        @gamepads[i] = null
      i++
    if changed
      for callback in @listeners
        callback(@gamepads)

  onChanged: (callback) ->
    @listeners.push callback

buttonMap =
  0: "one"
  1: "two"
  2: "three"
  3: "four"
  4: "left_trigger"
  5: "right_trigger"
  6: "left_bumper"
  7: "right_bumper"
  8: "select"
  9: "start"
  10: "left_stick_button"
  11: "right_stick_button"
  12: "dpad_up"
  13: "dpad_down"
  14: "dpad_left"
  15: "dpad_right"
  
axisMap =
  0: "left_x"
  1: "left_y"
  2: "right_x"
  3: "right_y"
  
  
GamepadDevPanel = React.createClass
  getInitialState: ->
    {
      gamepads: {0:null, 1:null, 2:null, 3:null}
      buttonMap: buttonMap
      axisMap: axisMap
    }
  
  componentWillMount: ->
    watcher = new GamepadConnectedWatcher(15)
    watcher.onChanged (gamepads) =>
      @setState gamepads: gamepads
      console.log "onChanged:",gamepads
    watcher.start()

  #
  # componentDidMount: ->
  #
  # componentWillUnmount: ->
  #
  # shouldComponentUpdate: (nextProps, nextState) ->
  #   true

  render: ->
    gps = []
    for i,gp of @state.gamepads
      gps.push(<DebugGamepad key={i} index={i} gamepad={gp}/>)

    <div id="gamepad-dev">
      Gamepad dev panel
      <div id="pads">
        {gps}
      </div>
    </div>

DebugGamepad = React.createClass
  getInitialState: ->
    {
      buttonMap: buttonMap
      axisMap: axisMap
    }

  render: ->
    gp = @props.gamepad
    i = @props.index
    gpdiv = if gp?
      buttonStates = gp.buttons.map (b,i) =>
        <div className="buttonState" key={i}>button {i} ({@state.buttonMap[i]}): {b.pressed} {b.value}</div>
      axes = gp.axes.map (a,i) =>
        <div className="axis" key={i}>Axis {i} ({@state.axisMap[i]}): {a}</div>

      connected = if gp.connected then "(CONNECTED)" else "(not connected)"
        
      <div className="debug-gamepad">
        <div className="header">Gamepad {gp.index}: {gp.id} {connected}</div>
        <div className="mapping">Mapping: {gp.mapping}</div>
        <div className="timestamp">Timestamp: {gp.timestamp}</div>
        <div className="buttonStates">
          {buttonStates}
        </div>
        <div className="axes">
          {axes}
        </div>
      </div>
    else
      <div className="debug-gamepad none">
      </div>
    gpdiv
