Sketches = {}
{euler,vec3,quat} = require '../lib/three_helpers'

cache = {}

#
# GET
#

module.exports =
  get: (name) ->
    if cache[name]?
      return cache[name]
    else
      sketch = Sketches[name]
      if sketch?
        map = new Map(name,sketch)
        cache[name] = map
        return map
      else
        throw new Error("No map data for '#{name}'")
#
####################################################


class Map
  constructor: (@name,@sketch) ->
    @tileWidth = 1.1
    @width = @sketch[0].length * @tileWidth
    @length = @sketch.length * @tileWidth

    xoffset = -@width/2 + @tileWidth/2
    zoffset = -@length/2 + @tileWidth/2

    @pelletLocs = []
    @blockLocs = []
    @startPos = null

    for rowSketch,r in @sketch
      for char,c in rowSketch
        z = r*@tileWidth + zoffset
        x = c*@tileWidth + xoffset
        switch char
          when "."
            pos = vec3(x,1,z)
            @pelletLocs.push pos
          when "#"
            pos = vec3(x,0,z)
            @blockLocs.push pos
          when "C"
            @startPos = vec3(x,1,z)

    @startPos ?= vec3(0+xoffset, 1, 0+zoffset)

  getTileWidth: -> @tileWidth

  getPelletLocations: -> @pelletLocs

  getBlockLocations: -> @blockLocs

  getStartPosition: -> @startPos

  getLength: -> @length

  getWidth: -> @width


#
# DATA
#

Sketches["level1"] = [
  "########## #########"
  "#..................#"
  "#.#.######.#######.#"
  "#.#.#............#.#"
  "#.#.#.##########.#.#"
  "#.#...#        #.#.#"
  "#.#.#.#        #.#.#"
  "#.#.#.##########.#.#"
  "#.#..............#.#"
  " ...#####..#####... "
  "#.#......C.......#.#"
  "#.#.####.#######.#.#"
  "#.#.#  #....#  #.###"
  "#.#.#  #.##.#  #.#.#"
  "#.#.#  #..#.#  #.#.#"
  "#.#.#######.####.#.#"
  "#.#............###.#"
  "#.########.#######.#"
  "#..................#"
  "########## #########"
]

#                                                                                  
#                             #                                                    
#          #    #      ##    ###                                                   
#               #             #                                                    
#                                                                                  
#                                                                                  
#                            ###                                                   
#                             #                                                    
#                                                                                  
#                            ###                                                    
#                                                                                  
#                                                                                  
#                                                                                  
#                                                                                  
#                                                                                  
#                                                                                  
#                                                                                  
#                                                                                  
#                                                                                  
#                                                                                  
#                                                                                  
