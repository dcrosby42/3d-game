Cannon = require 'cannon'
exports.canVec3 = (x,y,z) -> new Cannon.Vec3(x,y,z)
exports.canQuat = (x,y,z,w) -> new Cannon.Quaternion(x,y,z,w)
exports.canVec3Equals = (a,b) -> a.x == b.x and a.y == b.y and a.z == b.z
exports.canQuatEquals = (a,b) -> a.x == b.x and a.y == b.y and a.z == b.z and a.w == b.w
