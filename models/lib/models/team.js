'use strict';

var score = require('../helpers/score');

var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var Team = new Schema({
	teamId: String,
	cpId: String,
	name: String,
	description: String,
	leader: {
		type: Schema.Types.ObjectId,
		ref: 'Contact'
	},
	members: [{
		type: Schema.Types.ObjectId,
		ref: 'Contact'
	}],
	score: {
		type: Number,
		default: 0
	},
	created: {
		type: Date,
		default: Date.now
	}
});

Team.set('toJSON', {
	transform: function(doc, ret, options) {
		delete ret['teamId'];
		delete ret['cpId'];
		return ret;
	}
});

module.exports = mongoose.model('Team', Team);
