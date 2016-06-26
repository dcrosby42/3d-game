React = require 'react'
ReactDOM = require 'react-dom'

GameRoot = require './elements/game_root'
# Main = require './modules/main'
AsciiMaze = require './modules/ascii_maze'

gameDiv = document.getElementById('game1')

ReactDOM.render <GameRoot module={AsciiMaze}/>, gameDiv
