BaseSystem = require '../../../lib/ecs/base_system'
C = require '../components'
T = C.Types

{canVec3,canQuat} = require '../../../lib/cannon_helpers'

UpVec = canVec3(0,1,0)

DrivePoint = canVec3(0,0,0) # where to apply impulses on body
ForwardForce = 50
BackwardForce = 50
StrafeForce = 50
AscendForce = 50

SpinRate = 2 * Math.PI


class CameraFollowSystem extends BaseSystem
  @Subscribe: [
    [ T.FollowCamera, T.Location]
    [ {type:T.Tag, name:'player_piece'}, T.Location ]
  ]

  process: (cR, pR) ->
    [camera,camLocation] = cR.comps
    [_tag,location] = pR.comps

    eid = cR.eid

    timeStep = @input.dt

    cpos = camLocation.position
    ppos = location.position


    stick = canVec3(0,0,5)
    twist = canQuat()
    twist.setFromAxisAngle(canVec3(1,0,0), camera.vOrbit)
    twist.vmult(stick,stick)

    twist = canQuat()
    twist.setFromAxisAngle(UpVec, camera.hOrbit)
    twist.vmult(stick,stick)

    # quaternion = location.quaternion
    # quaternion.mult(twist,quaternion)

    ppos.vadd(stick, cpos)
    # FIXME: use camera orbit
    # cpos.set(ppos.x, ppos.y+3, ppos.z+5)

    camera.lookAt.copy(ppos)
    # console.log camera.hOrbit, camera.vOrbit

module.exports = -> new CameraFollowSystem()


