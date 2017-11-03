'use strict';

var crypto = require('crypto');
var express = require('express');
var router = express.Router();

var User = require('ojt-models').User;

router.use('/me', function(req, res, next) {
	User.findById(req.user.id)
		.populate('contact')
		.exec()
		.then(function(user) {
			if (!user) {
				throw res.error(404);
			}
			res.json(user);
		})
		.catch(next);
});

router.use('/contacts', require('./contacts'));
router.use('/schedules', require('./schedules'));
router.use('/events', require('./events'));
router.use('/teams', require('./teams'));
router.use('/actions', require('./actions'));
router.use('/scoreboard', require('./scoreboard'));
router.use('/communications', require('./communications'));

module.exports = router;
