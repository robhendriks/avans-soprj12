'use strict';
var chalk = require('chalk');
var async = require('async');
var models = require('ojt-models');

var Importer = require('../importer');
var ScheduleFactory = require('../factories/scheduleFactory');

var Schedule = models.Schedule;

function ScheduleImporter() {
	Importer.call(this, 'Schedule', ['Contact']);
}

ScheduleImporter.prototype = Object.create(Importer.prototype);
ScheduleImporter.prototype.constructor = ScheduleImporter;

ScheduleImporter.prototype.empty = function(callback) {
	Schedule.remove({})
		.then(function () { callback(null); })
		.catch(function(err) { callback(err); });
};

ScheduleImporter.prototype.import = function(manager, callback) {
	manager.mysql.query('SELECT * FROM `la_evenementsplanning`', function(err, rows) {
		if (err) {
			return callback(err);
		}

		console.log(chalk.dim('query to `la_evenementsplanning` returned %d row(s)'), rows.length);

		var scheduleBag = ScheduleFactory.createAll(rows);
		Schedule.collection.insert(scheduleBag, function(err, docs) {
			if (err) {
				return callback(err);
			}
			callback(null);
		});
	});
};

ScheduleImporter.prototype.resolve = function(manager, callback) {
	callback(null);
};

module.exports = new ScheduleImporter();
