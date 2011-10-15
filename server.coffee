#!/usr/bin/env coffee
sys = require 'sys'

express = require 'express'
app = express.createServer()
browserify = require 'browserify'
MongoStore = require 'connect-mongo'

db = require './lib/scheme'

# Configure website
{password} = config = require('./config')
years =
  2010: new Date 2010, 9, 16, 9, 0, 0
  2011: new Date 2011, 9, 15, 9, 0, 0

current_year = new Date().getFullYear()

howlong = 30

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
    #filter: require('uglify-js')
  app.use express.cookieParser()
  app.use express.bodyParser()
  app.use express.session
    secret: config.secret
    store: new MongoStore
      db: "jotihunt"

  app.use express.errorHandler({ dumpExceptions: true, showStack: true })

app.configure 'production', -> app.use express.errorHandler()

auth = (req, res, next) ->
  user = req.session.user
  db.User.findById user, (err, doc) ->
    if !err and doc != null
      res.local 'loggedin', true
      res.local 'username', doc.name
      next()
    else
      res.redirect '/login'

app.all '/*', (req, res, next) ->
  res.local 'loggedin', false
  res.local 'username', 'Gast'
  res.local 'current_year', current_year
  next()

# Route to index
#
app.get '/', auth, (req, res) ->
  res.local 'begin', years[current_year]
  res.local 'howlong', howlong
  res.render 'index'


app.post '/hints', auth, (req, res) ->
  hint = new db.Hint
    solver: req.session.user
    fox_group: req.body.fox_group
  time = new Date()
  time.setTime(parseInt(req.body.time))
  hint.time = time
  
  switch req.body.sort
    when 'rdh'
      hint.location =
        sort: 'rdh'
        value:
          x: parseInt req.body.rdh_x
          y: parseInt req.body.rdh_y

    when 'longlat'
      hint.location =
        sort: 'longlat'
        value:
          x: parseFloat req.body.longlat_x
          y: parseFloat req.body.longlat_y
 
    when 'address'
      hint.location =
        sort: 'address'
        value: req.body.address

    #when 'none'
      # TODO: En nu?
  hint.save (err) ->
    console.log err if err
    res.redirect '/'

app.get '/hint/:id/delete', auth, (req, res) ->
  db.Hint.findById(req.params.id).remove()
  res.redirect '/'

app.get '/hint/:id', auth, (req, res) ->
  db.Hint.findById(req.params.id).populate('solver').run (err, doc) ->
    return if err
    res.local 'doc', doc
    res.render 'hint', {layout: false}

app.get '/hints/:year.geo.json', auth, (req, res) ->
  db.Hint.$where('this.time.getFullYear() == '+parseInt(req.params.year)).sort('time', 1).exec (err, docs) ->
    groups = {}
    features = []
    for doc in docs
      groups[doc.fox_group] ||= []
      groups[doc.fox_group].push [doc.longlat.y, doc.longlat.x]
      features.push
        type: 'Feature'
        geometry:
          type: 'Point'
          coordinates: [doc.longlat.y, doc.longlat.x]
          properties:
            id: doc._id
            type: 'Hint'
    for name, group of groups
      features.push
        type: 'Feature'
        geometry:
          type: 'LineString'
          coordinates: group
          properties: {type: 'Line'}

    res.send
      type: 'FeatureCollection'
      features: features

app.get '/hints/:year.json', auth, (req, res) ->
  db.Hint.$where('this.time.getFullYear() == '+parseInt(req.params.year)).populate('solver').sort('time', 1).exec (err, docs) ->
    cords = []
    for doc in docs
      time = Math.round doc.time.getTime()/1000
      cords.push
        _id: doc._id
        longlat: doc.longlat
        location: doc.location
        time: time
        solver: doc.solver.name
        fox_group: doc.fox_group

    res.send cords




app.get '/login', (req, res) -> res.render 'login'
app.get '/logout', auth, (req, res) ->
  req.session.user = false
  res.redirect '/'

app.post '/authenticate', (req, res) ->
  if req.body.password != password
    res.redirect '/login#fail'
    return

  db.User.findOne {'name': req.body.name}, (err, doc) ->
    if !err and doc != null
      req.session.user = doc._id
      res.redirect '/'
      return

    user = new db.User
      name: req.body.name
      ip: req.socket.remoteAddress

    user.save (err) ->
      req.session.user = user._id
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
