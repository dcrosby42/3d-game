BaseSystem = require '../../../lib/ecs/base_system'
C = require '../components'
T = C.Types
{canVec3,canQuat} = require '../../../lib/cannon_helpers'

EntitySearch = require '../../../lib/ecs/entity_search'

Cannon = require 'cannon'

PhysicalSearcher = EntitySearch.prepare([T.Physical,T.Location])

Objects = require "../objects"

class PhysijsPhysicsSystem extends BaseSystem
  @Subscribe: [ T.PhysicsWorld ]

  process: (r) ->
    scene = @input.physijsScene
    if !scene?
      return

    PhysicalSearcher.run @estore, (r) =>
      [physical, location] = r.comps
      return if physical.bodyType == Objects.ShapeType.Static

      shape = scene.getObjectById(physical.viewId)
      if shape?
        Objects.updateFrom3DShape(shape, physical,location)
      else
        console.log "!! PhysijsPhysicsSystem: no shape found for physical.viewId=#{physical.viewId}"

      # TODO: propagate @input.physijsCollisions



module.exports = -> new PhysijsPhysicsSystem()
