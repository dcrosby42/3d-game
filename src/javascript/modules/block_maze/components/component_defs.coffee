BT = require './base_types'
Objects = require '../objects'
Defs =
 Name:
   name: BT.String

 Tag:
   name: BT.String

 Timer:
   time: BT.Number
   eventName: BT.String

 Rng:
   state: BT.Number.with(default:"1")

 Location:
   position: BT.Vec
   positionDirty: BT.Bool.with(default: "true")
   quaternion: BT.Quat
   quaternionDirty: BT.Bool.with(default: "true")
   velocity: BT.Vec
   velocityDirty: BT.Bool.with(default: "true")
   angularVelocity: BT.Vec
   angularVelocityDirty: BT.Bool.with(default: "true")
   impulse: BT.Comp
   _inner:
     Impulse:
       force: BT.Vec
       offset: BT.Vec
  
 Physical:
   shapeId: BT.Number
   kind: BT.String
   shapeType: BT.Number.with(default: "#{Objects.ShapeType.Dynamic}")
   receiveCollisions: BT.Bool
   data: BT.Comp
   _inner:
     Cube:
       color: BT.Color
     Plane:
       color: BT.Color
       width: BT.Number
       height: BT.Number
     Ball:
       color: BT.Color
       radius: BT.Number
     Block:
       color: BT.Color
       dim: BT.Vec
     PacMap:
       mapName: BT.String
     

 FollowCamera:
   followingTag: BT.String
   lookAt: BT.Vec
   followDistance: BT.Number.with(default: "5")
   hOrbit: BT.Number
   vOrbit: BT.Number

#  PhysicsWorld:
#    worldId: BT.Number

 Controller:
   inputName: BT.String
   states: BT.Obj.with(default: "{}")

   
   
module.exports = Defs
