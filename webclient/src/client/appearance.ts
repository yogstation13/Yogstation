import { mat3, vec4 } from "gl-matrix";
import { Atom } from "./atom";
import { DataPointer } from "./binary";
import { Icon } from "./icon";
import { matrix_interpolate } from "./matrix_interpolate";

export class Appearance {
	id = 0;
	name = "";
	mouse_opacity = 1;
	icon = 0;
	icon_state = "";
	dir = 2;
	bits = 0;
	layer = 2;
	overlays: Appearance[]|null = null;
	underlays: Appearance[]|null = null;
	pixel_x = 0; pixel_y = 0;
	pixel_z = 0; pixel_w = 0;
	glide_size = 0;
	transform: number[]|null = null;
	color_alpha = -1;
	blend_mode = 0;
	screen_loc: string|null = null;
	invisibility = 0;
	luminosity = 0;
	plane = 0;
	color_matrix: Float32Array|null = null;
	flick_time : number|null = null;
	get pixel_xw() {
		return this.pixel_x + this.pixel_w;
	}
	get pixel_yz() {
		return this.pixel_y + this.pixel_z;
	}

	get e3d_tag() : string {
		if(!this.screen_loc) return "";
		let char = this.screen_loc.length;
		while(char > 0) {
			let code = this.screen_loc.charCodeAt(char-1);
			if(code >= 9 && code <= 13)
				char--;
			else
				break;
		}
		return this.screen_loc.substring(char);
	}
	
	get animate_movement() : number {
		return ((this.bits >> 14) + 1) & 3;
	}

	copy(pixel_source? : Atom) {
		let new_appearance = new Appearance();
		Object.assign(new_appearance, this);
		if(pixel_source) {
			new_appearance.pixel_x += pixel_source.pixel_x;
			new_appearance.pixel_y += pixel_source.pixel_y;
			new_appearance.pixel_z += pixel_source.pixel_z;
			new_appearance.pixel_w += pixel_source.pixel_w;
		}
		return new_appearance;
	}

	copy_inherit(inherit_source : Appearance, inherit_pixel_source? : Atom, xy_to_wz = false) {
		let copy = this.copy();
		if(xy_to_wz) {
			this.pixel_w += this.pixel_x;
			this.pixel_x = 0;
			this.pixel_z += this.pixel_y;
			this.pixel_y = 0;
		}
		copy.pixel_x += (inherit_pixel_source?.pixel_x ?? 0) + inherit_source.pixel_x;
		copy.pixel_y += (inherit_pixel_source?.pixel_y ?? 0) + inherit_source.pixel_y;
		copy.pixel_z += (inherit_pixel_source?.pixel_z ?? 0) + inherit_source.pixel_z;
		copy.pixel_w += (inherit_pixel_source?.pixel_w ?? 0) + inherit_source.pixel_w;
		if(!(copy.bits & 0x1000000) && inherit_source.transform) copy.transform = inherit_source.transform;
		if(inherit_source.color_alpha != -1) {
			if(copy.color_alpha == -1) {
				copy.color_alpha = inherit_source.color_alpha;
			} else {
				let new_color = 0;
				for(let i = 0; i < 32; i += 24) {
					new_color |= Math.round(((copy.color_alpha>>i)&0xFF) * ((inherit_source.color_alpha>>i)&0xFF) / 255) << i;
				}
			}
			if(copy.bits & 0x400000) {
				copy.color_alpha = (copy.color_alpha & 0xFF000000) | (this.color_alpha & 0x00FFFFFF);
			}
			if(copy.bits & 0x800000) {
				copy.color_alpha = (copy.color_alpha & 0x00FFFFFF) | (this.color_alpha & 0xFF000000);
			}
		}
		if(!(copy.bits & 0x200) || copy.dir == 0) {
			copy.dir = inherit_source.dir;
		}
		return copy;
	}

