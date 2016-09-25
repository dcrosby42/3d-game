React = require 'react'

SceneWrapper = require './scene_wrapper'

MazeView = React.createClass
  displayName: 'FasterMazeView'

  getInitialState: ->
    {
      width: @props.width
      height: @props.height
      simAddress: @props.simAddress
      collisionAddress: @props.collisionAddress
    }
  
  # Called ONCE just before initial render.
  componentWillMount: ->

  # Called ONCE just after initial render. DOM refs of children are available.
  componentDidMount: ->
    @sceneWrapper = new SceneWrapper
      canvas: @canvas
      width: @state.width
      height: @state.height
      simAddress: @state.simAddress
      collisionAddress: @state.collisionAddress
  
  # Called once, just before removal from DOM.
  componentWillUnmount: ->

  componentWillReceiveProps: (nextProps) ->
    if nextProps.width != @state.width or nextProps.height != @state.height
      @setState {
        width: nextProps.width
        height: nextProps.height
      }

    @sceneWrapper.updateAndRender(nextProps.estore, nextProps.width, nextProps.height)
    return null

  # Determine if render and DOM flushing should occur.
  # Not called on initial render.
  shouldComponentUpdate: (nextProps, nextState) ->
    # Since SceneWrapper.updateAndRender handles the updating, this component
    # should only re-render if the shape changes:
    return (nextState.width != @state.width) or (nextState.height != @state.height)

  # Called just before render assuming shouldComponentUpdate returned true.
  # DO NOT CALL setState in here.
  # Not called on initial render.
  componentWillUpdate: (nextProps, nextState) ->

  # Called after render and DOM changes have been flushed
  # Not called on initial render.
  componentDidUpdate: (prevProps, prevState) ->

  render: ->
    <canvas 
      width={@state.width} 
      height={@state.height} 
      style={width:@state.width, height:@state.height} 

      ref={(ref) => @canvas = ref} 
    />

module.exports = MazeView

