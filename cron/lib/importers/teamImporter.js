'use strict';
var chalk = require('chalk');
var async = require('async');
var models = require('ojt-models');

var Importer = require('../importer');
var TeamFactory = require('../factories/teamFactory');

var Team = models.Team;
var Contact = models.Contact;

function TeamImporter() {
	Importer.call(this, 'Team', ['Contact']);
}

TeamImporter.prototype = Object.create(Importer.prototype);
TeamImporter.prototype.constructor = TeamImporter;

TeamImporter.prototype.empty = function(callback) {
	Team.remove({})
		.then(function() { 
			callback(null); 
		})
		.catch(callback);
};

TeamImporter.prototype.import = function(manager, callback) {
	manager.mysql.query('SELECT * FROM `la_teams`', function(err, rows) {
		if (err) {
			return callback(err);
		}

		console.log(chalk.dim('query to `la_teams` returned %d row(s)'), rows.length);

		var teamBag = TeamFactory.createAll(rows);
		Team.collection.insert(teamBag, function(err, docs) {
			if (err) {
				return callback(err);
			}
			callback(null);
		});
	});
};

TeamImporter.prototype.resolve = function(manager, callback) {
	async.series([
		function(callback) {
			Team.find({}).exec()
				.then(function(teams) {
					var fns = [];
					var team;
					for (var i = 0; i < teams.length; i++) {
						team = teams[i];
						if (!team.cpId) { continue; }

						fns.push(function(callback) {
							var self = this;
							Contact.findOne({cpId: self.cpId}).exec()
								.then(function(contact) {
									if (!contact) { return; }
									self.leader = contact.id;

									contact.isParent = false;
									contact.isLeader = true;
									contact.team = self.id;
									contact.save();

									return self.save();
								})
								.then(function(contact) {
									callback(null, (contact ? true : false));
								})
								.catch(function(err) {
									callback(err);
								});

						}.bind(team));
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
		},
		function(callback) {
			manager.mysql.query('SELECT * FROM `la_teamleden`', function(err, rows) {
				if (err) {
					return callback(err);
				}

				console.log(chalk.dim('query to `la_teamleden` returned %d row(s)'), rows.length);

				var items = {};
				var row;
				for (var i = 0; i < rows.length; i++) {
					row = rows[i];
					if (row.teamID in items)
						items[row.teamID].push(row.cpID);
					else {
						items[row.teamID] = [row.cpID];
					}
				}

				Team.find({teamId: {$in: Object.keys(items)}}).exec()
					.then(function(teams) {
						var fns = [];
						var team;
						for (var i = 0; i < teams.length; i++) {
							team = teams[i];
							fns.push(function(cpIds, callback) {
								var self = this;
								Contact.find({
									_id: {$ne: self.leader},
									cpId: {$in: cpIds}
								})
									.exec()
									.then(function(contacts) {
										var contact;
										for (var i = 0; i < contacts.length; i++) {
											contact = contacts[i];
											contact.team = self.id;
											contact.save();

											self.members.push(contact.id);
										}
										return self.save();
									})
									.then(function(team) {
										callback(err, team.members.length);
									})
									.catch(function(err) {
										callback(err);
									});
							}.bind(team, items[team.teamId]));
						}

						async.parallel(fns, function(err, results) {
							if (err) {
								return callback(err);
							}

							var count = 0;
							for (var i = 0; i < results.length; i++) {
								count += results[i];
							}
							console.log(chalk.green('resolved %d relationship(s)'), count);

							callback(null);
						});
					})
					.catch(function(err) {
						callback(err);
					});
			});
		}
	], function(err, results) {
		if (err) {
			return callback(err);
		}
		callback(null);
	});
};

module.exports = new TeamImporter();
