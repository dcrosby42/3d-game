React = require 'react'
ReactDOM = require 'react-dom'

# NonJsx = require './non-jsx'
# el = React.createElement(NonJsx)
# ReactDOM.render(el, document.getElementById('main'))

Simple = require './simple'
# el = React.createElement(Simple)
el = Simple.view()
ReactDOM.render(el, document.getElementById('main'))
