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
        for eventName in extras
          # console.log "ControllerSystem: @publishEvent",r.eid,eventName
          @publishEvent r.eid, eventName

    for key,val of controller.states
      # console.log "ControllerSystem: @publishEvent",r.eid,key
      @publishEvent r.eid, key


updateControlStates = (states, e, emit) ->
  extras = []
  {control,state} = e
  prevVal = states[control]
  if state == 'down'
    states[control] = true
    if !prevVal
      extras.push "#{control}Pressed"

  else
    delete states[control]
    if prevVal
      extras.push "#{control}Released"
  return [states,extras]

module.exports = -> new ControllerSystem()


