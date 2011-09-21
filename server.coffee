# Template parser
jade = require('jade')
fs = require('fs')
sys = require('sys')
path = require('path')
# Database
mongoose = require('mongoose').Mongoose
# less
less = require('less')
# Framework
express = require('express')
app = express.createServer()


app.configure ->
  app.set('views', __dirname + '/views')
  app.set('view engine', 'jade')
  app.set('view options', {layout: false})
  app.use(express.static(__dirname + '/public'))

uptime = 0
app.get '/', (req, res) ->
  res.render 'index.jade'

app.get '/css/*.*', (req, res) ->
  file = req.params[0] + '.less'
  file = path.join('./style/', path.normalize(file))
  fs.readFile file, 'utf-8', (e, str) ->
    return res.send 'Not found.', 404 if e

    new(less.Parser)({paths: [path.dirname(file)], optimization: 0 })
      .parse str, (err, tree) -> res.send tree.toCSS(), {'Content-Type': 'text/css'}, 201

app.listen 8124, "0.0.0.0"
console.log 'Server opgestart op localhost:8124'
