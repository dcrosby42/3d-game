FxHandlers = require './fx_handlers'

exports.processEffects = (effects,address) ->
  return unless effects?
  for e in effects
    handler = getHandlerFor(e)
    if handler?
      handler(e,address)

getHandlerFor = (effect) ->
  if !effect?
    console.log "!! FxHandlers.get() received null effect; dropping"
    return null
  handler = FxHandlers[effect.type]
  if !handler
    throw new Error("No handler effect defined for effect type '#{effect.type}'")
  return handler
