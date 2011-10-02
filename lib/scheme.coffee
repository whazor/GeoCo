mongoose = require 'mongoose'
Schema = mongoose.Schema
db = mongoose.createConnection 'mongodb://localhost/jotihunt'

FoxGroupSchema = new Schema
  name:
    type: String, required: true

UserSchema = new Schema
  name:
    type: String, required: true
  ip:
    type: String, required: true

HintSchema = new Schema
  solver:
    type: Schema.ObjectId, ref: 'User', required: true
  loc_rnd:
    type: (x: Number, y: Number), required: true # RND, numbers for calculation
  loc_lng:
    type: (x: Number, y: Number), required: true # lat, lang,
  loc_address:
    type: String, required: true
  fox_group:
    type: Schema.ObjectId, ref: 'FoxGroup', required: true
  time:
    type: Date, required: true
HintSchema.index loc_lnd: '2d'

exports.FoxGroup = db.model 'FoxGroup', FoxGroupSchema
exports.User = db.model 'User', UserSchema
exports.Hint = db.model 'Hint', HintSchema
