React = require 'react'

Fx = require '../lib/fx'
PostOffice = require '../lib/flarp/post_office'

GameRoot = React.createClass
  getInitialState: ->
    {
      main: null
      error: null
    }

  componentWillMount: ->
    @postOffice = new PostOffice()
    @actions = @postOffice.newMailbox()
    @actions.signal.subscribe @_handleAction

    [model,effects] = @props.module.initialState()
    @setState main: model
    Fx.processEffects(effects,@actions.address)
  
  componentDidMount: ->

  componentWillUnmount: ->

  shouldComponentUpdate: (nextProps, nextState) ->
    if nextState.NO_RENDER
      return false
    true

  _handleAction: (action) ->
    return if @state.error?
    try
      [updated,effects] = @props.module.update(@state.main, action)
      @setState main: updated
      Fx.processEffects(effects,@actions.address)

    catch e
      console.log "!! ERROR in GameRoot._handleAction",e
      @setState error: e

  render: ->
    err = if @state.error? then <div id="err">ERR!</div>
    <div id="game-root">
      {err}
      {@props.module.view(@state.main, @actions.address)}
    </div>

module.exports = GameRoot
