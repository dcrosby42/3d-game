React = require 'react'
React3 = require 'react-three-renderer'
Cannon = require 'cannon'
THREE = require 'three'

{euler,vec3,quat, convertCannonVec3, convertCannonQuat} = require '../../lib/three_helpers'
{canVec3,canQuat} = require '../../lib/cannon_helpers'

Data = require './data'

Bodies = {}
# Visuals = {}
Views = {}
ViewUpdaters = {}

# Visuals.ball = (key,physical,location) ->
#   pos = convertCannonVec3(location.position)
#   quat = convertCannonQuat(location.quaternion)
#   <group key={key}
#     position={pos}
#     quaternion={quat}
#   >
#     {buildAxisHelper(physical)}
#     <mesh
#       castShadow
#       receiveShadow
#     >
#       <geometryResource resourceId="ballGeo" />
#       <meshPhongMaterial
#         color={physical.data.color}
#       />
#     </mesh>
#   </group>

Views.ball = (physical,location) ->
  pos = convertCannonVec3(location.position)
  quat = convertCannonQuat(location.quaternion)

  group = new THREE.Group()
  group.position.set(pos.x,pos.y,pos.z)
  group.quaternion.set(quat.x,quat.y,quat.z,quat.w)

  geometry = new THREE.SphereGeometry(0.5, 10, 10)
  material = new THREE.MeshPhongMaterial(color: physical.data.color)
  mesh = new THREE.Mesh(geometry, material)
  mesh.castShadow = true
  mesh.receiveShadow = true

  group.add mesh

  return group
  
ViewUpdaters.ball = (view,physical,location) ->
  pos = convertCannonVec3(location.position)
  quat = convertCannonQuat(location.quaternion)

  # group = new THREE.Group()
  view.position.set(pos.x,pos.y,pos.z)
  view.quaternion.set(quat.x,quat.y,quat.z,quat.w)
  # TODO? requires that at build time we tuck refs into userData: view.userData.mesh.material.color = physical.data.color
  null


Bodies.ball = (physical,location) ->
  pos = location.position
  shape = new Cannon.Sphere(0.5)
  body = new Cannon.Body(mass: 2, shape: shape)
  body.position.set(pos.x, pos.y, pos.z)
  body.linearDamping = 0.1
  body.angularDamping = 0.3
  return body

# Bodies.terrain1 = (physical,location) ->
#   null
#
# Visuals.terrain1 = (key,physical,location) ->
#   null

# Visuals.cube = (key,physical,location) ->
#   pos = convertCannonVec3(location.position)
#   quat = convertCannonQuat(location.quaternion)
#   <group key={key}
#     position={pos}
#     quaternion={quat}
#   >
#     {buildAxisHelper(physical)}
#     <mesh
#       castShadow
#       receiveShadow
#     >
#       <geometryResource resourceId="cubeGeo" />
#       <meshPhongMaterial
#         color={physical.data.color}
#       />
#     </mesh>
#   </group>

Views.cube = (physical,location) ->
  pos = convertCannonVec3(location.position)
  quat = convertCannonQuat(location.quaternion)
  # dim = physical.data.dim

  group = new THREE.Group()
  group.position.set(pos.x,pos.y,pos.z)
  group.quaternion.set(quat.x,quat.y,quat.z,quat.w)

  geometry = new THREE.BoxGeometry(1,1,1, 10, 10)
  material = new THREE.MeshPhongMaterial(color: physical.data.color)
  mesh = new THREE.Mesh(geometry, material)
  mesh.castShadow = true
  mesh.receiveShadow = true

  group.add mesh
    # {buildAxisHelper(physical)}
  return group

  
ViewUpdaters.cube = (view,physical,location) ->
  pos = convertCannonVec3(location.position)
  quat = convertCannonQuat(location.quaternion)
  view.position.set(pos.x,pos.y,pos.z)
  view.quaternion.set(quat.x,quat.y,quat.z,quat.w)
  null

Bodies.cube = (physical,location) ->
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

# Visuals.block = (key,physical,location) ->
#   pos = convertCannonVec3(location.position)
#   quat = convertCannonQuat(location.quaternion)
#   # console.log physical
#   # window.physical = physical
#   # throw new Error("Stop!")
#   dim = physical.data.dim
#   <group key={key}
#     position={pos}
#     quaternion={quat}
#   >
#     {buildAxisHelper(physical)}
#     <mesh
#       castShadow
#       receiveShadow
#     >
#       <boxGeometry
#         width={dim.x}
#         height={dim.y}
#         depth={dim.z}
#
#         widthSegments={10}
#         heightSegments={10}
#       />
#       <meshPhongMaterial
#         color={physical.data.color}
#       />
#     </mesh>
#   </group>

Views.block = (physical,location) ->
  pos = convertCannonVec3(location.position)
  quat = convertCannonQuat(location.quaternion)
  dim = physical.data.dim

  group = new THREE.Group()
  group.position.set(pos.x,pos.y,pos.z)
  group.quaternion.set(quat.x,quat.y,quat.z,quat.w)

  geometry = new THREE.BoxGeometry(dim.x, dim.y, dim.z, 10, 10)
  material = new THREE.MeshPhongMaterial(color: physical.data.color)
  mesh = new THREE.Mesh(geometry, material)
  mesh.castShadow = true
  mesh.receiveShadow = true

  group.add mesh
    # {buildAxisHelper(physical)}
  return group

ViewUpdaters.block = (view,physical,location) ->
  # TODO: what if I don't want to assume blocks are static?
  # --> check physical.bodyType == Cannon.BodyTypes.STATIC)
  if physical.bodyType == Cannon.DYNAMIC # TODO don't use physical or cannon here?
    pos = convertCannonVec3(location.position)
    quat = convertCannonQuat(location.quaternion)
    view.position.set(pos.x,pos.y,pos.z)
    view.quaternion.set(quat.x,quat.y,quat.z,quat.w)
  # TODO? requires that at build time we tuck refs into userData: view.userData.mesh.material.color = physical.data.color
  null

