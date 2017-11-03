'use strict';
var chalk = require('chalk');
var async = require('async');
var models = require('ojt-models');

var Importer = require('../importer');
var DailyScheduleFactory = require('../factories/dailyScheduleFactory');
var DailySchedule = models.DailySchedule;
var Schedule = models.Schedule;

function DailyScheduleImporter() {
  Importer.call(this, 'DailySchedule', ['Schedule']);
}

DailyScheduleImporter.prototype = Object.create(Importer.prototype);
DailyScheduleImporter.prototype.constructor = DailyScheduleImporter;

DailyScheduleImporter.prototype.empty = function(callback) {
  DailySchedule.remove({})
    .then(function () { callback(null); })
    .catch(callback);
};

DailyScheduleImporter.prototype.import = function(manager, callback) {
  manager.mysql.query('SELECT * FROM `la_dagplanning`', function(err, rows) {
    if (err) {
      return callback(err);
    }

    console.log(chalk.dim('query to `la_dagplanning` returned %d row(s)'), rows.length);

    var scheduleBag = DailyScheduleFactory.createAll(rows);
    DailySchedule.collection.insert(scheduleBag, function(err, docs) {
      if (err) {
        return callback(err);
      }
      callback(null);
    });
  });
};

DailyScheduleImporter.prototype.resolve = function(manager, callback) {
  DailySchedule.find({}).exec()
    .then(function(dailySchedules) {
      var fns = [];
      var dailySchedule;

      for (var i = dailySchedules.length - 1; i >= 0; i--) {
        dailySchedule = dailySchedules[i];

        if (!dailySchedule.scheduleId) { 
          continue; 
        }

        fns.push(function(callback) {

          var self = this;

          Schedule.findOne({scheduleId: self.scheduleId}).exec()
            .then(function(schedule) {
              if (!schedule) { return; }
              schedule.daily.push(self.id);
              return schedule.save();
            })
            .then(function(schedule) {
              self.schedule = schedule;
              return self.save();
            })
            .then(function(dailySchedule) {
              return callback(null, (dailySchedule ? true : false));
            })
            .catch(callback);

        }.bind(dailySchedule));
      }

      async.parallel(fns, function(err, results) {
        if (err) {
          return callback(err);
        };

        var count = 0;
        for (var i = results.length - 1; i >= 0; i--) {
          if (results[i] !== false) { 
            count++; 
          }
        }
        console.log(chalk.green('resolved %d relationship(s)'), count);
        
        callback(null);
      });
    })
    .catch(callback);
};

module.exports = new DailyScheduleImporter();
