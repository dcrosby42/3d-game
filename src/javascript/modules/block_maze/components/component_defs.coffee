BT = require './base_types'
Defs =
 Location:
   position: BT.Vec
   velocity: BT.Vec
   quaternion: BT.Quat
   angularVelocity: BT.Vec
 Physical:
   bodyId: BT.Number
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
   states: BT.Obj
   
   
module.exports = Defs
