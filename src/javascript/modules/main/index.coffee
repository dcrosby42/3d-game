React = require 'react'
React3 = require 'react-three-renderer'

# KeyboardInput = require './keyboard_input'
MainView = require './main_view.coffee'

Action ={}
Action.Time =
  type: 'Time'
  new: (t) ->
    {type: 'Time', time: t}
Action.Input =
  type: 'Input'
  new: (a) ->
    {type: 'Input', inputAction: a}
Action.Mouse =
  type: 'Mouse'
  new: (a) ->
    {type: 'Mouse', mouse: a}

exports.initialState = ->
  model = {
    time:0
    seconds:0
    controllers: {}
    mouse: {}
  }
  [model,null]

exports.update = (model,action) ->
  model.NO_SYNC = false
  switch action.type
    when Action.Time.type
      time = action.time
      model.time = time
      intTime = Math.floor(time/1000)
      if intTime <= model.seconds
        model.NO_SYNC = true
      else
        model.seconds = intTime

      return [model, [{type: 'tick', map: Action.Time.new}]]

    when Action.Input.type
      # model.NO_SYNC = true

      ia = action.inputAction
      console.log "Input: #{ia.tag} #{ia.control} #{ia.state}"
      model.controllers[ia.tag] ?= {}
      model.controllers[ia.tag][ia.control] = ia.state

      return [model, null]

    when Action.Mouse.type
      model.NO_SYNC = true
      console.log "Mouse action",action.mouse
      return [model, null]

    else
      console.log "Main.update unhandled action", action


exports.view = (model,address) ->
  <MainView model={model} address={address} />

