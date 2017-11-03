'use strict';

var models = require('ojt-models');
var goosepage = require('goosepage');

var express = require('express');
var router = express.Router();

var Action = models.Action;

router.route('/')
  .get(function(req, res, next) {
    var query = Action.find()
      .sort('-created')
      .populate({
        path: 'originator',
        select: 'email contact',
        populate: {path: 'contact', select: 'name'}
      });

    goosepage(query, {page: req.query.page || 0})
      .then(function(actions) {
        res.json(actions);
      })
      .catch(next);
  });

router.route('/:type/:id')
  .get(function(req, res, next) {
    var query = Action
      .find({
        targetType: req.params.type || '',
        target: req.params.id || ''
      })
      .sort('-created')
      .populate({
        path: 'originator',
        select: 'email contact',
        populate: {path: 'contact', select: 'name'}
      });

    goosepage(query, {page: req.query.page || 0})
      .then(function(actions) {
        res.json(actions);
      })
      .catch(next);
  });

module.exports = router;
