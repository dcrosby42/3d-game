BaseSystem = require '../../../lib/ecs/base_system'
C = require '../components'
T = C.Types

class ControllerSystem extends BaseSystem
  @Subscribe: [ T.Controller ]

  process: (r) ->
    controller = r.comps[0]
    for e in @input.controllerEvents
      if e.tag == controller.inputName
        [controller.states,extras] = updateControlStates(controller.states, e)
        for [name,value] in extras
          # console.log "ControllerSystem: @publishEvent",r.eid,eventName
          @publishEvent r.eid, name, value

    for name,value of controller.states
      # console.log "ControllerSystem: @publishEvent",r.eid,key
      @publishEvent r.eid, name, value


updateControlStates = (states, e, emit) ->
  extras = []
  {control,state} = e
  prevVal = states[control]
  if state == 0
    delete states[control]
    if prevVal? and prevVal != 0
      extras.push ["#{control}Released",0]

  else
    states[control] = state
    if !prevVal? or prevVal == 0
      extras.push ["#{control}Pressed",state]

  return [states,extras]

module.exports = -> new ControllerSystem()


