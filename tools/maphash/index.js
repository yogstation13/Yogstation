const DMM = require('./lib/dmm.js');
const fs = require('fs').promises;
const path = require('path');
const readline = require("readline");
const crypto = require('crypto');

if(!fs) {
	console.error("Your node.js is out of date. You must have node.js 10 or newer.");
	process.exit(1);
}

//let text = fs.readFileSync('../../_maps/map_files/YogStation/YogStation.dmm', 'utf8');
//fs.writeFileSync('out.dmm', new DMM(text).toString());

console.log("Running maphash...");

let files = [];
let file_outputs = new Map();
let slashes = ['|', '/', '-', '\\'];
let slash_index = 0;
console.log();

let converted_file_cache = {};

async function do_dir(dirname) {
	let dir = await fs.readdir(dirname, {withFileTypes: true});
	let promises = [];
	for(let ent of dir) {
		if(ent.name == ".git" || ent.name == "node_modules") continue; // ignore folders with lots of irrelevant files.
		let ent_path = path.join(dirname, ent.name);
		if(ent.isDirectory()) {
			promises.push(do_dir(ent_path));
		} else if(ent.name.endsWith(".dmm")) {
			promises.push(fs.readFile(ent_path, 'utf8').then((file_text) => {
				process.stdout.write('\r' + slashes[(++slash_index) % 4]);
				let hash;
				if(converted_file_cache[path.resolve(ent_path)]) {
					hash = crypto.createHash('sha1').update(file_text).digest('base64');
					if(converted_file_cache[path.resolve(ent_path)] == hash) return;
				}
				try {
					let dmm = new DMM(file_text);
					let converted = dmm.toString();
					if(converted != file_text) {
						files.push(ent_path);
						file_outputs.set(ent_path, converted);
					} else {
						if(!hash) hash = crypto.createHash('sha1').update(file_text).digest('base64');
						converted_file_cache[path.resolve(ent_path)] = hash;
					}
				} catch(e) {
					console.error("In " + ent_path);
					console.error(e);
				}
			}));
		}
	}
	await Promise.all(promises);
}
(async () => {
	let initial_path = '../..';
	if(process.argv.includes("--root-dir")) {
		initial_path = process.argv[process.argv.indexOf('--root-dir') + 1];
	}

	try {
		converted_file_cache = JSON.parse(await fs.readFile(path.join(__dirname, "converted_file_cache.json"), 'utf8'));
	} catch(e) {}
	if(!converted_file_cache) converted_file_cache = {};

	await do_dir(initial_path);


	console.log();
	if(process.argv.includes("--check")) {
		if(files.length) {
			console.error("Some files don't match - " + files.join(", "));
			process.exit(1);
		} else {
			console.log("All files match.");
			process.exit(0);
		}
	}
	if(!files.length) {
		console.log("All files are already converted!");
		await fs.writeFile(path.join(__dirname, "converted_file_cache.json"), JSON.stringify(converted_file_cache));
		process.exit(0);
	}
	files.sort();
	for(let i = 0; i < files.length; i++) {
		console.log(i + ": " + files[i]);
	}
	function save(flagged_maps) {
		let promises = [];
		for(let map of flagged_maps) {
			let text = file_outputs.get(map);
			if(map) {
				promises.push(fs.copyFile(map, map + ".before").then(async () => {
					console.log("Created backup for " + map);
					await fs.writeFile(map, text);
					console.log("Written " + map);
					converted_file_cache[path.resolve(map)] = crypto.createHash('sha1').update(text).digest('base64');
				}).catch(console.error));
			}
		}
		Promise.all(promises).then(() => {
			return fs.writeFile(path.join(__dirname, "converted_file_cache.json"), JSON.stringify(converted_file_cache));
		});
	}
	if(process.argv.includes("--all")) {
		save(files);
	} else {
		const rl = readline.createInterface({
			input: process.stdin,
			output: process.stdout
		});
		rl.question('Which maps would you like to convert? ', (text) => {
			let flagged_maps = new Set();
			let parts = text.split(",");
			for(let part of parts) {
				let range = part.split("-");
				if(range.length == 2) {
					for(let i = +range[0]; i <= +range[1]; i++) {
						flagged_maps.add(files[i]);
					}
				} else {
					flagged_maps.add(files[+range[0]]);
				}
			}
			rl.close();
			save(flagged_maps);
		});
	}
})();
