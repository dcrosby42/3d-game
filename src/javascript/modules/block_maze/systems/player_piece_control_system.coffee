BaseSystem = require '../../../lib/ecs/base_system'
C = require '../components'
T = C.Types

{vec3,quat,euler} = require '../../../lib/three_helpers'

UpVec = vec3(0,1,0)

XAccel = YAccel = ZAccel = 0.01

AccelVec = vec3(0,0,ZAccel)

LeftSpin = quat().setFromAxisAngle(UpVec, Math.PI / 24)
RightSpin = quat().setFromAxisAngle(UpVec, -Math.PI / 24)

class PlayerPieceControlSystem extends BaseSystem
  @Subscribe: [ {type:T.Tag, name:'player_piece'}, T.Velocity, T.Rotation ]

  process: (r) ->
    [_tag,velComp, rotComp] = r.comps
    velocity = velComp.velocity
    rotation = rotComp.rotation

    @handleEvents r.eid,
      strafeLeft: ->
        velocity.x -= XAccel
      strafeRight: ->
        velocity.x += XAccel
      forward: ->
        velocity.add(AccelVec.clone().applyQuaternion(rotation))
        # velocity.z -= ZAccel
      backward: ->
        # velocity.z += ZAccel
        velocity.sub(AccelVec.clone().applyQuaternion(rotation))
      elevate: ->
        velocity.y += YAccel
      sink: ->
        velocity.y -= YAccel
      turnRight: ->
        rotation.multiply(RightSpin)
        # console.log "turnRight", rotation
      turnLeft: ->
        rotation.multiply(LeftSpin)
        # console.log "turnLeft", rotation



module.exports = -> new PlayerPieceControlSystem()


