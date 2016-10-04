C = require './components'
T = C.Types
Objects = require './objects'

Maps = require './maps'

{euler,vec3,quat} = require '../../lib/three_helpers'


class Construct
  @playerPiece: ({tag,position}) ->
    position ?= vec3(0,2,0)
    console.log "PlayerPiece construct at",position
    tag ?= 'the_player'
    [
      C.buildCompForType(T.Name, name: 'Player One')
      C.buildCompForType(T.Tag, name: tag)
      C.buildCompForType(T.Location, position: position)
      C.buildCompForType(T.Physical,
        kind: 'pacman'
        data: new C.Physical.Ball(0xaaaa22)
        receiveCollisions: true
        # axisHelper: 2
      )
      C.buildCompForType(T.Controller, inputName: 'player1')
    ]

  @playerFollowCamera: (opts={}) ->
    opts.followTag ?= 'the_player'
    [
      C.buildCompForType(T.Name, name: 'Follow Camera')
      C.buildCompForType(T.FollowCamera, followTag: opts.followTag)
      C.buildCompForType(T.Location, position: vec3(0,3,5))
    ]

  @pacMap: (mapName) ->
    [
      C.buildCompForType(T.Name, name: 'Pac Map')
      C.buildCompForType(T.Location)
      C.buildCompForType(T.Physical,
        kind: 'pac_map'
        data: new C.Physical.PacMap(mapName)
        shapeType: Objects.ShapeType.Static
      )
    ]

  @manyPellets: (pos) ->
    length = 10
    width = 10
    list = []
    y = 1
    for i in [0...length]
      for j in [0...width]
        list.push @pellet(position: vec3(j,y,i))
    list

  @pellet: ({position}) ->
    [
      C.buildCompForType(T.Tag, name: 'pellet')
      C.buildCompForType(T.Location, position: position)
      C.buildCompForType(T.Physical, kind: 'pellet')
    ]

  @gameBoard: (mapName) ->
    compLists = []

    compLists.push @pacMap(mapName)

    map = Maps.get(mapName)
    for pos in map.getPelletLocations()
      compLists.push @pellet(position: pos)

    compLists
    

  @sineGrassChunk: (pos) ->
    groundQuat = quat()
    groundQuat.setFromAxisAngle(vec3(1, 0, 0), -Math.PI / 2)
    [
      C.buildCompForType(T.Location, position: pos, quaternion: groundQuat)
      C.buildCompForType(T.Physical,
        kind: 'sine_grass_terrain'
      )
    ]

  @cube: (pos,color=0xffffff,name='Cube') ->
    [
      C.buildCompForType(T.Name, name: name)
      C.buildCompForType(T.Location, position: pos)
      C.buildCompForType(T.Physical,
        kind: 'cube'
        data: new C.Physical.Cube(color)
      )
    ]

  @slab: (pos,dim,color=0xffffff,name='Slab') ->
    [
      C.buildCompForType(T.Name, name: 'Slab')
      C.buildCompForType(T.Location, position: pos)
      C.buildCompForType(T.Physical,
        kind: 'block'
        shapeType: Objects.ShapeType.Static
        data: new C.Physical.Block(color, dim)
      )
    ]

  @slabFloor: ->
    compLists = []
    dark=false
    back = -2
    left = -2
    width = 4
    length = 4
    height = 0.5 
    y = 2
    z = -2
    lightColor = 0xffffff
    darkColor = 0x333366

    numXSlabs = 10 
    numZSlabs = 10

    for i in [0...numZSlabs]
      z = back + i*length
      for j in [0...numXSlabs]
        dark = if i % 2 == 0
          j % 2 == 0
        else
          j % 2 != 0
        x = left + j*width
        color = if dark then darkColor else lightColor
        compLists.push @slab(vec3(x, y, z), vec3(width,height,length), color)
        dark = !dark

    return compLists

module.exports = Construct




