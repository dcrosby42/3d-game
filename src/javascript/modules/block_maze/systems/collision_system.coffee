BaseSystem = require '../../../lib/ecs/base_system'
C = require '../components'
T = C.Types

class CollisionSystem extends BaseSystem
  @Subscribe: [ T.Physical ]

  process: (r) ->
    [physical] = r.comps
    for c in @input.collisions
      if c.this_eid == physical.eid and c.this_cid = physical.cid
        # console.log "CollisionSystem:",c
        @publishEvent r.eid, "collision", c

module.exports = -> new CollisionSystem()
