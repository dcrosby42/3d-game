BT = require './base_types'
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
   velocity: BT.Vec
   quaternion: BT.Quat
   angularVelocity: BT.Vec
   dirtyPosition: BT.Bool
   dirtyRotation: BT.Bool
  
 Physical:
   bodyId: BT.Number
   viewId: BT.Number
   kind: BT.String
   bodyType: BT.Number
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

 FollowCamera:
   followingTag: BT.String
   lookAt: BT.Vec
   hOrbit: BT.Number
   vOrbit: BT.Number

 PhysicsWorld:
   worldId: BT.Number

 Controller:
   inputName: BT.String
   states: BT.Obj.with(default: "{}")

   
   
module.exports = Defs
