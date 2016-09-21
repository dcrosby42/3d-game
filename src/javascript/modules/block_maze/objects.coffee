React = require 'react'
Cannon = require 'cannon'
THREE = require 'three'
Physijs = require '../../vendor/physijs_wrapper'

{euler,vec3,quat} = require '../../lib/three_helpers'

Data = require './data'

Bodies = {}
Views = {}
ViewUpdaters = {}

Kindness = class Kindness
  createShape: (physical,location) ->
    throw new Error("Kind #{@constructor.name} needs to implement @createShape")

  updateShape: (shape,physical,location) ->
    return if physical.bodyType == 0# "static" ... TODO define this in a shared location 
    pos = location.position
    vel = location.velocity
    quat = location.quaternion

    shape.position.set(pos.x, pos.y, pos.z)
    shape.quaternion.set(quat.x, quat.y, quat.z, quat.w)

    shape.setLinearVelocity(vel) # ASYNC! this gets posted as a message to physijs worker
    # TODO shape.setAngularVelocity(location.angularVelocity # ASYNC! this gets posted as a message to physijs worker)

    null

  # XXX:
  # createBody: (physical,location) ->
  #   throw new Error("Kind #{@constructor.name} needs to implement @createBody")
  #
  # updateBody: (body,physical,location) ->
  #   pos = location.position
  #   vel = location.velocity
  #   quat = location.quaternion
  #   body.position.set(pos.x, pos.y, pos.z)
  #   body.velocity.set(vel.x, vel.y, vel.z)
  #   body.quaternion.set(quat.x, quat.y, quat.z, quat.w)
  #   null
  #
  # createView: (physical,location) ->
  #   throw new Error("Kind #{@constructor.name} needs to implement @createView")
  #
  #
  # updateView: (view,physical,location) ->
  #   if physical.bodyType? and physical.bodyType != Cannon.DYNAMIC
  #     return
  #   [pos,quat] = convertedPosAndQuat(location)
  #   updateViewPosAndQuat(view,pos,quat)
  #   null

newGroup = (pos,quat) ->
  group = new THREE.Group()
  group.position.set(pos.x,pos.y,pos.z)
  group.quaternion.set(quat.x,quat.y,quat.z,quat.w)
  group

# updateViewPosAndQuat = (view,pos,quat) ->
#   view.position.set(pos.x,pos.y,pos.z)
#   view.quaternion.set(quat.x,quat.y,quat.z,quat.w)


class Ball extends Kindness
  createShape: (physical,location) ->
    pos = location.position
    quat = location.quaternion

    mass = 2
    friction = 0.8 # physijs default
    restitution = 0.2 # physijs default
    linearDamping = 0.1
    angularDamping = 0.3

    geometry = new THREE.SphereGeometry(0.5, 10, 10)
    threeMaterial = new THREE.MeshPhongMaterial(color: physical.data.color)
    material = Physijs.createMaterial(threeMaterial, friction, restitution)
    shape = new Physijs.SphereMesh( geometry, material, mass)
    shape.castShadow = true
    shape.receiveShadow = true
    shape.position.set(pos.x, pos.y, pos.z)
    console.log "objects.Ball createShape pos, shape.position",pos,shape.position#.set(pos.x, pos.y, pos.z)

    shape.setDamping(linearDamping, angularDamping)

    @updateShape(shape,physical,location)
    shape

class Cube extends Kindness
  createBody: (physical,location) ->
    shape = new Cannon.Box(new Cannon.Vec3(0.5,0.5,0.5)) # TODO get dimensions from physical comp
    pos = location.position
    body = new Cannon.Body(mass: 0.5, shape: shape)
    body.linearDamping = 0.1
    body.angularDamping = 0.1
    body.position.set(pos.x, pos.y, pos.z)
    # body.position.set(0,0,4)
    # body.linearDamping = 0.0
    # body.velocity.set(1,0,0)
    body

  # updateBody: (body,physical,location) ->

  createView: (physical,location) ->
    [pos,quat] = convertedPosAndQuat(location)
    group = newGroup(pos,quat)
    geometry = new THREE.BoxGeometry(1,1,1, 10, 10)
    material = new THREE.MeshPhongMaterial(color: physical.data.color)
    mesh = new THREE.Mesh(geometry, material)
    mesh.castShadow = true
    mesh.receiveShadow = true
    group.add mesh
    return group

  # updateView: (view,physical,location) ->

