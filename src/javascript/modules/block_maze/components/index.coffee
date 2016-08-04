_ = require 'lodash'
Domain = require '../../../lib/domain'
Cannon = require 'cannon'
# Motions = require './motions'
{vec3,quat,euler} = require '../../../lib/three_helpers'
{canVec3,canQuat,canVec3Equals,canQuatEquals} = require '../../../lib/cannon_helpers'

Types = new Domain('ComponentTypes')

exports.Location = class Location
  Types.registerClass @
  constructor: (@position,@velocity,@quaternion,@angularVelocity,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(canVec3(),canVec3(),canQuat(),canVec3(),null,null)
  clone: -> new @constructor(
    canVec3().copy(@position)
    canVec3().copy(@velocity)
    canQuat().copy(@quaternion)
    canVec3().copy(@angularVelocity)
    @eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and canVec3Equals(@position,o.position) and canVec3Equals(@velocity,o.velocity) and canQuatEquals(@quaternion,o.quaternion) and canVec3Equals(@angularVelocity,o.angularVelocity)

exports.Physical = class Physical
  Types.registerClass @
  constructor: (@kind,@bodyId,@data,@bodyType,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(null,null,null,Cannon.Body.DYNAMIC,null,null)
  clone: ->
    dataClone = if @data? then @data.clone() else null
    new @constructor(@kind,@bodyId,dataClone,@bodyType,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @kind == o.kind and @bodyId == o.bodyId and @bodyType == o.bodyType and (if @data? then @data.equals(o.data) else true)

  @Cube: class Cube
    constructor: (@color) ->
    @default: -> new @(0xFFFFFF)
    clone: -> new @constructor(@color)
    equals: (o) -> o? and @color == o.color

  @Plane: class Plane
    constructor: (@color,@width,@height) ->
    @default: -> new @(0xFFFFFF,1,1)
    clone: -> new @constructor(@color,@width,@height)
    equals: (o) -> o? and @color == o.color and @width == o.width and @height == o.height

  @Ball: class Ball
    constructor: (@color,@radius) ->
    @default: -> new @(0xFFFFFF,0.5)
    clone: -> new @constructor(@color,@radius)
    equals: (o) -> o? and @color == o.color and @radius == o.radius

  @Block: class Block
    constructor: (@color,@dim) ->
    @default: -> new @(0xFFFFFF,canVec3(1,1,1))
    clone: -> new @constructor(@color,@dim.clone())
    equals: (o) -> o? and @color == o.color and canVec3Equals(@dim,o.dim)

exports.PhysicsWorld = class PhysicsWorld
  Types.registerClass @
  constructor: (@worldId,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(null,null,null)
  clone: -> new @constructor(@worldId,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @worldId == o.worldId

exports.FollowCamera = class FollowCamera
  Types.registerClass @
  constructor: (@followTag,@lookAt,@hOrbit,@vOrbit,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(null,canVec3(),0,0,null,null)
  clone: -> new @constructor(@followTag,canVec3().copy(@lookAt),@hOrbit,@vOrbit,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @followTag == o.followTag and canVec3Equals(@lookAt,o.lookAt) and @hOrbit == o.hOrbit and @vOrbit == o.vOrbit

exports.Position = class Position
  Types.registerClass @
  constructor: (@position,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(vec3(0,0,0),null)
  clone: -> new @constructor(@position.clone(),@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @position.equals(o.position)

exports.Velocity = class Velocity
  Types.registerClass @
  constructor: (@velocity,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(vec3(0,0,0))
  clone: -> new @constructor(@velocity.clone(),@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @velocity.equals(o.velocity)

exports.Rotation = class Rotation
  Types.registerClass @
  constructor: (@rotation,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(quat())
  clone: -> new @constructor(@rotation.clone(),@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @rotation.equals(o.rotation)

exports.Gravity = class Gravity
  Types.registerClass @
  constructor: (@accel,@max,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(0,0)
  clone: -> new @constructor(@accel,@max,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @accel == o.accel and @max == o.max

exports.Controller = class Controller
  Types.registerClass @
  constructor: (@inputName,@states,@eid,@cid) -> @type = @constructor.type
  @default: -> new @('UNSET',{})
  clone: -> new @constructor(@inputName,@states,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @inputName == o.inputName and _.isEqual(@states,o.states)

exports.Expire = class Expire
  Types.registerClass @
  constructor: (@eid,@cid) -> @type = @constructor.type
  @default: -> new @()
  clone: -> new @constructor(@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid

exports.Name = class Name
  Types.registerClass @
  constructor: (@name,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(null)
  clone: -> new @constructor(@name,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @name == o.name

exports.Tag = class Tag
  Types.registerClass @
  constructor: (@name,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(@name)
  clone: -> new @constructor(@name,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @name == o.name

exports.Timer = class Timer
  Types.registerClass @
  constructor: (@time,@eventName,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(0,null)
  clone: -> new @constructor(@time,@eventName,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @time == o.time and @eventName == o.eventName

exports.Rng = class Rng
  Types.registerClass @
  constructor: (@state,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(1)
  clone: -> new @constructor(@state,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @state == o.state

exports.Cube = class Cube
  Types.registerClass @
  constructor: (@color,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(0xffffff, null)
  clone: -> new @constructor(@color,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @color == o.color

exports.Types = Types

#################################################################################

# Build a new component for the given type, optionally applying props from the given object.
# Starts from a new NON-defaulted instance of a component of the given type.
exports.emptyCompForType = (typeid,obj=null) ->
  clazz = Types.classFor(typeid)
  if !clazz?
    msg = "Components.buildCompForType() failed to get class for typeId '#{typeid}'"
    console.log msg + ", obj:",obj
    throw Error(msg)
  comp = new clazz()
  Object.assign comp, obj if obj?
  comp

# Build a new component for the given type, optionally applying props from the given object.
# Starts from a new defaulted instance of a component of the given type.
exports.buildCompForType = (typeid,obj=null) ->
  clazz = Types.classFor(typeid)
  if !clazz?
    msg = "Components.buildCompForType() failed to get class for typeId '#{typeid}'"
    console.log msg + ", obj:",obj
    throw Error(msg)
  comp = clazz.default()
  Object.assign comp, obj if obj?
  comp
  
ComponentTester = require './component_tester'
ComponentTester.run(exports, types: Types, excused: [ 'Types', 'buildCompForType', 'emptyCompForType' ])


