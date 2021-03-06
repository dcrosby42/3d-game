
exports.BaseType = class BaseType
  constructor: (@name) ->
  clone: -> @ivar()
  equals: -> "(#{@ivar()} == o.#{@name})"
  default: -> "null"
  ivar: ->
    "@#{@name}"
  @with: (opts={}) ->
    mydefault = opts.default
    class extends @
      default: ->
        mydefault

exports.String = class String extends BaseType

exports.Number = class Number extends BaseType

exports.Bool = class Bool extends BaseType
  default: -> "false"

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
    "(if #{@ivar()}? then #{@ivar()}.clone() else null)"
  equals: ->
    "(if #{@ivar()}? then #{@ivar()}.equals(o.#{@name}) else !o.#{@name}?)"
  default: ->
    "vec3()"

exports.Quat = class Quat extends BaseType
  clone: ->
    "(if #{@ivar()}? then #{@ivar()}.clone() else null)"
  equals: ->
    "(if #{@ivar()}? then #{@ivar()}.equals(o.#{@name}) else !o.#{@name}?)"
  default: ->
    "quat()"

exports.Comp = class Comp extends BaseType
  clone: ->
    "(if #{@ivar()}? then #{@ivar()}.clone() else null)"
  equals: ->
    "(if #{@ivar()}? then #{@ivar()}.equals(o.#{@name}) else !o.#{@name}?)"

exports.Color = class Color extends Number
  default: -> "0xffffff"
