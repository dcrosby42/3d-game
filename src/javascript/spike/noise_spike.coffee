canvas = null

addCanvas = ->
  width=400
  height=400
  canvas = document.createElement('canvas')
  canvas.id = 'noise-spike-canvas'
  canvas.setAttribute('width',"#{width}")
  canvas.setAttribute('height',"#{height}")
  canvas.setAttribute('style',"width:#{width}px; height:#{height};")
  document.getElementById('game1').appendChild(canvas)

drawSquares = ->
  ctx = canvas.getContext('2d')
  ctx.fillStyle="#FF0000"
  x = 25
  y = 25
  w = 4
  h = 4
  ctx.fillRect(x,y,w,h)

drawStuff = ->
  ctx = canvas.getContext('2d')
  for i in [0...6]
    for j in [0..6]
      ctx.fillStyle = 'rgb(' + Math.floor(255-42.5*i) + ',' + Math.floor(255-42.5*j) + ',0)'
      ctx.fillRect(j*25,i*25,25,25)
setup = ->
  addCanvas()
  # drawSquares()
  drawStuff()


module.exports = setup
