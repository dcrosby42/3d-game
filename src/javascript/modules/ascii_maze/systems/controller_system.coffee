BaseSystem = require '../../../lib/ecs/base_system'
C = require '../components'
T = C.Types

class ControllerSystem extends BaseSystem
  @Subscribe: [ T.Controller ]

  process: (r) ->
    controller = r.comps[0]
    cevts = @input.controllerEvents[controller.inputName]
    updateControllerStates(controller.states, cevts)
    for key,val of controller.states
      console.log "ControllerSystem: @publishEvent",r.eid, key, r.entity, controller
      @publishEvent r.eid, key

endsWithPressedOrReleased = /(Pressed|Released)$/

updateControllerStates = (states, events) ->
  for key,val of states
    if !val or key.match endsWithPressedOrReleased
      delete states[key]

  return unless events? and events.length > 0

  for e of events
    {control,state} = e
    prevVal = states[control]
    if state == 'down'
      states[control] = true
      if !prevVal
        states["#{control}Pressed"] = true
    else
      delete states[control]
      if prevVal
        states["#{control}Released"] = true

module.exports = -> new ControllerSystem()


