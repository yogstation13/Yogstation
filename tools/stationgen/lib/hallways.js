const {rand_int, pick, turn_dir, dir_dx, dir_dy} = require('./util.js');
const DMM = require('./dmm.js');
const wall_flags = require('./wall_flags.js');

function generate_hallways() {
	let cx = Math.round(this.dmm.maxx / 2);
	let cy = Math.round(this.dmm.maxy / 2);
	let box_width = rand_int(15,25);
	let box_height = rand_int(15,25);
	let stationname_dir = pick([1,2]);
	console.log("Generating hallway box...");
	this.fill_hallway(cx-box_width-3, cy-box_height-3, cx-box_width-1, cy+box_height+3, "/area/hallway/primary/central");
	this.fill_hallway(cx+box_width+1, cy-box_height-3, cx+box_width+3, cy+box_height+3, "/area/hallway/primary/central");
	this.fill_hallway(cx-box_width, cy+box_height+1, cx+box_width, cy+box_height+3, "/area/hallway/primary/central");
	this.fill_hallway(cx-box_width, cy-box_height-3, cx+box_width, cy-box_height-1, "/area/hallway/primary/central");

	for(let hallway_dir of [1,2,4,8]) {
		let start_x;
		let start_y;
		if(hallway_dir == 1 || hallway_dir == 2) {
			start_y = (hallway_dir == 1 ) ? cy + box_height + 4 : cy - box_height - 4;
			if(hallway_dir == stationname_dir) {
				start_x = rand_int(cx-box_width+8, cx+box_width-8);
				plaque_base_y = start_y + (hallway_dir == 1 ? -2 : 1);
				if(Math.random() < 0.33) {
					// jut the hallway out a bit
					let jut_width = pick([3,4]);
					let jut_depth = pick([1,2]);
					this.fill_hallway(start_x - jut_width, start_y, start_x + jut_width, start_y + dir_dy(hallway_dir) * (jut_depth - 1), "/area/hallway/primary/central");
					start_y += dir_dy(hallway_dir) * jut_depth;
				}
				for(let px = 0; px < 7; px++) {
					for(let py = 0; py < 2; py++) {
						this.dmm.add_object(px - 3 + start_x, py + plaque_base_y, 1, new DMM.Instance("/obj/effect/turf_decal/plaque", {"icon_state": `L${2 * px + (2-py)}`}));
					}
				}
				this.dmm.add_object(start_x, plaque_base_y, 1, "/obj/effect/landmark/observer_start");
			} else if(Math.random() < 0.33) {
				start_x = pick([cx-box_width-2, cx+box_width+2]);
			} else {
				start_x = rand_int(cx-box_width+5, cx+box_width-5);
			}
		} else {
			start_x = (hallway_dir == 4) ? cx+box_width+4 : cx-box_width-4;
			if(Math.random() < 0.33) {
				start_y = pick([cy-box_height-2, cy+box_height+2]);
			} else {
				start_y = rand_int(cy-box_height+5, cy+box_height-5);
			}
		}
		let hallway_length = rand_int(30, 60);
		let area_type = "/area/hallway/primary";
		if(hallway_dir == 1) {
			area_type = "/area/hallway/primary/fore";
		} else if(hallway_dir == 2) {
			area_type = "/area/hallway/primary/aft";
		} else if(hallway_dir == 8) {
			area_type = "/area/hallway/primary/port";
		} else if(hallway_dir == 4) {
			area_type = "/area/hallway/primary/starboard";
		}
		let [endpoint_x, endpoint_y] = this.make_hallway_branch(start_x, start_y, hallway_dir, hallway_length, area_type);
		let branching_dirs = [turn_dir(hallway_dir, 90), turn_dir(hallway_dir, -90)];
		for(let branch_dir of branching_dirs) {
			if(Math.random() < 0.7)
				continue;
			let branch_start_x = endpoint_x + dir_dx(branch_dir) * 2;
			let branch_start_y = endpoint_y + dir_dy(branch_dir) * 2;
			this.make_hallway_branch(branch_start_x, branch_start_y, branch_dir, rand_int(5, hallway_length), area_type, null);
		}
	}
}

function make_hallway_branch(base_x, base_y, hallway_dir, length, area = "/area/hallway", door_name = "Central Access") {
	this.fill_hallway(
		base_x + dir_dx(turn_dir(hallway_dir, -90)),
		base_y + dir_dy(turn_dir(hallway_dir, -90)),
		base_x + dir_dx(turn_dir(hallway_dir, 90)) + dir_dx(hallway_dir) * (length),
		base_y + dir_dy(turn_dir(hallway_dir, 90)) + dir_dy(hallway_dir) * (length),
		area);
	this.dmm.add_object(base_x, base_y, 1, "/obj/machinery/door/firedoor");
	this.dmm.add_object(base_x + dir_dx(turn_dir(hallway_dir, -90)), base_y + dir_dy(turn_dir(hallway_dir, -90)), 1, "/obj/machinery/door/firedoor");
	this.dmm.add_object(base_x + dir_dx(turn_dir(hallway_dir, 90)), base_y + dir_dy(turn_dir(hallway_dir, 90)), 1, "/obj/machinery/door/firedoor");
	if(door_name) {
		let doors_x = base_x + dir_dx(hallway_dir);
		let doors_y = base_y + dir_dy(hallway_dir);
		this.dmm.add_object(doors_x, doors_y, 1, new DMM.Instance("/obj/machinery/door/airlock/public/glass", {name: door_name}));
		this.dmm.add_object(doors_x + dir_dx(turn_dir(hallway_dir, -90)), doors_y + dir_dy(turn_dir(hallway_dir, -90)), 1, new DMM.Instance("/obj/machinery/door/airlock/public/glass", {name: door_name}));
		this.dmm.add_object(doors_x + dir_dx(turn_dir(hallway_dir, 90)), doors_y + dir_dy(turn_dir(hallway_dir, 90)), 1, new DMM.Instance("/obj/machinery/door/airlock/public/glass", {name: door_name}));
	}
	return [base_x + dir_dx(hallway_dir) * (length-1), base_y + dir_dy(hallway_dir) * (length-1)];
}

function fill_hallway(x1, y1, x2, y2, area="/area/hallway", turf="/turf/open/floor/plasteel") {
	let minx = Math.min(x1, x2);
	let maxx = Math.max(x1, x2);
	let miny = Math.min(y1, y2);
	let maxy = Math.max(y1, y2);
	for(let x = minx; x <= maxx; x++) {
		for(let y = miny; y <= maxy; y++) {
			this.dmm.set_area(x, y, 1, area);
			this.dmm.set_turf(x, y, 1, turf);
		}
	}
	for(let x = minx-1; x <= maxx+1; x++) {
		for(let y = miny-1; y <= maxy+1; y++) {
			if(this.dmm.get_turf(x, y, 1).istype("/turf/template_noop")) {
				this.dmm.set_turf(x, y, 1, new DMM.Instance("/turf/wall_marker", {"wall_flags": wall_flags.WINDOWS | wall_flags.WALLS | wall_flags.WINDOW_ALL | wall_flags.FLOOR}))
				this.dmm.set_area(x, y, 1, area);
			}
		}
	}
}

module.exports = {generate_hallways, fill_hallway, make_hallway_branch};
