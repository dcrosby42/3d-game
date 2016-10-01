BaseSystem = require '../../../lib/ecs/base_system'
C = require '../components'
T = C.Types
Objects = require "../objects"

class SyncFromSceneSystem extends BaseSystem
  @Subscribe: [T.Physical,T.Location]

  process: (r) ->
    # The "scene updates" arrive as input with a back reference to the actual Physijs scene.
    scene = @input.scene
    if !scene?
      return

    [physical, location] = r.comps
    return if physical.shapeType == Objects.ShapeType.Static

    shape = scene.getObjectById(physical.shapeId)
    if shape?
      Objects.updateFrom3DShape(shape, physical,location)
    else
      console.log "!! SyncFromSceneSystem: no shape found for physical.shapeId=#{physical.shapeId}"


module.exports = -> new SyncFromSceneSystem()
