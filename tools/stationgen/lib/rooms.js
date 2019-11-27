'use strict';
const MapTemplate = require('./template.js');
const {shuffle, dir_dx, dir_dy, turn_dir} = require('./util.js');
const wall_flags = require('./wall_flags.js');

const template_escape1 = MapTemplate.load("ungrouped/escape1.dmm");

function place_room(templates) {
	shuffle(templates);
	for(let template of templates) {
		for(let [x,y,z] of shuffle([...this.dmm.all_coordinates()])) {
			let area = this.dmm.get_area(x,y,z);
			let turf = this.dmm.get_turf(x,y,z);
			if(!area.istype(template.anchor_area)) continue;
			if(!turf.istype("/turf/wall_marker") || !(turf.vars.get("wall_flags") & wall_flags.FLOOR)) continue;
			let floor_dir = 0;
			for(let dir of [1,2,4,8]) {
				if(!this.dmm.get_turf(x+dir_dx(dir),y+dir_dy(dir),z).istype("/turf/open/floor")) continue;
				if(floor_dir == 0) floor_dir = dir;
				else if(floor_dir > 0) floor_dir = -1;
			}
			if(floor_dir <= 0) continue;
			let template_dir = turn_dir(floor_dir, 180);
			console.log(x + ", " + y + ", " + template_dir);
			if(template.check_placement_validity(this.dmm, x, y, template_dir)) {
				template.place(this.dmm, x, y, template_dir);
				return;
			}
		}
	}
	//throw new Error("Failed to place templates on the map");
}

function place_all_rooms() {
	this.place_room([template_escape1]);
}

module.exports = {place_room, place_all_rooms};
