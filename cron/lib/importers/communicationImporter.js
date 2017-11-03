'use strict';
var chalk = require('chalk');

var Importer = require('../importer');
var Communication = require('ojt-models').Communication;

function CommunicationImporter() {
	Importer.call(this, 'Communication');
}

CommunicationImporter.prototype = Object.create(Importer.prototype);
CommunicationImporter.prototype.constructor = CommunicationImporter;

CommunicationImporter.prototype.empty = function(callback) {
	Communication.remove({})
		.then(function() { 
			callback(null); 
		})
		.catch(callback);
};

CommunicationImporter.prototype.import = function(manager, callback) {
	callback(null);
};

CommunicationImporter.prototype.resolve = function(manager, callback) {
	callback(null);
};

module.exports = new CommunicationImporter();
