Cantor = require '../lib/cantor_pairing_fn'
Rng = require '../lib/park_miller_rng'

seed = 123456789

baseState = Rng.next(seed)
console.log "init: ",baseState

chunkBasis = baseState

getChunkSeed = (basis,x,y) ->
  basis * Cantor(x,y)

nRandomsInChunk = (basis,n,x,y) ->
  arr = []
  state = getChunkSeed(basis,x,y)
  # console.log "chunk seed @ #{x},#{y}",state
  for i in [0...n]
    [v,state] = Rng.nextInt(state,0,99)
    arr.push v
    # [v,state] = Rng.nextFloat(state,0,1)
    # arr.push v
    # state = Rng.next(state)
    # arr.push state
  arr

rec = {}
n = 10000
s = 20
for y in [0..s]
  for x in [0..s]
    rec["#{x}_#{y}"] = nRandomsInChunk(chunkBasis,n,x,y)

_ = require 'lodash'

okcount = 0
for key,nums of rec
  for okey,onums of rec
    if key != okey and _.isEqual(nums,onums)
      throw new Error("Nums for #{key} same as #{okey}")
    else
      okcount++

console.log "OK #{okcount}"
    

# lo = 0
# hi = 5
# for i in [0...100]
#   [num,state] = Rng.nextInt(state,lo,hi)
#   console.log num#,state

