const MapGenerator = require('./lib/generator.js');
const fs = require('fs');

let gen = new MapGenerator();
gen.generate();
fs.writeFileSync("out.dmm", gen.dmm.toString());
