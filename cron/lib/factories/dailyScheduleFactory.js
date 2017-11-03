'use strict';

var Factory = require('../factory');

function DailyScheduleFactory() {
  Factory.call(this);
}

DailyScheduleFactory.prototype = Object.create(Factory.prototype);
DailyScheduleFactory.prototype.constructor = DailyScheduleFactory;

DailyScheduleFactory.prototype.create = function(row) {
  return {
    dailyScheduleId: this.getId(row.dplanningID),
    scheduleId: this.getId(row.eplanningID),
    name: row.planningNaam,
    description: row.omschrijving,
    startsAt: row.tijdVan,
    endsAt: row.tijdTot,
    points: row.aantalPunten
  };
};

module.exports = new DailyScheduleFactory();
