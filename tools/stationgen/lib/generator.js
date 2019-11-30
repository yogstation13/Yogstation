'use strict';
const DMM = require('./dmm.js');
const wall_flags = require('./wall_flags.js');
const {dir_dx, dir_dy} = require('./util.js');

const parts = [
	'./hallways.js',
	'./rooms.js',
	'./maintenance.js'
];

class MapGenerator {
	constructor(maxx = 255, maxy = 255) {
		this.dmm = new DMM(maxx, maxy, 1);
	}

	generate() {
		this.make_space_border();
		this.generate_hallways();
		this.place_all_rooms();
		this.generate_maintenance();
		this.finalize_space();
	}

	make_space_border() {
		for(let x = 1; x <= this.dmm.maxx; x++) {
			for(let y = 1; y <= this.dmm.maxy; y++) {
				if(x <= 7 || y <= 7 || x > (this.dmm.maxx-7) || y > (this.dmm.maxy-7)) {
					this.dmm.set_turf(x,y,1,"/turf/open/space/basic");
					this.dmm.set_area(x,y,1,"/area/space");
				}
			}
		}
	}

	finalize_space() {
		console.log("Finalizing map...");
		for(let x = 1; x <= this.dmm.maxx; x++) {
			for(let y = 1; y <= this.dmm.maxy; y++) {
				let turf = this.dmm.get_turf(x,y,1);
				if(this.dmm.get_area(x,y,1).istype("/area/template_noop"))
					this.dmm.set_area(x,y,1,"/area/space");
				if(turf.istype("/turf/template_noop"))
					this.dmm.set_turf(x,y,1,"/turf/open/space/basic");
				if(turf.istype("/turf/wall_marker")) {
					let flags = turf.vars.get("wall_flags");
					let allow_window = true;
					let allow_rwindow = true;
					if(flags & wall_flags.WINDOWS) {
						for(let dir of [1,2,4,8]) {
							
						}
					}
					if(allow_window && (flags & wall_flags.WINDOW)) {
						this.dmm.set_turf(x,y,1,"/turf/open/floor/plating");
						this.dmm.add_object(x,y,1,"/obj/effect/spawner/structure/window");
					} else if(allow_window && (flags & wall_flags.RWINDOW)) {
						this.dmm.set_turf(x,y,1,"/turf/open/floor/plating");
						this.dmm.add_object(x,y,1,"/obj/effect/spawner/structure/window/reinforced");
					} else if(flags & wall_flags.SPACE) {
						this.dmm.set_turf(x,y,1,"/turf/open/space");
					} else if(flags & wall_flags.WALL) {
						this.dmm.set_turf(x,y,1,"/turf/closed/wall");
					} else if(flags & wall_flags.RWALL) {
						this.dmm.set_turf(x,y,1,"/turf/closed/wall/r_wall");
					}
				}
			}
		}
	}
}

for(let part of parts) {
	Object.assign(MapGenerator.prototype, require(part));
}

module.exports = MapGenerator;
