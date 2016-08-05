
exports.BaseType = class BaseType
  constructor: (@name) ->
  clone: -> @ivar()
  equals: -> "(#{@ivar()} == o.#{@name})"
  default: -> "null"
  ivar: ->
    "@#{@name}"

exports.String = class String extends BaseType

exports.Number = class Number extends BaseType

exports.Id = class Id extends BaseType
exports.Eid = class Eid extends Id
exports.Cid = class Cid extends Id

exports.Obj = class Object extends BaseType
  # TODO
  clone: ->
    "(if #{@ivar()}? then cloneObj(#{@ivar()}) else null)"
  equals: ->
    "(if #{@ivar()}? then _.isEqual(#{@ivar()}, o.#{@name}) else !o.#{@name})"

exports.Vec = class Vec extends BaseType
  clone: ->
    "canVec3().copy(#{@ivar()})"
  equals: ->
    "canVec3Equals(#{@ivar()},o.#{@name})"
  default: ->
    "canVec3()"

exports.Quat = class Quat extends BaseType
  clone: ->
    "canQuat().copy(#{@ivar()})"
  equals: ->
    "canQuatEquals(#{@ivar()},o.#{@name})"
  default: ->
    "canQuat()"

exports.Comp = class Comp extends BaseType
  clone: ->
    "(if #{@ivar()}? then #{@ivar()}.clone() else null)"
  equals: ->
    "(if #{@ivar()}? then #{@ivar()}.equals(o.#{@name}) else !o.#{@name}?)"

exports.Color = class Color extends Number
  default: -> "0xffffff"
