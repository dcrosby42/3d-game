builders = {}
cache = {}

builders["spike.terrain.flat"] = require './spike_terrain_flat'

module.exports.get = (key) ->
  if cached = cache[key]
    return cached
  if builder = builders[key]
    obj = builder()
    cache[key] = obj
    return obj


