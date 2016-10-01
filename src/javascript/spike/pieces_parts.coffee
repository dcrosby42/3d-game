THREE = Three = require 'three'
{euler,vec3,quat} = require '../lib/three_helpers'
Physijs = require '../vendor/physijs_wrapper'


module.exports.addChair = (scene) ->
  loader = new THREE.TextureLoader()

  chair_material = Physijs.createMaterial(
    new THREE.MeshLambertMaterial(map: loader.load( 'images/wood.jpg' ))
    0.6 # medium friction
    0.2 # low restitution
  )
  chair_material.map.wrapS = THREE.RepeatWrapping
  chair_material.map.wrapT = THREE.RepeatWrapping
  chair_material.map.repeat.set( 0.25, 0.25 )

  buildBack = ->
    back = new Physijs.BoxMesh(
      new THREE.BoxGeometry( 5, 1, 0.5 )
      chair_material
    )
    back.position.y = 5
    back.position.z = -2.5
    back.castShadow = true
    back.receiveShadow = true
    
    # rungs - relative to back
    _object = new Physijs.BoxMesh(
      new THREE.BoxGeometry( 1, 5, 0.5 )
      chair_material
    )
    _object.position.y = -3
    _object.position.x = -2
    _object.castShadow = true
    _object.receiveShadow = true
    back.add( _object )
    
    _object = new Physijs.BoxMesh(
      new THREE.BoxGeometry( 1, 5, 0.5 )
      chair_material
    )
    _object.position.y = -3
    _object.castShadow = true
    _object.receiveShadow = true
    back.add( _object )
    
    _object = new Physijs.BoxMesh(
      new THREE.BoxGeometry( 1, 5, 0.5 )
      chair_material
    )
    _object.position.y = -3
    _object.position.x = 2
    _object.castShadow = true
    _object.receiveShadow = true
    back.add( _object )
    
    return back
		
  buildLegs = ->
    # back left
    leg = new Physijs.BoxMesh(
      new THREE.BoxGeometry( 0.5, 4, 0.5 )
      chair_material
    )
    leg.position.x = 2.25
    leg.position.z = -2.25
    leg.position.y = -2.5
    leg.castShadow = true
    leg.receiveShadow = true
    
    # back right - relative to back left leg
    _leg = new Physijs.BoxMesh(
      new THREE.BoxGeometry( 0.5, 4, 0.5 ),
      chair_material
    )
    _leg.position.x = -4.5
    _leg.castShadow = true
    _leg.receiveShadow = true
    leg.add( _leg )
    
    # front left - relative to back left leg
    _leg = new Physijs.BoxMesh(
      new THREE.BoxGeometry( 0.5, 4, 0.5 ),
      chair_material
    )
    _leg.position.z = 4.5
    _leg.castShadow = true
    _leg.receiveShadow = true
    leg.add( _leg )
    
    # front right - relative to back left leg
    _leg = new Physijs.BoxMesh(
      new THREE.BoxGeometry( 0.5, 4, 0.5 ),
      chair_material
    )
    _leg.position.x = -4.5
    _leg.position.z = 4.5
    _leg.castShadow = true
    _leg.receiveShadow = true
    leg.add( _leg )
    
    return leg
		
  # seat of the chair
  chair = new Physijs.BoxMesh(
    new THREE.BoxGeometry( 5, 1, 5 ),
    chair_material
  )
  chair.castShadow = true
  chair.receiveShadow = true
  
  # back - relative to chair ( seat )
  back = buildBack()
  chair.add( back )
  
  # legs - relative to chair ( seat )
  legs = buildLegs()
  chair.add( legs )
  
  chair.position.y = 10
  chair.position.x = 0
  chair.position.z = 0
  
  # chair.rotation.set(
  #   Math.random() * Math.PI * 2,
  #   Math.random() * Math.PI * 2,
  #   Math.random() * Math.PI * 2
  # )
  
  scene.add( chair )

  null

module.exports.addThinger = (scene) ->
  material = Physijs.createMaterial(
    new THREE.MeshPhongMaterial(color: 0x5555FF, wireframe: true)
    0.6 # medium friction
    0.2 # low restitution
  )

  ball = new Physijs.SphereMesh(
    new THREE.SphereGeometry(1, 10, 10)
    material
  )
  ball.position.y = 5
  ball.castShadow = true
  ball.receiveShadow = true

  box = new Physijs.BoxMesh(
    new THREE.BoxGeometry(0.5, 0.5, 0.5, 5,5)
    material
  )
  box.castShadow =true
  box.receiveShadow =true
  box.position.y = -1

  ball.add box

  scene.add ball

module.exports.addPellets = (scene) ->
  length = 10
  width = 10
  list = []
  y = 2

  mass = 0.1
  friction = 1
  restitution = 0.2
  # @geometry = new THREE.SphereGeometry(0.1, 10,10)
  geometry = new THREE.BoxGeometry(0.2,0.2,0.2)
  threeMaterial = new THREE.MeshPhongMaterial(color: 0xffffff)
  material = Physijs.createMaterial(threeMaterial, friction, restitution)

  for i in [0...length]
    for j in [0...width]
      pos = vec3(j,y,i)

      shape = new Physijs.BoxMesh( geometry, material, mass)
      shape.castShadow = true
      shape.receiveShadow = true
      shape.position.set(pos.x, pos.y, pos.z)
      shape.addEventListener 'ready', ->
        linearDamping = 0.25
        angularDamping = 0.4
        shape.setDamping(linearDamping, angularDamping)
        shape.position.set(pos.x,pos.y,pos.z)

      scene.add shape

