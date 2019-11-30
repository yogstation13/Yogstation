'use strict';
const Heap = require('./heap.js');

class AStarTile {
	constructor(x, y, h) {
		this.x = x;
		this.y = y;
		this.g_score = Infinity;
		this.h_score = h;
		this.previous_node = null;
	}

	get f_score() {
		return this.g_score + this.h_score;
	}
}

class AStar {
	constructor(dmm) {
		this.dmm = dmm;
		this.cost_limit = Infinity;
	}

	run(...initial) {
		if(!initial) return;
		let open_nodes = new Heap((a,b) => {return a.f_score - b.f_score;});
		let nodes = new Map();
		if(initial && initial.length && (typeof initial[0] == "number"))
			initial = [initial];
		for(let [x,y] of initial) {
			if(nodes.has(`${x},${y}`)) continue;
			let node = new AStarTile(x, y, this.calculate_heuristic(x, y));
			node.g_score = 0;
			nodes.set(`${x},${y}`, node);
			open_nodes.insert(node);
		}
		let found_node = null;
		while(!open_nodes.is_empty()) {
			let explored_node = open_nodes.pop();
			let adj = this.get_adjacent(explored_node);
			for(let [x,y,score] of adj) {
				if(score <= 0) throw new Error("non-negative g-cost");
				if(score + explored_node.g_score > this.cost_limit) continue;
				let node = nodes.get(`${x},${y}`);
				if(node) {
					if(node.g_score > explored_node.g_score+score) {
						node.g_score = explored_node.g_score+score;
						node.previous_node = explored_node;
						open_nodes.resort(node);
					}
				} else {
					node = new AStarTile(x, y, this.calculate_heuristic(x, y));
					node.g_score = explored_node.g_score+score;
					node.previous_node = explored_node;
					nodes.set(`${x},${y}`, node);
					open_nodes.insert(node);
					if(this.check_complete(node)) {
						found_node = node;
						break;
					}
				}
			}
			if(found_node) break;
		}
		if(found_node) {
			let path = [];
			path.total_cost = found_node.g_score;
			while(found_node) {
				path.unshift([found_node.x, found_node.y]);
				found_node = found_node.previous_node;
			}
			return path;
		}
	}

	check_complete(tile) {
		return false;
	}

	get_adjacent(tile) {
		return [];
	}

	calculate_heuristic(x, y) {
		return 0;
	}
}

module.exports = AStar;
