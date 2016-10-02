
CompSet = require '../../../lib/ecs/comp_set'
C = require '../components'
T = C.Types

E =
  matchCompTypeValue: (entity, type, key, val) ->
    got = null
    entity.each type, (comp) ->
      if comp[key] == val
        got = comp
        return CompSet.BreakEach
    got

  hasTag: (entity, tagName) ->
    E.matchCompTypeValue(entity, T.Tag, 'name', tagName)?

module.exports = E
