mongoose = require 'mongoose'
db = mongoose.createConnection "mongodb://localhost/#{require('../config').database}"
cords = require './cords'
ent = require 'ent'
geo = require 'geo'
#FoxGroupSchema = new Schema
#  name:
#    type: String, required: true

Schema = mongoose.Schema
UserSchema = new Schema
  name:
    type: String
    required: true
    set: (string) -> ent.encode string
  ip:
    type: String
    required: true
    set: (string) -> ent.encode string

HintSchema = new Schema
  solver:
    type: Schema.ObjectId, ref: 'User', required: true
  location:
    type:
      longlat:
        x: Number
        y: Number
      rdh:
        x: Number
        y: Number
      address: String
      sourceType: String
    set: (doc) ->
      doc?.sourceType = doc?.sourceType?.toLowerCase()
      doc
  fox_group:
    type: String
    required: true
    set: (string) -> ent.encode(string).toLowerCase()
  time:
    type: Date, required: true
    
HintSchema.virtual('longlat')
  .get ->
    @location.longlat
HintSchema.virtual('location.raw')
  .get ->
    switch @location.sourceType
      when 'longlat', 'rdh'
        "#{@location[@location.sourceType].x}, #{@location[@location.sourceType].y}"
      when 'address'
        @location.address

HintSchema.index longlat: '2d'
HintSchema.pre 'save', (next) ->
  return unless @location
  switch @location.sourceType
    when 'address'
      geo.geocoder geo.google, @location.address, false, (formatted, lat, long) =>
        @location.longlat =
          x: lat
          y: long
        t = new cords.Geographic @location.longlat.x, @location.longlat.y
        g = t.toTriangular()
        @location.rdh = x: g.x, y: g.y
        next()
    when 'longlat'        
      t = new cords.Geographic @location.longlat.x, @location.longlat.y
      g = t.toTriangular()
      @location.rdh = x: g.x, y: g.y
      
      geo.geocoder geo.google, "#{@location.longlat.x}, #{@location.longlat.y}", false, (formatted, lat, long) =>
        @location.address = formatted
        next()
        
    when 'rdh'
      t = new cords.Triangular @location.rdh.x, @location.rdh.y
      g = t.toGeographic()
      @location.longlat = x: g.x, y: g.y
          
      geo.geocoder geo.google, "#{@location.longlat.x}, #{@location.longlat.y}", false, (formatted, lat, long) =>
        @location.address = formatted
        next()


#exports.FoxGroup = db.model 'FoxGroup', FoxGroupSchema
exports.User = db.model 'User', UserSchema
exports.Hint = db.model 'Hint', HintSchema
