Systems = require './systems'
Construct = require './construct'
Maps = require './maps'

# {euler,vec3,quat} = require '../lib/three_helpers'

exports.addInitialEntities = (estore) ->
  mapName = "level1"

  estore.createEntity Construct.playerPiece(tag:"player_piece", position: Maps.get(mapName).getStartPosition())
  estore.createEntity Construct.playerFollowCamera(followTag:"player_piece")
  
  for comps in Construct.gameBoard(mapName)
    estore.createEntity comps
  
  return estore


exports.getSystems = ->
  [
    Systems.collision_system()
    Systems.controller_system()
    Systems.player_piece_control_system()

    Systems.pellet_system()

    Systems.camera_follow_system()
  ]

exports.getInputConfig = ->
  {
    keyboardConfig:  # FIXME: KeyboardInput component cannot actually handle changes to this state, so don't modify it
      tag: "player1"
      mappings:
        "w": 'forward'
        "a": 'strafeLeft'
        "s": 'backward'
        "d": 'strafeRight'
        "left": 'orbitLeft'
        "right": 'orbitRight'
        "up": 'orbitUp'
        "down": 'orbitDown'
        "space": 'jump'
    gamepadConfig:# FIXME: GamepadInput component cannot actually handle changes to this state, so don't modify it
      tag: "player1"
      gamepadIndex: 0
      mappings:
        "dpad_up": 'forward'
        "dpad_left": 'strafeLeft'
        "dpad_down": 'backward'
        "dpad_right": 'strafeRight'
        "left_bumper": 'turnLeft'
        "right_bumper": 'turnRight'
        "three": 'jump'
        "axis_left_x": 'strafe'
        "axis_left_y": 'drive'
        "axis_right_x": 'orbitX'
        "axis_right_y": 'orbitY'
  }