Bodies.block = (physical,location) ->
  pos = location.position
  data = physical.data
  shape = new Cannon.Box(new Cannon.Vec3(data.dim.x/2, data.dim.y/2, data.dim.z/2))
  body = new Cannon.Body(shape: shape, type: physical.bodyType)
  body.position.set(pos.x, pos.y, pos.z)
  if physical.bodyType == Cannon.DYNAMIC
    body.mass = 2
    body.linearDamping = 0.1
    body.angularDamping = 0.1
  else
    body.mass = 0
  body

Views.plane = (physical,location) ->
  pos = convertCannonVec3(location.position)
  quat = convertCannonQuat(location.quaternion)
  dim = physical.data.dim

  group = new THREE.Group()
  group.position.set(pos.x,pos.y,pos.z)
  group.quaternion.set(quat.x,quat.y,quat.z,quat.w)


  axis = new THREE.AxisHelper(1)
  group.add axis



  ter = Data.get("spike.terrain.flat")
  # console.log ter
  # window.ter = ter
  geometry = new THREE.PlaneGeometry(
    ter.xSegments*ter.spacing
    ter.ySegments*ter.spacing
    ter.xSegments
    ter.ySegments
  )

  i = 0
  for row in ter.rows
    for h in row
      geometry.vertices[i].z = h
      i++
  # for h,i in ter.heights
  #   geometry.vertices[i].z = h


  # planeWidth = physical.data.width
  # planeHeight = physical.data.height
  # planeWSegs = 99
  # planeHSegs = 99
  # geometry = new THREE.PlaneGeometry(planeWidth,planeHeight,planeWSegs,planeHSegs)
  # console.log geometry.vertices
  # window.plane = geometry
  # for y in [0..planeHSegs]
  #   for x in [0..planeWSegs]
  #     val = Math.sin(x / 10) + 1
  #     i = (y*(planeWSegs+1)) + x
  #     geometry.vertices[i].z = val

  geometry.verticesNeedUpdate = false
  geometry.normalsNeedUpdate = false
  # geometry.colorsNeedUpdate = false
  # geometry.uvsNeedUpdate = false
  # geometry.groupsNeedUpdate = false

    # geometry.vertices[i].z = 2
  # for y in [0...planeHSegs]
  #   for x in [0...planeWSegs]
  #     # val = Math.sin(x / 10) * 2 + 1
  #     i = (y*planeWSegs) + x
  #     geometry.vertices[i].z = x / 10

  material = new THREE.MeshPhongMaterial(
    color: physical.data.color
    wireframe: true
  )
  mesh = new THREE.Mesh(geometry, material)
  # mesh.castShadow = true
  mesh.receiveShadow = true

  group.add mesh
    # {buildAxisHelper(physical)}
  return group

ViewUpdaters.plane = (view, physical, plane) ->
  return

Bodies.plane = (physical,location) ->


  # shape = new Cannon.Plane()
  # body = new Cannon.Body(mass: 0, shape: shape)
  # return body
  pos = convertCannonVec3(location.position)

  ter = Data.get("spike.terrain.flat")
  shape = new Cannon.Heightfield(ter.rows,
    elementSize: ter.spacing # Distance between the data points in X and Y directions
  )
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

# module.exports.VisualResources =
#   <resources>
#     <sphereGeometry
#       resourceId="ballGeo"
#       radius={0.5}
#       widthSegments={10}
#       heightSegments={10}
#     />
#     <boxGeometry
#       resourceId="cubeGeo"
#
#       width={1}
#       height={1}
#       depth={1}
#
#       widthSegments={10}
#       heightSegments={10}
#     />
#     <meshPhongMaterial
#       resourceId="cubeMaterial"
#       color={0x888888}
#     />
#   </resources>

buildAxisHelper = (physical) ->
  if s = physical.axisHelper?
    <axisHelper 
      scale={vec3(s,s,s)} 
    />

module.exports.createBody = (physical,location) ->
  bodyFactory = Bodies[physical.kind]
  if bodyFactory?
    try
      return bodyFactory(physical,location)
    catch err
      console.log "!! ERR: failed to build physical body for",physical,location
      throw err

  else
    console.log "!! ERR: Can't build physical body for",physical
    throw new Error("No body factory found for kind '#{physical.kind}'")

# module.exports.create3d = (key,physical,location) ->
#   visFactory = Visuals[physical.kind]
#   if visFactory?
#     try
#       return visFactory(key,physical,location)
#     catch err
#       console.log "!! ERR: failed to build 3d visual for",physical,location
#       throw err
#   else
#     console.log "!! ERR: Can't build 3d visual for ",physical
#     throw new Error("No 3d visual factory found for kind '#{physical.kind}'")

module.exports.create3DView = (physical,location) ->
  visFactory = Views[physical.kind]
  if visFactory?
    try
      return visFactory(physical,location)
    catch err
      console.log "!! ERR: failed to build 3d view for",physical,location
      throw err
  else
    console.log "!! ERR: Can't build 3d view for ",physical
    throw new Error("No 3d view factory found for kind '#{physical.kind}'")

module.exports.update3DView = (view,physical,location) ->
  visFactory = ViewUpdaters[physical.kind]
  if visFactory?
    try
      return visFactory(view,physical,location)
    catch err
      console.log "!! ERR: failed to build 3d view updater for",physical,location
      throw err
  else
    console.log "!! ERR: Can't build 3d view updater for ",physical
    throw new Error("No 3d view updater found for kind '#{physical.kind}'")
