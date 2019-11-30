'use strict';
const MapTemplate = require('./template.js');
const {shuffle, dir_dx, dir_dy, turn_dir} = require('./util.js');
const wall_flags = require('./wall_flags.js');

const template_escape1 = MapTemplate.load("ungrouped/escape1.dmm");
const template_arrivals1 = MapTemplate.load("ungrouped/arrivals1.dmm");
const template_chapel1 = MapTemplate.load("ungrouped/chapel1.dmm");
const template_locker_room1 = MapTemplate.load("ungrouped/locker_room1.dmm");

function place_room(templates, {slide = null, slide_gap = false} = {}) {
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
			if(template.check_placement_validity(this.dmm, x, y, template_dir)) {
				let placed_x = x;
				let placed_y = y;
				if(slide) {
					let right_dir = turn_dir(template_dir, 90);
					let right_dx = dir_dx(right_dir);
					let right_dy = dir_dy(right_dir);
					let slide_min = 0;
					let slide_max = 0;
					for(let i = -1; i >= -100; i--) {
						if(!template.check_placement_validity(this.dmm, x + right_dx * i, y + right_dy * i, template_dir)) {
							break;
						} else {
							slide_min = i;
						}
					}
					for(let i = 1; i <= 100; i++) {
						if(!template.check_placement_validity(this.dmm, x + right_dx * i, y + right_dy * i, template_dir)) {
							break;
						} else {
							slide_max = i;
						}
					}
					let slide_right = true;
					if(slide == "out") {
						let focal_x, focal_y;
						focal_x = this.dmm.maxx/2;
						focal_y = this.dmm.maxy/2;
						let right_awayness = ((x-focal_x) * right_dx) + ((y-focal_y) * right_dy); // do a dot product
						if(slide == "out") {
							slide_right = (right_awayness > 0);
						} else {
							slide_right = (right_awayness < 0);
						}
					}
					if(slide_right) {
						placed_x = x + right_dx * slide_max;
						placed_y = y + right_dy * slide_max;
					} else {
						placed_x = x + right_dx * slide_min;
						placed_y = y + right_dy * slide_min;
					}
				}

				template.place(this.dmm, placed_x, placed_y, template_dir);
				return;
			}
		}
	}
	throw new Error("Failed to place templates on the map");
}

function place_all_rooms() {
	console.log("Placing rooms...");
	this.place_room([template_escape1], {slide: "out"});
	this.place_room([template_arrivals1], {slide: "out"});
	this.place_room([template_chapel1], {slide: "out"});
	this.place_room([template_locker_room1], {slide: "out"});
}

module.exports = {place_room, place_all_rooms};
