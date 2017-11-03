'use strict';

var Factory = require('../factory');

function ContactFactory() {
	Factory.call(this);
}

ContactFactory.prototype = Object.create(Factory.prototype);
ContactFactory.prototype.constructor = ContactFactory;

ContactFactory.prototype.getName = function(row) {
	var parts = [
		(row.cpVoorvoegsel || '').trim(),
		(row.cpVoornaam || '').trim(),
		(row.cpTussenvoegsel || '').trim(),
		(row.cpAchternaam || '').trim()
	];
	var newParts = [];
	for (var i = 0; i < parts.length; i++) {
		if (parts[i] !== '') { newParts.push(parts[i]); }
	}
	return newParts.join(' ');
};

ContactFactory.prototype.create = function(row) {
	return {
		cpId: this.getId(row.cpID),
		parentCpId: this.getId(row.parentCpID),
		gender: (row.geslachtsID === 0 ? 'f' : 'm'),
		salutation: row.cpAanhef || '',
		initials: row.cpInitialen || '',
		firstName: (row.cpVoornaam || '').trim(),
		lastName: (row.cpAchternaam || '').trim(),
		prefix: (row.cpVoorvoegsel || '').trim(),
		insertion: (row.cpTussenvoegsel || '').trim(),
		name: this.getName(row),
		dateOfBirth: row.cpGeboortedatum,
		address: row.adres,
		zip: row.postcode,
		town: row.plaats,
		country: row.land,
		email: row.email,
		phone: row.telefoon,
		mobile: row.mobiel,
		isChild: false,
		isParent: false,
		isLeader: false,
		score: 0
	};
};

module.exports = new ContactFactory();
