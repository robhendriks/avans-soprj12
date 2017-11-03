'use strict';

var express = require('express');
var router = express.Router();
var oauth = require('../config/oauth');
var nifty = require('../libs/nifty');

// Nifty
router.use(nifty());

// OAuth2 grant token
router.post('/oauth/token', oauth.grant());

// API routes with authentication
router.use('/api', oauth.authorise(), require('./api'));

// OAuth2 error handler
router.use(oauth.errorHandler());

router.use(nifty.errorHandler());

module.exports = router;
