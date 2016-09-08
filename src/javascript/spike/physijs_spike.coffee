THREE = require 'three'

# 1. Update package.json, then run "npm install":
#
#   "three": "^0.79.0",
#   "physijs": "^0.0.4",
#   "physijs-browserify": "^0.0.2"
#
# 2. Get delayed-load libs into place in build/
#   cd node_modules/physijs-browserify/libs/
#   cp ammo.js ../../../build/
#   cp physi-worker.js ../../../build/
#   cd ../../..
#
# 3. Get grass.png
#   cd build/images/
#   wget http://chandlerprall.github.io/Physijs/examples/images/grass.png
#   cd ../..
#

PhysijsBrowserify = require 'physijs-browserify'
Physijs = PhysijsBrowserify(THREE)

Physijs.scripts.worker = 'physi-worker.js'
Physijs.scripts.ammo = 'ammo.js'

renderer = null
scene = null
light = null
ground = null
ground_geometry = null
ground_material = null
camera = null

initScene = ->
  console.log "initScene start"
  # TWEEN.start()
  
  renderer = new THREE.WebGLRenderer({ antialias: true })
  renderer.setSize( window.innerWidth, window.innerHeight )
  renderer.shadowMapEnabled = true
  renderer.shadowMapSoft = true

  document.getElementById( 'game1' ).appendChild( renderer.domElement )
  
  # render_stats = new Stats()
  # render_stats.domElement.style.position = 'absolute'
  # render_stats.domElement.style.top = '0px'
  # render_stats.domElement.style.zIndex = 100
  # document.getElementById( 'viewport' ).appendChild( render_stats.domElement )
  
  # physics_stats = new Stats()
  # physics_stats.domElement.style.position = 'absolute'
  # physics_stats.domElement.style.top = '50px'
  # physics_stats.domElement.style.zIndex = 100
  # document.getElementById( 'viewport' ).appendChild( physics_stats.domElement )
  
  scene = new Physijs.Scene({ fixedTimeStep: 1 / 120 })
  scene.setGravity(new THREE.Vector3( 0, -30, 0 ))

  updateFn = ->
    # console.log "updateFn"
    scene.simulate( undefined, 2 )
    # physics_stats.update()

  scene.addEventListener( 'update', updateFn)
  
  camera = new THREE.PerspectiveCamera(
    35,
    window.innerWidth / window.innerHeight,
    1,
    1000
  )
  camera.position.set( 60, 50, 60 )
  camera.lookAt( scene.position )
  scene.add( camera )
  
  # Light
  light = new THREE.DirectionalLight( 0xFFFFFF )
  light.position.set( 20, 40, -15 )
  light.target.position.copy( scene.position )
  light.castShadow = true
  light.shadowCameraLeft = -60
  light.shadowCameraTop = -60
  light.shadowCameraRight = 60
  light.shadowCameraBottom = 60
  light.shadowCameraNear = 20
  light.shadowCameraFar = 200
  light.shadowBias = -.0001
  light.shadowMapWidth = light.shadowMapHeight = 2048
  light.shadowDarkness = 0.7
  scene.add( light )
  
  # Materials
  ground_material = Physijs.createMaterial(
    new THREE.MeshLambertMaterial({ map: THREE.ImageUtils.loadTexture( 'images/grass.png' ) }), # FIXME get this image in place under build/
    0.8, # high friction
    0.4 # low restitution
  )
  ground_material.map.wrapS = THREE.RepeatWrapping
  ground_material.map.wrapT = THREE.RepeatWrapping
  ground_material.map.repeat.set( 2.5, 2.5 )
  
  # Ground
  # NoiseGen = new SimplexNoise
  
  ground_geometry = new THREE.PlaneGeometry( 75, 75, 50, 50 )
  for vertex in ground_geometry.vertices
    # vertex.z = NoiseGen.noise( vertex.x / 10, vertex.y / 10 ) * 2
    vertex.z = 1
    
  ground_geometry.computeFaceNormals()
  ground_geometry.computeVertexNormals()
  
  # If your plane is not square as far as face count then the HeightfieldMesh
  # takes two more arguments at the end: # of x faces and # of y faces that were passed to THREE.PlaneMaterial
  ground = new Physijs.HeightfieldMesh(
    ground_geometry,
    ground_material,
    0, # mass
    50,
    50
  )
  ground.rotation.x = Math.PI / -2
  ground.receiveShadow = true
  scene.add( ground )
  
  requestAnimationFrame( render )
  scene.simulate()
  
  createShape()

  console.log "initScene done"
	
