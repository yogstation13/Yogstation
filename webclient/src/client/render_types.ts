import { mat3, mat4, vec2, vec3, vec4 } from "gl-matrix";
import { Appearance } from "./appearance";
import { Icon, IconState } from "./icon";
import { LightingRenderPlan } from "./lighting";

export type RenderPlan = BatchRenderPlan|LightingRenderPlan;

let plane_normal = vec3.create();

let uv_temp = vec3.create();
export abstract class BatchRenderPlan {
	atom_id : number = 0;
	icon : number = 0xFFFF;
	alpha_sort_focus : vec3|null = null;
	alpha_sort_bias : number = 0;
	_alpha_sort_dist : number = 0;
	triangle_count : number = 0;
	is_static = false;
	cached_data : Float32Array|null = null;
	cached_icon_version : number|null = null;
	bits : number = 0;
	abstract write(attribs : Float32Array, iattribs : Uint32Array, offset : number, icon_info : Icon, time : number, camera_pos : vec3, camera_yaw : number) : number;
	write_plane(attribs : Float32Array, iattribs : Uint32Array, offset : number, state_index : number, plane_origin : vec3, plane_x : vec3, plane_y : vec3, normal? : vec3, color? : vec4|mat4, uv_box? : vec4|mat3, flip = false) : number {
		if(!normal) {
			vec3.cross(plane_normal, plane_x, plane_y);
			vec3.normalize(plane_normal, plane_normal);
			normal = plane_normal;
		}
		for(let vi = 0; vi < 6; vi++) {
			let vx = [0,1,0,0,1,1][flip ? 5-vi : vi];
			let vy = [0,0,1,1,0,1][flip ? 5-vi : vi];
			attribs[offset++] = plane_origin[0] + plane_x[0]*vx + plane_y[0]*vy;
			attribs[offset++] = plane_origin[1] + plane_x[1]*vx + plane_y[1]*vy;
			attribs[offset++] = plane_origin[2] + plane_x[2]*vx + plane_y[2]*vy;
			attribs[offset++] = normal[0];
			attribs[offset++] = normal[1];
			attribs[offset++] = normal[2];
			if(!color) {
				attribs[offset++] = 1;
				attribs[offset++] = 1;
				attribs[offset++] = 1;
				attribs[offset++] = 1;
			} else {
				let ci = color.length == 4 ? 0 : (vx<<2 + vy<<3);
				attribs[offset++] = color[ci++];
				attribs[offset++] = color[ci++];
				attribs[offset++] = color[ci++];
				attribs[offset++] = color[ci];
			}
			if(uv_box?.length == 9) {
				uv_temp[0] = vx;
				uv_temp[1] = vy;
				uv_temp[2] = 1;
				vec3.transformMat3(uv_temp, uv_temp, uv_box);
				attribs[offset++] = uv_temp[0];
				attribs[offset++] = uv_temp[1];
			} else {
				attribs[offset++] = uv_box ? (vx ? uv_box[2] : uv_box[0]) : vx;
				attribs[offset++] = uv_box ? (vy ? uv_box[3] : uv_box[1]) : vy;
			}
			attribs[offset++] = state_index;
			iattribs[offset++] = this.atom_id >>> 0;
			attribs[offset++] = this.bits;
		}
		return offset;
	}
	set_bits(bits : number) {
		this.bits = bits;
		return this;
	}
	set_draw_order(order : number) {
		this.icon = (this.icon & 0xFFFFFF) | (order << 24);
		return this;
	}
	set_alpha_sort(focus : vec3|null, bias = this.alpha_sort_bias) {
		this.alpha_sort_focus = focus;
		this.alpha_sort_bias = bias;
		return this;
	}

	clear_state_cache() {}

