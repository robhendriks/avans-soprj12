'use strict';

function NiftyError(status, description) {
	Error.call(this);
	Error.captureStackTrace(this);
	this.name = 'NiftyError';
	this.message = status.text;
	this.status = status;
	this.description = description;
}

NiftyError.prototype = Object.create(Error.prototype);
NiftyError.prototype.constructor = Error;

module.exports = NiftyError;
