'use strict';

var path = require('path');
var logger = require('morgan');
var express = require('express');
var bodyParser = require('body-parser');
var mongoose = require('mongoose');
var goosepage = require('goosepage');

var Promise = require('bluebird');
mongoose.Promise = Promise;

mongoose.connect(require('./config/db').url);

goosepage.defaults = {
  itemsPerPage: 30
};

var app = express();

app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: false}));

app.use('/', require('./routes'));

module.exports = app;
