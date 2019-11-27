'use strict';
const DMM = require('./dmm.js');
const wall_flags = require('./wall_flags.js');
const {dir_dx, dir_dy, turn_dir, dirs_angle} = require('./util.js');
const fs = require('fs');

class MapTemplate {
	constructor(dmm, props = {}) {
		if(typeof dmm == "string") {
			dmm = new DMM(dmm);
		}
		this.dmm = dmm;
		this.anchor_x = 1;
		this.anchor_y = 1;
		this.anchor_dir = 1;
		for(let [x,y,z] of this.dmm.all_coordinates()) {
			let turf = this.dmm.get_turf(x,y,z);
			if(turf.istype("/turf/wall_marker") && turf.type != "/turf/wall_marker") {
				let flags = 0;
				switch(turf.type) {
				case "/turf/wall_marker/window_wall":
					flags = wall_flags.WINDOWS | wall_flags.WALLS | wall_flags.WINDOW_ALL;
					break;
				case "/turf/wall_marker/rwindow_wall_space":
					flags = wall_flags.RWINDOW | wall_flags.WALLS | wall_flags.SPACE | wall_flags.WINDOW_ALL;
					break;
				case "/turf/wall_marker/rwindow_wall":
					flags = wall_flags.RWINDOW | wall_flags.WALLS | wall_flags.WINDOW_ALL;
					break;
				case "/turf/wall_marker/rswindow_wall":
					flags = wall_flags.RWINDOW | wall_flags.WALLS | wall_flags.WINDOW_SPACE | wall_flags.WINDOW_NOCABLE;
					break;
				case "/turf/wall_marker/rwindow_wall_floor":
					flags = wall_flags.RWINDOW | wall_flags.WALLS | wall_flags.FLOOR | wall_flags.WINDOW_ALL;
					break;
				case "/turf/wall_marker/rwindow_rwall":
					flags = wall_flags.RWINDOW | wall_flags.RWALL | wall_flags.WINDOW_ALL;
					break;
				case "/turf/wall_marker/wall":
					flags = wall_flags.WALLS;
					break;
				case "/turf/wall_marker/rwall":
					flags = wall_flags.RWALL;
					break;
				case "/turf/wall_marker/rswindow_rwall_space":
					flags = wall_flags.RWINDOW | wall_flags.RWALL | wall_flags.WINDOW_SPACE | wall_flags.WINDOW_NOCABLE | wall_flags.SPACE;
					break;
				case "/turf/wall_marker/rcswindow_rwall_space":
					flags = wall_flags.RWINDOW | wall_flags.RWALL | wall_flags.WINDOW_SPACE | wall_flags.SPACE;
					break;
				case "/turf/wall_marker/wall_space":
					flags = wall_flags.WALLS | wall_flags.SPACE;
					break;
				case "/turf/wall_marker/rwall_space":
					flags = wall_flags.RWALL | wall_flags.SPACE;
					break;
				case "/turf/wall_marker/rcwindow_rwall":
					flags = wall_flags.RWALL | wall_flags.RWINDOW | wall_flags.WINDOW_HALLWAY | wall_flags.WINDOW_DEPARTMENT | wall_flags.WINDOW_SPACE;
					break;
				case "/turf/wall_marker/rcdswindow_rwall":
					flags = wall_flags.RWALL | wall_flags.RWINDOW | wall_flags.WINDOW_DEPARTMENT | wall_flags.WINDOW_SPACE;
					break;
				}
				turf.type = "/turf/wall_marker";
				turf.vars.set("wall_flags", flags);
			}

			for(let obj of this.dmm.get_tile(x,y,z)) {
				if(obj.istype("/obj/effect/procedural_marker/anchor")) {
					this.anchor_x = x;
					this.anchor_y = y;
					this.anchor_dir = obj.vars.get("dir") || 2;
				}
			}
		}
		if(this.anchor_dir == 1) {
			this.dwidth = this.anchor_x - 1;
			this.width = this.dmm.maxx;
			this.dheight = this.anchor_y - 1;
			this.height = this.dmm.maxy;
		} else if(this.anchor_dir == 2) {
			this.dwidth = this.dmm.maxx - this.anchor_x;
			this.width = this.dmm.maxx;
			this.dheight = this.dmm.maxy - this.anchor_y;
			this.height = this.dmm.maxy;
		} else if(this.anchor_dir == 4) {
			this.dwidth = this.dmm.maxy - this.anchor_y;
			this.width = this.dmm.maxy;
			this.dheight = this.anchor_x - 1;
			this.height = this.dmm.maxx;
		} else if(this.anchor_dir == 8) {
			this.dwidth = this.anchor_y - 1;
			this.width = this.dmm.maxy;
			this.dheight = this.dmm.maxx - this.anchor_x;
			this.height = this.dmm.maxx;
		}
		this.allow_rotation = (props.allow_rotation == null) ? true : props.allow_rotation;
		this.anchor_area = props.anchor_area || "/area/hallway/primary";
	}

