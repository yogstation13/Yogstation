'use strict';

function rand_int(min, max) {
	return Math.floor(Math.random() * (max-min+1)) + min;
}

function pick(items) {
	return items[rand_int(0,items.length-1)];
}

function turn_dir(dir, angle) {
	dir = dir & 15;
	angle = ((angle % 360 + 360) % 360);
	return [ // woo lookup table time
		[0, 1, 2 ,3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15],
		[0, 5,10,15, 6, 4, 2,15, 9, 1, 8,15,15,15,15,15],
		[0, 4, 8,12, 2, 6,10,14, 1, 5, 9,13, 3, 7,11,15],
		[0, 6, 9,15,10, 2, 8,15, 5, 4, 1,15,15,15,15,15],
		[0, 2, 1, 3, 8,10, 9,11, 4, 6, 5, 7,12,14,13,15],
		[0,10, 5,15, 9, 8, 1,15, 6, 2, 4,15,15,15,15,15],
		[0, 8, 4,12, 1, 9, 5,13, 2,10, 6,14, 3,11, 7,15],
		[0, 9, 6,15, 5, 1, 4,15,10, 8, 2,15,15,15,15,15]
	][Math.floor(angle / 90) * 2 + ((angle % 90) == 0 ? 0 : 1)][dir];
}

function dir_dx(dir) {
	var dx = 0;
	if(dir & 4)
		dx++;
	if(dir & 8)
		dx--;
	return dx;
}

function dir_dy(dir) {
	var dy = 0;
	if(dir & 1)
		dy++;
	if(dir & 2)
		dy--;
	return dy;
}

function dirs_angle(dir1, dir2) {
	let angle1 = [0, 0, 180, 0, 90, 45, -45, 0, -90, -45, -135][dir1];
	let angle2 = [0, 0, 180, 0, 90, 45, -45, 0, -90, -45, -135][dir2];
	let angle = angle2 - angle1;
	if(angle > 180) angle -= 360;
	if(angle <= -180) angle += 360;
	return angle;
}

function shuffle(arr) {
	for(let i = 0; i < arr.length; i++) {
		let j = rand_int(i, arr.length-1);
		let tmp = arr[i];
		arr[i] = arr[j];
		arr[j] = tmp;
	}
	return arr;
}

module.exports = {rand_int, pick, turn_dir, dir_dx, dir_dy, dirs_angle, shuffle};
