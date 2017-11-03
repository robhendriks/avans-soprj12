'use strict';

var models = require('ojt-models');
var goosepage = require('goosepage');

var express = require('express');
var router = express.Router();

var Action = models.Action;
var Contact = models.Contact;

router.route('/')
	.get(function(req, res, next) {
		var query = Contact.find({})
			.sort('name')
			.populate('parent', 'name');

		goosepage(query, {page: req.page()})
			.then(function(contacts) {
				res.json(contacts);
			})
			.catch(next);
	});

router.route('/children')
	.get(function(req, res, next) {
		var query = Contact.find({isChild: true}).sort('name');

		goosepage(query, {page: req.page()})
			.then(function(contacts) {
				res.json(contacts);
			})
			.catch(next);
	});

router.route('/search')
	.get(function(req, res, next) {
		var expr = new RegExp((req.query.q || '').trim(), 'i');
		var query = Contact.find({'name': expr}).select('name');

		goosepage(query, {page: req.page()})
			.then(function(contacts) {
				res.json(contacts);
			})
			.catch(next);
	});

router.route('/:id')	
	.get(function(req, res, next) {
		Contact.findById(req.params.id)
			.populate('parent')
			.exec()
			.then(function(contact) {
				if (!contact) {
					throw res.error(404, null, 'User not found.');
				}
				res.json(contact);
			})
			.catch(next);
	});

router.route('/:id/children')
	.get(function(req, res, next) {
		Contact.findById(req.params.id).exec()
			.then(function(contact) {
				if (!contact) {
					throw res.error(404, null, 'User not found.');
				}

				var query = Contact.find({parent: req.params.id});
				return goosepage(query, {page: req.page()});
			})
			.then(function(contacts) {
				res.json(contacts);
			})
			.catch(next);
	});

router.route('/:id/team')
	.get(function(req, res, next) {
		Contact.findById(req.params.id)
			.populate('team')
			.exec()
			.then(function(contact) {
				if (!contact) {
					throw res.error(404, null, 'User not found.');
				}
				if (!contact.team) {
					throw res.error(404, null, 'Invalid user type.');	
				}
				res.json(contact.team);
			})
			.catch(next);
	});

router.route('/:id/score')
	.put(function(req, res, next) {
		var tmpContact;
		var tmpResult;

		Contact.findById(req.params.id).exec()
			.then(function(team) {
				tmpContact = team;
				if (!tmpContact) {
					throw res.error(404, null, 'User not found.');
				}
				if (!tmpContact.isChild) {
					throw res.error(400, null, 'Invalid user type.');
				}
				return tmpContact.updateScore(req.query.operator, req.query.value);
			})
			.then(function(result) {
				tmpContact.score = result.value.new;
				tmpContact.save();

				if (result.changed === false) {
					return res.json(result);
				}

				tmpResult = result;

				return new Action({
					originator: req.user.id,
					target: tmpContact.id,
					targetType: 'contact',
					actionType: 'update_score',
					actionArgs: result.value
				}).save();
			})
			.then(function(action) {
				res.json(tmpResult);
			})
			.catch(next);
	});

router.route('/:contactId/score/:dailyScheduleId')
	.post(function(req, res, next) {
		Contact.findById(req.params.contactId).exec()
			.then(function(contact) {

			})
			.catch(next);
	})
	.delete(function(req, res, next) {

	});

module.exports = router;
