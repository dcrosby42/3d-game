BaseSystem = require '../../../lib/ecs/base_system'
C = require '../components'
T = C.Types
Objects = require "../objects"

EntitySearch = require '../../../lib/ecs/entity_search'
PhysicalSearcher = EntitySearch.prepare([T.Physical,T.Location])


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


module.exports = -> new SyncFromSceneSystem()
