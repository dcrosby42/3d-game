Three = require 'three'
exports.euler = (args...) -> new Three.Euler(args...)
exports.vec3 = (args...) -> new Three.Vector3(args...)
exports.quat = (args...) -> new Three.Quaternion(args...)
exports.convertCannonVec3 = (cv3) -> new Three.Vector3(cv3.x, cv3.y, cv3.z)
exports.convertCannonQuat = (cq) -> new Three.Quaternion(cq.x, cq.y, cq.z, cq.w)
