'use strict';

var mongoose = require('mongoose');

require('./models');

module.exports = {
  Action: mongoose.model('Action'),
  Client: mongoose.model('Client'),
  Communication: mongoose.model('Communication'),
  Contact: mongoose.model('Contact'),
  DailySchedule: mongoose.model('DailySchedule'),
  Event: mongoose.model('Event'),
  Schedule: mongoose.model('Schedule'),
  Team: mongoose.model('Team'),
  User: mongoose.model('User')
};
