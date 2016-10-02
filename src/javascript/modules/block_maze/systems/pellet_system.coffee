BaseSystem = require '../../../lib/ecs/base_system'
C = require '../components'
T = C.Types

mag = 1/5
per = 2
offset = 1
bob = (x) -> mag * Math.sin(x * per) + offset

class PelletSystem extends BaseSystem
  @Subscribe: [{type:T.Tag, name:'pellet'},T.Location]

  process: (r) ->
    [_tag,location] = r.comps
    location.position.y = bob(@input.time)
    location.positionDirty = true

module.exports = -> new PelletSystem()


