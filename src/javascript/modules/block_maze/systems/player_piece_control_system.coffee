BaseSystem = require '../../../lib/ecs/base_system'
C = require '../components'
T = C.Types

# {vec3,quat,euler} = require '../../../lib/three_helpers'
{canVec3,canQuat} = require '../../../lib/cannon_helpers'

UpVec = canVec3(0,1,0)

DrivePoint = canVec3(0,0,0) # where to apply impulses on body
ForwardForce = 50
BackwardForce = 50
StrafeForce = 50
AscendForce = 50

SpinRate = 2 * Math.PI


class PlayerPieceControlSystem extends BaseSystem
  @Subscribe: [ {type:T.Tag, name:'player_piece'}, T.Location ]

  process: (r) ->
    [_tag,location] = r.comps

    timeStep = @input.dt / 1000

    @handleEvents r.eid,
      strafeLeft: =>
        impulse = canVec3(timeStep * StrafeForce, 0, 0)
        # @publishEvent r.eid, "localImpulse", impulse: impulse, point: DrivePoint
        @publishEvent r.eid, "impulse", impulse: impulse, point: DrivePoint

      strafeRight: =>
        impulse = canVec3(timeStep * -StrafeForce, 0, 0)
        # @publishEvent r.eid, "localImpulse", impulse: impulse, point: DrivePoint
        @publishEvent r.eid, "impulse", impulse: impulse, point: DrivePoint

      forward: =>
        impulse = canVec3(0, 0, timeStep * ForwardForce)
        # @publishEvent r.eid, "localImpulse", impulse: impulse, point: DrivePoint
        @publishEvent r.eid, "impulse", impulse: impulse, point: DrivePoint

      backward: =>
        impulse = canVec3(0, 0, timeStep * -BackwardForce)
        # @publishEvent r.eid, "localImpulse", impulse: impulse, point: DrivePoint
        @publishEvent r.eid, "impulse", impulse: impulse, point: DrivePoint

      elevate: =>
        impulse = canVec3(0, timeStep * AscendForce, 0)
        # @publishEvent r.eid, "localImpulse", impulse: impulse, point: DrivePoint
        @publishEvent r.eid, "impulse", impulse: impulse, point: DrivePoint

      sink: =>
        impulse = canVec3(0, timeStep * -AscendForce, 0)
        # @publishEvent r.eid, "localImpulse", impulse: impulse, point: DrivePoint
        @publishEvent r.eid, "impulse", impulse: impulse, point: DrivePoint

      turnRight: =>
        twist = canQuat()
        twist.setFromAxisAngle(UpVec, -SpinRate * timeStep)
        quaternion = location.quaternion
        quaternion.mult(twist,quaternion)
        
      turnLeft: =>
        twist = canQuat()
        twist.setFromAxisAngle(UpVec, SpinRate * timeStep)
        quaternion = location.quaternion
        quaternion.mult(twist,quaternion)


module.exports = -> new PlayerPieceControlSystem()


