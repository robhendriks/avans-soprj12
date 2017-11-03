'use strict';

var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var Communication = new Schema({
	title: {
		type: String,
		required: true
	},
  body: {
    type: String,
    required: true
  },
  author: {
    type: Schema.Types.ObjectId,
    required: true,
    ref: 'User'
  },
  created: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Communication', Communication);
