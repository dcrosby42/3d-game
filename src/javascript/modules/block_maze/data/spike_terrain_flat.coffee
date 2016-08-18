module.exports = ->
  obj = {
    spacing: 0.25
    xSegments: 30
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
  obj
