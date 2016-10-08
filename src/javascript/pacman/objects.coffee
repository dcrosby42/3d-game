React = require 'react'
Cannon = require 'cannon'
THREE = require 'three'
Physijs = require '../vendor/physijs_wrapper'
Maps = require './maps'

{euler,vec3,quat} = require '../lib/three_helpers'
mkQuat = quat

# Data = require './data'

# HitProfile = require './hit_profile'

ShapeType =
  Static: 0
  Dynamic: 1
  NonPhysical: 2

tol = 0.01
vecEquals = (a,b) ->
  if Math.abs(a.x - b.x) > tol and Math.abs(a.y - b.y) > tol and Math.abs(a.z - b.z) > tol
    return false

applyDispositionToShape = (shape,location) ->
  phys = shape._physijs?

  if location.positionDirty
    pos = location.position
    shape.position.set(pos.x, pos.y, pos.z)
    location.positionDirty = false
    shape.__dirtyPosition = true if phys

  if location.quaternionDirty
    rot = location.quaternion
    shape.quaternion.set(rot.x, rot.y, rot.z, rot.w)
    location.quaternionDirty = false
    shape.__dirtyRotation = true if phys

  if phys
    if location.velocityDirty
      shape.setLinearVelocity(location.velocity) # async -> phyisjs world
      location.velocityDiry = false

    if location.angularVelocityDirty
      shape.setAngularVelocity(location.angularVelocity) # async -> phyisjs world
      location.angularVelocityDirty = false

    if location.impulse?
      shape.applyImpulse(location.impulse.force, location.impulse.offset) # async -> phyisjs world
  
    # TODO shape.applyForce
    
    # TODO shape.applyTorque
 
  null

copyDispositionFromShape = (shape,location) ->
  pos = shape.position
  quat = shape.quaternion
  location.position.set(pos.x, pos.y, pos.z)
  location.positionDirty = false
  location.quaternion.set(quat.x, quat.y, quat.z, quat.w)
  location.quaternionDirty = false
  if shape._physijs?
    angVel = shape.getAngularVelocity()
    vel = shape.getLinearVelocity()
    location.velocity.set(vel.x, vel.y, vel.z)
    location.velocityDirty = false
    location.angularVelocity.set(angVel.x, angVel.y, angVel.z)
    location.angularVelocityDirty = false
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
    applyDispositionToShape(shape,location)

  updateFromShape: (shape,physical,location) ->
    return if physical.shapeType == ShapeType.Static
    copyDispositionFromShape(shape,location)


newGroup = (pos,quat) ->
  group = new THREE.Group()
  group.position.set(pos.x,pos.y,pos.z)
  group.quaternion.set(quat.x,quat.y,quat.z,quat.w)
  group

class PacMan extends Kindness
  createShape: (physical,location) ->
    mass = 2
    friction = 1
    restitution = 0.2
    radius = 0.45

    geometry = new THREE.SphereGeometry(radius, 20,20) # TODO set from phys data
    threeMaterial = new THREE.MeshPhongMaterial(color: physical.data.color)
    material = Physijs.createMaterial(threeMaterial, friction, restitution)
    shape = new Physijs.SphereMesh( geometry, material, mass)
    shape.castShadow = true
    shape.receiveShadow = true

    shape.addEventListener 'ready', ->
      if physical.shapeType == ShapeType.Dynamic
        linearDamping = 0.25
        angularDamping = 0.4
        shape.setDamping(linearDamping, angularDamping)

      applyDispositionToShape(shape, location)

    # rbox = mkBox(geom:[0.3,0.3,0.3, 10,10], color: 0x229944, position: vec3(0.5,0,0), mass: 1)
    # lbox = mkBox(geom:[0.3,0.3,0.3, 10,10], color: 0xcc6622, position: vec3(-0.5,0,0), mass: 1)
    # shape.add(rbox)
    # shape.add(lbox)

    shape.userData.hitProfile = #HitProfile.sphere(@radius) #.setLayerMask(0)
      hitSphere: new THREE.Sphere(vec3(), radius)
      canHitOn: 1
      getHitOn: 0

    shape

  updateShape: (shape,physical,location) ->
    super

  updateFromShape: (shape,physical,location) ->
    super

class Pellet extends Kindness
  constructor: ->
    # @mass = 0.1
    @mass = 0
    @friction = 1
    @restitution = 0.2
    @radius = 0.1
    sect=10
    @geometry = new THREE.SphereGeometry(@radius, sect,sect)
    # @geometry = new THREE.BoxGeometry(0.1,0.1,0.1,1,1)
    @threeMaterial = new THREE.MeshPhongMaterial(color: 0xffffff)
    @material = Physijs.createMaterial(@threeMaterial, @friction, @restitution)

  createShape: (physical,location) ->
    # shape = new Physijs.SphereMesh( @geometry, @material, @mass)
    # shape = new Physijs.BoxMesh( @geometry, @material, @mass)
    shape = new THREE.Mesh(@geometry, @material)
    shape.castShadow = true
    shape.receiveShadow = true

    shape.userData.hitProfile = #HitProfile.sphere(@radius) #.setLayerMask(0)
      hitSphere: new THREE.Sphere(vec3(), @radius-0.05)
      canHitOn: 0
      getHitOn: 1

    shape

