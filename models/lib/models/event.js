'use strict';

var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var Event = new Schema({
	eventId: String,
	name: String,
	description: String,
	dateFrom: Date,
	dateTo: Date,
	schedules: [{
		type: Schema.Types.ObjectId,
		ref: 'Schedule'
	}],
	created: {
		type: Date,
		default: Date.now
	}
});

Event.set('toJSON', {
	transform: function(doc, ret, options) {
		delete ret['eventId'];
		return ret;
	}
});

module.exports = mongoose.model('Event', Event);
