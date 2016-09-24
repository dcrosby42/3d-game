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
      # console.log "PhysijsPhysicsSystem returning becaues scene null"
      return

    # TODO? timeStep = @input.dt


    # Sync game state to physics world
    PhysicalSearcher.run @estore, (r) =>
      [physical, location] = r.comps
      return if physical.bodyType == 0

      shape = scene.getObjectById(physical.viewId)
      # console.log "."
      if shape?

        Objects.updateFrom3DShape(shape, physical,location)
      else
        console.log "!! PhysijsPhysicsSystem: no shape found for physical.viewId=#{physical.viewId}"

      # if events = worldEvents[body.id]
      #   for [type,otherId] in events
      #     otherComp = bodyIdsToComps[otherId]
      #     if otherComp?
      #       # console.log "publishEvent", physical.eid, type, cid: physical.cid, otherCid: otherComp.cid, otherEid: otherComp.eid
      #       @publishEvent physical.eid, type, cid: physical.cid, otherCid: otherComp.cid, otherEid: otherComp.eid



module.exports = -> new PhysijsPhysicsSystem()
