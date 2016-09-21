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
    rootGroup = @input.physijsScene
    if !rootGroup?
      # console.log "PhysijsPhysicsSystem returning becaues rootGroup null"
      return

    # return null unless rootGroup?

    # TODO? timeStep = @input.dt


    # Sync game state to physics world
    # pairings = []
    # bodyIdsToComps = {}

    PhysicalSearcher.run @estore, (r) =>
      [physical, location] = r.comps
      return if physical.bodyType == 0

      shape = rootGroup.getObjectById(physical.viewId)
      # console.log "."
      if shape?
        # console.log "Syncing comps from shape",physical.viewId, shape.id

        # Sync shape -> Location
        # console.log "PhysijsPhysicsSystem shape.position",shape.position
        pos = shape.position
        quat = shape.quaternion
        vel = shape.getLinearVelocity()
        # TODO: angular velocity
        location.position.set(pos.x, pos.y, pos.z)
        # console.log "PhysijsPhysicsSystem set location.position",location.position
        location.velocity.set(vel.x, vel.y, vel.z)
        location.quaternion.set(quat.x, quat.y, quat.z, quat.w)
      else
        console.log "!! PhysijsPhysicsSystem: no shape found for physical.viewId=#{physical.viewId}"

      # if events = worldEvents[body.id]
      #   for [type,otherId] in events
      #     otherComp = bodyIdsToComps[otherId]
      #     if otherComp?
      #       # console.log "publishEvent", physical.eid, type, cid: physical.cid, otherCid: otherComp.cid, otherEid: otherComp.eid
      #       @publishEvent physical.eid, type, cid: physical.cid, otherCid: otherComp.cid, otherEid: otherComp.eid



module.exports = -> new PhysijsPhysicsSystem()
