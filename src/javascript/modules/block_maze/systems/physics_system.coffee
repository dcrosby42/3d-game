BaseSystem = require '../../../lib/ecs/base_system'
C = require '../components'
T = C.Types
{canVec3,canQuat} = require '../../../lib/cannon_helpers'

EntitySearch = require '../../../lib/ecs/entity_search'

Cannon = require 'cannon'

PhysicalSearcher = EntitySearch.prepare([T.Physical,T.Location])

Objects = require "../objects"

class PhysicsSystem extends BaseSystem
  @Subscribe: [ T.PhysicsWorld ]

  process: (r) ->
    world = @getWorld()
    timeStep = @input.dt

    # Sync game state to physics world
    pairings = []
    bodyIdsToComps = {}
    PhysicalSearcher.run @estore, (r) =>
      [physical, location] = r.comps
      # Find / create body
      body = world.getBodyById(physical.bodyId)
      if !body?
        body = Objects.createBody(physical,location)
        physical.bodyId = body.id
        world.add body

      bodyIdsToComps[physical.bodyId] = physical
      # Sync Location -> body
      # IMPORTANT: copying state like position, velocity etc. will OVERRIDE the effects of applying impulses and so forth. Be sure to copy BEFORE applying impulse

      pos = location.position
      vel = location.velocity
      quat = location.quaternion
      body.position.set(pos.x, pos.y, pos.z)
      body.velocity.set(vel.x, vel.y, vel.z)
      body.quaternion.set(quat.x, quat.y, quat.z, quat.w)

      @handleEvents r.eid,
        localImpulse: ({impulse,point}) =>
          body.applyLocalImpulse impulse, point
        impulse: ({impulse,point}) =>
          body.applyImpulse impulse, point

      # Mark body as relevant
      body.__relevant = true
      
      # Hang onto the relationship between the components and body for a moment
      pairings.push [physical,location,body]

    # Sweep all world bodies and look for irrelevant bodies:
    markedForDeath = []
    for b in world.bodies
      if !b.__relevant
        markedForDeath.push b
      else
        b.__relevant = false
    
    # Clear irrelevant 
    for b in markedForDeath
      world.remove b

    # Step the physics simulation:
    worldEvents = @stepWorld(world,timeStep)

    # Sync physics world to game state
    for [physical,location,body] in pairings
      # Sync body -> Location
      pos = body.position
      vel = body.velocity
      quat = body.quaternion
      location.position.set(pos.x, pos.y, pos.z)
      location.velocity.set(vel.x, vel.y, vel.z)
      location.quaternion.set(quat.x, quat.y, quat.z, quat.w)
      if events = worldEvents[body.id]
        for [type,otherId] in events
          otherComp = bodyIdsToComps[otherId]
          if otherComp?
            # console.log "publishEvent", physical.eid, type, cid: physical.cid, otherCid: otherComp.cid, otherEid: otherComp.eid
            @publishEvent physical.eid, type, cid: physical.cid, otherCid: otherComp.cid, otherEid: otherComp.eid

  stepWorld: (world,timeStep) ->
    @_worldEvents = {}
    world.step(timeStep)
    return @_worldEvents

  getWorld: ->
    unless @_world?
      @_world = new Cannon.World()
      @_world.broadphase = new Cannon.NaiveBroadphase()
      @_world.gravity = canVec3(0,-9.82,0)

      @subscribeWorldCollisions()

      window.world = @_world
    @_world

  subscribeWorldCollisions: ->
    subscribe = (type) =>
      @_world.addEventListener type, (e) =>
        a = e.bodyA.id
        b = e.bodyB.id
        @_worldEvents[a] ?= []
        @_worldEvents[a].push [type, b]
        @_worldEvents[b] ?= []
        @_worldEvents[b].push [type, a]

    @_worldEvents = {}
    for t in [ "beginContact", "endContact" ]
      subscribe t



module.exports = -> new PhysicsSystem()
