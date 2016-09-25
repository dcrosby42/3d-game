BaseSystem = require '../../../lib/ecs/base_system'
C = require '../components'
T = C.Types
{canVec3,canQuat} = require '../../../lib/cannon_helpers'

EntitySearch = require '../../../lib/ecs/entity_search'

Cannon = require 'cannon'

PhysicalSearcher = EntitySearch.prepare([T.Physical,T.Location])

Objects = require "../objects"

class SyncFromSceneSystem extends BaseSystem
  @Subscribe: [ T.PhysicsWorld ]

  process: (r) ->
    scene = @input.scene
    if !scene?
      return

    PhysicalSearcher.run @estore, (r) =>
      [physical, location] = r.comps
      return if physical.shapeType == Objects.ShapeType.Static

      shape = scene.getObjectById(physical.shapeId)
      if shape?
        Objects.updateFrom3DShape(shape, physical,location)
      else
        console.log "!! SyncFromSceneSystem: no shape found for physical.shapeId=#{physical.shapeId}"

      # TODO: propagate @input.collisions ?



module.exports = -> new SyncFromSceneSystem()