render = ->
  # console.log "render"
  requestAnimationFrame( render )
  renderer.render( scene, camera )
	
createShapeCtx = ->
  addshapes = true
  shapes = 0
  box_geometry = new THREE.CubeGeometry( 3, 3, 3 )
  sphere_geometry = new THREE.SphereGeometry( 1.5, 32, 32 )
  cylinder_geometry = new THREE.CylinderGeometry( 2, 2, 1, 32 )
  cone_geometry = new THREE.CylinderGeometry( 0, 2, 4, 32 )
  octahedron_geometry = new THREE.OctahedronGeometry( 1.7, 1 )
  torus_geometry = new THREE.TorusKnotGeometry( 1.7, 0.2, 32, 4 )
  
  # setTimeout(
  #   function addListener() {
  #     var button = document.getElementById( 'stop' );
  #     if ( button ) {
  #       button.addEventListener( 'click', function() { addshapes = false; } );
  #     } else {
  #       setTimeout( addListener );
  #     }
  #   }
  # );
    
  doCreateShape = ->
    # console.log "doCreateShape"

    material = new THREE.MeshLambertMaterial({ opacity: 0, transparent: true })
    shape = null
    
    shape = if Math.floor(Math.random() * 2) == 0
      new Physijs.BoxMesh( box_geometry, material )
    else
      new Physijs.SphereMesh(
        sphere_geometry,
        material,
        undefined,
        { restitution: Math.random() * 1.5 }
      )
      
    shape.material.color.setRGB( Math.random() * 100 / 100, Math.random() * 100 / 100, Math.random() * 100 / 100 )
    shape.castShadow = true
    shape.receiveShadow = true
    
    shape.position.set(
      Math.random() * 30 - 15,
      20,
      Math.random() * 30 - 15
    )
    
    shape.rotation.set(
      Math.random() * Math.PI,
      Math.random() * Math.PI,
      Math.random() * Math.PI
    )
    
    if addshapes
      shape.addEventListener( 'ready', createShape )

    scene.add( shape )
    
    shape.material.opacity = 1
    # new TWEEN.Tween(shape.material).to({opacity: 1}, 500).start();
    
    # document.getElementById('shapecount').textContent = (++shapes) + ' shapes created';
  
  csfn = ->
    setTimeout( doCreateShape, 250 )
  csfn

createShape = createShapeCtx()




# createCanvas = (width,height) ->
#   canvas = document.createElement('canvas')
#   canvas.id = 'physijs-canvas'
#   canvas.setAttribute('width',"#{width}")
#   canvas.setAttribute('height',"#{height}")
#   canvas.setAttribute('style',"width:#{width}px; height:#{height};")
#   document.getElementById('game1').appendChild(canvas)
#   return canvas

# runNoiseExperiment = ->
#   # Create a drawing surface
#   canvas  = createCanvas(500,500)
#
#   genParams =
#     seed: 40
#     lod: 6
#     falloff: 0.6
#     scale: 100
#
#   # Create a drawing surface
#   generateAndDrawChunk = (h,v) ->
#     chw = 100
#     buf = new Buffer2d(chw, chw)
#     fn = mkNoiseFn(genParams)
#     xoff= h * chw
#     yoff= v * chw
#     buf.populate(fn,xoff,yoff)
#     drawBuffer(canvas,1,buf,xoff,yoff)
#
#   # Make a list of chunks to create
#   pairs = []
#   for y in [0...5]
#     for x in [0...5]
#       pairs.push [x,y]
#   pairs = _.shuffle(pairs) # shuffle them uot of order
#
#   # In delayed fashion, walk through each chunk coord pair, generate and draw:
#   walkThru = ->
#     pair = pairs.pop()
#     if pair
#       generateAndDrawChunk pair[0],pair[1]
#       setTimeout walkThru, 0
#   setTimeout walkThru, 0


module.exports = initScene
