React = require 'react'
EntitySearch = require '../../../lib/ecs/entity_search'
C = require '../components'
T = C.Types

AsciiView = React.createClass
  render: ->
    gridString = mkGridString(@props.estore)
    <pre className="ascii-grid-view">{gridString}</pre>


mkGridString = (estore) ->
  position = getPlayerPosition(estore)

  rows = mkCharGrid()
  rows[Math.floor(position.y)][Math.floor(position.x)] = "D"

  gridString=""
  for row in rows
    for c in row
      gridString += c
    gridString += "\n"
  gridString

pieceSearch = EntitySearch.prepare([{type:T.Tag,name:'player_piece'}, T.Position])
getPlayerPosition = (estore) ->
  pos = null
  pieceSearch.run estore, (r) ->
    [tag,position] = r.comps
    pos = position
  pos

mkCharGrid = ->
  numrows = 10
  numcols = 20
  rows = []
  for r in [0...numrows]
    row = []
    for c in [0...numcols]
      row.push "."
    rows.push row
  rows

module.exports = AsciiView