	static make_uv_box(icon_size : vec2, x_offset:number, y_offset:number, canvas_box? : vec4|null, transform? : number[]|null) : mat3|vec4|undefined {
		if(!x_offset && !y_offset && !transform && !canvas_box) return undefined;
		if(!canvas_box) {
			canvas_box = [0, 0, icon_size[0], icon_size[1]];
		}

		if(!transform) {
			return [
				(canvas_box[0] - x_offset) / icon_size[0],
				(canvas_box[1] - y_offset) / icon_size[1],
				(canvas_box[2] - x_offset) / icon_size[0],
				(canvas_box[3] - y_offset) / icon_size[1]
			];
		}
		let matrix : mat3 = mat3.identity(mat3.create());
		mat3.scale(matrix, matrix, [
			1 / (canvas_box[2] - canvas_box[0]),
			1 / (canvas_box[3] - canvas_box[1])
		]);
		mat3.translate(matrix, matrix, [
			icon_size[0]/2 + x_offset - canvas_box[0],
			icon_size[1]/2 + y_offset - canvas_box[1]
		]);
		let transform_full = [...transform, 0, 0, 1] as mat3;
		mat3.multiply(matrix, matrix, mat3.transpose(transform_full, transform_full));
		mat3.translate(matrix, matrix, [-icon_size[0]/2, -icon_size[1]/2]);
		mat3.scale(matrix, matrix, icon_size);
		mat3.invert(matrix, matrix);
		return matrix;
	}
}

let right_vec : vec3 = [1,0,0];
let forward_vec : vec3 = [0,1,0];
let up_vec : vec3 = [0,0,1];
let color_vec : vec4 = [0,0,0,0];
function vec4_color(out : vec4, color : number) {
	out[0] = ((color >> 0) & 0xFF) / 0xFF;
	out[1] = ((color >> 8) & 0xFF) / 0xFF;
	out[2] = ((color >> 16) & 0xFF) / 0xFF;
	out[3] = ((color >> 24) & 0xFF) / 0xFF;
	return out;
}

