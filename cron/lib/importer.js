'use strict';
var chalk = require('chalk');

function Importer(name, depends) {
	this._name = name;
	this._depends = depends || [];
}

Importer.prototype = {

	constructor: Importer,

	empty: function(callback) {
		console.log(chalk.red('Importer#resolve must be overridden by the subclass'));
		callback(null);
	},

	import: function(manager, callback) {
		console.log(chalk.red('Importer#resolve must be overridden by the subclass'));
		callback(null);
	},

	resolve: function(manager, callback) {
		console.log(chalk.red('Importer#resolve must be overridden by the subclass'));
		callback(null);
	},

	get name() {
		return this._name;
	},
	
	get depends() {
		return this._depends
	}

};

module.exports = Importer;
