React = require 'react'
React3 = require 'react-three-renderer'
Cannon = require 'cannon'

{euler,vec3,quat, convertCannonVec3, convertCannonQuat} = require '../../lib/three_helpers'
{canVec3,canQuat} = require '../../lib/cannon_helpers'

Bodies = {}
Visuals = {}

Visuals.ball = (key,physical,location) ->
  pos = convertCannonVec3(location.position)
  quat = convertCannonQuat(location.quaternion)
  <group key={key}
    position={pos}
    quaternion={quat}
  >
    {buildAxisHelper(physical)}
    <mesh
      castShadow
      receiveShadow
    >
      <geometryResource resourceId="ballGeo" />
      <meshPhongMaterial
        color={physical.data.color}
      />
    </mesh>
  </group>


Bodies.ball = (physical,location) ->
  pos = location.position
  shape = new Cannon.Sphere(0.5)
  body = new Cannon.Body(mass: 2, shape: shape)
  body.position.set(pos.x, pos.y, pos.z)
  body.linearDamping = 0.1
  body.angularDamping = 0.3
  return body

Bodies.terrain1 = (physical,location) ->
  null

Visuals.terrain1 = (key,physical,location) ->
  null

Visuals.cube = (key,physical,location) ->
  pos = convertCannonVec3(location.position)
  quat = convertCannonQuat(location.quaternion)
  <group key={key}
    position={pos}
    quaternion={quat}
  >
    {buildAxisHelper(physical)}
    <mesh
      castShadow
      receiveShadow
    >
      <geometryResource resourceId="cubeGeo" />
      <meshPhongMaterial
        color={physical.data.color}
      />
    </mesh>
  </group>

Bodies.cube = (physical,location) ->
  shape = new Cannon.Box(new Cannon.Vec3(0.5,0.5,0.5)) # TODO get dimensions from physical comp
  pos = location.position
  body = new Cannon.Body(mass: 2, shape: shape)
  body.linearDamping = 0.1
  body.angularDamping = 0.1
  body.position.set(pos.x, pos.y, pos.z)
  # body.position.set(0,0,4)
  # body.linearDamping = 0.0
  # body.velocity.set(1,0,0)
  body

Visuals.block = (key,physical,location) ->
  pos = convertCannonVec3(location.position)
  quat = convertCannonQuat(location.quaternion)
  # console.log physical
  # window.physical = physical
  # throw new Error("Stop!")
  dim = physical.data.dim
  <group key={key}
    position={pos}
    quaternion={quat}
  >
    {buildAxisHelper(physical)}
    <mesh
      castShadow
      receiveShadow
    >
      <boxGeometry
        width={dim.x}
        height={dim.y}
        depth={dim.z}

        widthSegments={10}
        heightSegments={10}
      />
      <meshPhongMaterial
        color={physical.data.color}
      />
    </mesh>
  </group>

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

Visuals.plane = (key,physical,location) ->
  pos = convertCannonVec3(location.position)
  quat = convertCannonQuat(location.quaternion)
  <group key={key}
      quaternion={quat}
      position={pos}
    >
    {buildAxisHelper(physical)}

    <mesh
      castShadow
      receiveShadow
    >
      <planeBufferGeometry
        width={physical.data.width}
        height={physical.data.height}
        widthSegments={100}
        heightSegments={100}
      />
      <meshLambertMaterial
        color={physical.data.color}
      />
    </mesh>
  </group>

Bodies.plane = (physical,location) ->
  shape = new Cannon.Plane()
  body = new Cannon.Body(mass: 0, shape: shape)
  body

module.exports.VisualResources =
  <resources>
    <sphereGeometry
      resourceId="ballGeo"
      radius={0.5}
      widthSegments={10}
      heightSegments={10}
    />
    <boxGeometry
      resourceId="cubeGeo"

      width={1}
      height={1}
      depth={1}

      widthSegments={10}
      heightSegments={10}
    />
    <meshPhongMaterial
      resourceId="cubeMaterial"
      color={0x888888}
    />
  </resources>

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

module.exports.create3d = (key,physical,location) ->
  visFactory = Visuals[physical.kind]
  if visFactory?
    try
      return visFactory(key,physical,location)
    catch err
      console.log "!! ERR: failed to build 3d visual for",physical,location
      throw err
  else
    console.log "!! ERR: Can't build 3d visual for ",physical
    throw new Error("No 3d visual factory found for kind '#{physical.kind}'")
