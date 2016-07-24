BaseSystem = require '../../../lib/ecs/base_system'
C = require '../components'
T = C.Types
{canVec3} = require '../../../lib/cannon_helpers'

EntitySearch = require '../../../lib/ecs/entity_search'

Cannon = require 'cannon'

createPhysicsBody = (physical) ->
  body = new Cannon.Body()

  switch physical.kind
    when 'cube'
      shape = new Cannon.Box(canVec3(0.5, 0.5, 0.5)) # TODO use physical.data.width/2 etc
      body.addShape(shape)
      body.linearDamping = 0.0
      # body.angularDamping = 0.5
      body.mass = 2
      body.velocity.set(1,0,0)
      body.addEventListener "sleepy", (event) =>
        console.log("The body is feeling sleepy...")
      body.addEventListener "sleep", (event) =>
        console.log("The body fell asleep!")

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

updateBodyFromComponents = (body,location) ->
  return
  pos = location.position
  # vel = location.velocity
  # console.log "updateBodyFromComponents", vel
  # q = location.quaternion
  # ang = location.angularVelocity

  body.position.set(pos.x, pos.y, pos.z)
  # body.velocity.set(vel.x, vel.y, vel.z)
  # console.log "updateBodyFromComponents body.vel", body.velocity
  # body.quaternion.set(q.x, q.y, q.z, q.w) #  TODO see how Cannon does quats
  # body.angularVelocity.set(ang.x, ang.y, ang.z, ang.w) #  TODO see how Cannon does quats
  # position
  # velocity
  # quaternion
  # angularVelocity
  #
  # throw new Error("IMPLEMENT updatePhysicsBodyFromEntity")

updateComponentsFromBody = (location,body) ->
  pos = body.position
  # vel = body.velocity
  # q = body.quaternion
  # ang = body.angularVelocity
  location.position.set(pos.x, pos.y, pos.z)
  # console.log "updated location position x", location.position.x
  # location.velocity.set(vel.x, vel.y, vel.z)
  
  # console.log "updateBodyFromComponents location.vel", location.velocity
  # console.log "updateBodyFromComponents location.position", location.position

  # location.quaternion.set(q.x, q.y, q.z, q.w) #  TODO see how Cannon does quats
  # location.angularVelocity.set(ang.x, ang.y, ang.z, ang.w) #  TODO see how Cannon does quats

PhysicalSearcher = EntitySearch.prepare([T.Physical,T.Location])

class PhysicsSystem extends BaseSystem
  @Subscribe: [ T.PhysicsWorld ]

  _process: (r) ->
    return if @_debug_i? and @_debug_i >= 200
    @_debug_i ?= 0
    @_debug_i += 1

    if !@_debug_world
      @_debug_world = new Cannon.World()
      @_debug_world.broadphase = new Cannon.NaiveBroadphase()
      console.log "Created new world:", @_debug_world
    world = @_debug_world

    timeStep = 1.0 / 60.0

    if !@_debug_body
      mass = 5
      radius = 1
      sphereShape = new Cannon.Sphere(radius)
      boxShape = new Cannon.Box(new Cannon.Vec3(1,1,1))
      sphereBody = new Cannon.Body(mass: mass, shape: boxShape)
      sphereBody.position.set(0,0,4)
      sphereBody.linearDamping = 0.5
      world.add(sphereBody)
      @_debug_body = sphereBody
      console.log "Created new body: ",@_debug_body

      groundShape = new Cannon.Plane()
      groundBody = new Cannon.Body(mass: 0, shape: groundShape)
      world.add(groundBody)

      pt = new Cannon.Vec3(0,0,0)
      impulse = new Cannon.Vec3(500 * timeStep, 0, 0)
      sphereBody.applyLocalImpulse(impulse,pt)
      @_debug_i

    body = @_debug_body

    world.step(timeStep)

    pos = body.position
    console.log("body position", pos)

# for i in [0...120]
#   pt = new Cannon.Vec3(0,0,0)
#   impulse = new Cannon.Vec3(500 * timeStep, 0, 0)
#   sphereBody.applyLocalImpulse(impulse,pt)


  process: (r) ->
    [worldComp] = r.comps

    # GET WORLD
    world = @getWorld()
    window.world = world
    # console.log world

    # ENTITIES-> PHYSiCS WORLD
    daters = []
    PhysicalSearcher.run @estore, (r) ->
      [physical, location] = r.comps
      body = world.getBodyById(physical.bodyId)
      if !body?
        body = createPhysicsBody(physical)
        physical.bodyId = body.id
        world.add body
        console.log "Added body",body
        window.body = body
        console.log "Updated Physical comp",physical
      body._componentLinkHit = true
      updateBodyFromComponents(body,location)
      daters.push [physical,location,body]
    
    # CLEANUP UNLINKED BODIES
    markedForDeath = []
    for b in world.bodies
      if !b._componentLinkHit
        markedForDeath.push b
    for b in markedForDeath
      console.log "Removing body from world",body
      world.remove b


    timeStep = @input.dt / 1000 # @input.dt is provided as fractional millis, eg, 16.6666

    # ITERATE PHYSICS WORLD
    # b = world.getBodyById(0)
    # f = 500
    # imp = canVec3(0,0, f * 500)
    # pt = canVec3(0,0,0)
    # b.applyLocalImpulse(imp,pt)
    # console.log b
    # console.log world.getBodyById(0).applyLocalImpulse
            # var worldPoint = new CANNON.Vec3(0,0,0);
            # var impulse = new CANNON.Vec3(f*dt,0,0);
            # body.applyLocalImpulse(impulse,worldPoint);
    # console.log "world.step", timeStep
    world.step(timeStep)

    # console.log world.getBodyById(0).position
   
    # PHYSICS WORLD -> COMPONENT
    for [physical,location,body] in daters
      updateComponentsFromBody(location,body)
      

  getWorld: ->
    @_naughty_cannon_world ?= @newWorld()

  newWorld: ->
    world = new Cannon.World()
    world.broadphase = new Cannon.NaiveBroadphase()
    world

module.exports = -> new PhysicsSystem()


