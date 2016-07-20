BaseSystem = require '../../../lib/ecs/base_system'
C = require '../components'
T = C.Types

MaxHVel = 3
MaxYVel = 3

Bounds =
  top: 0
  bottom: 10-1
  left: 0
  right: 20-1
  ceiling: 5
  floor: 0


class BoxedMovementSystem extends BaseSystem
  @Subscribe: [ {type:T.Tag, name:'player_piece'}, T.Velocity, T.Position ]

  process: (r) ->
    [tag,velComp,posComp] = r.comps
    position = posComp.position
    velocity = velComp.velocity

    position.x += velocity.x
    if position.x > Bounds.right
      position.x = Bounds.right
      velocity.x = 0
    else if position.x < Bounds.left
      position.x = Bounds.left
      velocity.x = 0

    position.y += velocity.y
    if position.y > Bounds.ceiling
      position.y = Bounds.ceiling
      velocity.y = 0
    else if position.y < Bounds.floor
      position.y = Bounds.floor
      velocity.y = 0
    
    position.z += velocity.z
    if position.z > Bounds.bottom
      position.z = Bounds.bottom
      velocity.z = 0
    else if position.z < Bounds.top
      position.z = Bounds.top
      velocity.z = 0

module.exports = -> new BoxedMovementSystem()


