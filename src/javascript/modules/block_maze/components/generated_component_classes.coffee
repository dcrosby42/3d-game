_ = require 'lodash'
Domain = require '../../../lib/domain'
Cannon = require 'cannon'
{vec3,quat,euler} = require '../../../lib/three_helpers'

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
  constructor: (@eid, @cid, @position, @positionDirty, @quaternion, @quaternionDirty, @velocity, @velocityDirty, @angularVelocity, @angularVelocityDirty, @impulse) -> @type = @constructor.type
  @default: -> new @(null, null, vec3(), true, quat(), true, vec3(), true, vec3(), true, null)
  clone: -> new @constructor(@eid, @cid, (if @position? then @position.clone() else null), @positionDirty, (if @quaternion? then @quaternion.clone() else null), @quaternionDirty, (if @velocity? then @velocity.clone() else null), @velocityDirty, (if @angularVelocity? then @angularVelocity.clone() else null), @angularVelocityDirty, (if @impulse? then @impulse.clone() else null))
  equals: (o) -> (@eid == o.eid) and (@cid == o.cid) and (if @position? then @position.equals(o.position) else !o.position?) and (@positionDirty == o.positionDirty) and (if @quaternion? then @quaternion.equals(o.quaternion) else !o.quaternion?) and (@quaternionDirty == o.quaternionDirty) and (if @velocity? then @velocity.equals(o.velocity) else !o.velocity?) and (@velocityDirty == o.velocityDirty) and (if @angularVelocity? then @angularVelocity.equals(o.angularVelocity) else !o.angularVelocity?) and (@angularVelocityDirty == o.angularVelocityDirty) and (if @impulse? then @impulse.equals(o.impulse) else !o.impulse?)
  
  @Impulse: class Impulse
    constructor: (@force, @offset) ->
    @default: -> new @(vec3(), vec3())
    clone: -> new @constructor((if @force? then @force.clone() else null), (if @offset? then @offset.clone() else null))
    equals: (o) -> (if @force? then @force.equals(o.force) else !o.force?) and (if @offset? then @offset.equals(o.offset) else !o.offset?)

exports.Physical = class Physical
  Types.registerClass @
  constructor: (@eid, @cid, @shapeId, @kind, @shapeType, @receiveCollisions, @data) -> @type = @constructor.type
  @default: -> new @(null, null, null, null, 1, false, null)
  clone: -> new @constructor(@eid, @cid, @shapeId, @kind, @shapeType, @receiveCollisions, (if @data? then @data.clone() else null))
  equals: (o) -> (@eid == o.eid) and (@cid == o.cid) and (@shapeId == o.shapeId) and (@kind == o.kind) and (@shapeType == o.shapeType) and (@receiveCollisions == o.receiveCollisions) and (if @data? then @data.equals(o.data) else !o.data?)
  
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
    @default: -> new @(0xffffff, vec3())
    clone: -> new @constructor(@color, (if @dim? then @dim.clone() else null))
    equals: (o) -> (@color == o.color) and (if @dim? then @dim.equals(o.dim) else !o.dim?)
  
  @PacMap: class PacMap
    constructor: (@mapName) ->
    @default: -> new @(null)
    clone: -> new @constructor(@mapName)
    equals: (o) -> (@mapName == o.mapName)

exports.FollowCamera = class FollowCamera
  Types.registerClass @
  constructor: (@eid, @cid, @followingTag, @lookAt, @hOrbit, @vOrbit) -> @type = @constructor.type
  @default: -> new @(null, null, null, vec3(), null, null)
  clone: -> new @constructor(@eid, @cid, @followingTag, (if @lookAt? then @lookAt.clone() else null), @hOrbit, @vOrbit)
  equals: (o) -> (@eid == o.eid) and (@cid == o.cid) and (@followingTag == o.followingTag) and (if @lookAt? then @lookAt.equals(o.lookAt) else !o.lookAt?) and (@hOrbit == o.hOrbit) and (@vOrbit == o.vOrbit)

exports.Controller = class Controller
  Types.registerClass @
  constructor: (@eid, @cid, @inputName, @states) -> @type = @constructor.type
  @default: -> new @(null, null, null, {})
  clone: -> new @constructor(@eid, @cid, @inputName, (if @states? then cloneObj(@states) else null))
  equals: (o) -> (@eid == o.eid) and (@cid == o.cid) and (@inputName == o.inputName) and (if @states? then _.isEqual(@states, o.states) else !o.states)

exports.Types = Types

