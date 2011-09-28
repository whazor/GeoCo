sys = require 'sys'

mongodb = require 'mongodb'
express = require 'express'
app = express.createServer()
browserify = require 'browserify'

# Configure mongodb
client = new mongodb.Db 'jotihunt', new mongodb.Server('127.0.0.1', 27017, {}), ->


# Configure website
app.configure ->
  app.register '.coffee', require('coffeekup').adapters.express

  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'coffee'
  #app.set 'view options', {layout: 'layout'}

  app.use express.static(__dirname + '/public')
  app.use browserify({entry: "#{__dirname}/lib/client.coffee", watch: true})
  app.use express.cookieParser()
  app.use express.session({ secret: "HIERMOETRANDOMKEYKOMEN" })

  app.use express.errorHandler({ dumpExceptions: true, showStack: true })

app.configure 'production', -> app.use express.errorHandler()

# Route to index
app.get '/', (req, res) -> res.render 'index'

app.get '/login', (req, res) -> res.render 'login'

# Less
fs = require 'fs'
path = require 'path'
app.get '/css/*.*', (req, res) ->
  file = req.params[0] + '.less'
  file = path.join('./style/', path.normalize(file))
  fs.readFile file, 'utf-8', (e, str) ->
    return res.send 'Not found.', 404 if e

    new(require('less').Parser)({paths: [path.dirname(file)], optimization: 0 })
      .parse str, (err, tree) -> res.send tree.toCSS(), {'Content-Type': 'text/css'}, 201

# Start application
startServer = (host, port) ->
  app.listen port, host
  console.log "Server opgestart op http://#{host}:#{port}"

startServer '0.0.0.0', 8124
