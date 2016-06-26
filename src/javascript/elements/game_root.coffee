React = require 'react'
React3 = require 'react-three-renderer'

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
    
    @setState main: @props.module.initialState()
  
  componentDidMount: ->

  componentWillUnmount: ->

  _handleAction: (action) ->
    return if @state.error?
    try
      [updated,effects] = @props.module.update(@state.main, action)
      @setState main: updated unless updated.NO_SYNC
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
