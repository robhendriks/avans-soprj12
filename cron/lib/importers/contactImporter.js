'use strict';
var chalk = require('chalk');
var async = require('async');
var models = require('ojt-models');

var Importer = require('../importer');
var ContactFactory = require('../factories/contactFactory');

var Contact = models.Contact;

function ContactImporter() {
	Importer.call(this, 'Contact');
}

ContactImporter.prototype = Object.create(Importer.prototype);
ContactImporter.prototype.constructor = ContactImporter;

ContactImporter.prototype.empty = function(callback) {
	Contact.remove({})
		.then(function () { callback(null); })
		.catch(function(err) { callback(err); });
};

ContactImporter.prototype.import = function(manager, callback) {
	manager.mysql.query('SELECT * FROM `la_contactpersonen`', function(err, rows) {
		if (err) {
			return callback(err);
		}

		console.log(chalk.dim('query to `la_contactpersonen` returned %d row(s)'), rows.length);

		var contactBag = ContactFactory.createAll(rows);
		Contact.collection.insert(contactBag, function(err, docs) {
			if (err) {
				return callback(err);
			}
			callback(null);
		});
	});
};

ContactImporter.prototype.resolve = function(manager, callback) {
	Contact.find({}).exec()
		.then(function(contacts) {
			var fns = [];
			var contact;
			for (var i = 0; i < contacts.length; i++) {
				contact = contacts[i];
				if (!contact.parentCpId) { continue; }

				fns.push(function(callback) {
					var self = this;
					Contact.findOne({cpId: self.parentCpId}).exec()
						.then(function(parentContact) {
							if (!parentContact) { return; }
							parentContact.children.push(self.id);
							return parentContact.save();
						})
						.then(function(parentContact) {
							self.parent = parentContact.id;
							self.isChild = true;

							parentContact.isParent = true;
							parentContact.save();
							
							return self.save();
						})
						.then(function(contact) {
							callback(null, (contact ? true : false));
						})
						.catch(function(err) {
							callback(err);
						});
				}.bind(contact));
			}

			async.parallel(fns, function(err, results) {
				if (err) {
					return callback(err);
				}

				var count = 0;
				for (var i = 0; i < results.length; i++) {
					if (results[i] !== false) { count++; }
				}
				console.log(chalk.green('resolved %d relationship(s)'), count);

				callback(null);
			});
		})
		.catch(function(err) {
			callback(err);
		});
};

module.exports = new ContactImporter();
