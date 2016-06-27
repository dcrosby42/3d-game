_ = require 'lodash'
Domain = require '../../../lib/domain'
# Motions = require './motions'

Types = new Domain('ComponentTypes')

exports.Position = class Position
  Types.registerClass @
  constructor: (@x,@y,@name,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(0,0,null)
  clone: -> new @constructor(@x,@y,@name,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @x == o.x and @y == o.y and @name == o.name

exports.Velocity = class Velocity
  Types.registerClass @
  constructor: (@x,@y,@eid,@cid) -> @type = @constructor.type
  @default: -> new @(0,0)
  clone: -> new @constructor(@x,@y,@eid,@cid)
  equals: (o) -> o? and @eid == o.eid and @cid == o.cid and @x == o.x and @y == o.y

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

exports.Types = Types

exports.emptyCompForType = (typeid,obj=null) ->
  clazz = Types.classFor(typeid)
  if !clazz?
    msg = "Components.buildCompForType() failed to get class for typeId '#{typeid}'"
    console.log msg + ", obj:",obj
    throw Error(msg)
  comp = new clazz()
  Object.assign comp, obj if obj?
  comp

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


