'use strict';

class Heap {
	constructor(compare) {
		this.cmp = compare;
		this.arr = [];
	}
	is_empty() {
		return !this.arr.length;
	}
	insert(obj) {
		this.arr.push(obj);
		this.swim(this.arr.length - 1);
	}

	pop() {
		if(!this.arr.length) return;
		let ret = this.arr[0];
		this.arr[0] = this.arr[this.arr.length-1];
		this.arr.length--;
		if(this.arr.length) {
			this.sink(0);
		}
		return ret;
	}

	swim(index) {
		let parent = Math.floor((index-1) * 0.5);
		while(parent >= 0 && this.cmp(this.arr[index], this.arr[parent]) < 0) {
			let tmp = this.arr[index];
			this.arr[index] = this.arr[parent];
			this.arr[parent] = tmp;
			index = parent;
			parent = Math.floor((index-1) * 0.5);
		}
	}

	sink(index) {
		let l_child = index;
		do {
			if(l_child != index) {
				let tmp = this.arr[index];
				this.arr[index] = this.arr[l_child];
				this.arr[l_child] = tmp;
				index = l_child;
			}
			let left_child = index * 2 + 1;
			if(left_child >= this.arr.length) {
				l_child = -1;
			} else if(left_child + 1 >= this.arr.length) {
				l_child = left_child;
			} else if(this.cmp(this.arr[left_child], this.arr[left_child + 1]) < 0) {
				l_child = left_child;
			} else {
				l_child = left_child + 1;
			}
		} while(l_child >= 0 && this.cmp(this.arr[index], this.arr[l_child]) > 0);
	}

	resort(elem) {
		let idx = this.arr.indexOf(elem);
		if(idx < 0) return;
		this.swim(idx);
		this.sink(idx);
	}
}

module.exports = Heap;
