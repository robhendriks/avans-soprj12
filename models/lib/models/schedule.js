'use strict';

var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var Schedule = new Schema({
	scheduleId: String,
	eventId: String,
	name: String,
	date: Date,
	starts: String,
	ends: String,
	event: {
		type: Schema.Types.ObjectId,
		ref: 'Event'
	},
	daily: [{
		type: Schema.Types.ObjectId,
		ref: 'DailySchedule'
	}],
	created: {
		type: Date,
		default: Date.now
	}
});

Schedule.set('toJSON', {
	transform: function(doc, ret, options) {
		delete ret['scheduleId'];
		delete ret['eventId'];
		return ret;
	}
});

module.exports = mongoose.model('Schedule', Schedule);
