Defs = require './component_defs'
BaseTypes = require './base_types'

class CompDef
  constructor: (@name, @def, @opts={}) ->
    @isInner = if @opts.isInner then true else false
    @inners = []
    @vars = []
    unless @isInner
      @vars.push new BaseTypes.Eid('eid')
      @vars.push new BaseTypes.Cid('cid')
    for varname,typeclass of @def
      if varname == "_inner"
        @_addInnerTypes(typeclass)
      else
        @vars.push new typeclass(varname)
    null

  _addInnerTypes: (innerDefs) ->
    for tname,tdef of innerDefs
      @inners.push new CompDef(tname,tdef, isInner: true)
    null

  classString: (opts={})->
    ind = if opts.indent then opts.indent else ""
    s = ""
    if @isInner
      s += "#{ind}@#{@name}: class #{@name}\n"
    else
      s += "#{ind}exports.#{@name} = class #{@name}\n"
    s += "#{ind}  Types.registerClass @\n" unless @isInner
    s += "#{ind}  constructor: (#{@vars.map((v)->v.ivar()).join(", ")}) ->"
    if @isInner
      s += "\n"
    else
      s += " @type = @constructor.type\n"
    s += "#{ind}  @default: -> new @(#{@vars.map((v)->v.default()).join(", ")})\n"
    s += "#{ind}  clone: -> new @constructor(#{@vars.map((v)->v.clone()).join(", ")})\n"
    s += "#{ind}  equals: (o) -> #{@vars.map((v)->v.equals()).join(" and ")}\n"
    for innerDef in @inners
      s+= "  \n"
      s+= innerDef.classString(indent:"  ")
    s

funcWriters =
  cloneObj: ->
    s = "cloneObj = (obj) ->\n"
    s += "  res = {}\n"
    s += "  for val,key of obj\n"
    s += "    res[key] = val\n"
    s += "  return res\n"
    s
  # equalsObj: ->
  #   s = "equalsObj = (obj) ->\n"
  #   s += "  for val,key of obj\n"
  #   s += "    return false unless val = obj[key]\n"
  #   s += "  return true\n"
  #   s

headWriter = ->
  s = ""
  s += "_ = require 'lodash'\n"
  s += "Domain = require '../../lib/domain'\n"
  s += "Cannon = require 'cannon'\n"
  s += "{vec3,quat,euler} = require '../../lib/three_helpers'\n"
  s += "\n"
  s += "Types = new Domain('ComponentTypes')\n"

console.log headWriter()
console.log
for name,writer of funcWriters
  console.log writer()
  console.log

for name, def of Defs
  compDef = new CompDef(name, def)
  console.log compDef.classString()
  console.log

console.log "exports.Types = Types\n"


