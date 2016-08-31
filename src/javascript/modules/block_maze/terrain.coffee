Cannon = require 'cannon'
CANNON = Cannon
THREE = require 'three'

{euler,vec3,quat, convertCannonVec3, convertCannonQuat} = require '../../lib/three_helpers'
{canVec3,canQuat} = require '../../lib/cannon_helpers'

Kindness = require './kindness'
Data = require './data'

convertedPosAndQuat = (location) ->
  pos = convertCannonVec3(location.position)
  quat = convertCannonQuat(location.quaternion)
  [pos,quat]

newGroup = (pos,quat) ->
  group = new THREE.Group()
  group.position.set(pos.x,pos.y,pos.z)
  group.quaternion.set(quat.x,quat.y,quat.z,quat.w)
  group

hfShape2Mesh = (shape) ->
  geometry = new THREE.Geometry()

  v0 = new CANNON.Vec3()
  v1 = new CANNON.Vec3()
  v2 = new CANNON.Vec3()

  # for (var xi = 0; xi < shape.data.length - 1; xi++) {
      # for (var yi = 0; yi < shape.data[xi].length - 1; yi++) {
          # for (var k = 0; k < 2; k++) {
  for xi in [0...(shape.data.length-1)]
    for yi in [0...shape.data[xi].length-1]
      for k in [0...2]
        shape.getConvexTrianglePillar(xi, yi, (k == 0))
        v0.copy(shape.pillarConvex.vertices[0])
        v1.copy(shape.pillarConvex.vertices[1])
        v2.copy(shape.pillarConvex.vertices[2])
        v0.vadd(shape.pillarOffset, v0)
        v1.vadd(shape.pillarOffset, v1)
        v2.vadd(shape.pillarOffset, v2)
        geometry.vertices.push(
            new THREE.Vector3(v0.x, v0.y, v0.z)
            new THREE.Vector3(v1.x, v1.y, v1.z)
            new THREE.Vector3(v2.x, v2.y, v2.z)
        )
        i = geometry.vertices.length - 3
        geometry.faces.push(new THREE.Face3(i, i+1, i+2))

  geometry.computeBoundingSphere()
  geometry.computeFaceNormals()
  material = new THREE.MeshPhongMaterial(
    color: 0xffffff
    wireframe: true
  )
  mesh = new THREE.Mesh(geometry, material)
  return mesh


genData = (sizeX,sizeY) ->
  matrix = []

  for i in [0...sizeX]
    matrix.push([])
    for j in [0...sizeY]
      height = Math.sin(i / sizeX * Math.PI * 8) * Math.sin(j / sizeY * Math.PI * 8) * 2 + 0
      if(i==0 || i == sizeX-1 || j==0 || j == sizeY-1)
        height = 2
      matrix[i].push(height)

  matrix

makeTerrainShape = (sizeX,sizeY,scale) ->
  new CANNON.Heightfield(genData(sizeX,sizeY), elementSize: scale / sizeX)

ter = Data.get("spike.terrain.flat")

class Terrain extends Kindness
  createBody: (physical,location) ->
    # pos = convertCannonVec3(location.position)

    # data = []
    # for row in ter.rows
    #   drow = []
    #   for h in row
    #     drow.push h
    #   data.push drow
    #
    # console.log "objects Plane making hfield from data rows #{data.length} cols #{data[0].length}"
    # shape = new Cannon.Heightfield(data,
    #   elementSize: ter.spacing # Distance between the data points in X and Y directions
    # )
    # window.heightfield = shape # XXX


    # shape = new CANNON.Heightfield(matrix, { elementSize: 300 / sizeX })
    shape = makeTerrainShape(64,64,30)

    # body = new Cannon.Body(mass: 0, shape: shape, bodyType: Cannon.Body.STATIC)
    body = new Cannon.Body(mass: 0, shape: shape)
    # x = pos.x
    # y = pos.y
    # z = pos.z
    # body.position.set(x,y,z)
    body.position.copy(location.position)
    return body

  createView: (physical,location) ->
    [pos,quat] = convertedPosAndQuat(location)
    group = newGroup(pos,quat)

    axis = new THREE.AxisHelper(1)
    group.add axis

    # data = []
    # for row in ter.rows
    #   drow = []
    #   for h in row
    #     drow.push h
    #   data.push drow
    # hfieldShape = new Cannon.Heightfield(data, elementSize: ter.spacing)

    shape = makeTerrainShape(64,64,30)

    mesh = hfShape2Mesh(shape)
    mesh.receiveShadow = true

    # mesh.position.set(length/2,width/2,0)
    # mesh.rotation.z = Math.PI/2

    group.add mesh
    return group


module.exports = Terrain
