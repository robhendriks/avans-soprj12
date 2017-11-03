'use strict';

var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var RefreshToken = new Schema({
	accessToken: {
		type: String,
		unique: true,
		required: true
	},
	userId: {
		type: String,
		required: true
	},
	clientId: {
		type: String,
		required: true
	},
	expires: Date
});

module.exports = mongoose.model('RefreshToken', RefreshToken);