class Block extends Kindness
  createShape: (physical,location) ->
    pos = location.position
    vel = location.velocity
    quat = location.quaternion

    dim = physical.data.dim

    mass = if physical.bodyType == 0 # "static" ... TODO define this in a shared location
      0
    else
      2 # TODO physical.mass
    friction = 0.8 # physijs default
    restitution = 0.2 # physijs default
    linearDamping = 0.1
    angularDamping = 0.3

    geometry = new THREE.BoxGeometry(dim.x, dim.y, dim.z, 10, 10)
    threeMaterial = new THREE.MeshPhongMaterial(color: physical.data.color)
    material = Physijs.createMaterial(threeMaterial, friction, restitution)
    shape = new Physijs.BoxMesh( geometry, material, mass)

    shape.castShadow = true
    shape.receiveShadow = true
    shape.position.set(pos.x, pos.y, pos.z)

    if physical.bodyType == 0 # "static" ... TODO define this in a shared location
      null # TODO fix this whole stanza
    else
      shape.setDamping(linearDamping, angularDamping)
      #TODO shape.setLinearVelocity(physical.velocity)
      #TODO shape.setAngularVelocity(physical.angularVelocity)

    return shape


ter = Data.get("spike.terrain.shapes")
class Plane extends Kindness

  createBody: (physical,location) ->
    # shape = new Cannon.Plane()
    # body = new Cannon.Body(mass: 0, shape: shape)
    # return body
    pos = convertCannonVec3(location.position)

    # data=ter.rows
    data = []
    for row in ter.rows
      drow = []
      for h in row
        drow.push h
      # drow.push 0
      data.push drow

    console.log "objects Plane making hfield from data rows #{data.length} cols #{data[0].length}"
    shape = new Cannon.Heightfield(data,
      elementSize: ter.spacing # Distance between the data points in X and Y directions
    )
    window.heightfield = shape # XXX
    body = new Cannon.Body(mass: 0, shape: shape, bodyType: Cannon.Body.STATIC)
    # halfx = (ter.xSegments*ter.spacing)/2
    # halfh = (ter.ySegments*ter.spacing)/2
    x = pos.x
    y = pos.y
    z = pos.z
    # console.log "plane pos",x,y,z
    # console.log "halfx #{halfx} halfh #{halfh}"
    body.position.set(x,y,z)
    return body
    # heightfieldBody.addShape(heightfieldShape);
    # world.addBody(heightfieldBody);

  # updateBody: (body,physical,location) ->

  createView: (physical,location) ->
    [pos,quat] = convertedPosAndQuat(location)
    group = newGroup(pos,quat)
    # dim = physical.data.dim

    axis = new THREE.AxisHelper(1)
    group.add axis

    # ter = Data.get("spike.terrain.flat")
    # console.log ter
    # window.ter = ter
    width = ter.xSegments * ter.spacing
    length = ter.ySegments * ter.spacing
    geometry = new THREE.PlaneGeometry(
      width
      length
      ter.xSegments
      ter.ySegments
    )

    i = 0
    for row in ter.rows
      for h in row
        geometry.vertices[i].z = h
        i++

    window.mesh = geometry

    geometry.verticesNeedUpdate = false
    geometry.normalsNeedUpdate = false
    # geometry.colorsNeedUpdate = false
    # geometry.uvsNeedUpdate = false
    # geometry.groupsNeedUpdate = false
    geometry.computeVertexNormals()

    material = new THREE.MeshPhongMaterial(
      color: physical.data.color
      wireframe: true
    )
    mesh = new THREE.Mesh(geometry, material)
    # mesh.castShadow = true
    mesh.receiveShadow = true
    # mesh.position.set(width/2, 0, length/2)
    mesh.position.set(length/2,width/2,0)
    mesh.rotation.z = Math.PI/2

    group.add mesh
      # {buildAxisHelper(physical)}
    return group

  # updateView: (view,physical,location) ->


Kinds = {}
Kinds.ball = new Ball()
Kinds.cube = new Cube()
Kinds.block = new Block()
Kinds.plane = new Plane()


getModule = (k) ->
  got = Kinds[k]
  if got?
    return got
  else
    throw new Error("No object kind '#{k}'")


# module.exports.createBody = (physical,location) ->
#   return getModule(physical.kind).createBody(physical,location)
#
# module.exports.updateBody = (body,physical,location) ->
#   return getModule(physical.kind).updateBody(body,physical,location)
#
# module.exports.create3DView = (physical,location) ->
#   return getModule(physical.kind).createView(physical,location)
#
# module.exports.update3DView = (view,physical,location) ->
#   return getModule(physical.kind).updateView(view, physical,location)

module.exports.create3DShape = (physical,location) ->
  return getModule(physical.kind).createShape(physical,location)

module.exports.update3DShape = (shape,physical,location) ->
  return getModule(physical.kind).updateShape(shape, physical,location)
