React = require 'react'
React3 = require 'react-three-renderer'

KeyboardInput = require '../../elements/keyboard_input'
# MainView = require './main_view.coffee'

class Action
  constructor: (@value) ->

class Input extends Action

class Nolo extends Action
# Action.Time =
#   type: 'Time'
#   new: (t) ->
#     {type: 'Time', time: t}
# Action.Input =
#   type: 'Input'
#   new: (a) ->
#     {type: 'Input', inputAction: a}
# Action.Mouse =
#   type: 'Mouse'
#   new: (a) ->
#     {type: 'Mouse', mouse: a}

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


exports.initialState = ->
  {
    grid: { width: 20, height: 10 }
    position: {x:3,y:3}
    skin: "O"
    # seconds:0
    # controllers: {}
    # mouse: {}
  }

exports.update = (model,action) ->
  if action instanceof Input
    v = action.value
    pos = model.position
    if v.tag == 'player1'
      if v.control == "up" and v.state == "down"
        pos.y -= 1
      else if v.control == "down" and v.state == "down"
        pos.y += 1
      else if v.control == "left" and v.state == "down"
        pos.x -= 1
      else if v.control == "right" and v.state == "down"
        pos.x += 1
  [model,null]

  # model.NO_SYNC = false
  # switch action.type
  #   when Action.Time.type
  #     time = action.time
  #     model.time = time
  #     intTime = Math.floor(time/1000)
  #     if intTime <= model.seconds
  #       model.NO_SYNC = true
  #     else
  #       model.seconds = intTime
  #
  #     return [model, [{type: 'tick', map: Action.Time.new}]]
  #
  #   when Action.Input.type
  #     # model.NO_SYNC = true
  #
  #     ia = action.inputAction
  #     console.log "Input: #{ia.tag} #{ia.control} #{ia.state}"
  #     model.controllers[ia.tag] ?= {}
  #     model.controllers[ia.tag][ia.control] = ia.state
  #
  #     return [model, null]
  #
  #   when Action.Mouse.type
  #     model.NO_SYNC = true
  #     console.log "Mouse action",action.mouse
  #     return [model, null]
  #
  #   else
  #     console.log "Main.update unhandled action", action


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

