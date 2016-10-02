class HitProfile
  constructor: ->
    @layerMask = 0

  setLayerMask: (@layerMask) ->

  @sphere: (r) ->
    new SphereProfile(r)

class SphereProfile
  constructor: (@radius) ->
    @sphere = new THREE.Sphere(vec3(), @radius)

module.exports = HitProfile
