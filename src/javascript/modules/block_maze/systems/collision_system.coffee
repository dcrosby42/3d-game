BaseSystem = require '../../../lib/ecs/base_system'
C = require '../components'
T = C.Types

class CollisionSystem extends BaseSystem
  @Subscribe: [ T.Physical ]

  process: (r) ->
    [physical] = r.comps
    for c in @input.collisions
      if c.this_eid == physical.eid and c.this_cid = physical.cid
        @publishEvent r.eid, "physics_collision", c

    for c in @input.hits
      if c.this_eid == physical.eid and c.this_cid = physical.cid
        @publishEvent r.eid, "hit", c

module.exports = -> new CollisionSystem()
