class GamepadGetter
  getGamepads: ->
    navigator.getGamepads()

class GamepadState
  constructor: (@id, @index, @timestamp, @connected) ->
    @buttons = []
    @axes = []

class GamepadButtonState
  constructor: (@index,@pressed,@value) ->

class GamepadAxisState
  constructor: (@index,@value) ->

axisMap =
  0: "left_x"
  1: "left_y"
  2: "right_x"
  3: "right_y"
  
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

copyGamepadState = (gamepad) ->
  st = new GamepadState(gamepad.id,gamepad.index,gamepad.timestamp,gamepad.connected)
  # st.id = gamepad.id
  # st.index = gamepad.index
  # st.timestamp = gamepad.timestamp
  # st.connected = gamepad.connected
  # st.buttons = []
  for b,i in gamepad.buttons
    st.buttons[i] = new GamepadButtonState(i, b.pressed, b.value)
  # st.axes = []
  for a,i in gamepad.axes
    st.axes[i] = new GamepadAxisState(i, a)
  st

addChanges = (changes, a, b) ->
  # for ab,i in a.buttons
  #   bb = b.buttons[i]
  #   if ab.pressed != bb.pressed or ab.value != bb.value
  #     changes.push type: "buttonChanged", index: a.index, id: a.id, control: buttonMap[i], oldPressed: ab.pressed, oldValue: ab.value, newPressed: bb.pressed, newValue: bb.value
  # for aa,i in a.axes
  #   ba = b.axes[i]
  #   if aa.value != ba.value
  #     changes.push type: "axisChanged", index: a.index, id: a.id, control: axisMap[i], oldValue: aa.value, newValue: ba.value
  changeCount = 0
  for ab,i in a.buttons
    bb = b.buttons[i]
    if ab.value != bb.value
      changes.push type: "valueChanged", index: a.index, id: a.id, control: buttonMap[i], oldValue: ab.value, newValue: bb.value
      changeCount++
  for aa,i in a.axes
    ba = b.axes[i]
    if aa.value != ba.value
      changes.push type: "valueChanged", index: a.index, id: a.id, control: axisMap[i], oldValue: aa.value, newValue: ba.value
      changeCount++
  return changeCount
    
class GamepadInterface
  constructor: ->
    @getter = new GamepadGetter()
    @gamepadIds = [null,null,null,null]
    @gamepads = {}
    @numGamepadSlots = @gamepadIds.length
    @gamepadStates = {}

  update: ->
    gamepads = @getter.getGamepads()
    changes = []
    i = 0
    while i < @numGamepadSlots
      gp = gamepads[i]
      prevId = @gamepadIds[i]
      if gp?
        if gp.id != @gamepadIds[i]
          # Gamepad @ i is different gamepad than before
          @gamepadIds[i] = gp.id
          @gamepads[i] = gp
          state = copyGamepadState(gp)
          @gamepadStates[i] = state
          if prevId?
            changes.push type: "gamepadRemoved", index: i, id: prevId
          changes.push type: "gamepadAdded", index: i, id: gp.id, gamepadState: state
        else
          # Gamepad @ i is same gamepad as before
          priorState = @gamepadStates[i]
          if gp.timestamp > priorState.timestamp
            newState = copyGamepadState(gp)
            addChanges(changes, priorState, newState)

      else
        # Gamepad @ i is gone
        if prevId?
          changes.push type: "gamepadRemoved", index: i, id: prevId
        @gamepadIds[i] = null
        @gamepads[i] = null
        @gamepadStates[i] = null
      i++
    return changes


module.exports = GamepadInterface
