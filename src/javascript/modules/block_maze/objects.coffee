React = require 'react'
Cannon = require 'cannon'
THREE = require 'three'
Physijs = require '../../vendor/physijs_wrapper'

{euler,vec3,quat} = require '../../lib/three_helpers'
mkQuat = quat

Data = require './data'

ShapeType =
  Static: 0
  Dynamic: 1
  NonPhysical: 2

applyDispositionToShape = (shape,location) ->
  pos = location.position
  quat = location.quaternion
  vel = location.velocity
  angVel = location.angularVelocity

  # TODO -- only set shape values if they differ from gamestate
  # Hypothesis: all changes need to be shuttled over to the physijs worker, but lets not if we don't have to
  shape.position.set(pos.x, pos.y, pos.z)
  shape.__dirtyPosition = true # required by physijs

  shape.quaternion.set(quat.x, quat.y, quat.z, quat.w)
  shape.__dirtyRotation = true # required by physijs

  shape.setLinearVelocity(vel) # async -> phyisjs world
  shape.setAngularVelocity(angVel) # async -> phyisjs world

  if location.impulse?
    shape.applyImpulse(location.impulse.force, location.impulse.offset) # async -> phyisjs world
    
    # TODO shape.applyForce
    # TODO shape.applyTorque
  null

copyDispositionFromShape = (shape,location) ->
  pos = shape.position
  quat = shape.quaternion
  angVel = shape.getAngularVelocity()
  vel = shape.getLinearVelocity()
  location.position.set(pos.x, pos.y, pos.z)
  location.quaternion.set(quat.x, quat.y, quat.z, quat.w)
  location.velocity.set(vel.x, vel.y, vel.z)
  location.angularVelocity.set(angVel.x, angVel.y, angVel.z)
  null

arrayEquals = (src,dest) ->
  if src? and dest?
    return false if src.length != dest.length
    for val,i in src
      if dest[i] != val
        return false
    return true
  else
    return (!src? and !dest?)

cloneArray = (src) ->
  return null unless src?
  dest = new Array(src.length)
  for val,i in src
    dest[i] = val
  return dest


Kindness = class Kindness
  createShape: (physical,location) ->
    throw new Error("Kind #{@constructor.name} needs to implement @createShape")

  updateShape: (shape,physical,location) ->
    return if physical.shapeType == ShapeType.Static
    # if physical.eid == 2
    #   console.log physical.eid, shape._physijs.touches
    applyDispositionToShape(shape,location)
    null

  updateFromShape: (shape,physical,location) ->
    return if physical.shapeType == ShapeType.Static
    copyDispositionFromShape(shape,location)

    # if physical.receiveCollisions and !arrayEquals(shape._physijs.touches, physical.touches)
    #   physical.touches = cloneArray(shape._physijs.touches)
    #   console.log "Physical e#{physical.eid} touches",physical.touches

    null


newGroup = (pos,quat) ->
  group = new THREE.Group()
  group.position.set(pos.x,pos.y,pos.z)
  group.quaternion.set(quat.x,quat.y,quat.z,quat.w)
  group

class Ball extends Kindness
  createShape: (physical,location) ->
    # console.log "ball type", physical.shapeType
    mass = if physical.shapeType == ShapeType.Static
      0
    else
      2
    # friction = 0.8 # physijs default
    friction = 1
    restitution = 0.2 # physijs default

    geometry = new THREE.SphereGeometry(0.5, 20,20) # TODO set from phys data
    threeMaterial = new THREE.MeshPhongMaterial(color: physical.data.color)
    material = Physijs.createMaterial(threeMaterial, friction, restitution)
    shape = new Physijs.SphereMesh( geometry, material, mass)
    shape.castShadow = true
    shape.receiveShadow = true

    shape.addEventListener 'ready', ->
      if physical.shapeType == ShapeType.Dynamic
        # linearDamping = 0.1
        # angularDamping = 0.3
        linearDamping = 0.25
        angularDamping = 0.4
        shape.setDamping(linearDamping, angularDamping)

      applyDispositionToShape(shape, location)

    # shape.userData.debugme = true

    shape

