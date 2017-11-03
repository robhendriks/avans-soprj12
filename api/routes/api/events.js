'use strict';

var models = require('ojt-models');
var goosepage = require('goosepage');

var express = require('express');
var router = express.Router();

var Event = models.Event;
var Schedule = models.Schedule;

router.route('/')
	.get(function(req, res, next) {
		var query = Event.find();

		goosepage(query, {page: req.query.page || 0})
			.then(function(events) {
				res.json(events);
			})
			.catch(next);
	});

router.route('/current')
	.get(function(req, res, next) {
		var date = new Date(Date.now());

		var query = Event.find({
			dateFrom: {$lt: date},
			dateTo: {$gt: date}
		})
		.sort('date')
		.populate({path: 'schedules', options: {sort: 'date'}});

		goosepage(query, {page: req.query.page || 0})
			.then(function(events) {
				res.json(events);
			})
			.catch(next);
	});

router.route('/search')
	.get(function(req, res, next) {
		var expr = new RegExp((req.query.q || '').trim(), 'i');
		var query = Event.find({'name': expr}).select('name');

		goosepage(query, {page: req.query.page || 0})
			.then(function(teams) {
				res.json(teams);
			})
			.catch(next);
	});

router.route('/:id')	
	.get(function(req, res, next) {
		Event.findById(req.params.id)
			.exec()
			.then(function(event) {
				if (!event) {
					throw res.error(404);
				}
				res.json(event);
			})
			.catch(next);
	});

router.route('/:id/schedules')
	.get(function(req, res, next) {
		Event.findById(req.params.id)
			.exec()
			.then(function(event) {
				if (!event) {
					throw res.error(404);
				}
				var query = Schedule.find({_id: {$in: event.schedules}}).sort('date');
				return goosepage(query, {page: req.query.page || 0});
			})
			.then(function(contacts) {
				res.json(contacts);
			})
			.catch(next);
	});

module.exports = router;
