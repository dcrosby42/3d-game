BaseSystem = require '../../../lib/ecs/base_system'
C = require '../components'
T = C.Types

EntitySearch = require '../../../lib/ecs/entity_search'

Cannon = require 'cannon'

createPhysicsBody = (physical) ->
  body = new Cannon.Body()
  switch physical.kind
    when 'cube'
      shape = new Cannon.Box(canVec3(0.5, 0.5, 0.5)) # TODO use physical.data.width/2 etc
      body.addShape(shape)
    else
      throw new Error("createPhysicsBody: unknown kind '#{physical.kind}', cannot create physics body and shape from component", physical)

  return body

  # TODO: set other body props based on physical: 
  # [position] Vec3 optional
  # [velocity] Vec3 optional
  # [angularVelocity] Vec3 optional
  # [quaternion] Quaternion optional
  # [mass] Number optional
  # [material] Material optional
  # [type] Number optional
  # [linearDamping=0.01] Number optional
  # [angularDamping=0.01] Number optional
  # [allowSleep=true] Boolean optional
  # [sleepSpeedLimit=0.1] Number optional
  # [sleepTimeLimit=1] Number optional
  # [collisionFilterGroup=1] Number optional
  # [collisionFilterMask=1] Number optional
  # [fixedRotation=false] Boolean optional
  # [shape] Body optional
  # j
  # throw new Error("IMPLEMENT createPhysicsBody")

updateBodyFromComponents = (body,physical,location) ->
  pos = location.position
  vel = location.velocity
  q = location.quaternion
  ang = location.angularVelocity

  body.position.set(pos.x, pos.y, pos.z)
  body.velocity.set(vel.x, vel.y, vel.z)
  body.quaternion.set(q.x, q,y, q,z, q.w) #  TODO see how Cannon does quats
  body.angularVelocity.set(ang.x, ang,y, ang,z, ang.w) #  TODO see how Cannon does quats
  # position
  # velocity
  # quaternion
  # angularVelocity
  #
  # throw new Error("IMPLEMENT updatePhysicsBodyFromEntity")

updateComponentsFromBody = (physical,location,body) ->
  pos = body.position
  vel = body.velocity
  q = body.quaternion
  ang = body.angularVelocity
  location.position.set(pos.x, pos.y, pos.z)
  location.velocity.set(vel.x, vel.y, vel.z)
  location.quaternion.set(q.x, q,y, q,z, q.w) #  TODO see how Cannon does quats
  location.angularVelocity.set(ang.x, ang,y, ang,z, ang.w) #  TODO see how Cannon does quats

PhysicalSearcher = EntitySearch.prepare([T.Physical,T.Location])

class PhysicsSystem extends BaseSystem
  @Subscribe: [ T.PhysicsWorld ]

  process: (r) ->
    [worldComp] = r.comps

    # GET WORLD
    world = @getWorld()
    console.log world

    # ENTITIES-> PHYSiCS WORLD
    daters = []
    PhysicalSearcher.run @estore, (r) ->
      [physical, location] = r.comps
      body = world.getBodyById(physical.bodyId)
      if !body?
        body = createPhysicsBody(physical)
        physical.bodyId = body.id
        world.add body
      body._componentLinkHit = true
      updateBodyFromComponents(body,physical,location)
      daters.push [physical,location,body]
    
    # CLEANUP UNLINKED BODIES
    markedForDeath = []
    for b in world.bodies
      if !b._componentLinkHit
        markedForDeath.push b
    for b in markedForDeath
      world.remove b

    # ITERATE PHYSICS WORLD
    world.step(@input.dt)
   
    # PHYSICS WORLD -> COMPONENT
    for [physical,location,body] in daters
      updateComponentsFromBody(physical,location,body)
      

  getWorld: ->
    @_naughty_cannon_world ?= @newWorld()

  newWorld: ->
    world = new Cannon.World()
    world.broadphase = new Cannon.NaiveBroadphase()
    world

module.exports = -> new PhysicsSystem()


