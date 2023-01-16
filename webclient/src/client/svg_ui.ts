import { vec2 } from "gl-matrix";
import { ByondClient } from ".";
import { Appearance } from "./appearance";
import { Atom } from "./atom";
import { MessageBuilder } from "./binary";

const clip_ctx = document.createElement("canvas").getContext("2d", {willReadFrequently: true})!;

export class SvgUi {
	ui_base = document.createElement("div");
	crosshair = document.createElement("div");
	mouse_label = document.createElement("div");
	status_overlay = document.createElement("div");
	constructor(public client : ByondClient) {
		this.ui_base.style.position = "absolute";
		this.ui_base.style.left = "0px";
		this.ui_base.style.top = "0px";
		this.ui_base.style.width = "100%";
		this.ui_base.style.height = "100%";
		this.ui_base.style.pointerEvents = "none";
		this.ui_base.style.overflow = "hidden";
		this.update_zoom(2);
		document.body.appendChild(this.ui_base);

		this.crosshair.style.position = "absolute";
		this.crosshair.style.left = "50%";
		this.crosshair.style.top = "50%";
		this.crosshair.style.width = "2px";
		this.crosshair.style.height = "2px";
		this.crosshair.style.backgroundColor = "white";
		this.crosshair.style.marginLeft= "-1px";
		this.crosshair.style.marginTop = "-1px";
		this.crosshair.style.border = "1px solid grey";
		this.crosshair.style.mixBlendMode = "difference";
		this.ui_base.appendChild(this.crosshair);

		this.mouse_label.style.position = "absolute";
		this.mouse_label.style.left = "0px";
		this.mouse_label.style.bottom = "0px";
		this.mouse_label.style.pointerEvents = "none";
		this.mouse_label.style.backgroundColor = "rgba(0,0,0,0.5)";
		this.mouse_label.style.color = "white";
		document.body.appendChild(this.mouse_label);

		this.status_overlay.id = "status-overlay";
		this.status_overlay.style.display = "none";
		document.body.appendChild(this.status_overlay);

		window.addEventListener("mousedown", this.mousedown);
	}

	set_status_overlay(str : string|null) {
		if(str) {
			this.status_overlay.textContent = str;
			this.status_overlay.style.removeProperty("display");
		} else {
			this.status_overlay.style.display = "none";
		}
	}

	chatpush_up_elems = new Set<Atom>();
	chatpush_up_amt : number = 0;
	chatpush_right_elems = new Set<Atom>();
	chatpush_right_amt : number = 0;

	zoom_target : number = 1;
	zoom_level : number = 1;
	update_zoom(zoom_target : number = this.zoom_target) {
		this.zoom_target = zoom_target;
		let rect = this.ui_base.getBoundingClientRect();
		let zoom_level = Math.min(zoom_target, rect.width / 480, rect.height / 320);
		if(this.zoom_level == zoom_level) return;
		this.chatpush_dirty();
		this.zoom_level = zoom_level;
		let size_percent = (100 / zoom_level) + "%";
		let translate_percent = ((0.5*(1 - 1 / zoom_level))*100) + "%";
		this.ui_base.style.transform = `scale(${zoom_level}) translate(${translate_percent}, ${translate_percent})`;
		this.ui_base.style.width = size_percent;
		this.ui_base.style.height = size_percent;
	}

	fullscreen_elems = new Set<HTMLElement>();

	frame(dt : number) {
		this.update_zoom();
		for(let elem of this.fullscreen_elems) {
			if(!elem.isConnected) {
				this.fullscreen_elems.delete(elem); continue;
			}
			elem.style.transform = `scale(${this.ui_base.clientWidth / 480}, ${this.ui_base.clientHeight / 480})`;
		}
	}

	plane_masters = new Map<number, Atom>();
	curr_plane_masters = new WeakMap<Atom, number>();
	blind_atom? : Atom;

