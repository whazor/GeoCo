mongoose = require 'mongoose'
db = mongoose.createConnection 'mongodb://localhost/jotihunt'
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
    type: (sort: String, value: Schema.Types.Mixed), required: true
  longlat:
    type: (x: Number, y: Number), required: true # lat, lang,
  fox_group:
    type: String
    required: true
    set: (string) -> ent.encode(string).toLowerCase()
  time:
    type: Date, required: true

HintSchema.index longlat: '2d'
HintSchema.pre 'save', (next) ->
  return unless @location
  switch @location.sort.toLowerCase()
    when 'address'
      geo.geocoder geo.google, @location.value, false, (formatted, lat, long) =>
        @longlat =
          x: lat
          y: long
        next()
    when 'longlat'
      @longlat = @location.value
      next()
    when 'rdh'
      t = new cords.Triangular @location.value.x, @location.value.y
      g = t.toGeographic()
      @longlat = {x: g.x, y: g.y}
      next()


#exports.FoxGroup = db.model 'FoxGroup', FoxGroupSchema
exports.User = db.model 'User', UserSchema
exports.Hint = db.model 'Hint', HintSchema
