React = require 'react'
Cannon = require 'cannon'
KeyboardInput = require '../../elements/keyboard_input'
GamepadInput = require '../../elements/gamepad_input'
C = require './components'
T = C.Types
Systems = require './systems'

EntityStore = require '../../lib/ecs/entity_store'
EcsMachine = require '../../lib/ecs/ecs_machine'

{euler,vec3,quat} = require '../../lib/three_helpers'
{canVec3,canQuat} = require '../../lib/cannon_helpers'

ActionBase = require '../../lib/action_base'
class Action extends ActionBase
class Input extends Action
class Time extends Action
class Mouse extends Action

ecsMachine = new EcsMachine([
  Systems.controller_system()
  Systems.player_piece_control_system()
  Systems.physics_system()
  # Systems.collision_detect_system()
  Systems.camera_follow_system()
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
      compLists.push mkSlabComps(canVec3(x, y, z), canVec3(width,height,length), color)
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
      bodyType: Cannon.Body.STATIC
      data: new C.Physical.Block(color, dim)
    )
  ]

exports.initialState = ->
  estore = new EntityStore()

  estore.createEntity([
    C.buildCompForType(T.Name, name: 'Physics World')
    C.buildCompForType(T.PhysicsWorld, worldId: 'myWorld')
  ])

  e = estore.createEntity([
    C.buildCompForType(T.Name, name: 'Player One')
    C.buildCompForType(T.Tag, name: 'player_piece')
    C.buildCompForType(T.Location)
    C.buildCompForType(T.Physical,
      kind: 'ball'
      data: new C.Physical.Ball(0x333399)
      # axisHelper: 2
    )
    C.buildCompForType(T.Controller, inputName: 'player1')
  ])


  for comps in generateSlabComps()
    estore.createEntity comps

  estore.createEntity mkCubeComps(canVec3(-1,1,-1),0x993333)
  estore.createEntity mkCubeComps(canVec3(-1.1,2,-1),0x993333)
  estore.createEntity mkCubeComps(canVec3(20,0,-1),0x993333)
  estore.createEntity mkCubeComps(canVec3(20,1,-1),0x993333)
  estore.createEntity mkCubeComps(canVec3(20,0,10),0x993333)
  estore.createEntity mkCubeComps(canVec3(20,1,10),0x993333)
  estore.createEntity mkCubeComps(canVec3(-1,0,10),0x993333)
  estore.createEntity mkCubeComps(canVec3(-1,1,10),0x993333)
  
  groundQuat = canQuat()
  groundQuat.setFromAxisAngle(canVec3(1, 0, 0), -Math.PI / 2)
  estore.createEntity([
    C.buildCompForType(T.Name, name: 'Ground')
    C.buildCompForType(T.Location, position: canVec3(0,0,12), quaternion: groundQuat)
    C.buildCompForType(T.Physical,
      kind: 'plane'
      data: new C.Physical.Plane(0x9999cc, 50, 50)
    )
  ])


  estore.createEntity([
    C.buildCompForType(T.Name, name: 'Follow Camera')
    C.buildCompForType(T.FollowCamera, followTag: 'player_piece')
    C.buildCompForType(T.Location, position: canVec3(0,3,5))
  ])


  model  = {
    lastTime: null
    estore: estore
    input:
      dt: null
      controllerEvents: []
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
        


  if action instanceof Time
    t = action.value
    if model.lastTime?
      dt = t - model.lastTime
      if dt > 0.1 or dt < 0
        dt = 1.0/60.0 # avoid big updates or the crazy first-reqAnimFr-is-huge-then-it-goes-back-to-normal issue. ?
      model.input.dt = dt
      [model.estore,glboalEvents] = ecsMachine.update(model.estore, model.input)
      # TODO handle global events....?

      # Update the dev camera
      # model.camera.data.pan += model.mouseLocation.x * -Math.PI/2 * dt
      # model.camera.data.tilt += model.mouseLocation.y * Math.PI/2 * dt

      # Reset the controller input queue for the next Time action (tick)
      model.input.controllerEvents = []
      
    else
      model.NO_RENDER=true
    model.lastTime = t

    return [model, [{type: 'tick', map: (v) -> new Time(v/1000.0)}]]

  else
    [model,null]

MazeView = require './elements/faster_maze_view'

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
      <MazeView width={width} height={height} camera={model.camera} estore={model.estore} />
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
