canvas = null

createCanvas = (width,height) ->
  canvas = document.createElement('canvas')
  canvas.id = 'noise-spike-canvas'
  canvas.setAttribute('width',"#{width}")
  canvas.setAttribute('height',"#{height}")
  canvas.setAttribute('style',"width:#{width}px; height:#{height};")
  document.getElementById('game1').appendChild(canvas)
  return canvas

drawSquares = ->
  ctx = canvas.getContext('2d')
  ctx.fillStyle="#FF0000"
  x = 25
  y = 25
  w = 4
  h = 4
  ctx.fillRect(x,y,w,h)

generateData = (dw,dh,fn) ->
  rows = []
  for y in [0...dh]
    row = []
    for x in [0...dw]
      row.push fn(x,y)
    rows.push row
  return rows

drawStuff = (canvas,data,tileSize) ->
  ctx = canvas.getContext('2d')
  for row,i in data
    y = i * tileSize
    for c,j in row
      x = j * tileSize
      ctx.fillStyle = "rgb(#{c},#{c},#{c})"
      ctx.fillRect(x,y,tileSize,tileSize)


drawColorGrid = ->
  ctx = canvas.getContext('2d')
  for i in [0...6]
    for j in [0..6]
      ctx.fillStyle = 'rgb(' + Math.floor(255-42.5*i) + ',' + Math.floor(255-42.5*j) + ',0)'
      ctx.fillRect(j*25,i*25,25,25)

rando = (x,y) ->
  Math.floor(Math.random() * 100)+100

radi = (x,y) ->
  mx = 60
  my = 40
  dx = Math.abs(x-mx)
  dy = Math.abs(y-my)
  Math.floor(Math.sqrt((dx*dx) + (dy*dy)) / 70 * 250)


Perlin = require 'proc-noise'
newPerlin = (seed,scale=50,lod=4,falloff=0.5) ->
  perlin = new Perlin(seed)
  perlin.noiseDetail(lod,falloff)
  return (x,y) ->
    Math.floor(perlin.noise(x/scale,y/scale) * 255)

  # var PerlinGenerator = require("proc-noise");
  # var Perlin = new PerlinGenerator(); // seeds itself if no seed is given as an argument
  # console.log( Perlin.noise( 817.2 ) ); // one dimensional
  # console.log( Perlin.noise( 9192, 818.53 ) ); // two dimensional
  # console.log( Perlin.noise( 5, 7, 9.22 ) ); // three dimensional

setup = ->
  fn = newPerlin(123456789, 150,8,0.6)
  data = generateData(500,500,fn)
  canvas  = createCanvas(500,500)
  drawStuff(canvas,data,1)


module.exports = setup
