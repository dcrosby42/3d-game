React = require 'react'
ReactDOM = require 'react-dom'

# Practice = require './spike/practice'
# Practice2 = require './spike/practice2'
# Root = require './spike/parent'
Root = require './spike/gm'
Main = require './spike/gm/main'

ReactDOM.render <Root module={Main}/>,
                document.getElementById('main')
