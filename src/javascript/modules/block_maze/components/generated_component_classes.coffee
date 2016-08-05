_ = require 'lodash'
Domain = require '../../../lib/domain'
Cannon = require 'cannon'
{vec3,quat,euler} = require '../../../lib/three_helpers'
{canVec3,canQuat,canVec3Equals,canQuatEquals} = require '../../../lib/cannon_helpers'

Types = new Domain('ComponentTypes')

cloneObj = (obj) ->
  res = {}
  for val,key of obj
    res[key] = val
  return res

exports.Name = class Name
  Types.registerClass @
  constructor: (@eid, @cid, @name) -> @type = @constructor.type
  @default: -> new @(null, null, null)
  clone: -> new @constructor(@eid, @cid, @name)
  equals: (o) -> (@eid == o.eid) and (@cid == o.cid) and (@name == o.name)

exports.Tag = class Tag
  Types.registerClass @
  constructor: (@eid, @cid, @name) -> @type = @constructor.type
  @default: -> new @(null, null, null)
  clone: -> new @constructor(@eid, @cid, @name)
  equals: (o) -> (@eid == o.eid) and (@cid == o.cid) and (@name == o.name)

exports.Timer = class Timer
  Types.registerClass @
  constructor: (@eid, @cid, @time, @eventName) -> @type = @constructor.type
  @default: -> new @(null, null, null, null)
  clone: -> new @constructor(@eid, @cid, @time, @eventName)
  equals: (o) -> (@eid == o.eid) and (@cid == o.cid) and (@time == o.time) and (@eventName == o.eventName)

exports.Rng = class Rng
  Types.registerClass @
  constructor: (@eid, @cid, @state) -> @type = @constructor.type
  @default: -> new @(null, null, 1)
  clone: -> new @constructor(@eid, @cid, @state)
  equals: (o) -> (@eid == o.eid) and (@cid == o.cid) and (@state == o.state)

exports.Location = class Location
  Types.registerClass @
  constructor: (@eid, @cid, @position, @velocity, @quaternion, @angularVelocity) -> @type = @constructor.type
  @default: -> new @(null, null, canVec3(), canVec3(), canQuat(), canVec3())
  clone: -> new @constructor(@eid, @cid, canVec3().copy(@position), canVec3().copy(@velocity), canQuat().copy(@quaternion), canVec3().copy(@angularVelocity))
  equals: (o) -> (@eid == o.eid) and (@cid == o.cid) and canVec3Equals(@position,o.position) and canVec3Equals(@velocity,o.velocity) and canQuatEquals(@quaternion,o.quaternion) and canVec3Equals(@angularVelocity,o.angularVelocity)

exports.Physical = class Physical
  Types.registerClass @
  constructor: (@eid, @cid, @bodyId, @kind, @bodyType, @data) -> @type = @constructor.type
  @default: -> new @(null, null, null, null, null, null)
  clone: -> new @constructor(@eid, @cid, @bodyId, @kind, @bodyType, (if @data? then @data.clone() else null))
  equals: (o) -> (@eid == o.eid) and (@cid == o.cid) and (@bodyId == o.bodyId) and (@kind == o.kind) and (@bodyType == o.bodyType) and (if @data? then @data.equals(o.data) else !o.data?)
  
  @Cube: class Cube
    constructor: (@color) ->
    @default: -> new @(0xffffff)
    clone: -> new @constructor(@color)
    equals: (o) -> (@color == o.color)
  
  @Plane: class Plane
    constructor: (@color, @width, @height) ->
    @default: -> new @(0xffffff, null, null)
    clone: -> new @constructor(@color, @width, @height)
    equals: (o) -> (@color == o.color) and (@width == o.width) and (@height == o.height)
  
  @Ball: class Ball
    constructor: (@color, @radius) ->
    @default: -> new @(0xffffff, null)
    clone: -> new @constructor(@color, @radius)
    equals: (o) -> (@color == o.color) and (@radius == o.radius)
  
  @Block: class Block
    constructor: (@color, @dim) ->
    @default: -> new @(0xffffff, canVec3())
    clone: -> new @constructor(@color, canVec3().copy(@dim))
    equals: (o) -> (@color == o.color) and canVec3Equals(@dim,o.dim)

exports.FollowCamera = class FollowCamera
  Types.registerClass @
  constructor: (@eid, @cid, @followingTag, @lookAt, @hOrbit, @vOrbit) -> @type = @constructor.type
  @default: -> new @(null, null, null, canVec3(), null, null)
  clone: -> new @constructor(@eid, @cid, @followingTag, canVec3().copy(@lookAt), @hOrbit, @vOrbit)
  equals: (o) -> (@eid == o.eid) and (@cid == o.cid) and (@followingTag == o.followingTag) and canVec3Equals(@lookAt,o.lookAt) and (@hOrbit == o.hOrbit) and (@vOrbit == o.vOrbit)

exports.PhysicsWorld = class PhysicsWorld
  Types.registerClass @
  constructor: (@eid, @cid, @worldId) -> @type = @constructor.type
  @default: -> new @(null, null, null)
  clone: -> new @constructor(@eid, @cid, @worldId)
  equals: (o) -> (@eid == o.eid) and (@cid == o.cid) and (@worldId == o.worldId)

exports.Controller = class Controller
  Types.registerClass @
  constructor: (@eid, @cid, @inputName, @states) -> @type = @constructor.type
  @default: -> new @(null, null, null, {})
  clone: -> new @constructor(@eid, @cid, @inputName, (if @states? then cloneObj(@states) else null))
  equals: (o) -> (@eid == o.eid) and (@cid == o.cid) and (@inputName == o.inputName) and (if @states? then _.isEqual(@states, o.states) else !o.states)

exports.Types = Types

