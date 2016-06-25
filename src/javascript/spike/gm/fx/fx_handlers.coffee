module.exports = H = {}

H.tick = (effect,address) ->
  requestAnimationFrame (t) ->
    action = effect.map(t)
    address.send(action)

