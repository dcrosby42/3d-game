BaseSystem = require '../../../lib/ecs/base_system'
C = require '../components'
T = C.Types

FrameRate = 60/1000

# {vec3,quat,euler} = require '../../../lib/three_helpers'
{canVec3,canQuat} = require '../../../lib/cannon_helpers'

UpVec = canVec3(0,1,0)

ForwardAccel = canVec3(0,0, 0.01*FrameRate)
BackwardAccel = canVec3(0,0, -0.01*FrameRate)

AscendAccel = canVec3(0, 0.01*FrameRate, 0)
DescendAccel = canVec3(0, -0.01*FrameRate, 0)

StrafeRightAccel = canVec3(-0.01*FrameRate, 0, 0)
StrafeLeftAccel = canVec3(0.01*FrameRate, 0, 0)

SpinRate = FrameRate * (Math.PI / 24)
LeftSpin = canQuat().setFromAxisAngle(UpVec, -Math.PI / 24)
RightSpin = canQuat().setFromAxisAngle(UpVec, Math.PI / 24)

boostVelocity = (velocity,vec,quaternion,dt) ->
  boost = vec.scale(dt)
  quaternion.vmult(boost,boost)
  velocity.vadd(boost,velocity)

debug = (args...) ->
  console.log "PlayerPieceControlSystem", args...

class PlayerPieceControlSystem extends BaseSystem
  @Subscribe: [ {type:T.Tag, name:'player_piece'}, T.Location ]

  process: (r) ->
    [_tag,location] = r.comps
    velocity = location.velocity
    quaternion = location.quaternion

    @handleEvents r.eid,
      strafeLeft: =>
        # debug "strafeLeft before boost vel",velocity
        boostVelocity velocity, StrafeLeftAccel, quaternion, @input.dt
        # debug "strafeLeft after boost vel",velocity
      strafeRight: =>
        boostVelocity velocity, StrafeRightAccel, quaternion, @input.dt
      forward: =>
        boostVelocity velocity, ForwardAccel, quaternion, @input.dt
      backward: =>
        # velocity.add(BackwardAccel.clone().multiplyScalar(@input.dt).applyQuaternion(rotation))
        boostVelocity velocity, BackwardAccel, quaternion, @input.dt
      elevate: =>
        # velocity.add(AscendAccel.clone().multiplyScalar(@input.dt))#.applyQuaternion(rotation))
        boostVelocity velocity, AscendAccel, quaternion, @input.dt
      sink: =>
        # velocity.add(DescendAccel.clone().multiplyScalar(@input.dt))#.applyQuaternion(rotation))
        boostVelocity velocity, DescendAccel, quaternion, @input.dt
        # velocity.y -= YAccel
      turnRight: =>
        twist = canQuat()
        twist.setFromAxisAngle(UpVec, -SpinRate * @input.dt)
        quaternion.mult(twist,quaternion)
        # rotation.multiply(quat().setFromAxisAngle(UpVec, -SpinRate * @input.dt))
      turnLeft: =>
        twist = canQuat()
        twist.setFromAxisAngle(UpVec, SpinRate * @input.dt)
        quaternion.mult(twist,quaternion)
        # rotation.multiply(quat().setFromAxisAngle(UpVec, SpinRate * @input.dt))



module.exports = -> new PlayerPieceControlSystem()


