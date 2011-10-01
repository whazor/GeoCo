sys = require 'sys'

express = require 'express'
app = express.createServer()
browserify = require 'browserify'

mongoose = require 'mongoose'
Schema = mongoose.Schema
db = mongoose.createConnection('mongodb://localhost/jotihunt')

FoxGroupSchema = new Schema
  name: String

UserSchema = new Schema
  name: String
  ip: String

HintSchema = new Schema
  solver: {type: Schema.ObjectId, ref: 'User'}
  loc: {x: Number, y: Number} # RND
  cache_loc: String # lat, lang
  fox_group: {type: Schema.ObjectId, ref: 'FoxGroup'}
  time: String # TODO
HintSchema.index {loc: '2d'}

FoxGroup = db.model 'FoxGroup', FoxGroupSchema
User = db.model 'User', UserSchema
Hint = db.model 'Hint', HintSchema

# Configure website
app.configure ->
  app.register '.coffee', require('coffeekup').adapters.express

  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'coffee'
  #app.set 'view options', {layout: 'layout'}

  app.use express.static(__dirname + '/public')
  app.use browserify
    mount: '/app.js'
    entry: "#{__dirname}/lib/client.coffee"
    watch: true
  app.use express.cookieParser()
  app.use express.session({ secret: "HIERMOETRANDOMKEYKOMEN" })

  app.use express.errorHandler({ dumpExceptions: true, showStack: true })

app.configure 'production', -> app.use express.errorHandler()

auth = (req, res, next) ->
  return next() #TODO: remove
  logged_in = false

  user = req.session.user
  if user
    User.findById user, (err, doc) ->
      return if err
      logged_in = true
      next()

  res.redirect '/login' unless logged_in

# Route to index
app.get '/', auth, (req, res) ->
  if req.session.user
    res.render 'index'
  else
    res.redirect '/login'

app.get '/login', (req, res) -> res.render 'login'

app.post '/authenticate', (req, res) ->
  User.findOne {}
  req.session.user = true
  res.redirect '/'

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
