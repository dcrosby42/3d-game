module.exports = ->
  obj = {
    spacing: 1
    xSegments: 10
    ySegments: 10
    rows: []
  }

  for y in [0..obj.ySegments]
    row = []
    for x in [0..obj.xSegments]
      row.push 0
    obj.rows.push row

  obj
  # for i in [0...((obj.xSegments+1)*(obj.ySegments+1))]
  #   obj.heights.push 0
    
  obj
