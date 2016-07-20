BaseSystem = require '../../../lib/ecs/base_system'
C = require '../components'
T = C.Types

XAccel = YAccel = ZAccel = 0.01

class PlayerPieceControlSystem extends BaseSystem
  @Subscribe: [ {type:T.Tag, name:'player_piece'}, T.Velocity ]

  process: (r) ->
    [_tag,velComp] = r.comps
    velocity = velComp.velocity

    @handleEvents r.eid,
      left: ->
        velocity.x -= XAccel
      right: ->
        velocity.x += XAccel
      up: ->
        velocity.z -= ZAccel
      down: ->
        velocity.z += ZAccel
      elevate: ->
        velocity.y += YAccel
      sink: ->
        velocity.y -= YAccel


module.exports = -> new PlayerPieceControlSystem()