export class FloorRenderPlan extends BatchRenderPlan {
	constructor(atom_id : number, public appearance : Appearance, public x : number, public y : number, public z : number, icon_or = 0) {
		super();
		this.atom_id = atom_id
		this.icon = appearance.icon | icon_or;
		this.triangle_count = 2;
	}
	icon_state_instance? : IconState|null;
	clear_state_cache() {
		this.icon_state_instance = undefined;
	}
	write(attribs : Float32Array, iattribs : Uint32Array, offset : number, icon_info : Icon, time : number, camera_pos : vec3) {
		this.is_static = true;
		const ft = this.appearance.flick_time;
		if(this.icon_state_instance === undefined) {
			this.icon_state_instance = icon_info.get_icon_state(this.appearance.icon_state)
		}
		if(this.icon_state_instance === null) {
			this.triangle_count = 0;
			return offset;
		}
		this.is_static = true;
		let frame = this.icon_state_instance.get_icon(this.appearance.dir, time, ft, this);
		let forward = forward_vec;
		let right = right_vec;
		let xo=0, yo=0;
		if(this.appearance.transform || icon_info.width != 32 || icon_info.height != 32) {
			let t = this.appearance.transform??[1,0,0,0,1,0];
			right = [t[0]*icon_info.width/32, t[3]*icon_info.width/32, 0];
			forward = [t[1]*icon_info.height/32, t[4]*icon_info.height/32, 0];
			xo = t[2]/32; yo = t[5]/32;
			xo += (icon_info.width - t[0]*icon_info.width - t[1]*icon_info.height) / 32 / 2
			yo += (icon_info.height - t[3]*icon_info.width - t[4]*icon_info.height) / 32 / 2
		}
		offset = this.write_plane(attribs, iattribs, offset, frame, [this.x+xo,this.y+yo,this.z], right, forward, up_vec, vec4_color(color_vec, this.appearance.color_alpha));
		return offset;
	}
}
let box_normals : vec3[] = [
	[0,-1,0],
	[1,0,0],
	[0,1,0],
	[-1,0,0]
];
let box_xy : vec2[] = [
	[0,0],[1,0],[1,1],[0,1]
];
function dir_to_box_index(dir : number) {
	if(dir == 4) return 1;
	if(dir == 1) return 2;
	if(dir == 8) return 3;
	return 0;
}
function dir_dx(dir : number) {
	let dx = 0;
	if(dir & 4) dx++;
	if(dir & 8) dx--;
	return dx;
}
function dir_dy(dir : number) {
	let dy = 0;
	if(dir & 1) dy++;
	if(dir & 2) dy--;
	return dy;
}
export class BoxRenderPlan extends BatchRenderPlan {
	constructor(atom_id : number, public appearance : Appearance, public x : number, public y : number) {
		super();
		this.atom_id = atom_id
		this.icon = appearance.icon;
		this.triangle_count = 10;
	}
	icon_state_instance? : IconState|null;
	clear_state_cache() {
		this.icon_state_instance = undefined;
	}
	write(attribs : Float32Array, iattribs : Uint32Array, offset : number, icon_info : Icon, time : number, camera_pos : vec3) {
		this.is_static = true;
		const ft = this.appearance.flick_time;
		if(this.icon_state_instance === undefined) {
			this.icon_state_instance = icon_info.get_icon_state(this.appearance.icon_state)
		}
		if(this.icon_state_instance === null) {
			this.triangle_count = 0;
			return offset;
		}
		let frame = this.icon_state_instance.get_icon(this.appearance.dir, time, ft, this);
		for(let i = 0; i < 4; i++) {
			offset = this.write_plane(attribs, iattribs, offset, frame, [this.x+box_xy[i][0],this.y+box_xy[i][1],0], box_normals[(i+1)&3], up_vec, box_normals[i], vec4_color(color_vec, this.appearance.color_alpha));
		}
		offset = this.write_plane(attribs, iattribs, offset, frame, [this.x,this.y,1], right_vec, forward_vec, up_vec, vec4_color(color_vec, this.appearance.color_alpha));
		return offset;
	}
}

