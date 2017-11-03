'use strict';

var models = require('ojt-models');
var goosepage = require('goosepage');

var express = require('express');
var router = express.Router();

var Schedule = models.Schedule;
var DailySchedule = models.DailySchedule;

router.route('/')
	.get(function(req, res, next) {
		var query = Schedule.find().sort('date');

		goosepage(query, {page: req.query.page || 0})
			.then(function(schedules) {
				res.json(schedules);
			})
			.catch(next);
	});

router.route('/search')
	.get(function(req, res, next) {
		var expr = new RegExp((req.query.q || '').trim(), 'i');
		var query = Schedule.find({'name': expr}).select('name');

		goosepage(query, {page: req.query.page || 0})
			.then(function(schedules) {
				res.json(schedules);
			})
			.catch(next);
	});

router.route('/:id')	
	.get(function(req, res, next) {
		Schedule.findById(req.params.id)
			.populate({
				path: 'daily',
				options: {
					sort: {
						startsAt: 1,
						name: 1
					}
				}
			})
			.exec()
			.then(function(schedule) {
				if (!schedule) {
					throw res.error(404);
				}
				res.json(schedule);
			})
			.catch(next);
	});

router.route('/:id/daily')	
	.get(function(req, res, next) {
		var query = DailySchedule.find({schedule: req.params.id}).sort('startsAt name');

		goosepage(query, {page: req.query.page || 0})
			.then(function(schedule) {
				if (!schedule) {
					throw res.error(404);
				}
				res.json(schedule);
			})
			.catch(next);
	});

module.exports = router;
