'use strict';

var models = require('ojt-models');
var User = models.User;
var Client = models.Client;

var AccessToken = require('./accessToken');
var RefreshToken = require('./refreshToken');

module.exports = {
	
	getClient: function(clientId, clientSecret, callback) {
		Client.findOne({clientId: clientId}).exec()
			.then(function(client) {
				if (!client) {
					return callback(null, false);
				}
				callback(null, client);
			})
			.catch(callback);
	},

	grantTypeAllowed: function(clientId, grantType, callback) {
		callback(null, true);
	},

	getUser: function(username, password, callback) {
		User.findOne({email: username}).exec()
			.then(function(user) {
				if (!user || !user.validPassword(password)) {
					return callback(null, false);
				}
				callback(null, user);
			})
			.catch(callback);
	},

	getAccessToken: function(bearerToken, callback) {
		AccessToken.findOne({accessToken: bearerToken}).exec()
			.then(function(accessToken) {
				if (!accessToken) {
					return callback(null, false);
				}
				callback(null, accessToken);
			});
	},

	saveAccessToken: function(accessToken, clientId, expires, user, callback) {
    console.log(accessToken);
		var token = new AccessToken({
			accessToken: accessToken,
			userId: user.id,
			clientId: clientId,
			expires: expires
		});

		AccessToken.remove({userId: user.id, clientId: clientId})
			.then(token.save)
			.then(function(accessToken) {
				callback(null, accessToken);
			})
			.catch(callback);
	},

	getRefreshToken: function(refreshToken, callback) {
		RefreshToken.findOne({refreshToken: refreshToken}).exec()
			.then(function(refreshToken) {
				if (!refreshToken) {
					return callback(null, false);
				}
				callback(null, refreshToken);
			});
	},

	saveRefreshToken: function(refreshToken, clientId, expires, user, callback) {
		var token = new RefreshToken({
			refreshToken: refreshToken,
			userId: user.id,
			clientId: clientId,
			expires: expires
		});

		RefreshToken.remove({userId: user.id, clientId: clientId})
			.then(token.save)
			.then(function(refreshToken) {
				callback(null, refreshToken);
			})
			.catch(callback);
	}

};