export class BillboardRenderPlan extends BatchRenderPlan {
	constructor(atom_id : number, public appearance : Appearance, public x : number, public y : number, public fixed_normal? : vec3, public double_sided = false, public clipped = false) {
		super();
		this.atom_id = atom_id
		this.icon = appearance.icon;
		this.triangle_count = double_sided ? 4 : 2;
	}
	offset_x : number = 0;
	offset_y : number = 0;
	set_offsets(x : number, y : number) {
		this.offset_x = x; this.offset_y = y;
		return this;
	}
	icon_state_instance? : IconState|null;
	clear_state_cache() {
		this.icon_state_instance = undefined;
	}
	write(attribs : Float32Array, iattribs : Uint32Array, offset : number, icon_info : Icon, time : number, camera_pos : vec3, camera_yaw : number) {
		if(this.icon_state_instance === undefined) {
			this.icon_state_instance = icon_info.get_icon_state(this.appearance.icon_state)
		}
		if(this.icon_state_instance === null) {
			this.triangle_count = 0;
			return offset;
		}
		let x = this.x, y = this.y;
		let dir = this.appearance.dir;
		let normal : vec3;
		if(this.fixed_normal) {
			normal = this.fixed_normal;
		} else {
			normal = [x,y, 0]
			vec3.subtract(normal, camera_pos, normal);
			normal[2] = 0;
			let distance = vec3.length(normal);
			if(distance < 0.2) {
				let dy = Math.cos(camera_yaw);
				let dx = -Math.sin(camera_yaw);
				normal = [dx, dy, 0];
				x -= dx * 0.2;
				y -= dy * 0.2;
				dir = 2;
			} else {
				vec3.scale(normal, normal, 1/distance);
				if(this.icon_state_instance.num_dirs > 1) {
					let angle = Math.atan2(-normal[0]* 1.01, -normal[1]) / Math.PI * 4;
					if(this.icon_state_instance.num_dirs > 4) {
						dir = IconState.turn_dir_8(dir, Math.round(angle));
						angle = Math.round(angle);
					} else {
						dir = IconState.turn_dir_4(dir, Math.round(angle*0.5));
						angle = Math.round(angle*0.5)*2;
					}
					angle = angle * Math.PI / 4;
					normal = [
						-Math.sin(angle),
						-Math.cos(angle),
						0
					]
				}
			}
		}
		let frame = this.icon_state_instance.get_icon(dir, time);
		let right : vec3 = [-normal[1]*icon_info.width/32, normal[0]*icon_info.width/32, 0];
		let up : vec3 = [0, 0, icon_info.height/32];
		let pos : vec3 = [x+normal[1]*0.5, y-normal[0]*0.5, 0];
		let uv_box : vec4|mat3|undefined = undefined;
		if(this.clipped) {
			uv_box = BatchRenderPlan.make_uv_box([icon_info.width, icon_info.height], this.offset_x, this.offset_y, undefined, this.appearance.transform);
		} else {
			let px = this.offset_x;
			let py = this.offset_y;
			if(this.appearance.transform) {
				let t = this.appearance.transform;
				let lx = -icon_info.width/64;
				let ly = -icon_info.height/64;
				px += (lx * t[0] + ly * t[1] + t[2]/32) - lx;
				py += (lx * t[3] + ly * t[4] + t[5]/32) - ly;
				let r = vec3.scale(vec3.create(), right, t[0]);
				vec3.scaleAndAdd(r, r, up, t[3]);
				let u = vec3.scale(vec3.create(), right, t[1	]);
				vec3.scaleAndAdd(u, u, up, t[4]);
				right = r; up = u;
			}
			pos[0] -= normal[1]*px;
			pos[1] += normal[0]*px;
			pos[2] += py;
		}
		offset = this.write_plane(attribs, iattribs, offset, frame, pos, right, up, normal, vec4_color(color_vec, this.appearance.color_alpha), uv_box);
		if(this.double_sided) {
			offset = this.write_plane(attribs, iattribs, offset, frame, pos, right, up, [-normal[0],-normal[1],-normal[2]], vec4_color(color_vec, this.appearance.color_alpha), uv_box, true);
		}
		return offset;
	}
}

export class WallmountRenderPlan extends BatchRenderPlan {
	constructor(atom_id : number, public appearance : Appearance, public x : number, public y : number, public pixel_x : number, public pixel_y : number, public hover = 0.01, public is_sign = false) {
		super();
		this.atom_id = atom_id
		this.icon = appearance.icon;
		this.triangle_count = 8;
	}
	icon_state_instance? : IconState|null;
	clear_state_cache() {
		this.icon_state_instance = undefined;
	}
	write(attribs : Float32Array, iattribs : Uint32Array, offset : number, icon_info : Icon, time : number, camera_pos : vec3) {
		const ft = this.appearance.flick_time;
		if(this.icon_state_instance === undefined) {
			this.icon_state_instance = icon_info.get_icon_state(this.appearance.icon_state)
		}
		if(this.icon_state_instance === null) {
			this.triangle_count = 0;
			return offset;
		}
		this.is_static = true;
		let dx = Math.sign(Math.round(this.pixel_x / 32));
		let dy = Math.sign(Math.round(this.pixel_y / 32));
		let num_written = 0;

		for(let i = 0; i < 4; i++) {
			if(box_normals[i][0] * dx + box_normals[i][1] * dy > -0.5) continue;
			let dir = 2;
			if(this.is_sign) {
				dir = IconState.turn_dir_4(this.appearance.dir, -i)
			}
			let right = box_normals[(i+1)&3];
			let px = 0; let py = 0;
			if(this.is_sign) {
				px += this.pixel_x/32 - dx;
				py += this.pixel_y/32 - dy;
			} else {
				if(!dy) py += this.pixel_y/32;
				if(!dx) px += this.pixel_x/32;
			}
			let base:vec3 = [
				this.x+dx+box_xy[i][0]+box_normals[i][0]*this.hover+px*right[0],
				this.y+dy+box_xy[i][1]+box_normals[i][1]*this.hover+px*right[1],
				py];
			let frame = this.icon_state_instance.get_icon(dir, time, ft, this);
			offset = this.write_plane(attribs, iattribs, offset, frame, base, right, up_vec, box_normals[i], vec4_color(color_vec, this.appearance.color_alpha));
			num_written++;
		}
		this.triangle_count = num_written*2;

		return offset;
	}
}

