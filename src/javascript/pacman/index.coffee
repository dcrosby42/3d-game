React = require 'react'
KeyboardInput = require '../elements/keyboard_input'
GamepadInput = require '../elements/gamepad_input'
Systems = require './systems'

ThreeView = require './three_view'

EntityStore = require '../lib/ecs/entity_store'
EcsMachine = require '../lib/ecs/ecs_machine'

World = require './play_world'

ActionBase = require '../lib/action_base'

# ---------------------------------------------------------------

class Action extends ActionBase
class Input extends Action
class Time extends Action
class Mouse extends Action
class ApplyScene extends Action
class ApplyCollision extends Action
class ApplyHit extends Action
  
TickEffect = {type: 'tick', map: (v) -> new Time(v/1000.0)}

# ---------------------------------------------------------------

DebugOn =
  update_limit: 360
  log: console.log
DebugOff =
  update_limit: null
  log: ->

Debug = DebugOff

# ---------------------------------------------------------------
#
# INITIAL STATE
#
# ---------------------------------------------------------------

exports.initialState = ->
  estore = new EntityStore()
  World.addInitialEntities(estore)

  inputConfig = World.getInputConfig()

  model  = {
    updateCount: 0
    lastTime: null
    estore: estore
    input:
      dt: null
      controllerEvents: []
      scene: null
      collisions: []
      hits: []
    keyboardConfig: inputConfig.keyboardConfig
    gamepadConfig: inputConfig.gamepadConfig
  }
  [model, [TickEffect]]


# ---------------------------------------------------------------
#
# UPDATE
#
# ---------------------------------------------------------------

ecsMachine = new EcsMachine(World.getSystems())

sceneSyncEcsMachine = new EcsMachine([
  Systems.sync_from_scene_system()
])


exports.update = (model,action) ->
  model.NO_RENDER = false
  # now = new Date().getTime()

  if action instanceof Input
    model.NO_RENDER=true
    e = action.value
    model.input.controllerEvents.push(e)

  # if action instanceof Mouse
    # model.NO_RENDER=true
    # {type,x,y,width,height,event} = action.value

    # Convert x and y into "unit rectangle"-relative coords, -1 <= x <= 1 and -1 <= y <= 1, y positive is up.  upper left is -1,1 and lower right is 1,-11
    # cx = (x * (2/width)) - 1
    # cy = (y * (-2/height)) + 1
    # model.mouseLocation.x = cx
    # model.mouseLocation.y = cy
    # Debug.log "Action.Mouse type=#{type}", cx,cy
        

  if action instanceof ApplyScene
    Debug.log "ApplyScene", action
    model.NO_RENDER=true
    thisInput = {scene: action.value}
    [model.estore, _globalEvents] = sceneSyncEcsMachine.update(model.estore, thisInput)
    return [model, null]

  if action instanceof ApplyCollision
    Debug.log "ApplyCollision", action
    model.NO_RENDER=true
    model.input.collisions.push(action.value)

  if action instanceof ApplyHit
    Debug.log "ApplyCollision", action
    model.NO_RENDER=true
    model.input.hits.push(action.value)

  if action instanceof Time
    Debug.log "Time", action
    t = action.value
    if model.lastTime?
      dt = t - model.lastTime
      if dt > 0.1 or dt < 0
        dt = 1.0/60.0 # avoid big updates or the crazy first-reqAnimFr-is-huge-then-it-goes-back-to-normal issue. ?
      model.updateCount += 1
      # Debug.log " Pacman update: Time: updateCount=#{model.updateCount} updating and rendering w dt=",dt
      model.input.dt = dt
      model.input.time = t
      [model.estore, _globalEvents] = ecsMachine.update(model.estore, model.input)
      # TODO handle global events....?

      # Update the dev camera
      # model.camera.data.pan += model.mouseLocation.x * -Math.PI/2 * dt
      # model.camera.data.tilt += model.mouseLocation.y * Math.PI/2 * dt

      # Reset the controller input queue for the next Time action (tick)
      model.input.controllerEvents = []
      model.input.scene = null
      model.input.collisions = []
      model.input.hits = []
      
    else
      Debug.log " update: NO_RENDER=true, so NOT updating or rendering scene"
      model.NO_RENDER=true
    model.lastTime = t

    if Debug.update_limit?
      effects = null
      if model.updateCount <= Debug.update_limit
        effects = [ TickEffect ]
        Debug.log "  (updateCount #{model.updateCount})"
      return [model, effects]
    else
      return [model, [TickEffect]]

  else
    [model,null]


# ---------------------------------------------------------------
#
# VIEW 
#
# ---------------------------------------------------------------


# handleMouse = (type,width,height,address) ->
#   (e) ->
#     e.stopPropagation()
#     e.preventDefault()
#     address.send new Mouse(
#       type: type
#       x: e.nativeEvent.offsetX
#       y: e.nativeEvent.offsetY
#       width: width
#       height: height
#       event: e
#     )

threeView_to_pacmanAction = (action) ->
  switch action.type
    when 'physics_collision'
      new ApplyCollision(action.data)
    when 'hit'
      new ApplyHit(action.data)
    when 'scene_update'
      new ApplyScene(action.data)
    else
      throw new Error("Pacman threeView_to_pacmanAction: unknown action from ThreeView: #{action}")

exports.view = (model,address) ->
  width = 1200
  height = 900
  
  keyboard = model.keyboardConfig
  gamepad = model.gamepadConfig
    #Adding these to the div surrounding MazeView causes props to be sent to MazeView with every event, like mouse motion
      # onMouseMove={handleMouse 'move', width,height,address}
      # onMouseDown={handleMouse 'down', width,height,address}
      # onMouseUp={handleMouse 'up', width,height,address}
  <div>
    <h3>Pac-Man Clone</h3>
    <div style={width:width,height:height}
    >
      <ThreeView 
        width={width} 
        height={height} 
        estore={model.estore} 
        address={address.forward (fsig) -> fsig.map(threeView_to_pacmanAction) }
      />
    </div>
    <KeyboardInput
      tag={keyboard.tag}
      mappings={keyboard.mappings}
      address={address.forward (fsig) -> fsig.map (v) -> new Input(v)} 
    />
    <GamepadInput
      tag={gamepad.tag}
      gamepadIndex={gamepad.gamepadIndex}
      mappings={gamepad.mappings}
      address={address.forward (fsig) -> fsig.map (v) -> new Input(v)} 
    />
  </div>
