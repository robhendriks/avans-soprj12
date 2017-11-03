var oauthserver = require('oauth2-server');

module.exports = oauthserver({
	model: require('../models/oauth'),
	grants: ['password'],
	accessTokenLifetime: null,
	debug: true
});
