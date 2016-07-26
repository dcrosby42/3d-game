BaseSystem = require '../../../lib/ecs/base_system'
C = require '../components'
T = C.Types
{canVec3} = require '../../../lib/cannon_helpers'

EntitySearch = require '../../../lib/ecs/entity_search'

Cannon = require 'cannon'

PhysicalSearcher = EntitySearch.prepare([T.Physical,T.Location])

class PhysicsSystem extends BaseSystem
  @Subscribe: [ T.PhysicsWorld ]

  process: (r) ->
    world = @getWorld()
    # timeStep = 1.0 / 60.0
    timeStep = @input.dt / 1000

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

      # TODO Mark bodies as referenced
      
      pairings.push [physical,location,body]

    # TODO: remove bodies that are no longer referenced by gamestate
    #   ...and "unmark" the remaining bodies

    # Step the physics simulation:
    world.step(timeStep)

    # Sync physics world to game state
    for [physical,location,body] in pairings
      # Sync body -> Location
      pos = body.position
      vel = body.velocity
      location.position.set(pos.x, pos.y, pos.z)
      location.velocity.set(vel.x, vel.y, vel.z)

  getWorld: ->
    unless @_world?
      @_world = new Cannon.World()
      @_world.broadphase = new Cannon.NaiveBroadphase()
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
