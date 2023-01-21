import { vec2, vec3 } from "gl-matrix";
import { ByondClient } from ".";
import { Appearance, Animation } from "./appearance";
import { BatchRenderPlan, BillboardRenderPlan, BoxRenderPlan, DiagonalWallRenderPlan, EdgeRenderPlan, FloorRenderPlan, SmoothWallRenderPlan, WallmountRenderPlan, WindoorRenderPlan } from "./render_types";

type AtomDependent = {mark_dirty(atom : Atom) : void};
export class Atom implements AtomDependent {
	appearance: Appearance|null = null;
	flick: {icon: number|null, icon_state: string|null, time: number, duration: number}|null = null;
	enabled = true;
	enabled_screen = false;
	constructor(public client : ByondClient, public full_id: number){}
	loc: number = 0;
	last_loc : Atom|null = null;
	contents : Atom[]|null = null;
	images : Atom[]|null = null;
	get type() {
		return (this.full_id >>> 24);
	}
	get id() {
		return (this.full_id & 0xFFFFFF);
	}
	pixel_x = 0; pixel_y = 0;
	pixel_z = 0; pixel_w = 0;
	glide_vec : vec2|null = null;
	vis_contents : number[]|null = null;
	dependents : Set<AtomDependent>|null = null;
	animation : Animation|null = null;
	last_draw_pos : vec3|null = null;
	reset() {
		this.appearance = null;
		this.loc = 0;
		this.glide_vec = null;
		this.pixel_x = 0;
		this.pixel_y = 0;
		this.pixel_z = 0;
		this.pixel_w = 0;
		this.vis_contents = null;
		this.mark_dirty();
	}
	glide_to_loc(new_loc : number) {
		let x1 = -10;
		let y1 = -10;
		let x2 = -10;
		let y2 = -10;
		if((this.loc >> 24) == 1) {
			let id = this.loc & 0xFFFFFF;
			x1 = id % this.client.maxx;
			id = (id / this.client.maxx)|0;
			y1 = id % this.client.maxy;
		}
		this.loc = new_loc;
		if((this.loc >> 24) == 1) {
			let id = this.loc & 0xFFFFFF;
			x2 = id % this.client.maxx;
			id = (id / this.client.maxx)|0;
			y2 = id % this.client.maxy;
		}
		this.glide_vec = [x1-x2,y1-y2];
		if(Math.abs(this.glide_vec[0]) > 1.01 || Math.abs(this.glide_vec[1]) > 1.01) this.glide_vec = null;
		this.mark_dirty();
	}
	get_turf() : Atom|null {
		if(this.type == 1) {
			return this;
		}
		let loc = this.client.atom_map.get(this.loc);
		if(loc?.type == 1) return loc;
		return null;
	}
	render_plan : BatchRenderPlan[]|null = null;
	get_render_plan(dt : number) {
		if(!this.enabled) {
			return null;
		}
		if(this.glide_vec && !this.appearance?.animate_movement) {
			this.glide_vec = null;
		}
		if(this.glide_vec) {
			this.render_plan = null;
			let appearance = this.appearance;
			if(!appearance) this.glide_vec = null;
			else {
				let moveDist = dt / 50 * Math.max(1, appearance.glide_size) / 32;
				if(appearance.bits & 0x200000) {
					let nz = false;
					for(let i = 0; i < 3; i++) {
						let gv = this.glide_vec[i];
						if((this.glide_vec[i] = Math.max(0, (Math.abs(gv) - moveDist)) * Math.sign(gv))) {
							nz = true;
						}
					}	
					if(!nz) this.glide_vec = null;
				} else {
					let actDist = vec2.length(this.glide_vec);
					if(actDist == 0) {
						this.glide_vec = null;
					} else {
						vec2.scale(this.glide_vec, this.glide_vec, Math.max(0, 1 - moveDist / actDist));
					}
				}
			}
		}
		if(this.flick && this.flick.duration+this.flick.time < this.client.time) {
			this.flick = null;
			this.mark_dirty();
		}
		if(this.animation) {
			this.render_plan = null;
		}
		if(!this.render_plan) {
			let x = 0;
			let y = 0;
			this.render_plan = [];
			let turf = this.get_turf();
			if(!turf) return;
			x = turf.id % this.client.maxx;
			y = ((turf.id / this.client.maxx)|0) % this.client.maxy;
			if(this.glide_vec) {
				x += this.glide_vec[0];
				y += this.glide_vec[1];
			}
			
			this.last_draw_pos = [x+0.5,y+0.5,0.5];

			let appearance_obj : Atom = this;
			if(this.images) for(let image of this.images) {
				if(image.appearance && image.appearance.bits & 0x40000) {
					appearance_obj = image;
				}
			}
			let appearance = appearance_obj.appearance;
			if(appearance && (this.pixel_w || this.pixel_x || this.pixel_y || this.pixel_z)) appearance = appearance.copy(appearance_obj);
			if(appearance_obj.animation && appearance) appearance = appearance_obj.animation.apply(appearance, this.client.time);
			

			let list = this.render_plan;
			if(appearance && appearance.invisibility <= this.client.eye_see_invisible) {
				let tag = appearance.e3d_tag;
				if(this.type == 1 && !tag?.length) {
					tag = appearance.plane == -1 ? E3D_TYPE_SMOOTHWALL : E3D_TYPE_FLOOR;
				}
				let func = e3d_type_handlers.get(tag);
				if(!func) func = e3d_type_handlers.get(E3D_TYPE_BILLBOARD)!;
				if(this.flick) {
					appearance = appearance.copy();
					appearance.icon = this.flick.icon ?? appearance.icon;
					appearance.icon_state = this.flick.icon_state ?? appearance.icon_state;
					appearance.flick_time = this.flick.time;
				}
				func.call(this, list, appearance, x, y);
			}
			if(this.images) for(let image of this.images) {
				let image_appearance = image.appearance;
				if(!image_appearance || image_appearance.plane == 19) continue;

				let func = e3d_type_handlers.get(image_appearance.e3d_tag) ?? e3d_type_handlers.get(E3D_TYPE_BILLBOARD)!;
				func.call(this, list, image_appearance, x, y);
			}
			return list;
		}
		return this.render_plan;
	}
	add_dependent(atom : AtomDependent) {
		if(!this.dependents) this.dependents = new Set();
		this.dependents.add(atom);
	}
	mark_dirty() {
		this.render_plan = null;
		let loc = this.loc ? this.client.get_atom(this.loc) : null;
		if(loc != this.last_loc) {
			if(this.type == 0xD) {
				if(this.last_loc?.images) {
					let i = this.last_loc.images.indexOf(this);
					this.last_loc.images.splice(i, 1);
				}
				this.last_loc = loc;
				if(this.last_loc) {
					if(!this.last_loc.images) this.last_loc.images = [];
					this.last_loc?.images.push(this);
				}
			} else {
				if(this.last_loc?.contents) {
					let i = this.last_loc.contents.indexOf(this);
					this.last_loc.contents.splice(i, 1);
				}
				this.last_loc = loc;
				if(this.last_loc) {
					if(!this.last_loc.contents) this.last_loc.contents = [];
					this.last_loc?.contents.push(this);
				}
			}
		}
		if(this.type == 1) this.client.gl_holder.lighting_holder.dirty_turfs.add(this);
		if(this.dependents) {
			for(let dependent of [...this.dependents]) {
				this.dependents.delete(dependent);
				dependent.mark_dirty(this);
			}
		}
	}

