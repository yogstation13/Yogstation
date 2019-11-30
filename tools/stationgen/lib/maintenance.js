'use strict';
const AStar = require('./astar.js');
const {dir_dx, dir_dy, pick, shuffle} = require('./util.js');

const MIN_SAMEAREA_MAINT_DOOR_DISTANCE = 30;
const MAX_MAINT_DISTANCE = 75;
const MAX_MAINT_COST = 100;

class AStarMaintenance extends AStar {
	constructor(dmm, target_x, target_y, cost_limit = Infinity) {
		super(dmm);
		this.target_x = target_x;
		this.target_y = target_y;
		this.cost_limit = cost_limit;
	}

	check_complete(tile) {
		return tile.x == this.target_x && tile.y == this.target_y;
	}

	get_adjacent(tile) {
		let prev_dx = 0;
		let prev_dy = 0;
		if(tile.previous_node) {
			prev_dx = tile.x - tile.previous_node.x;
			prev_dy = tile.y - tile.previous_node.y;
		}
		let adj = [];
		for(let dir of [1,2,4,8]) {
			let x = dir_dx(dir) + tile.x;
			let y = dir_dy(dir) + tile.y;
			if(x == this.target_x && y == this.target_y) {return [[x,y,1]];}
			let turf = this.dmm.get_turf(x, y, 1);
			let area = this.dmm.get_area(x, y, 1);
			if(!turf || (!turf.istype("/turf/template_noop") && !area.istype("/area/maintenance"))) {
				continue;
			}
			let give_hugging_bonus = false;
			let reject = false;
			for(let wdir of [1,2,4,8]) {
				let wturf = this.dmm.get_turf(x+dir_dx(wdir),y+dir_dy(wdir),1);
				if(!wturf || wturf.istype("/turf/open/floor") || wturf.istype("/turf/open/space"))
					reject = true;
				if(wturf.istype("/turf/wall_marker")) {
					give_hugging_bonus = true;
				}
			}
			if(reject) continue;
			let cost = 1.75;
			if(dir_dx(dir) != prev_dx || dir_dy(dir) != prev_dy) {
				cost += 0.5; // turn penalty
			}
			if(give_hugging_bonus) { // we like our maintenance hallways to hug walls, so I'm giving nodes that are next to walls a bonus.
				cost -= 0.75;
			}
			adj.push([x,y,cost]);
		}
		return adj;
	}

	calculate_heuristic(x, y) {
		return Math.sqrt((x - this.target_x)**2 + (y - this.target_y)**2);
	}
}

class MaintNode {
	constructor(x, y, is_door) {
		this.x = x;
		this.y = y;
		this.is_door = is_door;
		this.parent = this;
	}

	union(other) {
		let a = this.find();
		let b = other.find();
		if(a == b) return;
		if(a.y < b.y || (a.y == b.y && a.y < b.y)) {
			a.parent = b;
		} else {
			b.parent = a;
		}
	}

	find() {
		if(this.parent != this) {
			this.parent = this.parent.find();
		}
		return this.parent;
	}
}

