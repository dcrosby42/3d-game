BaseSystem = require '../../../lib/ecs/base_system'
C = require '../components'
T = C.Types

FrameRate = 60/1000

{vec3,quat,euler} = require '../../../lib/three_helpers'

UpVec = vec3(0,1,0)

ForwardAccel = vec3(0,0, 0.01*FrameRate)
BackwardAccel = vec3(0,0, -0.01*FrameRate)

AscendAccel = vec3(0, 0.01*FrameRate, 0)
DescendAccel = vec3(0, -0.01*FrameRate, 0)

StrafeRightAccel = vec3(-0.01*FrameRate, 0, 0)
StrafeLeftAccel = vec3(0.01*FrameRate, 0, 0)

SpinRate = FrameRate * (Math.PI / 24)
LeftSpin = quat().setFromAxisAngle(UpVec, -Math.PI / 24)
RightSpin = quat().setFromAxisAngle(UpVec, Math.PI / 24)


class PlayerPieceControlSystem extends BaseSystem
  @Subscribe: [ {type:T.Tag, name:'player_piece'}, T.Velocity, T.Rotation ]

  process: (r) ->
    # console.log @input.dt
    [_tag,velComp, rotComp] = r.comps
    velocity = velComp.velocity
    rotation = rotComp.rotation

    @handleEvents r.eid,
      strafeLeft: =>
        # TODO: using CANNON vecs/quats:
        # boost = StrafeLeftAccel.scale(@input.dt)
        # quaternion.vmult(boost,boost)
        # velocity.vadd(boost,velocity)
        velocity.add(StrafeLeftAccel.clone().multiplyScalar(@input.dt).applyQuaternion(rotation)) #XXX
      strafeRight: =>
        velocity.add(StrafeRightAccel.clone().multiplyScalar(@input.dt).applyQuaternion(rotation))
      forward: =>
        velocity.add(ForwardAccel.clone().multiplyScalar(@input.dt).applyQuaternion(rotation))
      backward: =>
        velocity.add(BackwardAccel.clone().multiplyScalar(@input.dt).applyQuaternion(rotation))
      elevate: =>
        velocity.add(AscendAccel.clone().multiplyScalar(@input.dt))#.applyQuaternion(rotation))
      sink: =>
        velocity.add(DescendAccel.clone().multiplyScalar(@input.dt))#.applyQuaternion(rotation))
        # velocity.y -= YAccel
      turnRight: =>
        rotation.multiply(quat().setFromAxisAngle(UpVec, -SpinRate * @input.dt))
      turnLeft: =>
        rotation.multiply(quat().setFromAxisAngle(UpVec, SpinRate * @input.dt))



module.exports = -> new PlayerPieceControlSystem()


