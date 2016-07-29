BaseSystem = require '../../../lib/ecs/base_system'
C = require '../components'
T = C.Types
{canVec3,canQuat} = require '../../../lib/cannon_helpers'

EntitySearch = require '../../../lib/ecs/entity_search'

Cannon = require 'cannon'

PhysicalSearcher = EntitySearch.prepare([T.Physical,T.Location])

class PhysicsSystem extends BaseSystem
  @Subscribe: [ T.PhysicsWorld ]

  process: (r) ->
    world = @getWorld()
    timeStep = @input.dt

    # Sync game state to physics world
    pairings = []
    PhysicalSearcher.run @estore, (r) =>
      [physical, location] = r.comps
      # Find / create body
      body = world.getBodyById(physical.bodyId)
      if !body?
        body = @createBody(physical)
        physical.bodyId = body.id
        world.add body

      # Sync Location -> body
      # IMPORTANT: copying state like position, velocity etc. will OVERRIDE the effects of applying impulses and so forth.
      #   - copy these things BEFORE applying impulses.
      #   - ...or contrive a way to avoid setting them when impulses are coming into play. <-- TODO?
      pos = location.position
      vel = location.velocity
      quat = location.quaternion
      body.position.set(pos.x, pos.y, pos.z)
      body.velocity.set(vel.x, vel.y, vel.z)
      body.quaternion.set(quat.x, quat.y, quat.z, quat.w)

      @handleEvents r.eid,
        localImpulse: ({impulse,point}) =>
          # console.log "phys2 body.applyLocalImpulse",impulse,point
          body.applyLocalImpulse impulse, point
        impulse: ({impulse,point}) =>
          # console.log "phys2 body.applyLocalImpulse",impulse,point
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
    world.step(timeStep)

    # Sync physics world to game state
    for [physical,location,body] in pairings
      # Sync body -> Location
      pos = body.position
      vel = body.velocity
      quat = body.quaternion
      location.position.set(pos.x, pos.y, pos.z)
      location.velocity.set(vel.x, vel.y, vel.z)
      location.quaternion.set(quat.x, quat.y, quat.z, quat.w)

  getWorld: ->
    unless @_world?
      @_world = new Cannon.World()
      @_world.broadphase = new Cannon.NaiveBroadphase()
      @_world.gravity = canVec3(0,-9.82,0)
      # console.log "Created world",@_world
      window.world = @_world
    @_world

  createDebugBody: ->
    shape = new Cannon.Box(new Cannon.Vec3(1,1,1))
    body = new Cannon.Body(mass: 2, shape: shape)
    # body.position.set(0,0,4)
    # body.linearDamping = 0.0
    # body.velocity.set(1,0,0)
    body

  createBody: (physical) ->
    switch physical.kind
      when 'cube'
        shape = new Cannon.Box(new Cannon.Vec3(0.5,0.5,0.5))
        body = new Cannon.Body(mass: 2, shape: shape)
        # body.position.set(0,0,4)
        # body.linearDamping = 0.0
        # body.velocity.set(1,0,0)
        body
      when 'plane'
        shape = new Cannon.Plane()
        body = new Cannon.Body(mass: 0, shape: shape)
        body

      else
        console.log "!! ERR PhysicsSystem.createBody: Cannot construct body from Physical",physical
        throw new Error("Cannot construct body from Physical kind '#{physical.kind}'")

module.exports = -> new PhysicsSystem()
