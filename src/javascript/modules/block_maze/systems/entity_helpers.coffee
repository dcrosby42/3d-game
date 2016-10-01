
CompSet = require '../../../lib/ecs/comp_set'

H =
  matchCompTypeValue: (entity, type, key, val) ->
    got = null
    entity.each type, (comp) ->
      if comp[key] == val
        got = comp
        return CompSet.BreakEach
    got

  hasTag: (entity, tagName) ->
    matchCompTypeValue(entity, T.Tag, 'name', tagName)?

module.export = H
