Rng = require '../lib/park_miller_rng'

seed = 123456789

baseState = Rng.next(seed)
console.log "init: ",baseState

chunkBasis = baseState

getChunkSeed = (basis,x,y) ->
  basis + x + (y*y)

nRandomsInChunk = (basis,n,x,y) ->
  arr = []
  state = getChunkSeed(basis,x,y)
  for i in [0...n]
    [v,state] = Rng.nextInt(state,0,99)
    arr.push v
  arr

a00 = nRandomsInChunk(chunkBasis,10000,0,0)
console.log a00
    





# lo = 0
# hi = 5
# for i in [0...100]
#   [num,state] = Rng.nextInt(state,lo,hi)
#   console.log num#,state

