'use strict';

function vars_comparator(a,b) {
	if(a[0] < b[0]) return -1;
	if(a[0] > b[0]) return 1;
	return 0;
}

class Instance {
	constructor(type = "/obj", init_vars) {
		this.type = type;
		this.vars = new Map();
		if(init_vars) {
			for(let [k,v] of Object.entries(init_vars)) {
				this.vars.set(k,v);
			}
		}
		Object.seal(this);
	}

	toString() {
		let encoded_vars = [];
		for(let [key, val] of [...this.vars].sort(vars_comparator)) {
			encoded_vars.push(key + " = " + encode_constant(val));
		}
		if(encoded_vars.length) {
			return `${this.type}{${encoded_vars.join("; ")}}`;
		} else {
			return this.type;
		}
	}

	istype(t, strict = false) {
		if(this.type == t)
			return true;
		if(!strict && this.type.startsWith(t + "/"))
			return true;
		return false;
	}

	copy() {
		let inst = new Instance(this.type);
		for(let [k,v] of this.vars) {
			inst.vars.set(k,v);
		}
		return inst;
	}
}

function readlist(text, delimiter=",") {
	let list = [];
	let associative = new Map();
	if (!text)
		return;

	let position;
	let old_position = 0;

	while(position != -1) {
		// find next delimiter that is not within  "..."
		position = find_next_delimiter_position(text,old_position,delimiter);

		// check if this is a simple variable (as in list(var1, var2)) or an associative one (as in list(var1="foo",var2=7))
		let equal_position = text.substring(0,position == -1 ? text.length : position).indexOf("=",old_position);

		let trim_left = text.substring(old_position,(equal_position != -1 ? equal_position : (position == -1 ? text.length : position))).trim();
		let left_constant = delimiter == ";" ? trim_left : parse_constant(trim_left);
		old_position = position + 1;

		if((equal_position != -1) && typeof left_constant != "number") {
			// Associative var, so do the association.
			// Note that numbers cannot be keys - the RHS is dropped if so.
			let trim_right = text.substring(equal_position+1,position == -1 ? text.length : position).trim()
			let right_constant = parse_constant(trim_right);
			associative.set(left_constant, right_constant);
		}
		list += left_constant;
	}
	if(associative.size) return associative;
	return list;
}

function parse_constant(text) {
	// number
	if(+text == +text)
		return +text;

	// string
	if(text[0] == "\"")
		return text.substring(1,text.indexOf("\"",1));

	// list
	if(text.substring(0,5) == "list(")
		return readlist(text.substring(5,text.length-1));

	// file
	if(text[0] == "'")
		return {"file": text.substring(1,text.length-1)};

	// null
	if(text == "null")
		return null;

	// not parsed:
	// - pops: /obj{name="foo"}
	// - new(), newlist(), icon(), matrix(), sound()

	// fallback: string
	return {"typepath": text};
}

function encode_constant(thing) {
	// number
	if(typeof thing == "number")
		return `${thing}`;
	if(typeof thing == "string")
		return `"${thing}"`
	if(thing instanceof Array)
		return encode_array(thing);
	if(thing instanceof Map)
		return encode_map(thing);
	if(thing == null)
		return "null";
	if(typeof thing == "object") {
		if(thing.file)
			return `'${thing.file}'`;
		if(thing.typepath)
			return thing.typepath;
	}
	return "null";
}

function encode_array(arr) {
	let encoded = [];
	for(let item of arr) {
		encoded.push(encode_constant(item));
	}
	return `list(${encoded.join(",")})`;
}

function encode_map(map) {
	let encoded = [];
	for(let [key,val] of arr) {
		encoded.push(encode_constant(key)+"="+encode_constant(val));
	}
	return `list(${encoded.join(",")})`;
}