export class WindoorRenderPlan extends BatchRenderPlan {
	base_state : string;
	anim_state : string|undefined;
	handle_state : string;
	surface_state : string;
	edge_state : string;
	base_inst? : IconState|null;
	handle_inst? : IconState|null;
	surface_inst? : IconState|null;
	edge_inst? : IconState|null;
	inner_offset = 5/32;
	outer_offset = 2/32;
	flip = false;
	rotate = 0;
	
	clear_state_cache() {
		this.edge_inst = undefined;
		this.handle_inst = undefined;
		this.surface_inst = undefined;
		this.edge_inst = undefined;
	}
	constructor(atom_id : number, public appearance : Appearance, public x : number, public y : number) {
		super();
		this.atom_id = atom_id;
		this.icon = appearance.icon;
		this.triangle_count = 10;

		this.alpha_sort_focus = [x+0.5,y+0.5,0.5];
		if(appearance.dir == 1) this.alpha_sort_focus[1] += 0.39;
		if(appearance.dir == 2) this.alpha_sort_focus[1] -= 0.39;
		if(appearance.dir == 4) this.alpha_sort_focus[0] += 0.39;
		if(appearance.dir == 8) this.alpha_sort_focus[0] -= 0.39;

		let icon_state = appearance.icon_state;
		let type = "";
		let anim_suffix : string|undefined;
		this.rotate = dir_to_box_index(appearance.dir);
		if(icon_state.startsWith("r")) this.flip = true;
		if(appearance.dir != 2) this.flip = !this.flip;
		if(icon_state.includes("secure")) {
			type = "secure";
			this.inner_offset = 6/32;
			this.outer_offset = 1/32;
		}
		if(icon_state.endsWith("closing")) anim_suffix = "closing";
		if(icon_state.endsWith("opening")) anim_suffix = "opening";
		if(icon_state.endsWith("open")) anim_suffix = "open";
		if(icon_state.endsWith("deny")) anim_suffix = "deny";
		if(icon_state.endsWith("spark")) anim_suffix = "spark";
		this.anim_state = anim_suffix;
		this.base_state = `e3d_windoor_${type}base`;
		this.handle_state = `e3d_windoor_${type}handle`;
		if(anim_suffix && anim_suffix != "open") this.handle_state += `_${anim_suffix}`;
		this.surface_state = `e3d_windoor_${type}surface`;
		this.edge_state = `e3d_windoor_${type}edge`;
	}

