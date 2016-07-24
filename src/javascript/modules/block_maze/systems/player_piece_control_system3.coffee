BaseSystem = require '../../../lib/ecs/base_system'
C = require '../components'
T = C.Types

FrameRate = 60/1000

# {vec3,quat,euler} = require '../../../lib/three_helpers'
{canVec3,canQuat} = require '../../../lib/cannon_helpers'

UpVec = canVec3(0,1,0)

DrivePoint = canVec3(0,0,0) # where to apply impulses on body
ForwardForce = 500
BackwardForce = 500
StrafeForce = 500
AscendForce = 500

# ForwardAccel = canVec3(0,0, 0.1*FrameRate)
# BackwardAccel = canVec3(0,0, -0.1*FrameRate)

AscendAccel = canVec3(0, 0.1*FrameRate, 0)
DescendAccel = canVec3(0, -0.1*FrameRate, 0)

StrafeRightAccel = canVec3(-0.1*FrameRate, 0, 0)
StrafeLeftAccel = canVec3(0.1*FrameRate, 0, 0)

SpinRate = FrameRate * (Math.PI / 24)
LeftSpin = canQuat().setFromAxisAngle(UpVec, -Math.PI / 24)
RightSpin = canQuat().setFromAxisAngle(UpVec, Math.PI / 24)

boostVelocity = (velocity,vec,quaternion,dt) ->
  boost = vec.scale(dt)
  quaternion.vmult(boost,boost)
  velocity.vadd(boost,velocity)

debug = (args...) ->
  console.log "PlayerPieceControlSystem3", args...

class PlayerPieceControlSystem extends BaseSystem
  @Subscribe: [ {type:T.Tag, name:'player_piece'}, T.Location ]

  process: (r) ->
    [_tag,location] = r.comps
    velocity = location.velocity
    quaternion = location.quaternion

    timeStep = @input.dt / 1000

    @handleEvents r.eid,
      strafeLeftPressed: =>
        impulse = canVec3(timeStep * StrafeForce, 0, 0)
        @publishEvent r.eid, "localImpulse", impulse: impulse, point: DrivePoint

      strafeRightPressed: =>
        impulse = canVec3(timeStep * -StrafeForce, 0, 0)
        @publishEvent r.eid, "localImpulse", impulse: impulse, point: DrivePoint

      forwardPressed: =>
        impulse = canVec3(0, 0, timeStep * ForwardForce)
        @publishEvent r.eid, "localImpulse", impulse: impulse, point: DrivePoint

      backwardPressed: =>
        impulse = canVec3(0, 0, timeStep * -BackwardForce)
        @publishEvent r.eid, "localImpulse", impulse: impulse, point: DrivePoint

      elevatePressed: =>
        impulse = canVec3(0, timeStep * AscendForce, 0)
        @publishEvent r.eid, "localImpulse", impulse: impulse, point: DrivePoint

      sinkPressed: =>
        impulse = canVec3(0, timeStep * -AscendForce, 0)
        @publishEvent r.eid, "localImpulse", impulse: impulse, point: DrivePoint

      turnRight: =>
        twist = canQuat()
        twist.setFromAxisAngle(UpVec, -SpinRate * @input.dt)
        quaternion.mult(twist,quaternion)
        
      turnLeft: =>
        twist = canQuat()
        twist.setFromAxisAngle(UpVec, SpinRate * @input.dt)
        quaternion.mult(twist,quaternion)


module.exports = -> new PlayerPieceControlSystem()