	get_canvas_box(icons : Map<number, Icon>, base? : vec4, include_xy = false) : vec4 {
		let w = 32, h = 32;
		let icon = icons.get(this.icon);
		if(icon) {
			w = icon.width;
			h = icon.height;
		}
		let box : vec4 = base ?? [Infinity, Infinity, -Infinity, -Infinity];
		let transform = this.transform;
		let px = this.pixel_w;
		if(include_xy) px += this.pixel_x;
		let py = this.pixel_z;
		if(include_xy) py += this.pixel_y;
		if(transform) {
			for(let i = 0; i < 4; i++) {
				let ix = (i & 1) ? w : 0;
				let iy = (i & 2) ? h : 0;
				ix -= w/2; iy -= h/2;
				let ox = ix*transform[0] + iy*transform[1] + w/2 + px + transform[2];
				let oy = ix*transform[3] + iy*transform[4] + w/2 + px + transform[5];
				box[0] = Math.min(box[0], ox);
				box[1] = Math.min(box[1], oy);
				box[2] = Math.max(box[2], ox);
				box[3] = Math.max(box[3], oy);
			}
		} else {
			box[0] = Math.min(box[0], px);
			box[1] = Math.min(box[1], py);
			box[2] = Math.max(box[2], px+w);
			box[3] = Math.max(box[3], py+h);
		}
		if(box.includes(Infinity) || box.includes(-Infinity)) return [0,0,0,0];
		return box;
	}
}

export function parse_appearance(dp : DataPointer, appearances : Map<number, Appearance>) {
	let appearance = new Appearance();
	appearance.id = dp.read_uint32as16();
	appearance.name = dp.read_utf_string();
	let flags = dp.read_uint8();
	let cursor_flags = dp.read_uint8();
	appearance.mouse_opacity = flags & 3;
	if(cursor_flags & 1) {
		if(dp.read_uint8() == 2) dp.read_uint32as16();
	}
	if(cursor_flags & 2) {
		if(dp.read_uint8() == 2) dp.read_uint32as16();
	}
	if(cursor_flags & 4) {
		if(dp.read_uint8() == 2) dp.read_uint32as16();
	}
	if(!dp.reached_end()) {
		appearance.icon = dp.read_uint32as16();
		appearance.icon_state = dp.read_utf_string();
		appearance.dir = dp.read_uint8();
		appearance.bits = dp.read_uint32();
		appearance.layer = dp.read_float();
		let num_overlays = dp.read_uint16();
		if(num_overlays) {
			let overlays : Appearance[] = [];
			for(let i = 0; i < num_overlays; i++) {
				let id = dp.read_uint32as16();
				let overlay = appearances.get(id);
				if(overlay) {overlays.push(overlay);}
			}
			if(overlays.length) appearance.overlays = overlays;
		}
		num_overlays = dp.read_uint16();
		if(num_overlays) {
			let overlays : Appearance[] = [];
			for(let i = 0; i < num_overlays; i++) {
				let id = dp.read_uint32as16();
				let overlay = appearances.get(id);
				if(overlay) {overlays.push(overlay);}
			}
			if(overlays.length) appearance.underlays = overlays;
		}
		let exbits = dp.read_uint8();
		if(exbits & 0x80) exbits = dp.read_uint32();
		if(exbits & 1) {
			appearance.pixel_x = dp.read_int16();
			appearance.pixel_y = dp.read_int16();
			appearance.pixel_w = dp.read_int16();
			appearance.pixel_z = dp.read_int16();
		}
		if(exbits & 2) {
			appearance.glide_size = dp.read_float();
		}
		if(exbits & 4) {
			appearance.transform = [
				dp.read_float(),
				dp.read_float(),
				dp.read_float(),
				dp.read_float(),
				dp.read_float(),
				dp.read_float()
			];
		}
		if(exbits & 8) {
			appearance.color_alpha = dp.read_int32();
		}
		if(exbits & 16) {
			appearance.blend_mode = dp.read_uint8();
		}
		if(exbits & 32) {
			dp.read_utf_string();
			dp.read_uint16();
			dp.read_uint16();
			dp.read_int16();
			dp.read_int16();
		}
		if(exbits & 64) {
			appearance.screen_loc = dp.read_utf_string();
		}
		if(exbits & 128) {
			appearance.invisibility = dp.read_uint8();
			appearance.luminosity = dp.read_uint8();
			dp.read_uint8();
		}
		if(exbits & 256) {
			appearance.plane = dp.read_int16();
		}
		if(exbits & 512) {
			let cm = new Float32Array(20);
			for(let i = 0; i < cm.length; i++) {
				cm[i] = dp.read_float();
			}
			appearance.color_matrix = cm;
		}
	}
	return appearance;
}

