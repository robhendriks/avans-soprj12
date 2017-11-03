'use strict';

var bcrypt = require('bcrypt-nodejs');

var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var User = new Schema({
	email: {
		type: String,
		required: true
	},
	password: {
		type: String,
		required: true
	},
	contact: {
		type: Schema.Types.ObjectId,
		ref: 'Contact'
	},
	created: {
		type: Date,
		default: Date.now
	}
});

User.statics.hashPassword = function(password) {
	return bcrypt.hashSync(password, bcrypt.genSaltSync(8), null);
};

User.methods.validPassword = function(password) {
	return bcrypt.compareSync(password, this.password);
};

module.exports = mongoose.model('User', User);