	get_smooth(appearance : Appearance, extra_overlays_out? : Appearance[]) {
		let diagonal_smooth : string|null = null;
		let smooths : Array<string|null> = [null,null,null,null];
		if(appearance.overlays) for(let overlay of appearance.overlays) {
			let result = overlay.icon_state.match(/^([1234])-(i|[nsew]|[ns][ew]|f)$/);
			if(result && result[2]) {
				smooths[+result[1] - 1] = result[2];
			} else if(/^d-[ns][ew]$/.test(overlay.icon_state)) {
				diagonal_smooth = overlay.icon_state.slice(2);
			} else {
				if(extra_overlays_out) extra_overlays_out.push(overlay);
			}
		}
		if(!smooths.includes(null)) return smooths as string[];
		else if(diagonal_smooth) return diagonal_smooth;
		return null;
	}
}

const E3D_TYPE_BILLBOARD = "\x09";
const E3D_TYPE_FLOOR = "\x0A";
const E3D_TYPE_WALLMOUNT = "\x0B";
const E3D_TYPE_WALLMOUNT_SIGN = "\x0C";
const E3D_TYPE_SMOOTHWALL = "\x0D";
const E3D_TYPE_FALSEWALL = "\x09\x09";
const E3D_TYPE_ITEM = "\x09\x0A";
const E3D_TYPE_DOOR = "\x09\x0B";
const E3D_TYPE_LIGHTFIXTURE = "\x09\x0C";
const E3D_TYPE_TABLE = "\x09\x0D";
const E3D_TYPE_BASICWALL = "\x0A\x09";
const E3D_TYPE_EDGE = "\x0A\x0A";
const E3D_TYPE_EDGEFIREDOOR = "\x0A\x0B";
const E3D_TYPE_EDGEWINDOOR = "\x0A\x0C";
const E3D_TYPE_GAS_OVERLAY = "\x0A\x0D";