	write(attribs: Float32Array, iattribs: Uint32Array, offset: number, icon_info: Icon, time : number) : number {
		if(this.base_inst === undefined) this.base_inst = icon_info.get_icon_state(this.base_state);
		if(this.edge_inst === undefined) this.edge_inst = icon_info.get_icon_state(this.edge_state);
		if(this.handle_inst === undefined) this.handle_inst = icon_info.get_icon_state(this.handle_state);
		if(this.surface_inst === undefined) this.surface_inst = icon_info.get_icon_state(this.surface_state);
		if(!this.base_inst && !this.edge_inst && !this.handle_inst && !this.surface_inst) {
			this.triangle_count = 0;
			return offset;
		}
		this.is_static = true;
		let base = box_xy[this.rotate];
		let normal = box_normals[this.rotate];
		let right = box_normals[(this.rotate+1)&3];
		let inv_normal = box_normals[(this.rotate+2)&3];
		let color = vec4_color(color_vec, this.appearance.color_alpha);
		if(this.flip) {
			base = box_xy[(this.rotate+1)&3];
			right = box_normals[(this.rotate+3)&3];
		}
		if(this.base_inst) offset = this.write_plane(
			attribs, iattribs, offset,
			this.base_inst.icons[0][0],
			[this.x+base[0], this.y+base[1], 0.02],
			right, inv_normal, up_vec,
			color, undefined,
			this.flip
		);
		let openness = 0;
		if(this.anim_state == "open") openness = 29/32;
		else if(this.anim_state == "opening" || this.anim_state == "closing") {
			this.is_static = false;
			let fac = (time - (this.appearance.flick_time??0));
			fac /= 9;
			fac = Math.min(1, Math.max(0, fac));
			if(this.anim_state == "closing") fac = 1 - fac;
			openness = 29/32 * fac;
		}
		let inv_openness = 1 - openness;

		if(this.handle_inst) offset = this.write_plane(
			attribs, iattribs, offset,
			this.handle_inst.get_icon(2, time, this.appearance.flick_time, this),
			[this.x+base[0]-right[0]*openness, this.y+base[1]-right[1]*openness, 0.5],
			right, inv_normal, up_vec,
			color, undefined,
			this.flip
		);

		if(this.edge_inst) offset = this.write_plane(
			attribs, iattribs, offset,
			this.edge_inst.icons[0][0],
			[this.x+base[0]+right[0]*inv_openness, this.y+base[1]+right[1]*inv_openness, 0],
			inv_normal, up_vec, right,
			color, undefined,
			this.flip
		);
		let surface_uv_box : vec4 = [
			openness, 0,
			1+openness, 1
		];
		if(this.surface_inst) offset = this.write_plane(
			attribs, iattribs, offset,
			this.surface_inst.icons[0][0],
			[this.x+base[0]+inv_normal[0]*this.outer_offset, this.y+base[1]+inv_normal[1]*this.outer_offset, 0],
			right, up_vec, normal,
			color, surface_uv_box,
			this.flip
		);
		if(this.surface_inst) offset = this.write_plane(
			attribs, iattribs, offset,
			this.surface_inst.icons[0][0],
			[this.x+base[0]+inv_normal[0]*this.inner_offset, this.y+base[1]+inv_normal[1]*this.inner_offset, 0],
			right, up_vec, normal,
			color, surface_uv_box,
			!this.flip
		);

		return offset;
	}
}

