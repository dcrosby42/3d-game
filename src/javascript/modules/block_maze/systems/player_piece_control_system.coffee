BaseSystem = require '../../../lib/ecs/base_system'
C = require '../components'
T = C.Types

{vec3,quat,euler} = require '../../../lib/three_helpers'

UpVec = vec3(0,1,0)

DrivePoint = vec3(0,0,0) # where to apply impulses on body
ForwardForce = 25
BackwardForce = 25
StrafeForce = 25
AscendForce = 25
JumpThrust = 50

OrbitSpeed = 1 * Math.PI

Left90 = quat()
Left90.setFromAxisAngle(UpVec, Math.PI/2)

Right90 = quat()
Right90.setFromAxisAngle(UpVec, -(Math.PI/2))

calcCamRelativeImpulse = (camLoc, playerLoc, timeStep, force) ->
  cpos = camLoc.position
  ppos = playerLoc.position
  impulse = vec3(ppos.x - cpos.x, 0, ppos.z - cpos.z)
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

      orbitRight: =>
        camera.hOrbit += -OrbitSpeed * timeStep

      orbitLeft: =>
        camera.hOrbit += OrbitSpeed * timeStep

      orbitUp: =>
        camera.vOrbit += -OrbitSpeed * timeStep
        if camera.vOrbit < -Math.PI/2
          camera.vOrbit = -Math.PI/2 + 0.01

      orbitDown: =>
        camera.vOrbit += OrbitSpeed * timeStep
        if camera.vOrbit > 0
          camera.vOrbit = 0

      jump: =>
        impulse = vec3(0, JumpThrust * timeStep, 0)
        @publishEvent eid, "impulse", impulse: impulse, point: DrivePoint


      # GAMEPAD:

      drive: (analog) =>
        impulse = calcCamRelativeImpulse(camLocation,location,timeStep, -analog*ForwardForce)
        @publishEvent eid, "impulse", impulse: impulse, point: DrivePoint

      strafe: (analog) =>
        impulse = calcCamRelativeImpulse(camLocation,location,timeStep, -analog*StrafeForce)
        Left90.vmult(impulse,impulse)
        @publishEvent eid, "impulse", impulse: impulse, point: DrivePoint

      orbitX: (analog) =>
        camera.hOrbit += -analog *OrbitSpeed * timeStep

      orbitY: (analog) =>
        camera.vOrbit += analog * OrbitSpeed * timeStep
        if camera.vOrbit < -Math.PI/2
          camera.vOrbit = -Math.PI/2 + 0.01
        else if camera.vOrbit > 0
          camera.vOrbit = 0


module.exports = -> new PlayerPieceControlSystem()