function generate_maintenance() {
	let maint_points = [];
	for(let [x,y,z] of this.dmm.all_coordinates()) {
		let is_door;
		if(this.dmm.locate(x,y,z,"/obj/machinery/door/airlock/maintenance")) {
			is_door = true;
		} else {
			continue;
		}
		maint_points.push(new MaintNode(x,y,is_door));
	}
	console.log("Generating maintenance...");
	for(let i = 0; i < maint_points.length; i++) {
		for(let j = i+1; j < maint_points.length; j++) {
			let a = maint_points[i];
			let b = maint_points[j];
			if(a.find() == b.find()) continue; // if we have already established that these two nodes are related then move on to the next pair of nodes.
			if((b.x-a.x)**2+(b.y-a.y)**2 > MAX_MAINT_DISTANCE**2) {
				continue;
			}
			let path = new AStarMaintenance(this.dmm, b.x, b.y, MAX_MAINT_COST).run(a.x,a.y);
			if(path) {
				a.union(b);
			}
		}
	}
	let sets = new Map();
	for(let node of maint_points) {
		let parent = node.find();
		let arr = sets.get(parent);
		if(!arr) {
			arr = [];
			sets.set(parent, arr);
		}
		arr.push(node);
	}
	sets = [...sets.values()];
	for(let set of sets) {
		if(set.length == 1) {
			let tile = this.dmm.get_tile(set[0].x,set[0].y,1,true);
			for(let k = 0; k < tile.length; k++) {
				if(tile[k].istype("/obj/machinery/door/airlock/maintenance")) {
					tile.splice(k, 1);
					k--;
					console.log("removed door");
				}
			}
			continue;
		}
		if(set.length == 0) continue;
		shuffle(set);
		for(let i = 1; i < set.length; i++) {
			for(let j = 0; j < i; j++) {
				let a = set[i];
				let b = set[j];
				if(!a.is_door && !b.is_door)
					continue;
				console.log("checking sameness");
				if(this.dmm.get_area(a.x,a.y,1) .type != this.dmm.get_area(b.x,b.y,1).type)
					continue;
				if((b.x-a.x)**2 + (b.y-a.y)**2 > MIN_SAMEAREA_MAINT_DOOR_DISTANCE**2)
					continue;
				console.log("same area!");
				let tile = this.dmm.get_tile(a.x,a.y,1,true);
				for(let k = 0; k < tile.length; k++) {
					if(tile[k].istype("/obj/machinery/door/airlock/maintenance")) {
						tile.splice(k, 1);
						k--;
						console.log("removed door");
					}
				}
				let found_alt = false;
				for(let dir of [1,2,4,8]) {
					let turf = this.dmm.get_turf(a.x+dir_dx(dir),a.y+dir_dy(dir),1);
					if(turf.istype("/turf/template_noop")) {
						a.x += dir_dx(dir);
						a.y += dir_dy(dir);
						found_alt = true;
						console.log("found alternate tile");
						break;
					}
				}
				if(!found_alt) {
					// get rid of the node because we can't even go to an empty tile next to it.
					set.splice(i, 1);
					i--;
				}
				break;
			}
		}
		let paths = [];
		for(let i = 0; i < set.length-1; i++) {
			let a = set[i];
			let b = set[i+1];
			let path = new AStarMaintenance(this.dmm, b.x, b.y).run(a.x,a.y); // no maint cost limit here because we already did that when generating the sets.
			if(path) {
				paths.push(path);
			} else {
				throw new Error(`Failed to find path! ${a.x},${a.y}-${b.x},${b.y}`);
			}
		}
		console.log(paths);
		let maint_tiles = new Map();
		for(let path of paths) {
			for(let [x,y] of path) {
				maint_tiles.set(`${x},${y}`,[x,y]);
			}
		}
		maint_tiles = [...maint_tiles.values()];
		// now decide on an area object.
		let cx = this.dmm.maxx/2;
		let cy = this.dmm.maxy/2;
		let relevances = {
			"/area/maintenance/aft": 0,
			"/area/maintenance/fore": 0,
			"/area/maintenance/port": 0,
			"/area/maintenance/port/aft": 0,
			"/area/maintenance/port/fore": 0,
			"/area/maintenance/starboard": 0,
			"/area/maintenance/starboard/aft": 0,
			"/area/maintenance/starboard/fore": 0,
			"/area/maintenance/central": 0
		}
		for(let [x,y] of maint_tiles) {
			relevances["/area/maintenance/aft"] += (y < cy) ? 1 : -1;
			relevances["/area/maintenance/fore"] += (y > cy) ? 1 : -1;
			relevances["/area/maintenance/port"] += (x < cx) ? 1 : -1;
			relevances["/area/maintenance/starboard"] += (x > cx) ? 1 : -1;
			relevances["/area/maintenance/port/aft"] += (x < cx && y < cy) ? 2 : -2;
			relevances["/area/maintenance/port/fore"] += (x < cx && y > cy) ? 2 : -2;
			relevances["/area/maintenance/starboard/aft"] += (x > cx && y < cy) ? 2 : -2;
			relevances["/area/maintenance/starboard/fore"] += (x > cx && y > cy) ? 2 : -2;
			relevances["/area/maintenance/central"] += (x > cx-25 && x < cx+25 && y > cy-25 && y < cy+25) ? 3 : -3;
		}
		let maint_area = null;
		for(let [area, relevance] of Object.entries(relevances)) {
			if(!maint_area || relevance > relevances[maint_area]) {
				maint_area = area;
			}
		}
		console.log("Choosing " + maint_area);
		for(let [x,y] of maint_tiles) {
			let x1 = x;
			let x2 = x;
			let y1 = y;
			let y2 = y;
			for(let dir of [1,2,4,8]) {
				let dx = dir_dx(dir);
				let dy = dir_dy(dir);
				for(let i = 0; i <= 3; i++) {
					let found = false;
					for(let ep = (dx != 0 ? y1 : x1); ep <= (dx != 0 ? y2 : x2); ep++) {
						let check_x = dx != 0 ? (x + (i+1) * dx) : ep;
						let check_y = dx != 0 ? ep : (y + (i+1) * dy);
						let turf = this.dmm.get_turf(check_x,check_y,1);
						let area = this.dmm.get_area(check_x,check_y,1);
						if(turf.istype("/turf/open/floor") && !area.istype("/area/maintenance")) {
							found = true;
							break;
						}
						if((turf.type == "/turf/wall_marker" || turf.istype("/turf/closed/wall")) && !area.istype("/area/maintenance")) {
							if(dx < 0) x1 -= i;
							if(dx > 0) x2 += i;
							if(dy < 0) y1 -= i;
							if(dy > 0) y2 += i;
							found = true;
							break;
						}
					}
					if(found) break;
				}
			}
			this.fill_hallway(x1,y1,x2,y2,maint_area,"/turf/open/floor/plating");
		}
	}
	console.log(sets);
}

module.exports = {generate_maintenance};
