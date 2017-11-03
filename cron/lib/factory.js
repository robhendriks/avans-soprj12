function Factory() {}

Factory.prototype = {

	constructor: Factory,

	getId: function(id) {
		return (id === '00000000-0000-0000-0000-000000000000' ? null : id);
	},

	create: function(row) {
		return {};
	},

	createAll: function(rows) {
		var results = [];
		for (var i = 0; i < rows.length; i++) {
			results.push(this.create(rows[i]));
		}
		return results;
	}

};

module.exports = Factory;
