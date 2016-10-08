React = require 'react'
ReactDOM = require 'react-dom'
gameDiv = document.getElementById('game1')
GameRoot = require './elements/game_root'
Pacman = require './pacman'
ReactDOM.render <GameRoot module={Pacman}/>, gameDiv

# GamepadSpike = require './spike/gamepad.coffee'
# GamepadSpike()

# NoiseSpike = require './spike/noise_spike'
# NoiseSpike()

# PhysijsSpike = require './spike/physijs_spike'
# window.onload = PhysijsSpike

