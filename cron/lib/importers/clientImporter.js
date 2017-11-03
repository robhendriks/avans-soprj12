'use strict';
var chalk = require('chalk');
var models = require('ojt-models');

var Client = models.Client;
var Importer = require('../importer');

function ClientImporter() {
	Importer.call(this, 'Client', ['Team']);
}

ClientImporter.prototype = Object.create(Importer.prototype);
ClientImporter.prototype.constructor = ClientImporter;

ClientImporter.prototype.empty = function(callback) {
	Client.remove({})
		.then(function() { 
			callback(null); 
		})
		.catch(callback);
};

ClientImporter.prototype.import = function(manager, callback) {
	var clientBag = [
		{
			name: 'iOS',
			clientId: 'foo',
			clientSecret: 'bar'
		},
		{
			name: 'Android',
			clientId: 'bar',
			clientSecret: 'foo'
		}
	];

	Client.collection.insert(clientBag, function(err, docs) {
		if (err) {
			return callback(err);
		}
		console.log(chalk.dim('created %d client(s)'), clientBag.length);
		callback(null);
	});
};

ClientImporter.prototype.resolve = function(manager, callback) {
	callback(null);
};

module.exports = new ClientImporter();
