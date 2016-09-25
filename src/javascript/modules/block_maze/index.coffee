React = require 'react'
KeyboardInput = require '../../elements/keyboard_input'
GamepadInput = require '../../elements/gamepad_input'
C = require './components'
T = C.Types
Systems = require './systems'

EntityStore = require '../../lib/ecs/entity_store'
EcsMachine = require '../../lib/ecs/ecs_machine'

{euler,vec3,quat} = require '../../lib/three_helpers'

ActionBase = require '../../lib/action_base'
class Action extends ActionBase
class Input extends Action
class Time extends Action
class Mouse extends Action
class ApplyScene extends Action
class ApplyCollision extends Action

# DEBUG_UPDATE_LIMIT = 100

TickEffect = {type: 'tick', map: (v) -> new Time(v/1000.0)}

ecsMachine = new EcsMachine([
  Systems.controller_system()
  Systems.player_piece_control_system()
  Systems.camera_follow_system()
])

sceneSyncEcsMachine = new EcsMachine([
  Systems.sync_from_scene_system()
])


generateSlabComps = () ->
  compLists = []
  dark=false
  back = -2
  left = -2
  width = 4
  length = 4
  height = 0.5 
  y = -2
  z = -2
  lightColor = 0xffffff
  darkColor = 0x333366

  numXSlabs = 10 
  numZSlabs = 10

  for i in [0...numZSlabs]
    z = back + i*length
    for j in [0...numXSlabs]
      dark = if i % 2 == 0
        j % 2 == 0
      else
        j % 2 != 0
      x = left + j*width
      color = if dark then darkColor else lightColor
      compLists.push mkSlabComps(vec3(x, y, z), vec3(width,height,length), color)
      dark = !dark

  return compLists

mkCubeComps = (pos,color=0xffffff,name='Cube') ->
  [
    C.buildCompForType(T.Name, name: name)
    C.buildCompForType(T.Location, position: pos)
    C.buildCompForType(T.Physical,
      kind: 'cube'
      data: new C.Physical.Cube(color)
    )
  ]

mkSlabComps = (pos,dim,color=0xffffff,name='Slab') ->
  [
    C.buildCompForType(T.Name, name: 'Slab')
    C.buildCompForType(T.Location, position: pos)
    C.buildCompForType(T.Physical,
      kind: 'block'
      bodyType: 0
      data: new C.Physical.Block(color, dim)
    )
  ]

