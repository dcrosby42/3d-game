React = require 'react'
ReactDOM = require 'react-dom'
React3 = require 'react-three-renderer'

GamepadApi = require '../lib/gamepad/gamepad_api'

module.exports = ->
  gameDiv = document.getElementById('game1')
  renderme = ->
    ReactDOM.render <GamepadDevPanel />, gameDiv
    requestAnimationFrame renderme
  requestAnimationFrame renderme

# buttonMap =
#   0: "one"
#   1: "two"
#   2: "three"
#   3: "four"
#   4: "left_trigger"
#   5: "right_trigger"
#   6: "left_bumper"
#   7: "right_bumper"
#   8: "select"
#   9: "start"
#   10: "left_stick_button"
#   11: "right_stick_button"
#   12: "dpad_up"
#   13: "dpad_down"
#   14: "dpad_left"
#   15: "dpad_right"
#   
# axisMap =
#   0: "left_x"
#   1: "left_y"
#   2: "right_x"
#   3: "right_y"
  
  
GamepadDevPanel = React.createClass
  getInitialState: ->
    {
      gamepads: {0:null, 1:null, 2:null, 3:null}
    }
  
  _onTick: (millis) ->
    changes = @gamepadApi.update()
    if changes.length > 0
      @setState gamepads: @gamepadApi.gamepadStates
      for c in changes
        console.log c
    requestAnimationFrame @_onTick

  componentWillMount: ->
    @gamepadApi = new GamepadApi()
    requestAnimationFrame @_onTick

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
      gps.push(<DebugGamepad key={i} index={i} gamepad={gp} layout={GamepadApi.DefaultLayout}/>)

    <div id="gamepad-dev" className="pure-g">
      <div id="pads" className="pure-u-1-1 pure-g">
        <div className="pure-u-6-24">Zero</div>
        <div className="pure-u-6-24">One</div>
        <div className="pure-u-6-24">Two</div>
        <div className="pure-u-6-24">Three</div>
        {gps}
      </div>
    </div>

DebugGamepad = React.createClass
  render: ->
    {buttonMap,axisMap} = @props.layout
    gp = @props.gamepad
    i = @props.index
    gpdiv = if gp?
      buttonStates = gp.buttons.map (b,i) =>
        <div className="buttonState" key={i}>button {i} ({buttonMap[i]}): pressed='{b.pressed}' value='{b.value}'</div>
      axes = gp.axes.map (a,i) =>
        <div className="axis" key={i}>Axis {i} ({axisMap[i]}): {a.value}</div>

      connected = if gp.connected then "(CONNECTED)" else "(not connected)"
        
      <div className="debug-gamepad pure-u-6-24">
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