	atoms = new Map<Atom, HTMLElement>();
	update_atom(atom : Atom) {
		this.chatpush_dirty();
		let elem = this.atoms.get(atom);
		const appearance = atom.appearance;
		const screen_loc = appearance ? ScreenLoc.from_string(appearance.screen_loc) : null;

		this.plane_masters.delete(this.curr_plane_masters.get(atom)!);
		this.curr_plane_masters.delete(atom);

		let on_screen = appearance && appearance.invisibility <= 15 && screen_loc && atom.enabled_screen;

		if(appearance && on_screen && (appearance.bits & 0x10000000)) {
			let plane = appearance.plane;
			this.curr_plane_masters.delete(this.plane_masters.get(plane)!);
			this.plane_masters.set(plane, atom);
			this.curr_plane_masters.set(atom, plane);
			atom.add_dependent(this);
			on_screen = false;
		}

		if(appearance && on_screen && appearance.plane == 20 && (appearance.icon_state == "blindimageoverlay")) {
			this.blind_atom = atom;
			on_screen = false;
			atom.add_dependent(this);
		} else {
			if(this.blind_atom == atom) this.blind_atom = undefined;
		}
		
		if(!appearance || !on_screen || !screen_loc || appearance.plane < 0 || appearance.plane == 15) {
			if(elem) {
				elem.parentElement?.removeChild(elem);
			}
			this.atoms.delete(atom);
			this.chatpush_right_elems.delete(atom);
			this.chatpush_up_elems.delete(atom);
			return;
		}
		if(!elem) {
			elem = document.createElement("div");
			this.atoms.set(atom, elem);
			elem.dataset.atomId = ""+atom.full_id;
			elem.style.position = "absolute";
			elem.style.width = "32px";
			elem.style.height = "32px";
			this.ui_base.appendChild(elem);
		}
		if(screen_loc.x_frac < 0.75 && screen_loc.y_frac < 0.25) {
			this.chatpush_up_elems.add(atom);
			this.chatpush_right_elems.delete(atom);
		} else if(screen_loc.x_frac < 0.25 && screen_loc.y_frac < 0.75) {
			this.chatpush_right_elems.add(atom);
			this.chatpush_up_elems.delete(atom);
		}
		elem.style.zIndex = ""+Math.round(appearance.layer * 10000);
		elem.style.left = screen_loc.css_left();
		elem.style.bottom = screen_loc.css_bottom();
		this.appearance_to_elem(appearance, elem, 0, 0);
		atom.add_dependent(this);
	}

	chatpush_raf : number|null = null;
	chatpush_dirty() {
		if(this.chatpush_raf == null) {
			this.chatpush_raf = requestAnimationFrame(this.update_chatpush);
		}
	}
	update_chatpush = () => {
		this.chatpush_raf = null;
		this.chatpush_up_amt = 0;
		this.chatpush_right_amt = 0;
		let full_rect = this.ui_base.getBoundingClientRect();
		for(let atom of this.chatpush_right_elems) {
			let elem = this.atoms.get(atom);
			if(!elem) {
				this.chatpush_right_elems.delete(atom);
				continue;
			}
			let elem_rect = elem.getBoundingClientRect();
			this.chatpush_right_amt = Math.max(this.chatpush_right_amt, elem_rect.right - full_rect.left);
		}
		for(let atom of this.chatpush_up_elems) {
			let elem = this.atoms.get(atom);
			if(!elem) {
				this.chatpush_up_elems.delete(atom);
				continue;
			}
			let elem_rect = elem.getBoundingClientRect();
			this.chatpush_up_amt = Math.max(this.chatpush_up_amt, full_rect.bottom - elem_rect.top);
		}
		this.client.browseroutput_container.style.left = `${this.chatpush_right_amt + 10}px`;
		this.client.browseroutput_container.style.bottom = `${this.chatpush_up_amt + 10}px`;
	}

	mark_dirty(atom : Atom) {
		this.update_atom(atom);
	}

