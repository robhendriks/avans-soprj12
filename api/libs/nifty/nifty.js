'use strict';

var http = require('http');
var NiftyError = require('./niftyError');

function getStatus(code, text) {
	var statusCode = code || 200;
	var statusText = text;
	if (!text && !(statusText = http.STATUS_CODES[statusCode])) {
		throw new Error('Unsupported status code');
	}
	return {code: statusCode, text: statusText}
}

function getError(code, text, description) {
	var status = getStatus(code, text);
	return new NiftyError(status, description || null);
}

function getPage() {
	return parseInt(this.query.page || 0) || 0;
}

function nifty() {
	
	return function(req, res, next) {
		// Request extensions
		req.page = getPage.bind(req);

		// Response extensions
		res.error = getError.bind(res);

		next();
	}

}

nifty.errorHandler = require('./errorHandler');

module.exports = nifty;