exports.initialState = ->
  estore = new EntityStore()

  estore.createEntity([
    C.buildCompForType(T.Name, name: 'Physics World')
    C.buildCompForType(T.PhysicsWorld, worldId: 'myWorld')
  ])

  estore.createEntity([
    C.buildCompForType(T.Name, name: 'Player One')
    C.buildCompForType(T.Tag, name: 'player_piece')
    C.buildCompForType(T.Location, position: vec3(0,1,0))
    C.buildCompForType(T.Physical,
      kind: 'ball'
      data: new C.Physical.Ball(0x333399)
      # axisHelper: 2
    )
    C.buildCompForType(T.Controller, inputName: 'player1')
  ])


  for comps in generateSlabComps()
    estore.createEntity comps

  # TODO
  estore.createEntity mkCubeComps(vec3(-1,1,-1),0x993333)
  estore.createEntity mkCubeComps(vec3(-1.1,2,-1),0x993333)
  estore.createEntity mkCubeComps(vec3(20,0,-1),0x993333)
  estore.createEntity mkCubeComps(vec3(20,1,-1),0x993333)
  estore.createEntity mkCubeComps(vec3(20,0,10),0x993333)
  estore.createEntity mkCubeComps(vec3(20,1,10),0x993333)
  estore.createEntity mkCubeComps(vec3(-1,0,10),0x993333)
  estore.createEntity mkCubeComps(vec3(-1,1,10),0x993333)
  
  # TODO
  # groundQuat = quat()
  # groundQuat.setFromAxisAngle(vec3(1, 0, 0), -Math.PI / 2)
  # estore.createEntity([
  #   C.buildCompForType(T.Name, name: 'Ground')
  #   C.buildCompForType(T.Location, position: vec3(0,0,12), quaternion: groundQuat)
  #   C.buildCompForType(T.Physical,
  #     kind: 'plane'
  #     data: new C.Physical.Plane(0x9999cc, 50, 50)
  #   )
  # ])


  estore.createEntity([
    C.buildCompForType(T.Name, name: 'Follow Camera')
    C.buildCompForType(T.FollowCamera, followTag: 'player_piece')
    C.buildCompForType(T.Location, position: vec3(0,3,5))
  ])


  model  = {
    updateCount: 0
    lastTime: null
    estore: estore
    input:
      dt: null
      controllerEvents: []
      scene: null
      collisions: []
    # camera:
    #   type: "dev"
    #   data:
    #     name: "dev"
    #     position: vec3(0,3,5)
    #     pan: 0
    #     tilt: 0
    mouseLocation:
      x: 0
      y: 0
  }
  [model, [{type: 'tick', map: (v) -> new Time(v)}]]


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
    # console.log "Action.Mouse type=#{type}", cx,cy
        

  if action instanceof ApplyScene
    model.NO_RENDER=true
    model.input.scene = action.value
    [model.estore, _globalEvents] = sceneSyncEcsMachine.update(model.estore, model.input)
    return [model, null]

  # TODO
  # if action instanceof ApplyCollision
  #   model.NO_RENDER=true
  #   model.input.collisions.push(action.value)

  if action instanceof Time
    # console.log "BlockMaze update: Time",now
    t = action.value
    if model.lastTime?
      dt = t - model.lastTime
      if dt > 0.1 or dt < 0
        dt = 1.0/60.0 # avoid big updates or the crazy first-reqAnimFr-is-huge-then-it-goes-back-to-normal issue. ?
      model.updateCount += 1
      # console.log " BlockMaze update: Time: updateCount=#{model.updateCount} updating and rendering w dt=",dt
      model.input.dt = dt
      [model.estore, _globalEvents] = ecsMachine.update(model.estore, model.input)
      # TODO handle global events....?

      # Update the dev camera
      # model.camera.data.pan += model.mouseLocation.x * -Math.PI/2 * dt
      # model.camera.data.tilt += model.mouseLocation.y * Math.PI/2 * dt

      # Reset the controller input queue for the next Time action (tick)
      model.input.controllerEvents = []
      model.input.scene = null
      model.input.collisions = []
      
    else
      # console.log " BlockMaze update: NOT updating or rendering"
      model.NO_RENDER=true
    model.lastTime = t

    if DEBUG_UPDATE_LIMIT? 
      effects = null
      if model.updateCount <= DEBUG_UPDATE_LIMIT
        effects = [ TickEffect ]
      return [model, effects]
    else
      return [model, [TickEffect]]

  else
    [model,null]

MazeView = require './elements/maze_view'

handleMouse = (type,width,height,address) ->
  (e) ->
    e.stopPropagation()
    e.preventDefault()
    address.send new Mouse(
      type: type
      x: e.nativeEvent.offsetX
      y: e.nativeEvent.offsetY
      width: width
      height: height
      event: e
    )

exports.view = (model,address) ->
  width = 1200
  height = 600
  
  <div>
    <h3>Maze Thinger</h3>
    <div style={width:width,height:height}
      onMouseMove={handleMouse 'move', width,height,address}
      onMouseDown={handleMouse 'down', width,height,address}
      onMouseUp={handleMouse 'up', width,height,address}
    >
      <MazeView 
        width={width} 
        height={height} 
        camera={model.camera} 
        estore={model.estore} 
        simAddress={address.forward (fsig) -> fsig.map (scene) -> new ApplyScene(scene)} 
        collisionAddress={address.forward (fsig) -> fsig.map (col) -> new ApplyCollision(col)} 
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
