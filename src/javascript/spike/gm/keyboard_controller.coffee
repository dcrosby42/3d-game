MousetrapWrapper = require './mousetrap_wrapper'

statefulUpDown = (address,control) ->
  prev = null
  (state) ->
    if state != prev
      address.send {control: control, state:state}
      prev = state

bindKey = (key,control,address) ->
  relay = statefulUpDown(address,control)
  MousetrapWrapper.bind(key, (-> relay('down')), 'keydown')
  MousetrapWrapper.bind(key, (-> relay('up')), 'keyup')

exports.bindKeys = (address, mappings) ->
  for k,c of mappings
    bindKey(k,c,address)

exports.unbindKeys = (mappings) ->
  for k,c of mappings
    MousetrapWrapper.unbind(k)
