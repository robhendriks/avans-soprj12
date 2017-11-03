'use strict';

var async = require('async');
var models = require('ojt-models');

var express = require('express');
var router = express.Router();

var Contact = models.Contact;
var Team = models.Team;

router.route('/')
  .get(function(req, res, next) {
    async.parallel({
      teams: function(callback) {
        Team.find({score: {$gt: 0}})
          .sort('name')
          .limit(5)
          .exec()
          .then(function(teams) {
            callback(null, teams);
          })
          .catch(callback);
      },
      contacts: function(callback) {
        Contact.find({score: {$gt: 0}, isChild: true})
          .sort('-score name')
          .limit(10)
          .exec()
          .then(function(contacts) {
            callback(null, contacts);
          })
          .catch(callback);
      }
    }, function(err, results) {
      if (err) {
        return next(err);
      }
      res.json(results);
    });
  });

module.exports = router;