function parse_grid_model(grid_model) {
	if(grid_model == "null") return;
	let objects = [];
	let index = 0;
	let old_position = 0;
	let dpos;
	while(dpos != -1) {
		//finding next member (e.g /turf/uns`imulated/wall{icon_state = "rock"} or /area/mine/explored)
		dpos = find_next_delimiter_position(grid_model, old_position, ",", "{", "}") //find next delimiter (comma here) that's not within {...}

		let full_def = grid_model.substring(old_position, dpos == -1 ? grid_model.length : dpos).trim() //full definition, e.g : /obj/foo/bar{variables=derp}
		let variables_start = full_def.indexOf("{")
		let path_text = full_def.substring(0, variables_start == -1 ? full_def.length : variables_start).trim()
		old_position = dpos + 1

		//transform the variables in text format into a list (e.g {var1="derp"; var2; var3=7} => list(var1="derp", var2, var3=7))
		let instance = new Instance(path_text);

		if(variables_start != -1) {//if there's any variable
			full_def = full_def.substring(variables_start+1,full_def.length-1)//removing the last '}'
			instance.vars = readlist(full_def, ";")
		}

		objects.push(instance);
	}
	return objects;
}

function find_next_delimiter_position(text,initial_position=0, delimiter=",",opening_escape="\"",closing_escape="\"") {
	let position = initial_position;
	let next_delimiter = text.indexOf(delimiter,position);
	let next_opening = text.indexOf(opening_escape,position);

	while((next_opening != -1) && (next_opening < next_delimiter)) {
		position = text.indexOf(closing_escape,next_opening + 1)+1;
		next_delimiter = text.indexOf(delimiter,position);
		next_opening = text.indexOf(opening_escape,position);
	}

	return next_delimiter;
}

class DMM {
	constructor(maxx, maxy, maxz) {
		this.z_levels = [];
		if(typeof maxx == "number") {
			this.maxx = maxx;
			this.maxy = maxy;
			this.maxz = maxz;
			for(let z = 0; z < maxz; z++) {
				let z_level = [];
				this.z_levels.push(z_level);
				for(let y = 0; y < maxy; y++) {
					let row = [];
					z_level.push(row);
					for(let x = 0; x < maxx; x++) {
						row.push([new Instance("/turf/template_noop"),new Instance("/area/template_noop")]);
					}
				}
			}
		} else {
			this.maxx = 0;
			this.maxy = 0;
			this.maxz = 0;
			let dmm_regex = /"([a-zA-Z]+)" = \(((?:.|\r?\n)*?)\)\r?\n(?!\t)|\((\d+),(\d+),(\d+)\) = \{"([a-zA-Z\r\n]*)"\}/g;
			let regex_result = null;
			let dmm_text = maxx;
			let grid_models = new Map();
			let key_len = 1;
			while(regex_result = dmm_regex.exec(dmm_text)) {
				if(regex_result[1]) {
					let key = regex_result[1];
					key_len = key.length;
					if(!grid_models.has(key)) {
						grid_models.set(key, regex_result[2]);
					}
				} else if(regex_result[3]) {
					let init_x = +regex_result[3];
					let y = +regex_result[4];
					let z = +regex_result[5];
					let lines = regex_result[6].split(/\r?\n/g);
					let z_level = this.z_levels[z-1];
					if(!z_level) {
						z_level = [];
						this.z_levels[z-1] = z_level;
					}
					this.maxz = Math.max(this.maxz, z);
					for(let line of lines) {
						line = line.trim();
						if(!line.length) continue;
						this.maxy = Math.max(this.maxy, y);
						let row = z_level[y-1];
						if(!row) {
							row = [];
							z_level[y-1] = row;
						}
						let x = init_x;
						for(let i = 0; i < line.length; i += key_len) {
							row[x-1] = parse_grid_model(grid_models.get(line.substring(i, i + key_len)));
							this.maxx = Math.max(this.maxx, x);
							x++;
						}
						y++;
					}
				}
			}
			for(let z_level of this.z_levels) {
				z_level.reverse(); // origin is bottom left.
			}
		}
	}

	get_tile(x,y,z) {
		if(x < 1 || y < 1 || z < 1) return undefined;
		if(x > this.maxx || y > this.maxy || z > this.maxz) return undefined;
		return this.z_levels[z-1][y-1][x-1];
	}
	set_tile(x,y,z,tile) {
		if(x < 1 || y < 1 || z < 1) return;
		if(x > this.maxx || y > this.maxy || z > this.maxz) return;
		this.z_levels[z-1][y-1][x-1] = [...tile];
	}