export class EdgeRenderPlan extends BatchRenderPlan {
	rotate = 0;
	constructor(atom_id : number, public appearance : Appearance, public x : number, public y : number, public thickness : number = 7/32) {
		super();
		this.atom_id = atom_id
		this.icon = appearance.icon;
		this.triangle_count = 8;
		this.rotate = dir_to_box_index(appearance.dir);
		this.triangle_count = 8;

		this.alpha_sort_focus = [
			this.x+0.5+dir_dx(appearance.dir)*0.4,
			this.y+0.5+dir_dy(appearance.dir)*0.4,
			0.5
		];
	}
	icon_state_instance? : IconState|null;
	surface_instance? : IconState|null;
	clear_state_cache() {
		this.icon_state_instance = undefined;
		this.surface_instance = undefined;
	}
	write(attribs: Float32Array, iattribs: Uint32Array, offset: number, icon_info: Icon, time : number) {
		const ft = this.appearance.flick_time;
		if(this.icon_state_instance === undefined) this.icon_state_instance = icon_info.get_icon_state(this.appearance.icon_state);
		if(this.surface_instance === undefined) this.surface_instance = icon_info.get_icon_state("e3dedge_" + this.appearance.icon_state);
		if(!this.icon_state_instance) {
			this.triangle_count = 0;
			return offset;
		}
		let base = box_xy[this.rotate];
		let normal = box_normals[this.rotate];
		let right = box_normals[(this.rotate+1)&3];
		let inv_normal = box_normals[(this.rotate+2)&3];
		let left = box_normals[(this.rotate+3)&3];
		let color = vec4_color(color_vec, this.appearance.color_alpha);
		this.is_static = true;
		offset = this.write_plane(
			attribs, iattribs, offset,
			this.surface_instance?.get_icon(2, time, ft, this) ?? this.icon_state_instance.get_icon(5, time, ft, this),
			[this.x+base[0],this.y+base[1],0],
			right, up_vec, normal,
			color
		)
		offset = this.write_plane(
			attribs, iattribs, offset,
			this.surface_instance?.get_icon(2, time, ft, this) ?? this.icon_state_instance.get_icon(5, time, ft, this),
			[this.x+base[0]+right[0]+inv_normal[0]*this.thickness,this.y+base[1]+right[1]+inv_normal[1]*this.thickness,0],
			left, up_vec, inv_normal,
			color
		);
		offset = this.write_plane(
			attribs, iattribs, offset,
			this.icon_state_instance.get_icon(4, time, ft, this),
			[this.x+base[0]+inv_normal[0],this.y+base[1]+inv_normal[1],0],
			normal, up_vec, left,
			color
		);
		offset = this.write_plane(
			attribs, iattribs, offset,
			this.icon_state_instance.get_icon(8, time, ft, this),
			[this.x+base[0]+right[0],this.y+base[1]+right[1],0],
			inv_normal, up_vec, right,
			color
		);
		return offset;
	}
}

export class DiagonalWallRenderPlan extends BatchRenderPlan {
	constructor(atom_id : number, public appearance : Appearance, public x : number, public y : number, public dir = appearance.dir, public face_states = ["1-w","2-e","3-w","4-e"]) {
		super();
		this.atom_id = atom_id;
		this.icon = appearance.icon;
		this.triangle_count = face_states.length * 2;
	}
	face_state_instances : Array<IconState|null>|undefined;
	clear_state_cache() {
		this.face_state_instances = undefined;
	}
	write(attribs : Float32Array, iattribs : Uint32Array, offset : number, icon_info : Icon, time : number, camera_pos : vec3) {
		this.is_static = true;
		const ft = this.appearance.flick_time;
		if(this.face_state_instances === undefined) {
			this.face_state_instances = this.face_states.map(i => {
				if(i) {
					return icon_info.get_icon_state(i);
				}
				return null;
			});
		}
		let index = dir_to_box_index(this.dir);
		for(let state of this.face_state_instances) {
			if(!state) continue;
			let b1 = box_normals[index];
			let b2 = box_normals[(index+1)&3];
			let b3 = box_normals[(index+2)&3];
			let normal:vec3 = [
				(b1[0] + b2[0]) * Math.SQRT1_2,
				(b1[1] + b2[1]) * Math.SQRT1_2,
				0
			];
			let right:vec3 = [
				b2[0] + b3[0],
				b2[1] + b3[1],
				0
			];
			offset = this.write_plane(
				attribs, iattribs, offset,
				state.get_icon(2, time, ft, this),
				[box_xy[index][0]+this.x, box_xy[index][1]+this.y, 0],
				right, up_vec, normal,
				vec4_color(color_vec, this.appearance.color_alpha)
			);
		}
		return offset;
	}
}

export class SmoothWallRenderPlan extends BatchRenderPlan {
	dir_states : Array<string|undefined> = Array(16);
	dir_state_instances : Array<IconState|null>|undefined = undefined;
	top_states : Array<string|undefined> = Array(4);
	top_state_instances : Array<IconState|null>|undefined = undefined;
	clip_height : number = 1;
	inset : number = 0;
	
