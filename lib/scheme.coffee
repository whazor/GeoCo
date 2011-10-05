mongoose = require 'mongoose'
db = mongoose.createConnection 'mongodb://localhost/jotihunt'

#FoxGroupSchema = new Schema
#  name:
#    type: String, required: true

Schema = mongoose.Schema
UserSchema = new Schema
  name:
    type: String, required: true
  ip:
    type: String, required: true

HintSchema = new Schema
  solver:
    type: Schema.ObjectId, ref: 'User', required: true
  loc_rdc:
    type: (x: Number, y: Number), required: true # RDC, numbers for calculation
  loc_lng:
    type: (x: Number, y: Number), required: true # lat, lang,
  loc_address:
    type: String, required: true
  fox_group:
    type: String, required: true#type: Schema.ObjectId, ref: 'FoxGroup', required: true
  time:
    type: Date, required: true

HintSchema.index loc_lnd: '2d'
HintSchema.pre 'save', (next) ->
  if !@loc_lng and !@log_rdc and !@loc_address
    next(new mongoose.Error('something went wrong'))


#exports.FoxGroup = db.model 'FoxGroup', FoxGroupSchema
exports.User = db.model 'User', UserSchema
exports.Hint = db.model 'Hint', HintSchema
