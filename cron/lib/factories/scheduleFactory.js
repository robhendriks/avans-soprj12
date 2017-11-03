'use strict';

var Factory = require('../factory');

function ScheduleFactory() {
	Factory.call(this);
}

ScheduleFactory.prototype = Object.create(Factory.prototype);
ScheduleFactory.prototype.constructor = ScheduleFactory;

ScheduleFactory.prototype.create = function(row) {
	return {
		scheduleId: this.getId(row.eplanningID),
		eventId: this.getId(row.evenementID),
		name: row.planningNaam,
		date: row.datum,
		starts: row.van,
		ends: row.tot
	};
};

module.exports = new ScheduleFactory();
