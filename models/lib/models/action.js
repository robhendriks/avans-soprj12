'use strict';

var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var Action = new Schema({
  originator: {
    type: Schema.Types.ObjectId,
    required: true,
    ref: 'User'
  },
  target: {
    type: Schema.Types.ObjectId,
    required: true
  },
  targetType: {
    type: String,
    required: true,
    enum: ['contact', 'team']
  },
  actionType: {
    type: String,
    required: true,
    enum: ['update_score']
  },
  actionArgs: {
    type: Schema.Types.Mixed
  },
  created: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Action', Action);
