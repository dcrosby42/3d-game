fs = require 'fs'
_ = require 'lodash'

sorted = _.sortBy(fs.readdirSync("."))

for fname in sorted
  if fname.endsWith("_system.coffee")
    sysname = fname.replace(".coffee","")
    console.log "exports.#{sysname} = require './#{sysname}'"