let e3d_type_handlers = new Map<string, (this: Atom, list : BatchRenderPlan[], appearance:Appearance, x:number, y:number) => void>(Object.entries({
	[E3D_TYPE_BILLBOARD](list, appearance, x, y) : void {
		x += appearance.pixel_x/32;
		y += appearance.pixel_y/32;
		let focus : vec3 = [x+0.5, y+0.5, 0.5];
		this.last_draw_pos = focus;
		let plan;
		list.push(plan = new BillboardRenderPlan(this.full_id, appearance, x+0.5, y+0.5).set_offsets(appearance.pixel_w/32, appearance.pixel_z/32).set_alpha_sort(focus));
		if(appearance.plane >= 13) plan.bits |= 1;
		if(appearance.overlays) for(let overlay of appearance.overlays) {
			if(overlay.plane == 12) continue;
			let bias = -0.05;
			if(overlay.layer < 0) bias = -(51 + overlay.layer) / 1000;
			overlay = overlay.copy_inherit(appearance, undefined, true);
			list.push(plan = new BillboardRenderPlan(this.full_id, overlay, x+0.5, y+0.5).set_offsets(overlay.pixel_w/32, overlay.pixel_z/32).set_alpha_sort(focus, bias));
			if(appearance.plane >= 13) plan.bits |= 1;
		}
		if(this.vis_contents) {
			for(let thing_id of this.vis_contents) {
				let thing = this.client.get_atom(thing_id);
				thing.add_dependent(this);
				let thing_appearance = thing.appearance;
				if(!thing_appearance) continue;
				if(thing.animation) {
					thing_appearance = thing.animation.apply(thing_appearance, this.client.time);
					this.render_plan = null;
				}
				if(thing_appearance.plane == 12) continue;
				let plan;
				let bias = -0.051;
				thing_appearance = thing_appearance.copy_inherit(appearance, thing, true);
				list.push(plan = new BillboardRenderPlan(this.full_id, thing_appearance, x+0.5, y+0.5).set_alpha_sort(focus, bias).set_offsets(thing_appearance.pixel_w/32, thing_appearance.pixel_z/32));
				if(thing_appearance.plane == 13 || thing_appearance.plane == 14) {
					plan.icon |= (1 << 24);
					plan.bits |= 1;
					plan.alpha_sort_bias -= 0.001;
				}
			}
		}
	},
	[E3D_TYPE_FLOOR](list, appearance, x, y) : void {
		x += (appearance.pixel_x)/32;
		y += (appearance.pixel_y)/32;
		let z = this.type == 1 ? 0 : (0.01 + Math.max(0, (appearance.layer - 2.19) * 0.1));
		this.last_draw_pos = [x+0.5,y+0.5,z];
		let odz = this.type == 1 ? 0 : 0.001;
		list.push(new FloorRenderPlan(this.full_id, appearance, x, y, z));
		let overlay_counter = 0;
		let vis_contents = this.vis_contents;
		if(appearance.overlays) for(let overlay of appearance.overlays) {
			if(overlay.icon_state.startsWith("e3d_gases:")) {
				vis_contents = overlay.icon_state.substring(10).split(",").map(a => (
					+a.substring(1, a.length-1)
				));
			}
			if(overlay.plane == -32767 || overlay.plane == appearance.plane) {
				overlay = overlay.copy_inherit(appearance);
				let ox = x + (overlay.pixel_x + overlay.pixel_w)/32;
				let oy = y + (overlay.pixel_y + overlay.pixel_z)/32;
				list.push(new FloorRenderPlan(this.full_id, overlay, ox, oy, z+(odz * ++overlay_counter), 1<<24));
			}
		}
		if(appearance.underlays) for(let overlay of appearance.underlays) {
			if(overlay.plane == -32767 || overlay.plane == appearance.plane) {
				overlay = overlay.copy_inherit(appearance);
				let ox = x + (overlay.pixel_x + overlay.pixel_w)/32;
				let oy = y + (overlay.pixel_y + overlay.pixel_z)/32;
				list.push(new FloorRenderPlan(this.full_id, overlay, ox, oy, z-odz, (-1)<<24));
			}
		}
		if(vis_contents) for(let vc of vis_contents) {
			let appearance = this.client.get_atom(vc).appearance;
			if(!appearance) continue;
			if(appearance.e3d_tag == E3D_TYPE_GAS_OVERLAY) {
				list.push(new BoxRenderPlan(this.full_id, appearance, x, y).set_alpha_sort([x+0.5,y+0.5,0.5], -0.2))
			}
		}
	},
	[E3D_TYPE_WALLMOUNT](list, appearance, x, y) : void {
		let pixel_x = appearance.pixel_x;
		let pixel_y = appearance.pixel_y;
		list.push(new WallmountRenderPlan(this.full_id, appearance, x, y, pixel_x, pixel_y, 0.01, false));
		if(appearance.overlays) for(let overlay of appearance.overlays) {
			if(overlay.plane == 12) continue;
			list.push(new WallmountRenderPlan(this.full_id, overlay, x, y, pixel_x, pixel_y, 0.011, false));
		}
		if(this.vis_contents) {
			for(let thing_id of this.vis_contents) {
				let thing = this.client.get_atom(thing_id);
				thing.add_dependent(this);
				let thing_appearance = thing.appearance;
				if(!thing_appearance) continue;
				if(thing.animation) {
					thing_appearance = thing.animation.apply(thing_appearance, this.client.time);
					this.render_plan = null;
				}
				if(thing_appearance.plane == 12) continue;
				let plan;
				list.push(plan = new WallmountRenderPlan(this.full_id, thing_appearance, x, y, pixel_x, pixel_y, 0.011, false));
				if(thing_appearance.plane == 13 || thing_appearance.plane == 14 || thing_appearance.plane > 15) {
					plan.icon |= (1 << 24);
					plan.bits |= 1;
				}
			}
		}
	},
	[E3D_TYPE_WALLMOUNT_SIGN](list, appearance, x, y) : void {
		list.push(new WallmountRenderPlan(this.full_id, appearance, x, y, appearance.pixel_x, appearance.pixel_y, 0.005, true));
	},
	[E3D_TYPE_SMOOTHWALL](list, appearance, x, y) : void {
		let extra_overlays : Appearance[] = [];
		let smooths = this.get_smooth(appearance, extra_overlays);
		if(typeof smooths == "string") {
			let dir = 2;
			if(smooths == "ne") dir = 4;
			else if(smooths == "nw") dir = 1;
			else if(smooths == "sw") dir = 8;
			list.push(new DiagonalWallRenderPlan(this.full_id, appearance, x, y, dir));
			if(appearance.overlays) for(let overlay of appearance.overlays) {
				list.push(new FloorRenderPlan(this.full_id, overlay, x, y, 1));
			}
			if(appearance.underlays) for(let underlay of appearance.underlays) {
				if(underlay.plane == 15) continue;
				e3d_type_handlers.get(E3D_TYPE_FLOOR)!.call(this, list, underlay, x, y);
			}
		} else {
			let plan : BatchRenderPlan;
			if(smooths instanceof Array) {
				list.push(plan = new SmoothWallRenderPlan(this.full_id, appearance, x, y, smooths));
			} else {
				list.push(plan = new BoxRenderPlan(this.full_id, appearance, x, y));
			}
			if(this.type != 1) {
				plan.alpha_sort_focus = [x+0.5,y+0.5,0.5];
				plan.alpha_sort_bias = -0.1;
			}
			for(let overlay of extra_overlays) {
				list.push(plan = new BoxRenderPlan(this.full_id, overlay, x, y));
				if(this.type != 1) {
					plan.alpha_sort_focus = [x+0.5,y+0.5,0.5];
					plan.alpha_sort_bias = -0.11
				}
			}
		}
	},
	[E3D_TYPE_FALSEWALL](list, appearance, x, y) : void {
		let smooths = this.get_smooth(appearance);
		if(smooths instanceof Array) {
			list.push(new SmoothWallRenderPlan(this.full_id, appearance, x, y, smooths));
		} else {
			list.push(new BoxRenderPlan(this.full_id, appearance, x, y));
		}
	},
	[E3D_TYPE_ITEM](list, appearance, x, y) : void {
		let stack_height = 0;
		let on_table = false;
		if(this.loc) {
			let items_done = false;
			let loc = this.client.get_atom(this.loc);
			if(loc.contents) for(let item of loc.contents) {
				if(item == this) {items_done = true; continue;}
				if(!item.appearance) continue;
				let tag = item.appearance.e3d_tag;
				if(tag == E3D_TYPE_TABLE) {
					on_table = true;
				} else if(tag == E3D_TYPE_ITEM && !items_done) {
					stack_height++;
				}
				item.add_dependent(this);
			}
		}
		x += appearance.pixel_x/32;
		y += appearance.pixel_y/32;
		let z = 1.5/32 + stack_height/500;
		if(on_table) z += 6.6/32;
		list.push(new FloorRenderPlan(this.full_id, appearance, x, y, z));
		if(appearance.overlays) for(let overlay of appearance.overlays) {
			if(overlay.plane == -32767 || overlay.plane == appearance.plane) {
				overlay = overlay.copy_inherit(appearance);
				list.push(new FloorRenderPlan(this.full_id, overlay, x, y, z, 1<<24));
			}
		}
	},
	[E3D_TYPE_DOOR](list, appearance, x, y) : void {
		let icon = this.client.icons.get(appearance.icon);
		let is_wide = (icon ? icon.width > 32 : false);
		let plan;
		list.push(plan = new BillboardRenderPlan(this.full_id, appearance, x+0.5, y+0.5, is_wide ? [0,-1,0]:undefined, is_wide, true));
		if(appearance.overlays) for(let overlay of appearance.overlays) {
			if(overlay.plane == -32767 || overlay.plane == appearance.plane) {
				let overlay_plan = new BillboardRenderPlan(this.full_id, appearance, x+0.5, y+0.5, is_wide ? [0,-1,0]:undefined, is_wide, true);
				overlay_plan.icon |= 1<<24;
				overlay_plan.alpha_sort_focus = [x+0.5,y+0.5,0.5];
				list.push(overlay_plan);
			}
		}
		if(this.vis_contents) {
			for(let thing_id of this.vis_contents) {
				let thing = this.client.get_atom(thing_id);
				thing.add_dependent(this);
				let thing_appearance = thing.appearance;
				if(!thing_appearance) continue;
				thing_appearance = thing_appearance.copy(thing);
				if(thing.animation) {
					thing_appearance = thing.animation.apply(thing_appearance, this.client.time);
					this.render_plan = null;
				}
				let plan;
				list.push(plan = new BillboardRenderPlan(this.full_id, thing_appearance, x+0.5, y+0.5, is_wide ? [0,-1,0]:undefined, is_wide, true));
				plan.offset_x += thing_appearance.pixel_x+thing_appearance.pixel_w;
				plan.offset_y += thing_appearance.pixel_y+thing_appearance.pixel_z;
				if(thing_appearance.layer != -2) {
					plan.icon |= 1<<24;
					plan.alpha_sort_focus = [x+0.5,y+0.5,0.5];
				}
				if(thing_appearance.overlays) for(let overlay of thing_appearance.overlays) {
					list.push(plan = new BillboardRenderPlan(this.full_id, overlay.copy_inherit(thing_appearance), x+0.5, y+0.5, is_wide ? [0,-1,0]:undefined, is_wide, true));
					plan.alpha_sort_focus = [x+0.5,y+0.5,0.5];
					plan.offset_x += thing_appearance.pixel_x+thing_appearance.pixel_w;
					plan.offset_y += thing_appearance.pixel_y+thing_appearance.pixel_z;
				}
			}
		}
	},
	[E3D_TYPE_LIGHTFIXTURE](list, appearance, x, y) : void {
		list.push(new FloorRenderPlan(this.full_id, appearance, x, y, 0.5));
	},
	[E3D_TYPE_TABLE](list, appearance, x, y) : void {
		let z = 8/32;
		let extras : Appearance[] = [];
		let smooth = this.get_smooth(appearance, extras);
		if(smooth instanceof Array) {
			let plan = new SmoothWallRenderPlan(this.full_id, appearance, x, y, smooth, true);
			plan.clip_height = z;
			plan.inset = 3/32;
			list.push(plan);
		} else {
			list.push(new FloorRenderPlan(this.full_id, appearance, x, y, z));
		}
		if(appearance.overlays) for(let overlay of extras) {
			if(overlay.plane == -32767 || overlay.plane == appearance.plane) {
				list.push(new FloorRenderPlan(this.full_id, overlay, x, y, z, 1<<24));
			}
		}
	},
	[E3D_TYPE_BASICWALL](list, appearance, x, y) : void {
		list.push(new BoxRenderPlan(this.full_id, appearance, x, y));
		if(appearance.overlays) for(let overlay of appearance.overlays) {
			if(overlay.plane == -32767 || overlay.plane == appearance.plane) {
				let plan = new BoxRenderPlan(this.full_id, overlay, x, y);
				plan.icon |= 1<<24;
				list.push(plan);
			}
		}``
	},
	[E3D_TYPE_EDGEWINDOOR](list, appearance, x, y) : void {
		list.push(new WindoorRenderPlan(this.full_id, appearance, x, y));
	},
	[E3D_TYPE_EDGE](list, appearance, x, y) : void {
		list.push(new EdgeRenderPlan(this.full_id, appearance, x, y));
	},
	[E3D_TYPE_EDGEFIREDOOR](list, appearance, x, y) : void {
		let plan : EdgeRenderPlan;
		list.push(plan = new EdgeRenderPlan(this.full_id, appearance, x, y, 9/32));
		if(appearance.icon_state == "door_open") plan.alpha_sort_focus = null;
		if(appearance.overlays) for(let overlay of appearance.overlays) {
			list.push(plan = new EdgeRenderPlan(this.full_id, overlay, x, y, 9/32));
			if(appearance.icon_state == "door_open") plan.alpha_sort_focus = null;
		}
	}
}));
