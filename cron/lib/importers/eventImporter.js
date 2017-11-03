'use strict';
var chalk = require('chalk');
var async = require('async');
var models = require('ojt-models');

var Importer = require('../importer');
var EventFactory = require('../factories/eventFactory');

var Event = models.Event;
var Schedule = models.Schedule;

function EventImporter() {
	Importer.call(this, 'Event', ['Schedule']);
}

EventImporter.prototype = Object.create(Importer.prototype);
EventImporter.prototype.constructor = EventImporter;

EventImporter.prototype.empty = function(callback) {
	Event.remove({})
		.then(function () { callback(null); })
		.catch(function(err) { callback(err); });
};

EventImporter.prototype.import = function(manager, callback) {
	manager.mysql.query('SELECT * FROM `la_evenementen`', function(err, rows) {
		if (err) {
			return callback(err);
		}

		console.log(chalk.dim('query to `la_evenementen` returned %d row(s)'), rows.length);

		var eventBag = EventFactory.createAll(rows);
		Event.collection.insert(eventBag, function(err, docs) {
			if (err) {
				return callback(err);
			}
			callback(null);
		});
	});
};

EventImporter.prototype.resolve = function(manager, callback) {
	Schedule.find({}).exec()
		.then(function(schedules) {
			var items = {};
			var schedule;
			for (var i = 0; i < schedules.length; i++) {
				schedule = schedules[i];
				if (schedule.eventId in items) {
					items[schedule.eventId].push(schedule.scheduleId);
				} else {
					items[schedule.eventId] = [schedule.scheduleId];
				}
			}

			Event.find({eventId: {$in: Object.keys(items)}}).exec()
				.then(function(events) {
					var fns = [];
					var event;
					for (var i = 0; i < events.length; i++) {
						event = events[i];
						fns.push(function(scheduleIds, callback) {
							var self = this;
							Schedule.find({scheduleId: {$in: scheduleIds}}).exec()
								.then(function(schedules) {
									for (var i = 0; i < schedules.length; i++) {
										schedules[i].event = self;
										schedules[i].save();
										self.schedules.push(schedules[i].id);
									}
									return self.save();
								})
								.then(function(event) {
									callback(null, event.schedules.length);
								})
								.catch(function(err) {
									callback(null);
								});
						}.bind(event, items[event.eventId]));
					}

					async.parallel(fns, function(err, results) {
						if (err) {
							return callback(err);
						}

						var count = 0;
						for (var i = 0; i < results.length; i++) {
							count += results[i];
						}
						console.log(chalk.green('resolved %d relationship(s)'), count);

						callback(null);
					});
				})
				.catch(function(err) {
					callback(err);
				});
		})
		.catch(function(err) {
			callback(err);
		});
};

module.exports = new EventImporter();
