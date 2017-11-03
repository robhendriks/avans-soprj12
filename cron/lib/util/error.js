module.exports = {

	toString: function(e) {
		return e.stack || (e.message || e);
	}

};
