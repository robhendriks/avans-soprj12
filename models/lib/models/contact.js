'use strict';

var score = require('../helpers/score');

var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var Contact = new Schema({
	cpId: String,
	parentCpId: String,
	parent: {
		type: Schema.Types.ObjectId,
		ref: 'Contact'
	},
	children: [{
		type: Schema.Types.ObjectId,
		ref: 'Contact'
	}],
	team: {
		type: Schema.Types.ObjectId,
		ref: 'Team'
	},
	gender: String,
	salutation: String,
	initials: String,
	firstName: String,
	lastName: String,
	prefix: String,
	insertion: String,
	name: String,
	dateOfBirth: Date,
	address: String,
	zip: String,
	town: String,
	country: String,
	email: String,
	phone: String,
	mobile: String,
	score: {
		type: Number,
		default: 0
	},
	isChild: {
		type: Boolean,
		default: false
	},
	isParent: {
		type: Boolean,
		default: false
	},
	isLeader: {
		type: Boolean,
		default: false
	},
	created: {
		type: Date,
		default: Date.now
	}
});

Contact.path('score').set(function(newVal) {
	var oldVal = this.score
	if (newVal > oldVal) {
		this._addScore = newVal - oldVal;
		this._subScore = 0;
		console.log('add', newVal - oldVal, 'points');
	} else if (oldVal > newVal) {
		this._subScore = oldVal - newVal;
		this._addScore = 0;
		console.log('sub', oldVal - newVal, 'points');
	}
	return newVal;
});

Contact.pre('save', function(next) {
	if (!this.team || (this._addScore === 0 && this._subScore === 0)) {
		next();
		return;
	}

	var Team = this.model('Team');
	var self = this;

	Team.findById(this.team)
		.then(function(team) {
			if (!team) {
				next();
				return;
			}

			if (self._addScore > 0) {
				team.score += self._addScore;
				self._addScore = 0;
			} else if (self._subScore > 0) {
				team.score -= self._subScore;
				self._subScore = 0;
			} else {
				next();
				return;
			}

			return team.save();
		})
		.then(function(team) { next(); })
		.catch(function(err) { next(); });
});

Contact.methods.updateScore = function(op, val) {
	return score.updateScore(this, {op: op, val: val});
};

Contact.set('toJSON', {
	transform: function(doc, ret, options) {
		delete ret['cpId'];
		delete ret['parentCpId'];
		return ret;
	}
});

module.exports = mongoose.model('Contact', Contact);