	* ordered_locs(x = this.anchor_x, y = this.anchor_y, dir = this.anchor_dir, width = this.width, height = this.height, dwidth = this.dwidth, dheight = this.dheight) {
		let f_dx = dir_dx(dir);
		let f_dy = dir_dy(dir);
		let r_dx = f_dy;
		let r_dy = -f_dx;
		for(let ly = 0; ly < height; ly++) {
			for(let lx = 0; lx < width; lx++) {
				let out_x = x + f_dx * (ly - dheight) + r_dx * (lx - dwidth);
				let out_y = y + f_dy * (ly - dheight) + r_dy * (lx - dwidth);
				yield [out_x, out_y];
			}
		}
	}

	place(target, place_x, place_y, place_dir) {
		let ordered_source = [...this.ordered_locs()];
		let ordered_target = [...this.ordered_locs(place_x, place_y, place_dir)];

		let angle = dirs_angle(this.anchor_dir, place_dir);

		for(let i = 0; i < ordered_source.length; i++) {
			let [sx, sy] = ordered_source[i];
			let [tx, ty] = ordered_target[i];

			for(let obj of this.dmm.get_tile(sx, sy, 1)) {
				if(obj.istype("/turf")
					|| obj.istype("/area")
					|| obj.istype("/obj/effect/procedural_marker/anchor")
					|| obj.istype("/obj/effect/procedural_marker/turf_check"))
					continue;
				target.add_object(tx, ty, 1, this.make_rotated_copy(obj, angle));
				if(obj.istype("/obj/docking_port/stationary")) {
					for(let [x,y] of this.ordered_locs(tx, ty, turn_dir(obj.vars.get("dir") || 2, angle), obj.vars.get("width")||1, obj.vars.get("height")||1, obj.vars.get("dwidth")||0, obj.vars.get("dheight")||0)) {
						target.set_turf(x,y,1,"/turf/open/space/basic");
						target.set_area(x,y,1,"/area/space");
					}
				}
			}

			let target_turf = target.get_turf(tx, ty, 1);
			let source_turf = this.dmm.get_turf(sx, sy, 1);

			if(source_turf.istype("/turf/template_noop")) {
				// S K I P.
			} else if(source_turf.type == "/turf/wall_marker" && target_turf.type == "/turf/wall_marker") {
				target_turf.vars.set("wall_flags", target_turf.vars.get("wall_flags") & source_turf.vars.get("wall_flags"));
			} else if(target_turf.istype(source_turf.type) && target_turf.type != "/turf/open/space/basic") {
				// We don't write if the target turf is a subtype (or equal to) the source turf. For example, putting a white floor on a normal floor would keep white floor.
			} else if(source_turf.type == "/turf/open/space/basic" && target_turf.type == "/turf/open/space") {
				// don't upgrade regular turfs to "basic".
			} else {
				target.set_turf(tx, ty, 1, this.make_rotated_copy(source_turf, angle));
			}

			let target_area = target.get_area(tx, ty, 1);
			let source_area = this.dmm.get_area(sx, sy, 1);

			if(source_area.istype("/area/template_noop")) {
				// S K I P.
			} else if(target_area.istype(source_area.type)) {
				// same thing with areas. If we have a /area/hallway being placed on a /area/hallway/primary/central, the /area/hallway/primary/central stays.
			} else {
				target.set_area(tx, ty, 1, this.make_rotated_copy(source_area, angle));
			}
		}
	}

