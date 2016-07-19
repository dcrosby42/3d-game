React = require 'react'
React3 = require 'react-three-renderer'
KeyboardInput = require '../../elements/keyboard_input'
# MainView = require './main_view.coffee'

C = require './components'
T = C.Types
Systems = require './systems'

EntityStore = require '../../lib/ecs/entity_store'
EcsMachine = require '../../lib/ecs/ecs_machine'

ActionBase = require '../../lib/action_base'

class Action extends ActionBase
class Nolo extends Action
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

  # switch action.type
  #   when Action.Time.type
  #     time = action.time
  #     model.time = time
  #     intTime = Math.floor(time/1000)
  #     if intTime <= model.seconds
  #       model.NO_RENDER = true
  #     else
  #       model.seconds = intTime
  #
  #     return [model, [{type: 'tick', map: Action.Time.new}]]
  #
  #   when Action.Input.type
  #     # model.NO_RENDER = true
  #
  #     ia = action.inputAction
  #     console.log "Input: #{ia.tag} #{ia.control} #{ia.state}"
  #     model.controllers[ia.tag] ?= {}
  #     model.controllers[ia.tag][ia.control] = ia.state
  #
  #     return [model, null]
  #
  #   when Action.Mouse.type
  #     model.NO_RENDER = true
  #     console.log "Mouse action",action.mouse
  #     return [model, null]
  #
  #   else
  #     console.log "Main.update unhandled action", action

# mungeInputs = (dt,controllerEvents) ->
#   {
#   }


AsciiView = require './elements/ascii_view'
MazeView = require './elements/maze_view'

exports.view = (model,address) ->
  
  <div>
    <h3>Maze Thinger</h3>
    {# <AsciiView estore={model.estore} /> #}
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


_getPlayerPosition = (estore) ->
  pos = null
  pieceSearch.run estore, (r) ->
    [tag,position] = r.comps
    pos = position
  pos
    



