'use strict';
var chalk = require('chalk');
var models = require('ojt-models');

var Importer = require('../importer');
var UserFactory = require('../factories/userFactory');

var User = models.User;
var Contact = models.Contact;

function UserImporter() {
	Importer.call(this, 'User', ['Team']);
}

UserImporter.prototype = Object.create(Importer.prototype);
UserImporter.prototype.constructor = UserImporter;

UserImporter.prototype.empty = function(callback) {
	User.remove({})
		.then(function() { 
			callback(null); 
		})
		.catch(callback);
};

UserImporter.prototype.import = function(manager, callback) {
	callback(null);
};

UserImporter.prototype.resolve = function(manager, callback) {
	Contact.find({
		isChild: false,
		$or: [
			{isParent: true}, 
			{isLeader: true}
		]
	})
		.then(function(contacts) {
			var userBag = UserFactory.createAll(contacts);
			User.collection.insert(userBag, function(err, docs) {
				if (err) {
					return callback(err);
				}
				console.log(chalk.dim('created %d user(s)'), userBag.length);
				callback(null);
			});
		})
		.catch(callback);
};

module.exports = new UserImporter();
