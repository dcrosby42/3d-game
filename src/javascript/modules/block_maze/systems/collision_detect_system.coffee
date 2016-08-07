BaseSystem = require '../../../lib/ecs/base_system'
C = require '../components'
T = C.Types

class CollisionDetectSystem extends BaseSystem
  @Subscribe: [ T.Physical ]

  process: (r) ->
    physical = r.comps[0]
    @handleEvents r.eid,
      beginContact: (data) ->
        console.log "CollisionDetectSystem beginContact",data
      endContact: (data) ->
        console.log "CollisionDetectSystem endContact",data

module.exports = -> new CollisionDetectSystem()
