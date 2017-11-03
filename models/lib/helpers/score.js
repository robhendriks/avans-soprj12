'use strict';

var Promise = require('mpromise');

var Score = module.exports;

Score.fns = {
  '+': function(value) {
    return this + value;
  },
  '-': function(value) {
    return this - value;
  }
};

Score.getFn = function(key) {
  return (key in this.fns) ? this.fns[key] : false;
};

Score.updateScore = function(obj, args) {
  var p = new Promise();

  var options = args || {};
  var op = options.op || false;
  var val = new Number(options.val);
  var fn = this.getFn(op);

  if (!fn) {
    return p.reject(new Error('Invalid or missing operator'));
  } else if (!val) {
    return p.reject(new Error('Invalid or missing value'));
  }

  var oldVal = obj.score;
  var newVal = Math.max(0, fn.call(oldVal, Math.abs(val)));

  return p.fulfill({
    value: {
      old: oldVal, 
      new: newVal
    },
    changed: newVal !== oldVal
  });
};
