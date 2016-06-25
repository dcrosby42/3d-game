React = require 'react'
React3 = require 'react-three-renderer'

Fx = require './fx'
PostOffice = require './flarp/post_office'

Main = require './main'


GmRoot = React.createClass
  getInitialState: ->
    {
      main: null
      error: null
    }

  componentWillMount: ->
    console.log "GM componentWillMount"
    @postOffice = new PostOffice()
    @actions = @postOffice.newMailbox()
    @actions.signal.subscribe @_handleAction
    
    @setState main: @props.module.initialState()
  
  componentDidMount: ->
    console.log "GM componentDidMount"

  componentWillUnmount: ->
    console.log "GM componentWillUnmount"

  _handleAction: (action) ->
    return if @state.error?
    try
      [updated,effects] = @props.module.update(@state.main, action)
      @setState main: updated unless updated.NO_SYNC
      Fx.processEffects(effects,@actions.address)

    catch e
      console.log e
      @setState error: e

  render: ->
    err = if @state.error? then <div id="err">ERR!</div>
    <div id="root">
      {err}
      {@props.module.view(@state.main, @actions.address)}
    </div>

module.exports = GmRoot
