BaseSystem = require '../../../lib/ecs/base_system'
C = require '../components'
T = C.Types
{canVec3} = require '../../../lib/cannon_helpers'

EntitySearch = require '../../../lib/ecs/entity_search'

Cannon = require 'cannon'

PhysicalSearcher = EntitySearch.prepare([T.Physical,T.Location])

class PhysicsSystem extends BaseSystem
  @Subscribe: [ T.PhysicsWorld ]

  getWorld: ->
    unless @_world?
      @_world = new Cannon.World()
      @_world.broadphase = new Cannon.NaiveBroadphase()
      console.log "Created world",@_world
      window.world = @_world
    @_world

  createDebugBody: ->
    shape = new Cannon.Box(new Cannon.Vec3(1,1,1))
    body = new Cannon.Body(mass: 2, shape: shape)
    # body.position.set(0,0,4)
    # body.linearDamping = 0.0
    body.velocity.set(1,0,0)
    body

  process: (r) ->
    world = @getWorld()

    pairings = []
    PhysicalSearcher.run @estore, (r) =>
      [physical, location] = r.comps
      body = world.getBodyById(physical.bodyId)
      if !body?
        body = @createDebugBody()
        physical.bodyId = body.id
        world.add body
        # console.log "Added body",body

      pos = location.position
      body.position.set(pos.x, pos.y, pos.z)
      vel = location.velocity
      body.velocity.set(vel.x, vel.y, vel.z)

      pairings.push [physical,location,body]

    timeStep = 1.0 / 60.0
    world.step(timeStep)

    for [physical,location,body] in pairings
      pos = body.position
      location.position.set(pos.x, pos.y, pos.z)
      vel = body.velocity
      location.velocity.set(vel.x, vel.y, vel.z)

module.exports = -> new PhysicsSystem()
