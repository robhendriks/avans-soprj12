'use strict';

var Factory = require('../factory');

function EventFactory() {
	Factory.call(this);
}

EventFactory.prototype = Object.create(Factory.prototype);
EventFactory.prototype.constructor = EventFactory;

EventFactory.prototype.create = function(row) {
	return {
		eventId: this.getId(row.evenementID),
		name: row.evenementNaam,
		description: row.omschrijving,
		dateFrom: row.datumVan,
		dateTo: row.datumTot
	};
};

module.exports = new EventFactory();
