React = require 'react'
KeyboardInput = require '../../elements/keyboard_input'
GamepadInput = require '../../elements/gamepad_input'
Systems = require './systems'
Maps = require './maps'

EntityStore = require '../../lib/ecs/entity_store'
EcsMachine = require '../../lib/ecs/ecs_machine'

Construct = require './construct'

{euler,vec3,quat} = require '../../lib/three_helpers'

ActionBase = require '../../lib/action_base'
class Action extends ActionBase
class Input extends Action
class Time extends Action
class Mouse extends Action
class ApplyScene extends Action
class ApplyCollision extends Action
class ApplyHit extends Action

DebugOn =
  update_limit: 360
  log: console.log
DebugOff =
  update_limit: null
  log: ->

Debug = DebugOff

TickEffect = {type: 'tick', map: (v) -> new Time(v/1000.0)}

#
# INITIAL STATE
#

exports.initialState = ->
  model  = {
    updateCount: 0
    lastTime: null
    estore: initialEntityStore()
    input:
      dt: null
      controllerEvents: []
      scene: null
      collisions: []
      hits: []
  }
  [model, [TickEffect]]

initialEntityStore = ->
  mapName = "level1"

  estore = new EntityStore()
  # estore.createEntity(Construct.sineGrassChunk(vec3(0,0,0)))

  estore.createEntity Construct.playerPiece(tag:"player_piece", position: Maps.get(mapName).getStartPosition())
  estore.createEntity Construct.playerFollowCamera(followTag:"player_piece")

  # estore.createEntity Construct.cube(vec3(-1,1,-1),0x993333)
  # estore.createEntity Construct.cube(vec3(-1.1,2,-1),0x993333)
  # estore.createEntity Construct.cube(vec3(20,0,-1),0x993333)
  # estore.createEntity Construct.cube(vec3(20,1,-1),0x993333)
  # estore.createEntity Construct.cube(vec3(20,0,10),0x993333)
  # estore.createEntity Construct.cube(vec3(20,1,10),0x993333)
  # estore.createEntity Construct.cube(vec3(-1,0,10),0x993333)
  # estore.createEntity Construct.cube(vec3(-1,1,10),0x993333)

  # estore.createEntity(Construct.pacMap())
  # for pcomps in Construct.manyPellets()
  #   estore.createEntity pcomps
  for comps in Construct.gameBoard(mapName)
    estore.createEntity comps
  
  return estore

#
# UPDATE
#

ecsMachine = new EcsMachine([
  Systems.collision_system()
  Systems.controller_system()
  Systems.player_piece_control_system()

  Systems.pellet_system()

  Systems.camera_follow_system()
])

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
    model.NO_RENDER=true
    Debug.log "ApplyScene", action
    # model.input.scene = action.value
    thisInput = {scene: action.value}
    [model.estore, _globalEvents] = sceneSyncEcsMachine.update(model.estore, thisInput)
    return [model, null]

  # TODO
  if action instanceof ApplyCollision
    model.NO_RENDER=true
    Debug.log "ApplyCollision", action
    model.input.collisions.push(action.value)

  if action instanceof ApplyHit
    model.NO_RENDER=true
    # Debug.log "ApplyCollision", action
    # model.input.collisions.push(action.value)
    model.input.hits.push(action.value)


  if action instanceof Time
    Debug.log "Time", action
    # Debug.log "BlockMaze update: Time",now
    t = action.value
    if model.lastTime?
      dt = t - model.lastTime
      if dt > 0.1 or dt < 0
        dt = 1.0/60.0 # avoid big updates or the crazy first-reqAnimFr-is-huge-then-it-goes-back-to-normal issue. ?
      model.updateCount += 1
      # Debug.log " BlockMaze update: Time: updateCount=#{model.updateCount} updating and rendering w dt=",dt
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
      # Debug.log " BlockMaze update: NOT updating or rendering"
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


#
# VIEW 
#

MazeView = require './elements/maze_view'

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

mazeView_to_blockMaze = (action) ->
  switch action.type
    when 'physics_collision'
      new ApplyCollision(action.data)
    when 'hit'
      new ApplyHit(action.data)
    when 'scene_update'
      new ApplyScene(action.data)
    else
      console.log "!! BlockMaze mazeView_to_blockMaze: unknown action from MazeView:",action
      null

exports.view = (model,address) ->
  width = 1200
  height = 600
  
    #Adding these to the div surrounding MazeView causes props to be sent to MazeView with every event, like mouse motion
      # onMouseMove={handleMouse 'move', width,height,address}
      # onMouseDown={handleMouse 'down', width,height,address}
      # onMouseUp={handleMouse 'up', width,height,address}
  <div>
    <h3>Maze Thinger</h3>
    <div style={width:width,height:height}
    >
      <MazeView 
        width={width} 
        height={height} 
        camera={model.camera} 
        estore={model.estore} 
        address={address.forward (fsig) -> fsig.map(mazeView_to_blockMaze) }
      />
    </div>
    <KeyboardInput
      tag="player1"
      mappings={{
        "w": 'forward'
        "a": 'strafeLeft'
        "s": 'backward'
        "d": 'strafeRight'
        "left": 'orbitLeft'
        "right": 'orbitRight'
        "up": 'orbitUp'
        "down": 'orbitDown'
        "space": 'jump'
      }}
      address={address.forward (fsig) -> fsig.map (v) -> new Input(v)} 
    />
    <GamepadInput
      tag="player1"
      gamepadIndex={0}
      mappings={{
        "dpad_up": 'forward'
        "dpad_left": 'strafeLeft'
        "dpad_down": 'backward'
        "dpad_right": 'strafeRight'
        "left_bumper": 'turnLeft'
        "right_bumper": 'turnRight'
        # "one": 'elevate'
        "three": 'jump'
        "axis_left_x": 'strafe'
        "axis_left_y": 'drive'
        "axis_right_x": 'orbitX'
        "axis_right_y": 'orbitY'
      }}
      address={address.forward (fsig) -> fsig.map (v) -> new Input(v)} 
    />
  </div>