	appearance_to_elem(appearance : Appearance, elem : HTMLElement, pixel_xw : number, pixel_yz : number, dir_inherit = appearance.dir) : boolean {
		let icon_elem = elem.querySelector(":scope > .icon") as HTMLElement|null;
		const dir = (appearance.bits & 0x200) ? appearance.dir : dir_inherit;
		const icon = this.client.icons.get(appearance.icon);
		if(icon) {
			if(!icon_elem) icon_elem = document.createElement("div");
			icon_elem.style.position = "absolute";
			icon_elem.style.bottom = pixel_yz + "px";
			icon_elem.style.left = pixel_xw + "px";
			icon_elem.style.width = "0px";
			icon_elem.style.height = "0px";
			icon_elem.style.background = "none";
			icon_elem.style.pointerEvents = appearance.mouse_opacity ? "auto" : "none";
			icon_elem.style.clipPath = "none";
			icon_elem.dataset.icon = ""+appearance.icon;
			icon_elem.dataset.icon_state = appearance.icon_state;
			icon_elem.dataset.dir = ""+dir;
			if(appearance.transform) {
				let t = appearance.transform;
				icon_elem.style.transform = `matrix(${t[0]},${t[3]},${t[1]},${t[4]},${t[2]},${t[5]})`;
			}
			if(appearance.screen_loc == "CENTER-7,CENTER-7" && icon.width == 480 && icon.height == 480) {
				this.fullscreen_elems.add(icon_elem);
			}
			(async () => {
				let image = icon.image;
				if(!image) image = await icon.make_image(await this.client.get_resource_blob(icon.resource));
				if(icon_elem.dataset.icon_state != appearance.icon_state) return;
				if(icon_elem.dataset.icon != ""+appearance.icon) return;
				if(icon_elem.dataset.dir != ""+dir) return;
				let icon_state = icon.get_icon_state(appearance.icon_state);
				if(!icon_state) return;
				let frame = icon_state.icons[icon_state.get_dir_index(dir)][0];
				let frame_x = (frame % icon.sheet_width) * icon.width;
				let frame_y = ((frame / icon.sheet_width)|0) * icon.height;
				icon_elem.style.width = icon.width+"px";
				icon_elem.style.height = icon.height+"px";
				icon_elem.style.background = `url("${image.src}") ${-frame_x}px ${-frame_y}px`;
				if(appearance.mouse_opacity == 1) {
					let path = icon.frame_paths.get(frame);
					if(!path) {
						if(clip_ctx.canvas.width < icon.width) clip_ctx.canvas.width = icon.width;
						if(clip_ctx.canvas.height < icon.height) clip_ctx.canvas.height = icon.height;
						clip_ctx.globalCompositeOperation = "copy";
						clip_ctx.drawImage(image, -frame_x, -frame_y);
						path = this.image_data_to_path(clip_ctx.getImageData(0, 0, icon.width, icon.height));
						icon.frame_paths.set(frame, path);
					}
					icon_elem.style.clipPath = `path("M0.2,0.2${path}")`;
				}
			})();
		} else {
			icon_elem = null;
		}
		elem.innerHTML = "";
		if(icon_elem) elem.appendChild(icon_elem);
		if(appearance.overlays) for(let overlay of appearance.overlays) {
			let overlayElem = document.createElement("div");
			overlayElem.style.position = "absolute";
			overlayElem.style.left = "0px"; overlayElem.style.bottom = "0px";
			overlayElem.style.width = "32px"; overlayElem.style.height = "32px";
			this.appearance_to_elem(overlay, overlayElem, overlay.pixel_w+overlay.pixel_x, overlay.pixel_y+overlay.pixel_z, dir);
			elem.appendChild(overlayElem);
		}
		return true;
	}

	image_data_to_path(data : ImageData, origin_x=0, origin_y=0, width=data.width-origin_x, height=data.height-origin_y) : string {
		let parts = new Map<string,string[]>();
		let add = (a:string, b:string) => {
			let arr = parts.get(a);
			if(!arr) {
				arr = [];
				parts.set(a, arr);
			}
			arr.push(b);
		}
		for(let y = 0; y <= height; y++) {
			let curr_top : number|null = null;
			let curr_bottom : number|null = null;
			for(let x = 0; x <= width; x++) {
				let top_state = false;
				let bottom_state = false;
				if(x >= 0 && x < width) {
					if(y < height)
						bottom_state = !!data.data[((x+origin_x) + (y+origin_y)*data.width)*4 + 3];
					if(y > 0)
						top_state = !!data.data[((x+origin_x) + (y+origin_y-1)*data.width)*4 + 3];
				}
				if(top_state && bottom_state) {top_state = false; bottom_state = false;}
				if(top_state && curr_top == null) curr_top = x;
				if(bottom_state && curr_bottom == null) curr_bottom = x;
				if(!top_state && curr_top != null) {
					add(`${curr_top},${y}`,`${x},${y}`);
					curr_top = null;
				}
				if(!bottom_state && curr_bottom != null) {
					add(`${x},${y}`,`${curr_bottom},${y}`);
					curr_bottom = null
				}
			}
		}
		for(let x = 0; x <= width; x++) {
			let curr_right : number|null = null;
			let curr_left : number|null = null;
			for(let y = 0; y <= height; y++) {
				let right_state = false;
				let left_state = false;
				if(y >= 0 && y < height) {
					if(x < width)
						right_state = !!data.data[((x+origin_x) + (y+origin_y)*data.width)*4 + 3];
					if(x > 0)
						left_state = !!data.data[((x+origin_x-1) + (y+origin_y)*data.width)*4 + 3];
				}
				if(left_state && right_state) {left_state = false; right_state = false};
				if(right_state && curr_right == null) curr_right = y;
				if(left_state && curr_left == null) curr_left = y;
				if(!right_state && curr_right != null) {
					add(`${x},${curr_right}`,`${x},${y}`);
					curr_right = null;
				}
				if(!left_state && curr_left != null) {
					add(`${x},${y}`,`${x},${curr_left}`);
					curr_left = null;
				}
			}
		}
		let last_rel_x = 0;
		let last_rel_y = 0;
		let loopy_str = "";
		let rel = (next:string,line = true, closing = false) => {
			let [x2,y2] = next.split(",");
			let dx = +x2 - last_rel_x;
			let dy = +y2 - last_rel_y;
			last_rel_x = +x2;
			last_rel_y = +y2;
			if(line) {
				if(closing) loopy_str += `z`;
				else if(dy == 0) loopy_str += `h${dx}`;
				else if(dx == 0) loopy_str += `v${dy}`;
				else loopy_str += `l${dx},${dy}`;
			} else loopy_str += `m${dx},${dy}`
		}
		for(let [starting_pre, starting_arr] of parts) {
			let starting_point;
			while(starting_point = starting_arr.pop()) {
				if(!starting_arr.length) parts.delete(starting_pre);
				rel(starting_pre, false); rel(starting_point);
				let curr_point = starting_point;
				let next_points;
				while((next_points = parts.get(curr_point)) && next_points.length) {
					let next_point = next_points.pop()!;
					if(!next_points.length) parts.delete(curr_point);
					if(next_point == starting_pre) {
						rel(next_point, true, true);
						break;
					} else {
						rel(next_point);
					}
					curr_point = next_point;
				}
			}
		}
		return loopy_str;
	}