	locate(x,y,z,type,strict = false) {
		let tile = this.get_tile(x,y,z, false);
		if(!tile) return;
		for(let inst of tile) {
			if(strict ? inst.type == type : inst.type.startsWith(type)) {
				return inst;
			}
		}
	}
	get_turf(x,y,z) {return this.locate(x,y,z,"/turf");}
	get_area(x,y,z) {return this.locate(x,y,z,"/area");}
	set_turf(x,y,z,inst) {
		let tile = this.get_tile(x,y,z, true);
		if(!tile) return;
		if(typeof inst == "string") inst = new Instance(inst);
		let turf_index = -1;
		let area_index = -1;
		for(let i = 0; i < tile.length; i++) {
			if(tile[i].type.startsWith("/turf")) turf_index = i;
			if(tile[i].type.startsWith("/area")) area_index = i;
		}
		if(turf_index != -1) {
			tile[turf_index] = inst;
		} else if(area_index != -1) {
			tile.splice(area_index, 0, inst);
		} else {
			tile.push(inst);
		}
	}
	set_area(x,y,z,inst) {
		let tile = this.get_tile(x,y,z, true);
		if(!tile) return;
		if(typeof inst == "string") inst = new Instance(inst);
		let turf_index = -1;
		let area_index = -1;
		for(let i = 0; i < tile.length; i++) {
			if(tile[i].type.startsWith("/turf")) turf_index = i;
			if(tile[i].type.startsWith("/area")) area_index = i;
		}
		if(area_index != -1) {
			tile[area_index] = inst;
		} else if(turf_index != -1) {
			tile.splice(turf_index+1, 0, inst);
		} else {
			tile.push(inst);
		}
	}
	add_object(x,y,z,inst) {
		let tile = this.get_tile(x,y,z, true);
		if(!tile) return;
		if(typeof inst == "string") inst = new Instance(inst);
		let insert_index = -1;
		for(let i = 0; i < tile.length; i++) {
			let type = tile[i].type;
			if(type.startsWith("/turf") || type.startsWith("/area")) {
				insert_index = i;
				break;
			}
		}
		if(insert_index != -1) {
			tile.splice(insert_index, 0, inst);
		} else {
			tile.push(insert_index, 0, inst);
		}
	}

	* all_coordinates() {
		for(let z = 1; z <= this.maxz; z++) {
			for(let y = 1; y <= this.maxy; y++) {
				for(let x = 1; x <= this.maxx; x++) {
					yield [x,y,z];
				}
			}
		}
	}

	* potential_keys(key_len) {
		if(key_len <= 1) {
			for(let i = 97; i <= 122; i++) {
				yield String.fromCharCode(i);
			}
			for(let i = 65; i <= 90; i++) {
				yield String.fromCharCode(i);
			}
			return;
		}
		for(let first_char of this.potential_keys(1)) {
			for(let the_rest of this.potential_keys(key_len - 1)) {
				yield first_char + the_rest;
			}
		}
	}

	toString() {
		let out = "";
		let instance_strings = new Set();
		for(let [x,y,z] of this.all_coordinates()) {
			instance_strings.add(this.get_tile(x,y,z).join(","));
		}
		let key_len = 1;
		while(instance_strings.size > 52**key_len)
			key_len++;
		let instance_keys = new Map();
		let keygen = this.potential_keys(key_len);
		for(let str of instance_strings) {
			let key = keygen.next().value;
			out += `"${key}" = (${str})\n`;
			instance_keys.set(str, key);
		}
		out += '\n';
		for(let z = 1; z <= this.maxz; z++) {
			out += `(1,1,${z}) = {"\n`;
			for(let y = this.maxy; y >= 1; y--) {
				for(let x = 1; x <= this.maxx; x++) {
					out += instance_keys.get(this.get_tile(x,y,z).join(","));
				}
				out += `\n`;
			}
			out += `"}`;
		}
		return out;
	}
}

DMM.Instance = Instance;

module.exports = DMM;
