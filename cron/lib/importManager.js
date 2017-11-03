'use strict';

var toposort = require('toposort');
var async = require('async');
var config = require('config');
var mongoose = require('mongoose');
var mysql = require('mysql');
var error = require('./util/error');

var Promise = require('bluebird');
mongoose.Promise = Promise;

function ImportManager() {
	this._config = {};
	this._importers = {};
	this._order = [];

	this._mongoConn = null;
	this._mysqlConn = null;

	this._init();
}

ImportManager.prototype = {

	constructor: ImportManager,

	_init: function() {
		console.log('loading importers...');

		var importers = require('./importers');
		for (var i = 0; i < importers.length; i++) {
			this._importers[importers[i].name] = importers[i];
		}

		console.log('loaded %d importer(s)', importers.length);

		this._prepare();
	},

	_prepare: function() {
		var self = this;
		async.series({
			a: this._sort.bind(this),
			b: this._connectMongo.bind(this),
			c: this._connectMysql.bind(this)
		}, function(err, results) {
			if (err) {
				console.error(error.toString(err));
				return;
			}

			self._mongoConn = results.b;
			self._mysqlConn = results.c;

			self._start();
		});
	},

	_sort: function(callback) {
		console.log('determining dependency order...');

		var nodes = [];
		var edges = [];

		var importer;
		var node;

		for (var key in this._importers) {
			importer = this._importers[key];
			nodes.push(importer.name);
			
			if (importer.depends.length === 0) { continue; }

			for (var i = 0; i < importer.depends.length; i++) {
				edges.push([importer.name, importer.depends[i]]);
			}
		}

		try {
			this._order = toposort.array(nodes, edges).reverse();
		} catch (err) {
			return callback(err);
		}

		console.log('dependency order: %s', this._order.join(', '));
		callback(null);
	},

	_connectMongo: function(callback) {
		console.log('establishing MongoDB connection...');

		var options = config.get('mongoose');
		mongoose.connect(options.url, function(err) {
			if (err) {
				return callback(err);
			}
			callback(null, mongoose.connection);
		});
	},

	_connectMysql: function(callback) {
		console.log('establishing MySQL connection...');

		var options = config.get('mysql');
		var connection = mysql.createConnection(options);
		connection.connect(function(err) {
			if (err) {
				return callback(err);
			}
			callback(null, connection);
		});
	},

	_start: function() {
		async.series([
			this._empty.bind(this),
			this._import.bind(this),
			this._resolve.bind(this),
			this._cleanup.bind(this)
		], function(err, results) {
			if (err) {
				console.error(error.toString(err));
				return;
			}
			console.log('done');
		});
	},

	_batch: function(func, callback) {
		var fns = [], fn;
		var importer;
		for (var i = 0; i < this._order.length; i++) {
			importer = this._importers[this._order[i]];
			fns.push(func.bind(importer));
		}

		async.series(fns, function(err, results) {
			if (err) {
				return callback(err);
			}
			callback(null);
		});
	},

	_empty: function(callback) {
		console.log('emptying collections...');

		this._batch(function(callback) {
			console.log('emptying `%s`...', this.name);
			this.empty(callback);
		}, callback);
	},

	_import: function(callback) {
		console.log('importing collections...');

		var self = this;

		this._batch(function(callback) {
			console.log('importing `%s`...', this.name);
			this.import(self, callback);
		}, callback);
	},

	_resolve: function(callback) {
		console.log('resolving relationships...');

		var self = this;

		this._batch(function(callback) {
			console.log('resolving `%s`...', this.name);
			this.resolve(self, callback);
		}, callback);
	},

	_cleanup: function(callback) {
		console.log('cleaning up...');

		async.parallel([
			this._disconnectMongo.bind(this),
			this._disconnectMysql.bind(this)
		], function(err, results) {
			callback(null);
		});
	},

	_disconnectMongo: function(callback) {
		console.log('closing MongoDB connection...');

		this._mongoConn.close(function() {
			callback(null);
		});
	},

	_disconnectMysql: function(callback) {
		console.log('closing MySQL connection...');
		
		this._mysqlConn.end(function() {
			callback(null);
		});
	},

	get mongoose() {
		return this._mongoConn;
	},

	get mysql() {
		return this._mysqlConn;
	}

};

module.exports = new ImportManager();
