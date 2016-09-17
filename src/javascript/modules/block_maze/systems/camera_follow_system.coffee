BaseSystem = require '../../../lib/ecs/base_system'
C = require '../components'
T = C.Types

{vec3,quat,euler} = require '../../../lib/three_helpers'

UpVec = vec3(0,1,0)

DrivePoint = vec3(0,0,0) # where to apply impulses on body
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


    stick = vec3(0,0,5)
    twist = quat()
    twist.setFromAxisAngle(vec3(1,0,0), camera.vOrbit)
    stick.applyQuaternion(twist)

    twist = quat()
    twist.setFromAxisAngle(vec3(0,1,0), camera.hOrbit)
    stick.applyQuaternion(twist)
    # twist.multiplyVector3(stick)

    # quaternion = location.quaternion
    # quaternion.mult(twist,quaternion)
    
    cpos.addVectors(ppos, stick)
    # ppos.clone().add(stick)
    # ppos.vadd(stick, cpos)
    # FIXME: use camera orbit
    # cpos.set(ppos.x, ppos.y+3, ppos.z+5)

    camera.lookAt.set(ppos.x, ppos.y, ppos.z)
    # console.log camera.hOrbit, camera.vOrbit

module.exports = -> new CameraFollowSystem()


