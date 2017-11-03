'use strict';

module.exports = function() {

	return [
		function(req, res, next) {
			next(res.error(404));
		},
		function(err, req, res, next) {
			var status;
			var body = {};

			if (err.name === 'NiftyError' && (status = err.status)) {
				body.code = status.code;
				body.error = status.text;
				
				if (err.description) {
					body.error_description = err.description;
				}
			} else {
				body.code = 500;
				body.error = err.message || err;
				console.error(err.stack || err);
			}

			res.status(body.code).json(body);
		}
	];

};
