React = require 'react'
ReactDOM = require 'react-dom'
NonJsx = require './non-jsx'

el = React.createElement(NonJsx)
ReactDOM.render(el, document.getElementById('main'))
