_ = require 'lodash'

GeneratedComponentClasses = require './generated_component_classes'
for name,item of GeneratedComponentClasses
  exports[name] = item

#################################################################################

# Build a new component for the given type, optionally applying props from the given object.
# Starts from a new NON-defaulted instance of a component of the given type.
exports.emptyCompForType = (typeid,obj=null) ->
  clazz = exports.Types.classFor(typeid)
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
  clazz = exports.Types.classFor(typeid)
  if !clazz?
    msg = "Components.buildCompForType() failed to get class for typeId '#{typeid}'"
    console.log msg + ", obj:",obj
    throw Error(msg)
  comp = clazz.default()
  Object.assign comp, obj if obj?
  comp
  
ComponentTester = require './component_tester'
ComponentTester.run(exports, types: exports.Types, excused: [ 'Types', 'buildCompForType', 'emptyCompForType' ])


