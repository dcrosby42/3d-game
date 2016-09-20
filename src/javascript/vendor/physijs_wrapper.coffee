THREE = require 'three'
PhysijsBrowserify = require 'physijs-browserify'
Physijs = PhysijsBrowserify(THREE)

Physijs.scripts.worker = 'physi-worker.js'
Physijs.scripts.ammo = 'ammo.js'

module.exports = Physijs
