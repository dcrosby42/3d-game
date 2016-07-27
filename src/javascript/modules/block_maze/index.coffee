React = require 'react'
React3 = require 'react-three-renderer'
KeyboardInput = require '../../elements/keyboard_input'

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
])

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
      kind: 'cube'
      data: new C.Physical.Cube(0x333399)
      axisHelper: 2
    )
    C.buildCompForType(T.Controller, inputName: 'player1')
  ])

  estore.createEntity([
    C.buildCompForType(T.Name, name: 'Corner1')
    C.buildCompForType(T.Location, position: canVec3(-1,0,-1))
    C.buildCompForType(T.Physical,
      kind: 'cube'
      data: new C.Physical.Cube(0x993333)
    )
  ])
  estore.createEntity([
    C.buildCompForType(T.Name, name: 'Corner2')
    C.buildCompForType(T.Location, position: canVec3(20,0,-1))
    C.buildCompForType(T.Physical,
      kind: 'cube'
      data: new C.Physical.Cube(0x993333)
    )
  ])
  estore.createEntity([
    C.buildCompForType(T.Name, name: 'Corner3')
    C.buildCompForType(T.Location, position: canVec3(20,0,10))
    C.buildCompForType(T.Physical,
      kind: 'cube'
      data: new C.Physical.Cube(0x993333)
    )
  ])
  estore.createEntity([
    C.buildCompForType(T.Name, name: 'Corner4')
    C.buildCompForType(T.Location, position: canVec3(-1,0,10))
    C.buildCompForType(T.Physical,
      kind: 'cube'
      data: new C.Physical.Cube(0x993333)
    )
  ])
  
  groundQuat = canQuat()
  groundQuat.setFromAxisAngle(canVec3(1, 0, 0), -Math.PI / 2)
  estore.createEntity([
    C.buildCompForType(T.Name, name: 'Ground')
    C.buildCompForType(T.Location, position: canVec3(0,-0.5,0), quaternion: groundQuat)
    C.buildCompForType(T.Physical,
      kind: 'plane'
      data: new C.Physical.Plane(0x9999cc, 100, 100)
    )
  ])

  model  = {
    lastTime: null
    estore: estore
    input:
      dt: null
      controllerEvents: []
  }
  [model, [{type: 'tick', map: (v) -> new Time(v)}]]


exports.update = (model,action) ->
  model.NO_RENDER = false

  if action instanceof Input
    model.NO_RENDER=true
    e = action.value
    model.input.controllerEvents.push(e)

  if action instanceof Mouse
    model.NO_RENDER=true
    {type,x,y,event} = action.value
    # console.log "Action.Mouse type=#{type}", x,y

  if action instanceof Time
    t = action.value
    if model.lastTime?
      model.input.dt = t - model.lastTime
      # input = mungeInputs(dt,model.controllerEvents)
      [model.estore,glboalEvents] = ecsMachine.update(model.estore, model.input)
      # TODO handle global events....?
      model.input.controllerEvents = []
      
    else
      model.NO_RENDER=true
    model.lastTime = t

    return [model, [{type: 'tick', map: (v) -> new Time(v)}]]

  else
    [model,null]

MazeView = require './elements/maze_view'

handleMouse = (type,address) ->
  (e) ->
    e.stopPropagation()
    e.preventDefault()
    address.send new Mouse(
      type: type
      x: e.nativeEvent.offsetX
      y: e.nativeEvent.offsetY
      event: e
    )

exports.view = (model,address) ->
  
  <div>
    <h3>Maze Thinger</h3>
    <div style={width:"800px",height:"400px"}
      onMouseMove={handleMouse 'move', address}
      onMouseDown={handleMouse 'down', address}
      onMouseUp={handleMouse 'up', address}
    >
      <MazeView estore={model.estore} />
    </div>
    <KeyboardInput
      tag="player1"
      mappings={{
        "w": 'forward'
        "a": 'strafeLeft'
        "s": 'backward'
        "d": 'strafeRight'
        "left": 'turnLeft'
        "right": 'turnRight'
        "space": 'elevate'
        "shift": 'sink'
      }}
      address={address.forward (fsig) -> fsig.map (v) -> new Input(v)} 
    />
  </div>
