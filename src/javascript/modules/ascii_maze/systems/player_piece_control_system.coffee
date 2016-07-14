BaseSystem = require '../../../lib/ecs/base_system'
C = require '../components'
T = C.Types

VAccel = 0.1
HAccel = VAccel

class PlayerPieceControlSystem extends BaseSystem
  @Subscribe: [ {type:T.Tag, name:'player_piece'}, T.Velocity ]

  process: (r) ->
    [tag,velocity] = r.comps

    @handleEvents r.eid,
      left: ->
        velocity.x -= HAccel
      right: ->
        velocity.x += HAccel
      up: ->
        velocity.y -= VAccel
      down: ->
        velocity.y += VAccel

module.exports = -> new PlayerPieceControlSystem()


