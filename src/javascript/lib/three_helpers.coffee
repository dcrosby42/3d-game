Three = require 'three'
exports.euler = (args...) -> new Three.Euler(args...)
exports.vec3 = (args...) -> new Three.Vector3(args...)
exports.quat = (args...) -> new Three.Quaternion(args...)
