'use strict';

var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var DailySchedule = new Schema({
  dailyScheduleId: String,
  scheduleId: String,
  name: String,
  description: String,
  startsAt: String,
  endsAt: String,
  points: {
    type: Number,
    default: 0
  },
  schedule: {
    type: Schema.Types.ObjectId,
    ref: 'Schedule'
  },
  created: {
    type: Date,
    default: Date.now
  }
});

DailySchedule.set('toJSON', {
  transform: function(doc, ret, options) {
    delete ret['dailyScheduleId'];
    delete ret['scheduleId'];
    return ret;
  }
});

module.exports = mongoose.model('DailySchedule', DailySchedule);