class Cube extends Kindness
  createShape: (physical,location) ->
    mass = if physical.shapeType == ShapeType.Static
      0
    else
      2
    friction = 0.8 # physijs default
    restitution = 0.2 # physijs default

    geometry = new THREE.BoxGeometry(1,1,1, 10, 10) # TODO get dimensions from physical comp
    threeMaterial = new THREE.MeshPhongMaterial(color: physical.data.color)
    material = Physijs.createMaterial(threeMaterial, friction, restitution)
    shape = new Physijs.BoxMesh( geometry, material, mass)
    shape.castShadow = true
    shape.receiveShadow = true

    shape.addEventListener 'ready', ->
      if physical.shapeType == ShapeType.Dynamic
        linearDamping = 0.1
        angularDamping = 0.1
        shape.setDamping(linearDamping, angularDamping)

      applyDispositionToShape(shape,location)
    
    shape

class Block extends Kindness
  createShape: (physical,location) ->
    mass = if physical.shapeType == ShapeType.Static
      console.log "block mass 0"
      0
    else
      1 # TODO physical.mass
    friction = 0.8 # physijs default
    restitution = 0.2 # physijs default
    dim = physical.data.dim

    geometry = new THREE.BoxGeometry(dim.x, dim.y, dim.z, 10, 10)
    threeMaterial = new THREE.MeshPhongMaterial(color: physical.data.color)
    material = Physijs.createMaterial(threeMaterial, friction, restitution)
    shape = new Physijs.BoxMesh( geometry, material, mass)
    shape.castShadow = true
    shape.receiveShadow = true

    if physical.shapeType == ShapeType.Dynamic
      shape.addEventListener 'ready', ->
        linearDamping = 0.1
        angularDamping = 0.3
        shape.setDamping(linearDamping, angularDamping)

      applyDispositionToShape(shape, location)

    shape

class Terrain extends Kindness
  createShape: (physical,location) ->
    mass = 0
    # friction = 0.8 # physijs default
    friction = 1#0.8 # physijs default
    restitution = 0.4

    width = 80
    height = 80
    xfaces = 80
    yfaces = 80
    geometry = new THREE.PlaneGeometry( width, height, xfaces, yfaces )
    # NoiseGen = new SimplexNoise
    for vertex in geometry.vertices
      # vertex.z = NoiseGen.noise( vertex.x / 10, vertex.y / 10 ) * 2
      # vertex.z = 0
      vertex.z = Math.sin(vertex.x / 2)
    geometry.computeFaceNormals()
    geometry.computeVertexNormals()

    # threeMaterial = new THREE.MeshPhongMaterial(color: 0x66cc66)
    threeMaterial = new THREE.MeshLambertMaterial(map: THREE.ImageUtils.loadTexture('images/grass.png'))
    threeMaterial.map.wrapS = THREE.RepeatWrapping
    threeMaterial.map.wrapT = THREE.RepeatWrapping
    threeMaterial.map.repeat.set(10,10) 
    material = Physijs.createMaterial(threeMaterial, friction, restitution)

    # If your plane is not square as far as face count then the HeightfieldMesh
    # takes two more arguments at the end: # of x faces and # of y faces that were passed to THREE.PlaneMaterial
    shape = new Physijs.HeightfieldMesh(
      geometry
      material
      mass
      xfaces
      yfaces
    )
    # shape.rotation.x = Math.PI / -2
    shape.receiveShadow = true
    # shape.castShadow = true

    shape.addEventListener 'ready', ->
      applyDispositionToShape(shape, location)

    shape

#######################################################

class Block extends Kindness
  createShape: (physical,location) ->
    mass = if physical.shapeType == ShapeType.Static
      0
    else
      2 # TODO physical.mass
    friction = 0.8 # physijs default
    restitution = 0.2 # physijs default
    dim = physical.data.dim

    geometry = new THREE.BoxGeometry(dim.x, dim.y, dim.z, 10, 10)
    threeMaterial = new THREE.MeshPhongMaterial(color: physical.data.color)
    material = Physijs.createMaterial(threeMaterial, friction, restitution)
    shape = new Physijs.BoxMesh( geometry, material, mass)
    shape.castShadow = true
    shape.receiveShadow = true

    if physical.shapeType == ShapeType.Dynamic
      linearDamping = 0.1
      angularDamping = 0.3
      shape.setDamping(linearDamping, angularDamping)

    applyDispositionToShape(shape, location)

    shape



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
    body = new Cannon.Body(mass: 0, shape: shape, shapeType: Cannon.Body.STATIC)
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
Kinds.terrain = new Terrain()


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

module.exports.updateFrom3DShape = (shape,physical,location) ->
  return getModule(physical.kind).updateFromShape(shape, physical,location)

module.exports.ShapeType = ShapeType
