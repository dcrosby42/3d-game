cantor = require '../lib/cantor_pairing_fn'

d = 100
left = -d
# left = 0
right = d
top = -d
# top = 0
bottom = d

mult = (x,y) ->
  x*y

basis = (x,y) ->
  1 + x + y*y*y

basis2 = (x,y) ->
  1 + x + y


rows = []
all = []
for y in [top..bottom]
  row = []
  for x in [left..right]
    val = cantor(x,y)
    row.push val
    all.push val
  rows.push row

# Visualize:
# for row in rows
#   s = ""
#   for v in row
#     s += "[#{v}]\t"
#   console.log s

# Search all values, make sure no repeats
for v in all
  count = 0
  for o in all
    if v == o
      count++
  if count > 1
    throw new Error("!! HEY I FOUND VALUE #{v} MORE THAN ONCE: #{count} !!")

console.log "IT WORKS."


