Cannon = require 'cannon'

{euler,vec3,quat, convertCannonVec3, convertCannonQuat} = require '../../lib/three_helpers'
{canVec3,canQuat} = require '../../lib/cannon_helpers'

convertedPosAndQuat = (location) ->
  pos = convertCannonVec3(location.position)
  quat = convertCannonQuat(location.quaternion)
  [pos,quat]

updateViewPosAndQuat = (view,pos,quat) ->
  view.position.set(pos.x,pos.y,pos.z)
  view.quaternion.set(quat.x,quat.y,quat.z,quat.w)


class Kindness
  createBody: (physical,location) ->
    throw new Error("Kind #{@constructor.name} needs to implement @createBody")

  updateBody: (body,physical,location) ->
    pos = location.position
    vel = location.velocity
    quat = location.quaternion
    body.position.set(pos.x, pos.y, pos.z)
    body.velocity.set(vel.x, vel.y, vel.z)
    body.quaternion.set(quat.x, quat.y, quat.z, quat.w)
    null

  createView: (physical,location) ->
    throw new Error("Kind #{@constructor.name} needs to implement @createView")

  updateView: (view,physical,location) ->
    if physical.bodyType? and physical.bodyType != Cannon.DYNAMIC
      return
    [pos,quat] = convertedPosAndQuat(location)
    updateViewPosAndQuat(view,pos,quat)
    null

module.exports = Kindness
