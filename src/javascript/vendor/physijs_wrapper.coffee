THREE = require 'three'

# Physijs is a physics library that essentially transforms Three.js into a physics world. It does its simulation in a separate thread.
#
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# 
# physijs_worker.js and ammo.js 
#    physijs_worker.js MUST BE AVAILABLE FOR DOWNLOAD AT RUNTIME
#      
#    physi.js is hardcoded to use "physijs_worker.js"
#    physijs_worker.js is bundled up with ammo.js using the browserify tools, see gulp/config.js under browserify.bundleConfigs:
#         {
#           entries: src + '/javascript/vendor/physijs_worker.js',
#           dest: dest,
#           outputName: 'physijs_worker.js'
#         }
#
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# Physijs home: https://github.com/chandlerprall/Physijs
#   2016-10-08 dcrosby42 -- Physijs itself at version 7a5372647f5af47732e977c153c0d1c2550950a0, Oct 19 2015
# Ammo.js home: https://github.com/kripken/ammo.js
#   This is a JS port of Bullet physics
#
# What's the big fuss about with this wrapper and the src files?
#
# Out of the box, physi.js source isn't node/browserify/webpack friendly.
# There are two projects out there trying to solve this, "physijs for webpack" and "physijs-browserify".
#   As of Oct 2016 physijs is out of date wrt the latest Physijs.  I started using physijs-browserify but decided to smush this
#   directly into my vendor dir and use it my way.
#
# ./physi.js and ./physijs_worker.js 
#   - I copied these out of node_modules/physijs/src/ from the "physijs for webpack" node module v 0.0.4
#   - The only diff in the webpack version is tweaks to the require/window code.
#   - I then had to hack physi.js a little more because.
#      Line 393: this._worker = new Worker( 'physijs_worker.js' ); 
#
# ./ammo.js
#   - Copied this out of Physijs git project under examples/js/ammo.js
#   - Not sure precisely which version of Ammo.js this is.
#     - It's not identical to the github release 0.0.2 or 0.0.3 nor the current build https://github.com/kripken/ammo.js/blob/e9f38a4bfdd521ac81cc4a288506b70615499556/builds/ammo.js
#       (which was Feb 12 2016)
#

module.exports = require('./physi')(THREE)
