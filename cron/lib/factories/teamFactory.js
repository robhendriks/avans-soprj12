'use strict';

var Factory = require('../factory');

function TeamFactory() {
	Factory.call(this);
}

TeamFactory.prototype = Object.create(Factory.prototype);
TeamFactory.prototype.constructor = TeamFactory;

TeamFactory.prototype.create = function(row) {
	return {
		teamId: row.teamID,
		cpId: row.eersteCP,
		name: row.teamNaam,
		description: row.omschrijving,
    score: 0
	};
};

module.exports = new TeamFactory();