	check_placement_validity(target, place_x, place_y, place_dir) {
		let ordered_source = [...this.ordered_locs()];
		let ordered_target = [...this.ordered_locs(place_x, place_y, place_dir)];

		let angle = dirs_angle(this.anchor_dir, place_dir);

		for(let i = 0; i < ordered_source.length; i++) {
			let [sx, sy] = ordered_source[i];
			let [tx, ty] = ordered_target[i];
			if(tx < 1 || ty < 1 || tx > target.maxx || ty > target.maxy) {
				console.log("oob");
				return false;
			}

			let target_turf = target.get_turf(tx, ty, 1);
			let source_turf = this.dmm.get_turf(sx, sy, 1);
			let target_area = target.get_area(tx, ty, 1);
			let source_area = this.dmm.get_area(sx, sy, 1);

			if(target.locate(sx, sy, 1, "/obj/effect/procedural_marker/turf_check") && !source_turf.istype(target_turf.type) && !target_turf.istype(source_turf.type)) {
				console.log("failed turf check");
				return false;
			}

			let docking_port = this.dmm.locate(sx, sy, 1, "/obj/docking_port/stationary");
			if(docking_port) {
				console.log("Checking docking port");
				for(let [x,y] of this.ordered_locs(tx, ty, turn_dir(docking_port.vars.get("dir") || 2, angle), docking_port.vars.get("width")||1, docking_port.vars.get("height")||1, docking_port.vars.get("dwidth")||0, docking_port.vars.get("dheight")||0)) {
					if(x < 1 || y < 1 || x > target.maxx || y > target.maxy)
						return false;
					if(!target.get_turf(x,y,1).istype("/turf/template_noop"))
						return false;
				}
			}

			if(source_turf.istype("/turf/template_noop") || target_turf.istype("/turf/template_noop")) {
				// S K I P.
			} else if(source_turf.type == "/turf/wall_marker") {
				if(!this.check_turf_to_wall_marker(target_turf, source_turf)) {
					console.log("failed template wall marker");
					return false;
				}
			} else if(target_turf.type == "/turf/wall_marker") {
				if(!this.check_turf_to_wall_marker(source_turf, target_turf)) {
					console.log("failed target wall marker");
					return false;
				}
			} else if(!target_turf.istype(source_turf.type) && !source_turf.istype(target_turf.type)){
				console.log("failed type check of turf");
				return false;
			}
			if(!target_area.istype(source_area.type) && !source_area.istype(target_area.type) && source_turf.istype("/turf/open/floor") && target_turf.istype("/turf/open/floor")) {
				console.log("non-matching area");
				return false; // check area equality but only if it's a floor being placed on a floor.
			}
		}
		return true;
	}

	check_turf_to_wall_marker(turf, wall_marker) {
		let flags = wall_marker.vars.get("wall_flags");
		if(turf.type == "/turf/wall_marker") {
			return !!(turf.vars.get("wall_flags") & flags);
		} else if(turf.istype("/turf/open/floor") && (flags & wall_flags.FLOOR)
			|| turf.type == "/turf/closed/wall" && (flags & wall_flags.WALL)
			|| turf.type == "/turf/closed/wall/r_wall" && (flags & wall_flags.RWALL)
			|| turf.type == "/turf/open/space" && (flags & wall_flags.SPACE)) {
			return true;
		}
		return false;
	}

	make_rotated_copy(obj, angle) {
		obj = obj.copy();
		if(obj.istype("/area")) return obj; // hey you don't rotate areas you chumbis
		let named_dirs = [null,"north","south",null,"east",null,null,null,"west"];
		let named_dirs_result = /\/(north|south|east|west)(?=$|\/)/.exec(obj.type);
		if(named_dirs_result) {
			obj.type = obj.type.replace(/\/(north|south|east|west)(?=$|\/)/, "/"+named_dirs[turn_dir(named_dirs.indexOf(named_dirs_result[1]), angle)]);
			return obj;
		}
		obj.vars.set("dir", turn_dir(obj.vars.get("dir") || 2, angle));
		let pixel_x = obj.vars.get("pixel_x") || 0;
		let pixel_y = obj.vars.get("pixel_y") || 0;
		if(pixel_x || pixel_y) {
			let s = dir_dx(turn_dir(1,angle));
			let c = dir_dy(turn_dir(1,angle));
			obj.vars.set("pixel_x", pixel_x * c + pixel_y * s);
			obj.vars.set("pixel_y", -pixel_x * s + pixel_y * c);
		}
		return obj;
	}

	static load(name, props = {}) {
		return new MapTemplate(fs.readFileSync("../../_maps/StationParts/" + name, "utf8"), props);
	}
}

module.exports = MapTemplate;
