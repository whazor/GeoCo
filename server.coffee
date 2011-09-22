fs = require('fs')
sys = require('sys')
path = require('path')

jade = require('jade')
less = require('less')

express = require('express')
app = express.createServer()
browserify = require('browserify')

app.configure ->
  app.set('views', __dirname + '/views')
  app.set('view engine', 'jade')
  app.set('view options', {layout: false})
  app.use(express.static(__dirname + '/public'))
  app.use browserify({entry: "#{__dirname}/lib/client.coffee", watch: true})

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
