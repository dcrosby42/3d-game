React = require 'react'
React3 = require 'react-three-renderer'
KeyboardInput = require '../../elements/keyboard_input'

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



ecsMachine = new EcsMachine([
  Systems.controller_system()
  Systems.player_piece_control_system()
  Systems.boxed_movement_system()
])

exports.initialState = ->
  estore = new EntityStore()
  estore.createEntity([
    C.buildCompForType(T.Name, name: 'Player One')
    C.buildCompForType(T.Tag, name: 'player_piece')
    C.buildCompForType(T.Position)
    C.buildCompForType(T.Velocity)
    C.buildCompForType(T.Controller, inputName: 'player1')
    C.buildCompForType(T.Cube, color: 0x339933)
  ])
  estore.createEntity([
    C.buildCompForType(T.Name, name: 'corner-marker-ul')
    C.buildCompForType(T.Position, position: vec3(-1,0,-1))
    C.buildCompForType(T.Cube, color: 0x880000)
  ])
  estore.createEntity([
    C.buildCompForType(T.Name, name: 'corner-marker-ur')
    C.buildCompForType(T.Position, position: vec3(20,0,-1))
    C.buildCompForType(T.Cube, color: 0x880000)
  ])
  estore.createEntity([
    C.buildCompForType(T.Name, name: 'corner-marker-lr')
    C.buildCompForType(T.Position, position: vec3(20,0,10))
    C.buildCompForType(T.Cube, color: 0x880000)
  ])
  estore.createEntity([
    C.buildCompForType(T.Name, name: 'corner-marker-ll')
    C.buildCompForType(T.Position, position: vec3(-1,0,10))
    C.buildCompForType(T.Cube, color: 0x880000)
  ])

  #TODO add grid entity 

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

  if action instanceof Time
    t = action.value
    if model.lastTime?
      model.input.dt = model.lastTime - t
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

# AsciiView = require './elements/ascii_view'
MazeView = require './elements/maze_view'

exports.view = (model,address) ->
  
  <div>
    <h3>Maze Thinger</h3>
    {#<AsciiView estore={model.estore} /> #}
    <MazeView estore={model.estore} />
    <KeyboardInput
      tag="player1"
      mappings={{
        "right": 'right'
        "left": 'left'
        "up": 'up'
        "down": 'down'
      }}
      address={address.forward (fsig) -> fsig.map (v) -> new Input(v)} 
    />
  </div>