	last_mousemove? : MouseEvent;
	curr_mouse_info? : MouseInfo;

	last_click? : MouseInfo;
	last_click_time : number = 0;

	update_mouse_info(e? : MouseEvent) {
		let info = this.get_mouse_info(e);
		if(JSON.stringify(info) != JSON.stringify(this.curr_mouse_info)) {
			this.curr_mouse_info = info;
			this.mouse_label.textContent = this.client.atom_map.get(info?.atom_id!)?.appearance?.name ?? ""
		}
		return info;
	}

	mousedown = async (md : MouseEvent) => {
		let md_info = this.update_mouse_info(md);
		if(!md_info) return;
		this.send_mouse_info(3, md, md_info);
		let mu = await Promise.race([
		   new Promise<MouseEvent>(resolve => window.addEventListener("mouseup", resolve, {once: true})),
		   new Promise<void>(resolve => setTimeout(()=>{resolve();}, 200)) 
		]);
		if(mu) {
			let mu_info = this.update_mouse_info(mu);
			if(mu_info) this.send_mouse_info(4, mu, mu_info);
			this.send_click(md, md_info);
			return;
		}
		mu = await new Promise<MouseEvent>(resolve => window.addEventListener("mouseup", resolve, {once: true}));
		let mu_info = this.update_mouse_info(mu);
		if(mu_info) this.send_mouse_info(4, mu, mu_info);
		if(mu_info?.atom_id != md_info?.atom_id) {
			if(mu_info) {
				this.send_mouse_info(7, md, mu_info, md_info);
			}
			mu.preventDefault();
		} else {
			this.send_click(mu, mu_info);
		}
	}

	send_click(event : MouseEvent, info : MouseInfo) {
		this.send_mouse_info(1, event, info);
		if(Date.now() - this.last_click_time < 400 && info.atom_id == this.last_click?.atom_id) {
			this.send_mouse_info(2, event, info);
		}
		this.last_click = info;
		this.last_click_time = Date.now();
	}

	send_mouse_info(id : number, event : MouseEvent, info : MouseInfo, last_info? : MouseInfo) {
		//this.client.send_click(2, info.atom_id, last_info?.atom_id, event, undefined, info.screen_offset, info.icon_offset, info.params)
		console.log(id, info.atom_id, last_info?.atom_id);
		let msg = new MessageBuilder(215);
		msg.write_uint8(0).write_uint8(id);

		let flags = event.buttons & 7;
		if(event.shiftKey) flags |= 16;
		if(event.ctrlKey) flags |= 8;
		if(event.altKey) flags |= 32;
		msg.write_uint8(flags);
		
		if(last_info) this.write_event(id, msg, last_info);
		this.write_event(id, msg, info);
		msg.write_string(info.params ?? "");
		this.client.websocket.send(msg.collapse());
	}
	write_event(id : number, msg : MessageBuilder, info : MouseInfo) {
		msg.write_uint32(info.atom_id);
		if(id == 9) {
			msg.write_int16(0).write_int16(0);
		}
		msg.write_int16(info.screen_offset?.[0] ?? 32768).write_int16(info.screen_offset?.[1] ?? 32768);
		msg.write_int16(info.icon_offset?.[0] ?? 0).write_int16(info.icon_offset?.[1] ?? 0);
		msg.write_uint8(0);
		msg.write_string("");
		msg.write_string("map");
	}

