module.exports = ->
  obj = {
    spacing: 1
    xSegments: 11
    ySegments: 10
    rows: []
  }

  for y in [0..obj.ySegments]
    row = []
    for x in [0..obj.xSegments]
      row.push 0
    obj.rows.push row

  console.log "data spike terrain rows #{obj.rows.length}, cols #{obj.rows[0].length}"
  console.log "data spike terrain",obj

  obj.rows[0][0] = 0.5
  obj.rows[0][1] = 0.5
  obj.rows[0][2] = 0.5
  obj.rows[1][0] = 0.5
  obj.rows[1][1] = 0.5
  obj.rows[1][2] = 0.5
  obj.rows[3][5] = 1.5

  obj.rows[0][10] = 1.5
  obj.rows[1][10] = 1.5
  obj.rows[2][10] = 1.5
  obj.rows[3][10] = 1.5

  console.log "terarin data",obj
  obj
