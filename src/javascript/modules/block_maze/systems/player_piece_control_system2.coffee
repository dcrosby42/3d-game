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

Left90 = canQuat()
Left90.setFromAxisAngle(UpVec, Math.PI/2)

Right90 = canQuat()
Right90.setFromAxisAngle(UpVec, -(Math.PI/2))

calcCamRelativeImpulse = (camLoc, playerLoc, timeStep, force) ->
  cpos = camLoc.position
  ppos = playerLoc.position
  impulse = canVec3(ppos.x - cpos.x, 0, ppos.z - cpos.z)
  impulse.normalize()
  impulse.scale(timeStep * force, impulse)
  impulse


class PlayerPieceControlSystem extends BaseSystem
  @Subscribe: [
    [ {type:T.Tag, name:'player_piece'}, T.Location ]
    [ T.FollowCamera, T.Location]

  ]

  process: (pR, cR) ->
    [_tag,location] = pR.comps
    [camera,camLocation] = cR.comps

    eid = pR.eid

    timeStep = @input.dt

    @handleEvents eid,
      forward: (val) =>
        impulse = calcCamRelativeImpulse(camLocation,location,timeStep, ForwardForce)
        @publishEvent eid, "impulse", impulse: impulse, point: DrivePoint

      backward: =>
        impulse = calcCamRelativeImpulse(camLocation,location,timeStep, -BackwardForce)
        @publishEvent eid, "impulse", impulse: impulse, point: DrivePoint
      
      strafeLeft: =>
        impulse = calcCamRelativeImpulse(camLocation,location,timeStep, StrafeForce)
        Left90.vmult(impulse,impulse)
        @publishEvent eid, "impulse", impulse: impulse, point: DrivePoint

      strafeRight: =>
        impulse = calcCamRelativeImpulse(camLocation,location,timeStep, StrafeForce)
        Right90.vmult(impulse,impulse)
        @publishEvent eid, "impulse", impulse: impulse, point: DrivePoint

      #   impulse = canVec3(timeStep * -StrafeForce, 0, 0)
      #   # @publishEvent r.eid, "localImpulse", impulse: impulse, point: DrivePoint
      #   @publishEvent r.eid, "impulse", impulse: impulse, point: DrivePoint

      # drive: (analog) =>
      #   impulse = canVec3(0, 0, timeStep * ForwardForce * -analog)
      #   @publishEvent r.eid, "impulse", impulse: impulse, point: DrivePoint
      #
      # strafe: (analog) =>
      #   impulse = canVec3(timeStep * StrafeForce * -analog, 0, 0)
      #   @publishEvent r.eid, "impulse", impulse: impulse, point: DrivePoint
      #
      #
      # turn: (analog) =>
      #   twist = canQuat()
      #   twist.setFromAxisAngle(UpVec, -SpinRate * timeStep * analog)
      #   quaternion = location.quaternion
      #   quaternion.mult(twist,quaternion)
      #
      # strafeLeft: =>
      #   impulse = canVec3(timeStep * StrafeForce, 0, 0)
      #   # @publishEvent r.eid, "localImpulse", impulse: impulse, point: DrivePoint
      #   @publishEvent r.eid, "impulse", impulse: impulse, point: DrivePoint
      #
      # strafeRight: =>
      #   impulse = canVec3(timeStep * -StrafeForce, 0, 0)
      #   # @publishEvent r.eid, "localImpulse", impulse: impulse, point: DrivePoint
      #   @publishEvent r.eid, "impulse", impulse: impulse, point: DrivePoint
      #
      #
      # backward: =>
      #   impulse = canVec3(0, 0, timeStep * -BackwardForce)
      #   # @publishEvent r.eid, "localImpulse", impulse: impulse, point: DrivePoint
      #   @publishEvent r.eid, "impulse", impulse: impulse, point: DrivePoint
      #
      # elevate: =>
      #   impulse = canVec3(0, timeStep * AscendForce, 0)
      #   # @publishEvent r.eid, "localImpulse", impulse: impulse, point: DrivePoint
      #   @publishEvent r.eid, "impulse", impulse: impulse, point: DrivePoint
      #
      # sink: =>
      #   impulse = canVec3(0, timeStep * -AscendForce, 0)
      #   # @publishEvent r.eid, "localImpulse", impulse: impulse, point: DrivePoint
      #   @publishEvent r.eid, "impulse", impulse: impulse, point: DrivePoint
      #
      # turnRight: =>
      #   twist = canQuat()
      #   twist.setFromAxisAngle(UpVec, -SpinRate * timeStep)
      #   quaternion = location.quaternion
      #   quaternion.mult(twist,quaternion)
      #   
      # turnLeft: =>
      #   twist = canQuat()
      #   twist.setFromAxisAngle(UpVec, SpinRate * timeStep)
      #   quaternion = location.quaternion
      #   quaternion.mult(twist,quaternion)
      


module.exports = -> new PlayerPieceControlSystem()


