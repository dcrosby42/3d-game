THREE = Three = require 'three'

class SceneWrapper
  constructor: ({@canvas,@width,@height}) ->
    @scene = new THREE.Scene()

    @renderer = new THREE.WebGLRenderer(canvas: @canvas)
    @renderer.setSize( @width, @height)

    # XXX
    aspect = @width/@height
    @camera = new THREE.PerspectiveCamera( 75, aspect, 1, 1000 )
    @camera.position.z = 500

    
    geometry = new THREE.IcosahedronGeometry(200, 1 )
    material =  new THREE.MeshBasicMaterial({
                                              color: 0xfff999fff,
                                              wireframe: true,
                                              wireframeLinewidth:1 })

    mesh = new THREE.Mesh(geometry, material)
    @scene.add( mesh )


  updateAndRender: (estore, width, height) ->
    if width != @width or height != @height
      console.log "!! SceneWrapper.update TODO: dimensions changed, but we're not equipped to handle that change yet !!"

    aspect = @width/@height

    if @camera?
      @renderer.render(@scene, @camera)
    else
      throw new Error("SceneWrapper.updateAndRender: no camera!")

module.exports = SceneWrapper
