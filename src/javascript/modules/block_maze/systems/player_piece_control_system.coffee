BaseSystem = require '../../../lib/ecs/base_system'
C = require '../components'
T = C.Types

VAccel = 0.01
HAccel = VAccel

class PlayerPieceControlSystem extends BaseSystem
  @Subscribe: [ {type:T.Tag, name:'player_piece'}, T.Velocity ]

  process: (r) ->
    [tag,velComp] = r.comps
    velocity = velComp.velocity

    @handleEvents r.eid,
      left: ->
        velocity.x -= HAccel
      right: ->
        velocity.x += HAccel
      up: ->
        velocity.z -= VAccel
      down: ->
        velocity.z += VAccel

module.exports = -> new PlayerPieceControlSystem()


