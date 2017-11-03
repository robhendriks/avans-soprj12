'use strict';
var models = require('ojt-models');
var goosepage = require('goosepage');

var express = require('express');
var router = express.Router();

var User = models.User;
var Communication = models.Communication;

router.route('/')
	.get(function(req, res, next) {
		var query = Communication.find()
			.populate({
				path: 'author',
				select: 'id name contact',
				populate: {
					path: 'contact',
					select: 'id name'
				}
			})
			.sort('-created');

		goosepage(query, {page: req.query.page || 0})
			.then(function(schedules) {
				res.json(schedules);
			})
			.catch(next);
	})
	.post(function(req, res, next) {
		User.findById(req.user.id)
			.populate('contact')
			.then(function(user) {
				if (!user || (!req.query.dooty && !user.contact.isLeader)) {
					throw res.error(401);
				}

				var entry = new Communication(req.body);
				entry.author = user.id;

				if (entry.validateSync()) {
					throw res.error(400);
				}

				return entry.save();
			})
			.then(function() {
				res.sendStatus(201);
			})
			.catch(next);
	});

module.exports = router;
