React = require 'react'
React3 = require 'react-three-renderer'
KeyboardInput = require '../../elements/keyboard_input'
# MainView = require './main_view.coffee'

C = require './components'
T = C.Types

EntityStore = require '../../lib/ecs/entity_store'
EcsMachine = require '../../lib/ecs/ecs_machine'

ActionBase = require '../../lib/action_base'

class Action extends ActionBase
class Nolo extends Action
class Input extends Action
class Time extends Action
class Mouse extends Action


ecsMachine = new EcsMachine([
  Systems.controllerSystem()
  Systems.gridMovementSystem()
])


exports.initialState = ->
  estore = new EntityStore()
  estore.createEntity([
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
  # if action instanceof Input
  #   v = action.value
  #   pos = model.position
  #   if v.tag == 'player1'
  #     if v.control == "up" and v.state == "down"
  #       pos.y -= 1
  #     else if v.control == "down" and v.state == "down"
  #       pos.y += 1
  #     else if v.control == "left" and v.state == "down"
  #       pos.x -= 1
  #     else if v.control == "right" and v.state == "down"
  #       pos.x += 1

  if action instanceof Input
    model.NO_RENDER=true
    e = action.value
    model.input.controllerEvents.push(e)

  if action instanceof Time
    t = action.value
    if model.lastTime?
      model.input.dt = model.lastTime - t
      input = mungeInputs(dt,model.controllerEvents)
      model.estore = ecsMachine.update(model.estore, input)
      model.input.controllerEvents = []
      
    else
      model.NO_RENDER=true
    model.lastTime = t

    return [model, [{type: 'tick', map: (v) -> new Time(v)}]]

  else
    [model,null]

  # model.NO_RENDER = false
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

mkCharGrid = ->
  numrows = 10
  numcols = 20
  rows = []
  for r in [0...numrows]
    row = []
    for c in [0...numcols]
      row.push "."
    rows.push row
  rows

exports.view = (model,address) ->
  rows = mkCharGrid()
  rows[model.position.y][model.position.x] = model.skin
  gridString=""
  for row in rows
    for c in row
      gridString += c
    gridString += "\n"
  
  <div class="ascsii-maze">
    <pre>{gridString}</pre>
    <KeyboardInput 
      tag="player1" 
      mappings={{
        "right": 'right'
        "left": 'left'
        "up": 'up'
        "down": 'down'
      }}
      address={address.forward (s) -> s.map (v) -> new Input(v)} 
    />
  </div>

