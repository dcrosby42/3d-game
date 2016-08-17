Perlin = require 'proc-noise'
_ = require 'lodash'

canvas = null

createCanvas = (width,height) ->
  canvas = document.createElement('canvas')
  canvas.id = 'noise-spike-canvas'
  canvas.setAttribute('width',"#{width}")
  canvas.setAttribute('height',"#{height}")
  canvas.setAttribute('style',"width:#{width}px; height:#{height};")
  document.getElementById('game1').appendChild(canvas)
  return canvas

class Buffer2d
  constructor: (@width,@height) ->
    @data = new Array(@height*@width)

  populate: (fn,offx,offy) ->
    for y in [0...@height]
      for x in [0...@width]
        @data[(y * @width) + x] = fn(x+offx,y+offy)
    @data

  scan: (fn) ->
    for y in [0...@height]
      for x in [0...@width]
        val = @data[(y * @width) + x]
        fn(val,x,y)



drawBuffer = (canvas,scale,buffer,offx,offy) ->
  ctx = canvas.getContext('2d')
  buffer.scan (val, x,y) ->
    sx = (x+offx) * scale
    sy = (y+offy) * scale
    ctx.fillStyle = "rgb(#{val},#{val},#{val})"
    ctx.fillRect(sx,sy,scale,scale)
    

rando = (x,y) ->
  Math.floor(Math.random() * 100)+100

radi = (x,y) ->
  mx = 60
  my = 40
  dx = Math.abs(x-mx)
  dy = Math.abs(y-my)
  Math.floor(Math.sqrt((dx*dx) + (dy*dy)) / 70 * 250)



mkNoiseFn = (params) ->
  perlin = new Perlin(params.seed)
  perlin.noiseDetail(params.lod, params.falloff)
  return (x,y) ->
    Math.floor(perlin.noise(x/params.scale,y/params.scale) * 255)

runNoiseExperiment = ->
  # Create a drawing surface
  canvas  = createCanvas(500,500)

  genParams =
    seed: 40
    lod: 6
    falloff: 0.6
    scale: 100

  # Create a drawing surface
  generateAndDrawChunk = (h,v) ->
    chw = 100
    buf = new Buffer2d(chw, chw)
    fn = mkNoiseFn(genParams)
    xoff= h * chw
    yoff= v * chw
    buf.populate(fn,xoff,yoff)
    drawBuffer(canvas,1,buf,xoff,yoff)

  # Make a list of chunks to create
  pairs = []
  for y in [0...5]
    for x in [0...5]
      pairs.push [x,y]
  pairs = _.shuffle(pairs) # shuffle them uot of order

  # In delayed fashion, walk through each chunk coord pair, generate and draw:
  walkThru = ->
    pair = pairs.pop()
    if pair
      generateAndDrawChunk pair[0],pair[1]
      setTimeout walkThru, 0
  setTimeout walkThru, 0


module.exports = runNoiseExperiment
