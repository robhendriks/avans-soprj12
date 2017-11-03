'use strict';

var models = require('ojt-models');
var User = models.User;

var Factory = require('../factory');

function UserFactory() {
	Factory.call(this);
}

UserFactory.prototype = Object.create(Factory.prototype);
UserFactory.prototype.constructor = UserFactory;

UserFactory.prototype.create = function(row) {
	return {
		email: row.email,
		password: User.hashPassword('test'),
		contact: row.id,
		created: Date.now()
	};
};

module.exports = new UserFactory();