	get_mouse_info(e : MouseEvent|undefined = this.last_mousemove) : MouseInfo|undefined {
		this.last_mousemove = e;
		let atom = ((e?.target as HTMLElement|undefined)?.closest("[data-atom-id]") as HTMLElement);
		if(atom && e) {
			let atom_rect = atom.getBoundingClientRect();
			let clickpos_vec : vec2 = [
				(e.clientX - atom_rect.x) / atom_rect.width * 32,
				(1 - (e.clientY - atom_rect.y) / atom_rect.height) * 32
			];
			return {
				atom_id: +atom.dataset.atomId!,
				icon_offset: clickpos_vec
			};
		}
		let is_canvas = e?.target == this.client.gl_holder.canvas;
		if(is_canvas) {
			let params = {
				"e3d-yaw": (this.client.gl_holder.camera_yaw*180/Math.PI).toFixed(1),
				"e3d-pitch": (this.client.gl_holder.camera_pitch*180/Math.PI).toFixed(1),
				"e3d-camera-pos": [...this.client.gl_holder.inv_view_matrix.slice(4, 7)].map(a => a.toFixed(2)).join(","),
				"e3d-camera-vec": [...this.client.gl_holder.inv_view_matrix.slice(12, 15)].map(a => a.toFixed(2)).join(","),
			}
			return {
				atom_id: this.client.gl_holder.mouse_hit_id,
				params: Object.entries(params).map(([k, v]) => `${k}=${encodeURIComponent(v)}`).join(";")
			}
		}
		return undefined;
	}
}

interface MouseInfo {
	atom_id : number;
	icon_offset? : vec2;
	screen_offset? : vec2;
	params? : string;
}

class ScreenLoc {
	x = 0;
	y = 0;
	x_frac = 0;
	y_frac = 0;
	px = 0;
	py = 0;
	repeat_width = 1;
	repeat_height = 1;
	
	css_left() {
		if(this.x_frac == 0) return `${this.x*32+this.px}px`;
		return `calc(${this.x_frac*100}% + ${this.x*32 + this.px - (32*this.x_frac)}px)`;
	}
	css_bottom() {
		if(this.y_frac == 0) return `${this.y*32+this.py}px`;
		return `calc(${this.y_frac*100}% + ${this.y*32 + this.py - (32*this.y_frac)}px)`;
	}
	static from_string(screen_loc: string | null) : ScreenLoc|null {
		try {
			if(!screen_loc) return null;
			let to_split = screen_loc.split(" to ");
			if(to_split.length >= 2) {
				let loc1 = ScreenLoc.from_string(to_split[0]);
				let loc2 = ScreenLoc.from_string(to_split[1]);
				if(!loc1 || !loc2) return null;
				loc1.repeat_width = loc2.x-loc1.x;
				loc1.repeat_height = loc2.y-loc1.y;
				return loc1;;
			}
			let result = new ScreenLoc();
			let parts = screen_loc.split(",");
			if(parts[1] && /EAST|WEST/.test(parts[1]) && /NORTH|SOUTH/.test(parts[0])) {
				parts.reverse();
			}
			for(let i = 0; i < 2; i++) {
				const tile_var = (["x","y"] as const)[i];
				const frac_var = (["x_frac","y_frac"] as const)[i];
				const pixel_var = (["px","py"] as const)[i];
				let part = parts[i] || parts[0];
				part = part.trim();
				const match = part.match(/^(CENTER|(?:NORTH|SOUTH)?(?:EAST|WEST)?)?(?:\+?(-?[\d\.]+)|(-?[\d\.]+%))?(?::\+?(-?\d+))?$/);
				if(!match) return null;
				if(match[1]) {
					if(match[1] == "CENTER") result[frac_var] = 0.5;
					else if(i == 0) {
						if(match[1].includes("EAST")) result[frac_var] = 1;
					} else if(i == 1) {
						if(match[1].includes("NORTH")) result[frac_var] = 1;
					}
				}
				if(match[2]) result[tile_var] = +match[2] - (match[1] ? 0 : 1);
				if(match[3]) result[frac_var] += +match[3]/100;
				if(match[4]) result[pixel_var] = +match[4];
			}
			return result;
		} catch(e) {
			return null;
		}
	}
}