	clear_state_cache() {
		this.dir_state_instances = undefined;
		this.top_state_instances = undefined;
	}
	constructor(atom_id : number, public appearance : Appearance, public x : number, public y : number, smooth_dirs : string[], public flip_bottom = false) {
		super();
		this.atom_id = atom_id
		this.icon = appearance.icon;
		this.triangle_count = 0;
		for(let i = 0; i < 4; i++) {
			let relevant_state = smooth_dirs[(i & 2) ? 0 : 3];
			if(relevant_state == "f" || relevant_state.includes("senw"[i])) {
				continue;
			}
			this.triangle_count += 8;

			let left_state = smooth_dirs[[2,3,1,0][i]] == "i";
			let right_state = smooth_dirs[[3,1,0,2][i]] == "i";
			let base = i << 2;
			this.dir_states[base+0] = left_state ? "1-i" : "1-w";
			this.dir_states[base+1] = right_state ? "2-i" : "2-e";
			this.dir_states[base+2] = left_state ? "3-i" : "3-w";
			this.dir_states[base+3] = right_state ? "4-i" : "4-e";
		}
		for(let i = 0; i < 4; i++) {
			if(i >= 2 && flip_bottom) {
				this.top_states[i] = (i-1) + "-" + smooth_dirs[i].replace("s", "n");
			} else {
				this.top_states[i] = (i+1) + "-" + smooth_dirs[i];
			}
			this.triangle_count += 2;
		}
	}
	write(attribs : Float32Array, iattribs : Uint32Array, offset : number, icon_info : Icon, time : number, camera_pos : vec3) {
		this.is_static = true;
		const ft = this.appearance.flick_time;
		if(this.dir_state_instances === undefined) {
			this.dir_state_instances = this.dir_states.map(i => {
				if(i) {
					return icon_info.get_icon_state(i);
				}
				return null;
			});
		}
		if(this.top_state_instances === undefined) {
			this.top_state_instances = this.top_states.map(i => {
				if(i) {
					return icon_info.get_icon_state(i);
				}
				return null;
			});
		}
		const normal_scale = icon_info.width / 32;
		const scale_offset = (icon_info.width - 32) / 2 / 32;
		for(let i = 0; i < 4; i++) {
			for(let j = 0; j < 4; j++) {
				let state = this.dir_state_instances[(i<<2) + j];
				if(!state) continue;
				let frame = state.get_icon(2, time, ft, this);
				let right = box_normals[(i+1)&3];
				let orig_right = right;
				let up = up_vec;
				if(normal_scale != 1) {
					right = vec3.scale(vec3.create(), right, normal_scale);
					up = vec3.scale(vec3.create(), up, normal_scale);
				}
				if(this.clip_height != 1) {
					up = vec3.scale(vec3.create(), up, this.clip_height);
				}
				offset = this.write_plane(
					attribs, iattribs, offset,
					frame,
					[
						this.x+box_xy[i][0]-scale_offset*orig_right[0]-box_normals[i][0]*this.inset,
						this.y+box_xy[i][1]-scale_offset*orig_right[1]-box_normals[i][1]*this.inset,
						-scale_offset
					],
					right, up, box_normals[i],
					vec4_color(color_vec, this.appearance.color_alpha),
					[0, 0, 1, this.clip_height]
				);
			}
			let top_state = this.top_state_instances[i];
			if(!top_state) continue;
			offset = this.write_plane(
				attribs, iattribs, offset,
				top_state.get_icon(2, time, ft, this),
				[this.x-scale_offset, this.y-scale_offset, this.clip_height],
				[normal_scale,0,0], [0,normal_scale,0], up_vec,
				vec4_color(color_vec, this.appearance.color_alpha),
				i >= 2 && this.flip_bottom ? [0,1,1,0] : undefined
			);
		}
		return offset;
	}
}
