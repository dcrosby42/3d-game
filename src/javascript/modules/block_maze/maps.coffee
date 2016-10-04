Sketches = {}
{euler,vec3,quat} = require '../../lib/three_helpers'

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
    @pelletLocs = []
    @blockLocs = []
    @startPos = vec3(0,1,0)

    for rowSketch,r in @sketch
      for char,c in rowSketch
        switch char
          when "."
            pos = vec3(c,1,r)
            @pelletLocs.push pos
          when "#"
            pos = vec3(c,0,r)
            @blockLocs.push pos
          when "C"
            @startPos = vec3(c,1,r)

  getPelletLocations: -> @pelletLocs

  getBlockLocations: -> @blockLocs

  getStartPosition: -> @startPos


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