export class Animation {
	atom_id = 0;
	start_time = 0;
	is_new = false;
	frames : {
		from_appearance: Appearance,
		to_appearance: Appearance,
		flags: number,
		loop: number,
		easing: number,
		duration: number,
		parallel_start?: number
	}[] = [];
	total_duration = 0;
	parallel_parent? : Animation;
	sequence = -1;
	pre_len = 0;

	apply(target : Appearance, time : number) : Appearance {
		let unadjusted_time = time;
		time -= this.start_time;
		if(time < 0) return this.frames[0]?.from_appearance ?? target;
		if(!this.frames.length || !this.total_duration) return target;
		let final = this.frames[this.frames.length-1].to_appearance;
		let frame_index = 0;
		while(time > this.frames[frame_index].duration) {
			time -= this.frames[frame_index].duration;
			frame_index++;
			if(frame_index >= this.frames.length) {
				frame_index = 0;
				if(this.frames[0].loop == 1 || this.frames[0].loop == 0) {
					return this.parallel_parent ? this.parallel_parent.apply(target, time) : target;
				} else if(this.frames[0].loop > 1) {
					this.frames[0].loop--;
				}
				this.frames[0].from_appearance = this.frames[this.frames.length-1].to_appearance;
				this.start_time += this.total_duration;
			}
		}
		let frame = this.frames[frame_index];
		let prev = frame.from_appearance;
		let next = frame.to_appearance;
		target = target.copy();
		let fac = time / frame.duration;
		if(final.dir != next.dir) target.dir = next.dir;
		if(final.icon != next.icon) target.icon = next.icon;
		if(final.icon_state != next.icon_state) target.icon_state = next.icon_state;
		if(final.invisibility != next.invisibility) target.invisibility = next.invisibility;
		target.pixel_x = lerp_apply(prev.pixel_x, next.pixel_x, final.pixel_x, target.pixel_x, fac);
		target.pixel_y = lerp_apply(prev.pixel_y, next.pixel_y, final.pixel_y, target.pixel_y, fac);
		target.pixel_z = lerp_apply(prev.pixel_z, next.pixel_z, final.pixel_z, target.pixel_z, fac);
		target.pixel_w = lerp_apply(prev.pixel_w, next.pixel_w, final.pixel_w, target.pixel_w, fac);
		target.layer = lerp_apply(prev.layer, next.layer, final.layer, target.layer, fac);
		if(final.color_alpha != next.color_alpha || final.color_alpha != prev.color_alpha) {
			let orig_color = target.color_alpha;
			target.color_alpha = 0;
			for(let i = 0; i < 32; i += 8) {
				let component = lerp_apply(
					prev.color_alpha >> i & 0xFF,
					next.color_alpha >> i & 0xFF,
					final.color_alpha >> i & 0xFF,
					orig_color >> i & 0xFF,
					fac
				);
				target.color_alpha |= (Math.round(Math.max(0, Math.min(255, component))) & 0xFF) << i;
			}
		}
		if(!matrix_equals(final.transform, next.transform) || !matrix_equals(final.transform, prev.transform)) {
			let final_invert : mat3|null = !final.transform ? mat3.identity(mat3.create()) : ([...final.transform, 0, 0, 1] as mat3);
			mat3.transpose(final_invert, final_invert);
			final_invert = mat3.invert(final_invert, final_invert);

			if(final_invert && !matrix_equals(final.transform, target.transform)) {
				let orig_transform:mat3 = !target.transform ? mat3.identity(mat3.create()) : ([...target.transform, 0, 0, 1] as mat3);
				mat3.multiply(orig_transform, final_invert, orig_transform);
				let target_transform = [...matrix_interpolate(prev.transform??[1,0,0,0,1,0], next.transform??[1,0,0,0,1,0], fac, !!(frame.flags & 2)), 0, 0, 1] as mat3;
				mat3.multiply(target_transform, target_transform, orig_transform);
				target.transform = target_transform.slice(0, 6) as number[];
			} else {
				target.transform = matrix_interpolate(prev.transform??[1,0,0,0,1,0], next.transform??[1,0,0,0,1,0], fac, !!(frame.flags & 2));
			}
		}
		if(this.parallel_parent) target = this.parallel_parent.apply(target, unadjusted_time);
		return target;
	}