cache = {}
class BlenderMesh extends Kindness
  createShape: (physical,location) ->
    if cache.dude
      geometry = new THREE.BoxGeometry(2,2,2)
      material = new THREE.MeshBasicMaterial(color: 0x99ff99)
      shape = new THREE.Mesh(geometry,material)
      return shape

    else
      geometry = new THREE.BoxGeometry(1,1,1)
      material = new THREE.MeshBasicMaterial(color: 0x9999ff,wireframe:true)
      shape = new THREE.Mesh(geometry,material)

      callback = ->
        cache.dude = true
        shape.userData.rebuild = true
      setTimeout callback, 3000
      return shape

    # fname = physical.data.fileName
    #
    # loader = new THREE.JSONLoader()
    # loader.load fname, (geometry,m) ->
    #   mesh = new THREE.Mesh(geometry,new THREE.MeshFaceMaterial(m))#,material)
    #   mesh.castShadow = true
    #   fn(mesh)
    #   scene.add(mesh)

      

      


    # shape.addEventListener 'ready', ->
    #   linearDamping = 0.25
    #   angularDamping = 0.4
    #   shape.setDamping(linearDamping, angularDamping)
    #   applyDispositionToShape(shape, location)
    applyDispositionToShape(shape, location)

    shape

  # updateShape: (shape,physical,location) ->
  #   super



mkBox = (opts={}) ->
  opts.position ?= vec3()
  opts.quaternion ?= mkQuat()
  opts.friction ?= 0.8
  opts.restitution ?= 0.2
  opts.color ?= 0xffffff
  opts.geom ?= [1,1,1, 1,1]
  opts.mass ?= 1
  opts.castShadow ?= true
  opts.receiveShadow ?= true

  geometry = new THREE.CubeGeometry(opts.geom...)
  threeMaterial = new THREE.MeshPhongMaterial(color: opts.color)
  material = Physijs.createMaterial(threeMaterial)
  box = new Physijs.BoxMesh( geometry, material, opts.mass)
  box.position.set(opts.position.x,opts.position.y,opts.position.z)
  box.castShadow = opts.castShadow
  box.receiveShadow = opts.receiveShadow
  box



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

class SineGrassTerrain extends Kindness
  createShape: (physical,location) ->
    mass = 0
    # friction = 0.8 # physijs default
    friction = 1#0.8 # physijs default
    restitution = 0.4

    width = 20
    height = 20
    xfaces = 40
    yfaces = 40
    geometry = new THREE.PlaneGeometry( width, height, xfaces, yfaces )
    # NoiseGen = new SimplexNoise
    for vertex in geometry.vertices
      # vertex.z = NoiseGen.noise( vertex.x / 10, vertex.y / 10 ) * 2
      # vertex.z = 0
      vertex.z = Math.sin(vertex.x * (Math.PI/ 10) * 2)

    geometry.computeFaceNormals()
    geometry.computeVertexNormals()

    # threeMaterial = new THREE.MeshPhongMaterial(color: 0x66cc66, wireframe: true)
    threeMaterial = new THREE.MeshLambertMaterial(map: THREE.ImageUtils.loadTexture('images/grass.png'))
    threeMaterial.map.wrapS = THREE.RepeatWrapping
    threeMaterial.map.wrapT = THREE.RepeatWrapping
    threeMaterial.map.repeat.set(2.5,2.5)
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
class PacMap extends Kindness
  createShape: (physical,location) ->
    map = Maps.get(physical.data.mapName)

    params =
      position: vec3(0,0,0)
      floorColor: 0x333399
      wallColor: 0x5555cc
      width: 50
      length: 90
      floorThickness: 1
      wallHeight: 1
      blockThickness: map.getTileWidth()

    # floor = mkBox(position: params.position, geom: [params.width,params.floorThickness,params.length], color: params.floorColor, mass: 0)
    width = map.getWidth()
    length = map.getLength()
    console.log "floor width=#{width} lengtjh=#{length}"
    pos = params.position
    # pos.x += width/2
    # pos.z += length/2
    floor = mkBox(position: pos, geom: [width,params.floorThickness,length], color: params.floorColor, mass: 0)

    wy = params.floorThickness/2+ params.wallHeight/2

    for pos in map.getBlockLocations()
      pos.y = wy
      # pos.z -= length/2
      block = mkBox(position: pos, geom: [params.blockThickness, params.wallHeight, params.blockThickness], color: params.wallColor, mass: 0)
      # block.add new THREE.AxisHelper()
      floor.add block


    # floor.add new THREE.AxisHelper(3)
    floor
    


    

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

    shape.position.x = location.position.x
    shape.position.y = location.position.y
    shape.position.z = location.position.z
    # applyDispositionToShape(shape, location)

    shape



Kinds = {}
Kinds.pacman = new PacMan()
Kinds.cube = new Cube()
Kinds.block = new Block()
Kinds.sine_grass_terrain = new SineGrassTerrain()
Kinds.pac_map = new PacMap()
Kinds.pellet = new Pellet()
Kinds.blender_mesh = new BlenderMesh()


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
