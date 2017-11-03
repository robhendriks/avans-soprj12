'use strict';

var models = require('ojt-models');
var goosepage = require('goosepage');

var express = require('express');
var router = express.Router();

var Action = models.Action;
var Contact = models.Contact;
var Team = models.Team;

router.route('/')
	.get(function(req, res, next) {
		var query = Team.find().sort('name');

		goosepage(query, {page: req.query.page || 0})
			.then(function(teams) {
				res.json(teams);
			})
			.catch(next);
	});

router.route('/search')
	.get(function(req, res, next) {
		var expr = new RegExp((req.query.q || '').trim(), 'i');
		var query = Team.find({'name': expr})
			.select('name').sort('name');

		goosepage(query, {page: req.query.page || 0})
			.then(function(teams) {
				res.json(teams);
			})
			.catch(next);
	});

router.route('/:id')	
	.get(function(req, res, next) {
		Team.findById(req.params.id)
			.populate('leader')
			.exec()
			.then(function(team) {
				if (!team) {
					throw res.error(404);
				}
				res.json(team);
			})
			.catch(next);
	});

router.route('/:id/members')
	.get(function(req, res, next) {
		Team.findById(req.params.id).exec()
			.then(function(team) {
				if (!team) {
					throw res.error(404);
				}
				var query = Contact.find({_id: {$in: team.members, $ne: team.leader}}).sort('name');
				return goosepage(query, {page: req.query.page || 0});
			})
			.then(function(contacts) {
				res.json(contacts);
			})
			.catch(next);
	});

module.exports = router;