	static from_msg(dp : DataPointer, appearances : Map<number, Appearance>) {
		let anim = new Animation();
		anim.atom_id = dp.read_uint32();
		anim.start_time = dp.read_float();
		anim.is_new = !!dp.read_uint8();
		anim.sequence = dp.read_uint16();
		let num_frames = dp.read_uint16();
		for(let i = 0; i < num_frames; i++) {
			let from_id = dp.read_uint32as16();
			let to_id = dp.read_uint32as16();
			let from_appearance = appearances.get(from_id);
			let to_appearance = appearances.get(to_id);
			if(!from_appearance || !to_appearance) return anim;
			let time = dp.read_float();
			let loop = dp.read_int32();
			let easing = dp.read_uint8();
			let flags = dp.read_uint8();
			let parallel_start : number|undefined = undefined;
			if(flags & 4) {
				parallel_start = dp.read_float();
			}
			anim.frames.push({
				from_appearance, to_appearance,
				duration: time, easing, flags, loop,
				parallel_start
			});
			anim.total_duration += time;
		}
		console.log(anim);
		return anim;
	}

	recalc_duration() {
		this.total_duration = 0;
		for(let frame of this.frames) this.total_duration += frame.duration;
	}

	merge_fixup(curr_time : number, prev? : Animation|null) {
		this.start_time += curr_time;
		if(prev && prev.sequence == this.sequence) {
			this.pre_len = this.frames.splice(0, prev.frames.length + prev.pre_len).length;
			this.recalc_duration();
			this.start_time = Math.min(prev.start_time + prev.total_duration, curr_time);
			if(this.frames[0]?.parallel_start != undefined) {
				this.start_time = this.frames[0].parallel_start + curr_time;
			}

			if(this.frames[0] && (this.frames[0].flags & 4)) {
				this.parallel_parent = prev;
			} else if(this.frames.length && !(this.frames[0].flags & 1)) {
				this.frames[0].from_appearance = prev.apply(this.frames[0].from_appearance, this.start_time);
			}
		}
		for(let i = 0; i < this.frames.length; i++) {
			if(i != 0 && ((this.frames[i].flags & (1|4)) || this.frames[i].loop != 1)) {
				let new_prev = new Animation();
				new_prev.sequence = this.sequence;
				new_prev.atom_id = this.atom_id;
				new_prev.is_new = this.is_new;
				new_prev.start_time = this.start_time;
				new_prev.frames = this.frames.splice(0, i);
				new_prev.pre_len = this.pre_len;
				new_prev.parallel_parent = this.parallel_parent;
				this.parallel_parent = undefined;
				this.pre_len += new_prev.frames.length
				i = 0;
				new_prev.recalc_duration();
				this.recalc_duration();
				this.start_time += new_prev.total_duration;
				this.start_time = Math.max(this.start_time, curr_time);
				if(this.frames[0]?.parallel_start != undefined) {
					this.start_time = this.frames[0].parallel_start + curr_time;
				}
				if(this.frames[0].flags & 4) {
					this.parallel_parent = new_prev;
				} else if(!(this.frames[0].flags & 1)) {
					this.frames[0].from_appearance = new_prev.apply(this.frames[0].from_appearance, this.start_time);
				}
			}
		}
	}
}

function lerp_apply(a:number, b:number, final:number, target:number, fac:number) {
	return (a*(1-fac) + b*fac) + target-final;
}

let identity = [1,0,0,0,1,0];
function matrix_equals(a : number[]|null, b : number[]|null) {
	if(!a && !b) return true;
	if(!a) a = identity;
	if(!b) b = identity;
	for(let i = 0; i < 6; i++) {
		if(a[i] != b[i]) return false;
	}
	return true;
}
