'use strict';
const DMM = require('./dmm.js');

const parts = [
	'./hallways.js'
];

class MapGenerator {
	constructor(maxx = 255, maxy = 255) {
		this.dmm = new DMM(maxx, maxy, 1);
	}

	generate() {
		this.generate_hallways();
	}
}

for(let part of parts) {
	Object.assign(MapGenerator.prototype, require(part));
}

module.exports = MapGenerator;
