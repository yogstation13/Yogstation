import { vec2 } from "gl-matrix";
import { Appearance, Animation, parse_appearance } from "./appearance";
import { Atom } from "./atom";
import { DataPointer, MessageBuilder } from "./binary";
import { Icon } from "./icon";
import { despam_promise } from "./promise_despammer";
import { BatchRenderPlan, BillboardRenderPlan, BoxRenderPlan, FloorRenderPlan, SmoothWallRenderPlan, WallmountRenderPlan } from "./render_types";
import { SoundCommand, SoundPlayer } from "./sound";
import { SvgUi } from "./svg_ui";
import { GlHolder } from "./webgl";
import "./index.css";
import { get_webgl_stats } from "./stat_collection";

export class ByondClient {
	websocket : WebSocket;
	maxx=0; maxy=0; maxz=0;
	appearance_map = new Map<number, Appearance>();
	atom_map = new Map<number, Atom>();
	gl_holder : GlHolder;
	sound_player : SoundPlayer;
	ui : SvgUi;
	is_test_env = false;
	eye_x = 0;
	eye_y = 0;
	eye_z = 1;
	eye_height = 0.82;
	time = 0;
	eye_glide_size = 0;
	eye_bits = 0;
	eye_sight = 0;
	eye_see_invisible = 0;
	icons = new Map<number, Icon>();
	has_quit = false;
	constructor() {
		// @ts-ignore
		window.byond_client = this;
		this.websocket = new WebSocket('ws'+window.location.origin.substring(4));
		this.websocket.binaryType = "arraybuffer";
		this.websocket.addEventListener("message", this.handle_message);
		this.websocket.addEventListener("error", () => {
			this.ui.set_status_overlay("WebSocket error");
			this.has_quit = true;
		});
		this.websocket.addEventListener("close", () => {
			if(!this.has_quit) {
				this.ui.set_status_overlay("Connection closed");
				this.has_quit = true;
			}
		});
		window.addEventListener("wheel", (e) => {
			let delta_y = e.deltaY;
			if(e.deltaMode == WheelEvent.DOM_DELTA_PIXEL) delta_y /= 100;
			else if(e.deltaMode == WheelEvent.DOM_DELTA_LINE) delta_y /= 3;

			let log = Math.log2(this.gl_holder.camera_zoom + 1);
			log += delta_y;
			this.gl_holder.camera_zoom = Math.max(0, Math.min(20, 2**log - 1));
		})
		window.addEventListener("keydown", (e) => {
			if((e.target as HTMLElement).closest("input,select,button,textarea") || this.has_quit) return;
			if(e.code == "Tab") {
				if(document.pointerLockElement != this.gl_holder.canvas) {
					this.gl_holder.canvas.requestPointerLock();
				} else {
					document.exitPointerLock();
				}
				e.preventDefault();
				return;
			}
			if(this.is_test_env) {
				if(e.code == "ArrowUp") this.command(".north");
				if(e.code == "ArrowDown") this.command(".south");
				if(e.code == "ArrowRight") this.command(".east");
				if(e.code == "ArrowLeft") this.command(".west");
			}
			let key = this.js_keycode_to_byond(e.which);
			if(key) {
				if(!e.repeat) {
					for(let macro of this.macros.values()) {
						if(macro.get("name") == key) {
							this.command(macro.get("command") ?? "");
						}
					}
					this.command(`KeyDown "${key}"`);
				}
				e.preventDefault();
			}
		});
		window.addEventListener("keyup", (e) => {
			let key = this.js_keycode_to_byond(e.which);
			if(key) this.command(`KeyUp "${key}"`);
		})
		window.addEventListener("message", (e) => {
			if(typeof e.data == "string") {
				if(e.data.startsWith("go:")) {
					let href = e.data.substring(3);
					if(!href.startsWith("byond://") && !href.startsWith("?")) {
						let qi = href.indexOf("?");
						if(qi >= 0) href = href.substring(qi);
					}
					if(href.startsWith("?")) {
						this.topic(href.substring(1));
					} else if(href.startsWith("byond://?")) {
						this.topic(href.substring(9));
					} else if(href.match(/byond:\/\/win(?:get|set)\?/)) {
						let split = href.substring(href.indexOf("?") + 1).split(/[;&]/g);
						let id : string = "";
						let parts = new Map<string,string>();
						for(let splitpart of split) {
							let sep = splitpart.indexOf('=');
							if(sep < 0) continue;
							let key = decodeURIComponent(splitpart.substring(0, sep).replace(/\+/g, " "));
							let val = decodeURIComponent(splitpart.substring(sep+1).replace(/\+/g, " "));
							if(key == "id") id = val;
							else parts.set(key, val);
						}

						if(href.startsWith("byond://winset")) this.winset(id, parts);
						else {
							const result: {[p: string]: unknown} = Object.fromEntries(this.winget(id, parts.get("property")?.split(",") ?? []).entries())
							Object.keys(result).filter(x => x.includes(".")).forEach(x => {
								let value = result[x];

								delete result[x];

								let current = result;
								const path = x.split(".");
								while(path.length) {
									const currentPathElement = path.shift()!;
									if(!path.length) {
										current[currentPathElement] = value;
										break;
									}

									if(typeof current[currentPathElement] !== "object") current[currentPathElement] = {};
									current = current[currentPathElement] as Record<string, unknown>;
								}
							});
							const payload = "callback:" + JSON.stringify({
								callback: parts.get("callback"),
								data: JSON.stringify(result)
							})
							// @ts-ignore
							e.source?.postMessage(payload, "*");
						}
					} else {
						console.error("Unimplemented byond protocol handler", href)
					}
				}
			}
		})
		this.gl_holder = new GlHolder(this);
		this.ui = new SvgUi(this);
		this.sound_player = new SoundPlayer(this);
		this.ui.set_status_overlay("Connecting...");
		this.frameLoop();
		this.gl_holder.canvas.addEventListener("dblclick", (e) => {
			if(!e.defaultPrevented && document.pointerLockElement != this.gl_holder.canvas) {
				this.gl_holder.canvas.requestPointerLock();
			}
		});
		document.addEventListener("mousemove", (e) => {
			if(document.pointerLockElement != this.gl_holder.canvas) {
				this.ui.update_mouse_info(e);
				return;
			}
			this.gl_holder.camera_pitch -= e.movementY / 300;
			if(this.gl_holder.camera_pitch <= -Math.PI/2) {
				this.gl_holder.camera_secondyaw -= e.movementX / 300;
			} else {
				this.gl_holder.camera_yaw -= e.movementX / 300;
			}
			this.send_angle();
		});

		document.body.style.overflow = "hidden";
		document.body.id = "window-mainwindow";

		let stats_browser = document.createElement("iframe");
		stats_browser.style.display = "none";
		stats_browser.id = "control-asset_cache_browser";
		document.body.appendChild(stats_browser);

		let bocontainer = this.browseroutput_container = document.createElement("div");
		bocontainer.style.position = "absolute";
		bocontainer.style.pointerEvents = "none";
		bocontainer.style.overflow = "hidden";
		bocontainer.style.width = "min(40%, 800px)";
		bocontainer.style.height = "min(55vh, 600px)";
		bocontainer.style.left = "0px";
		bocontainer.style.bottom = "100px";
		bocontainer.id = "window-outputwindow";
		document.body.appendChild(bocontainer);
		let browseroutput = document.createElement("iframe");
		browseroutput.style.pointerEvents = "auto";
		browseroutput.style.position = "absolute";
		browseroutput.style.width = "100%";
		browseroutput.style.height = "min(55vh, 600px)";
		browseroutput.style.bottom = "0px";
		browseroutput.style.left = "0px";
		browseroutput.id = "control-browseroutput";
		browseroutput.style.border = "none";
		bocontainer.appendChild(browseroutput);

		let statbrowser = document.createElement("iframe");
		statbrowser.style.position = "absolute";
		statbrowser.style.right = "64px";
		statbrowser.style.top = "0px";
		statbrowser.id = "control-statbrowser";
		statbrowser.style.width = "400px";
		statbrowser.style.height = "350px";
		statbrowser.style.border = "none";
		document.body.appendChild(statbrowser);

		let tooltip_elem = document.createElement("iframe");
		tooltip_elem.style.position = "absolute";
		tooltip_elem.style.display = "none";
		tooltip_elem.id = "control-tooltip";
		document.body.appendChild(tooltip_elem);

		document.addEventListener("pointerlockchange", () => {
			let action;
			if(document.pointerLockElement == this.gl_holder.canvas) {
				action = "gainPointerLock";
			} else {
				action = "losePointerLock";
			}
			this.output(encodeURIComponent(JSON.stringify({type: action})), "browseroutput:update");
		});
	}
	browseroutput_container : HTMLDivElement;

	async frameLoop() {
		let t1 = performance.now();
		while(!this.has_quit) {
			let t2 = await new Promise(requestAnimationFrame);
			this.time += (t2-t1)*0.01;
			this.gl_holder.frame(t2 - t1);
			this.ui.frame(t2-t1);
			this.sound_player.frame();
			t1 = t2;
		}
	}

	get_atom(id : number) : Atom {
		let atom = this.atom_map.get(id);
		if(atom) return atom;
		atom = new Atom(this, id);
		this.atom_map.set(id, atom);
		return atom;
	}

	get_turf(x=this.eye_x|0, y:number=this.eye_y|0, z:number=this.eye_z|0) {
		if(x < 0 || y < 0 || z < 0 || x >= this.maxx || y >= this.maxy || z >= this.maxz) return null;
		let id = x + ((y + z * this.maxy) * this.maxx) + 0x01000000;
		return this.get_atom(id);
	}

	resize(maxx:number, maxy:number, maxz:number) : void {
		if(maxx == this.maxx && maxy == this.maxy && maxz == this.maxz) return;
		let coord_map : [number,number,number,Atom][] = [];
		for(let [id, atom] of this.atom_map) {
			if((id & 0xFF000000) == 0x01000000) {
				this.atom_map.delete(id);
				if(this.maxx && this.maxy && this.maxz) {
					let coord_index = id & 0xFFFFFF;
					let x = coord_index % this.maxx;
					coord_index = (coord_index / this.maxx)|0;
					let y = coord_index % this.maxy;
					let z = (coord_index / this.maxy)|0;
					coord_map.push([x,y,z,atom]);
				}
			}
		}
		this.maxx = maxx;
		this.maxy = maxy;
		this.maxz = maxz;
		if(this.maxx && this.maxy && this.maxz) {
			for(let [x,y,z,atom] of coord_map) {
				if(x < this.maxx && y < this.maxy && z < this.maxz) {
					let new_id = ((z * this.maxy) + y) * this.maxx + x;
					new_id &= 0xFFFFFF;
					new_id |= 0x01000000;
					atom.full_id = new_id;
					this.atom_map.set(new_id, atom);
				}
			}
		}
	}

	handle_message = (e: MessageEvent) => {
		if(!(e.data instanceof ArrayBuffer)) return;
		let dp = new DataPointer(new Uint8Array(e.data));

		let msgtype = dp.read_int16(false);
		switch(msgtype) {
		case 0: {
			console.log("Quit " + dp.read_uint16());
			this.ui.set_status_overlay(`Disconnected by server\n${this.last_output}`);
			this.has_quit = true;
			this.websocket.close();
			break;
		} case 1: {
			let major = dp.read_uint32();
			let minor = dp.read_uint32();
			console.log(`BYOND Server ${major}.${minor}`);
			this.websocket.send(new MessageBuilder(1).write_uint8(0).write_string("127.0.0.1").write_string("").collapse());
			break;
		} case 14: {
			console.log("Cache list");
			let n = dp.read_uint16();
			let bytes = dp.read_uint32();
			for(let i = 0; i < n; i++) {
				let a = dp.read_uint32();
				let str = dp.read_string();
				let size = dp.read_uint32();
				//console.log(a, str, size);
			}
			break;
		} case 26: {
			console.log("Key event");
			if(dp.reached_end()) {
				this.ui.set_status_overlay(`Logging in...`);
				this.websocket.send(new MessageBuilder(26).write_string('-').collapse())
			} else {
				this.websocket.send(new MessageBuilder(183).collapse());
				this.command(`.e3d_webgl_stats ${JSON.stringify(JSON.stringify(get_webgl_stats()))}`);
			}
			break;
		} case 30: {
			console.log("Reset");
			break;
		} case 39: {
			let str = dp.read_string();
			if(str.endsWith("<br/>\n")) {
				str = str.substring(0, str.length - 6);
			}
			let ctrl = dp.reached_end() ? ":output" : dp.read_string();
			let id = dp.reached_end() ? 0 : dp.read_uint32();
			let len = dp.reached_end() ? 0 : dp.read_uint32();
			this.output(str, ctrl);
			break;
		} case 51: {
			this.image_changes(dp, false);
			break;
		} case 52: {
			while(!dp.reached_end()) {
				let id = dp.read_uint32as16() | 0xD000000;
				let image = this.atom_map.get(id);
				if(image) {
					image.loc = 0;
					this.active_images.delete(image);
					image.mark_dirty();
				}
			}
			break;
		} case 53: {
			this.image_changes(dp, true);
			break;
		} case 108: {
			let atom_id = dp.read_uint32();
			let flags = dp.read_uint8();
			let atom = this.atom_map.get(atom_id);
			if(atom) {
				atom.flick = {
					icon: (flags & 1) ? dp.read_uint32as16() : null,
					icon_state: (flags & 2) ? dp.read_utf_string() : null,
					time: this.time,
					duration: 0
				};
				let icon_thingy = this.icons.get((atom.flick.icon ?? atom.appearance?.icon)!);
				if(icon_thingy) {
					let icon_state = icon_thingy.get_icon_state(atom.flick.icon_state ?? atom.appearance?.icon_state ?? "");
					if(icon_state) {
						atom.flick.duration = icon_state.total_delay;
					}
				}
				atom.mark_dirty();
			}
			break;
		} case 118: {
			this.movable_changes(dp, true);
			break;
		} case 176: {
			let value = this.read_value(dp);
			let target = dp.read_string();
			if(value == null) {
				let control = document.getElementById("window-" + target);
				if(control) control.style.display = "none";
			}
			break;
		} case 207: {
			this.gl_holder.num_icon_sends++;
			let icon = Icon.from_message(dp);
			if(!this.icons.has(icon.id))
				this.icons.set(icon.id, icon);
			break;
		} case 211: case 212: case 213: {
			let desc="",title="",default_choice="",type=0,id:number;
			let can_cancel = true;
			if(msgtype == 213) {
				title = dp.read_utf_string();
				desc = dp.read_utf_string();
				type = dp.read_uint32();
				id = dp.read_uint32();
			} else if(msgtype == 212) {
				id = dp.read_uint32();
				desc = dp.read_utf_string();
				title = dp.read_utf_string();
				can_cancel = false;
			} else {
				id = dp.read_uint32();
				desc = dp.read_utf_string();
				title = dp.read_utf_string();
				default_choice = dp.read_utf_string();
				type = dp.read_uint32();
				can_cancel = !!(type * 0x80);
			}
			let num_choices = !dp.reached_end() ? dp.read_uint16() : 0;
			let choices : string[] = [];
			for(let i = 0; i < num_choices; i++) choices.push(dp.read_utf_string());

			let wnd = this.create_window();
			document.body.appendChild(wnd);
			let form = document.createElement("form");
			form.classList.add("prompt-form");
			wnd.appendChild(form);
			wnd.style.width = "auto";
			wnd.style.height = "auto";
			wnd.querySelector(".titlebar-text")!.textContent = title;
			let desc_div = document.createElement("div");
			desc_div.style.whiteSpace = "pre-wrap";
			desc_div.textContent = desc;
			form.appendChild(desc_div);
			if(msgtype == 212) {
				let buttons_div = document.createElement("div");
				form.appendChild(buttons_div);
				let buttons : HTMLInputElement[] = [];
				for(let choice of choices) {
					let button = document.createElement("input");
					button.type = "submit";
					button.value = choice;
					buttons_div.appendChild(button);
					buttons.push(button);
				}
				form.addEventListener("submit", (e) => {
					e.preventDefault();
					wnd.parentElement?.removeChild(wnd);
					let msg = new MessageBuilder(214);
					msg.write_uint32(id);
					msg.write_string((e.submitter as HTMLInputElement)?.value ?? buttons[0].value);
					this.websocket.send(msg.collapse());
				});
				(document.activeElement as HTMLElement|undefined)?.blur?.();
				(buttons_div.children[0] as HTMLElement)?.focus();
			} else {
				let input : HTMLInputElement|HTMLTextAreaElement|HTMLSelectElement;
				if(choices.length) {
					input = document.createElement("select");
					input.size = 15;
					for(let choice of choices) {
						let option = document.createElement("option");
						option.value = choice;
						option.textContent = choice;
						if(choice == default_choice) option.defaultSelected = true;
						input.appendChild(option);
					}
					if(!input.value) {
						let first = (input.children[0] as HTMLOptionElement);
						if(first) {
							first.defaultSelected = true;
							first.selected = true;
						}
					}
				} else if(type & 0x800) {
					can_cancel = false;
					input = document.createElement("textarea");
					input.cols = 50;
					input.rows = 15;
				} else {
					input = document.createElement("input");
					if(type & 0x20000) {
						input.type = "color";
					} else if(type & 0x610) {
						input.type = "file";
						if(!(type & 0x10)) {
							let accept : string[] = [];
							if(type & 0x200) {
								accept.push("image/png,image/gif,image/jpeg,image/bmp,.dmi");
							} else if(type & 0x400) {
								accept.push("audio/*");
							}
							input.accept = accept.join(",");
						}
					} else if(type & 0x8000) {
						can_cancel = false;
						input.type = "password";
					} else if((type & 0x8) && !(type & 0x4)) {
						input.type = "number";
						input.step = "any";
					} else {
						can_cancel = false;
						input.type = "text";
					}
					if(default_choice) {
						if(input.type == "color" && default_choice.length == 4) {
							let d = default_choice;
							input.value = d[0]+d[1]+d[1]+d[2]+d[2]+d[3]+d[3];
						} else {
							input.value = default_choice;
						}
					}
				}
				form.appendChild(input);
				(document.activeElement as HTMLElement|undefined)?.blur?.();
				input.focus();
				let buttons_elem = document.createElement("div");
				form.appendChild(buttons_elem);
				let ok_submit = document.createElement("input");
				ok_submit.type = "submit";
				ok_submit.value = "OK";
				buttons_elem.appendChild(ok_submit);
				let cancel_submit : HTMLInputElement|undefined;
				if(!can_cancel) wnd.classList.add("window-unclosable");
				if(can_cancel) {
					cancel_submit = document.createElement("input");
					cancel_submit.type = "submit";
					cancel_submit.value = "Cancel";
					buttons_elem.appendChild(cancel_submit);
				}
				wnd.querySelector(".titlebar-close")?.addEventListener("click", () => {
					cancel_submit?.click();
				});
				form.addEventListener("submit", (e) => {
					e.preventDefault();
					wnd.parentElement?.removeChild(wnd);
					let msg = new MessageBuilder(214);
					msg.write_uint32(id);
					if(cancel_submit && e.submitter == cancel_submit) {
						msg.write_string("");
					} else {
						msg.write_string(input.value);
					}
					this.websocket.send(msg.collapse());
				});
			}
			wnd.style.left = ((innerWidth / 2) - (wnd.clientWidth / 2) + (Math.random()*100-50)) + "px";
			wnd.style.top = ((innerHeight / 2) - (wnd.clientWidth / 2) + (Math.random()*100-50)) + "px";
			break;
		} case 222: {
			let reply_id = dp.read_uint32();
			let control = dp.read_utf_string();
			let num_options = dp.read_uint16();
			let opts : string[] = [];
			for(let i = 0; i < num_options; i++) {
				opts.push(dp.read_utf_string());
			}
			let answer = [...this.winget(control, opts)];
			let replymsg = new MessageBuilder(222);
			replymsg.write_uint32(reply_id);
			replymsg.write_uint16(answer.length);
			for(let [key,val] of answer) {
				replymsg.write_utf_string(key);
				replymsg.write_utf_string(val);
			}
			this.websocket.send(replymsg.collapse());
			break;
		} case 223: {
			this.sound_player.play_sound(SoundCommand.from_msg(dp));
			break;
		} case 225: {
			let id = 0;
			if(!dp.reached_end()) id = dp.read_uint8();
			this.websocket.send(new MessageBuilder(225).write_uint8(id).collapse());
			break;
		} case 229: {
			let winset_count = dp.read_uint16();
			for(let i = 0; i < winset_count; i++) {
				let control = dp.read_utf_string();
				let num_keyvals = dp.read_uint16();
				let keyvals = new Map<string, string>();
				for(let j = 0; j < num_keyvals; j++) {
					let key = dp.read_utf_string();
					let val = dp.read_utf_string();

					keyvals.set(key, val);
				}
				this.winset(control, keyvals);
			}
			break;
		} case 240: {
			let anim = Animation.from_msg(dp, this.appearance_map);
			let atom = this.atom_map.get(anim.atom_id);
			if(atom) {
				if(anim) {
					anim.merge_fixup(this.time, atom.animation);
					atom.animation = anim;
				} else {
					atom.animation = null;
				}
				atom.mark_dirty();
			}
			break;
		} case 243: {
			let file = dp.read_utf_string();
			let opts : Map<string, string> = new Map([["window", dp.read_utf_string()]]);
			let opts_count = dp.read_uint16();
			for(let i = 0; i < opts_count; i++) {
				let key = dp.read_utf_string();
				let val = dp.read_utf_string();
				opts.set(key, val);
			}
			this.browse(file, opts);
			break;
		} case 247: {
			let appearance = parse_appearance(dp, this.appearance_map);
			this.appearance_map.set(appearance.id, appearance);
			break;
		} case 248: {
			this.resize(dp.read_uint16(), dp.read_uint16(), dp.read_uint16());
			console.log("Map size: ", this.maxx, this.maxy, this.maxz);
			let view_width, view_height;
			console.log("Tile/icon sizes", view_width = dp.read_uint16(), view_height = dp.read_uint16(), dp.read_uint16(), dp.read_uint16());
			console.log("Format", dp.read_uint8());
			console.log("Map dir", dp.read_uint8());
			console.log("Home", dp.read_uint16(), dp.read_uint16());
			console.log("Draw View", dp.read_uint16(), dp.read_uint16());

			this.gl_holder.draw_dist = Math.min(view_width, view_height) / 2;
			break;
		} case 249: {
			console.debug("Turf block:");
			let old_id = dp.read_uint32();
			let old_x = (old_id & 0xFFFFFF) % this.maxx;
			let old_y = ((old_id & 0xFFFFFF) / this.maxx)|0 % this.maxy;
			let old_width = old_id ? dp.read_uint16() : 0;
			let old_height = old_id ? dp.read_uint16() : 0;
			console.debug("  old", old_x, old_y, old_width, old_height);
			let new_id = dp.read_uint32();
			let new_x = (new_id & 0xFFFFFF) % this.maxx;
			let new_y = ((new_id & 0xFFFFFF) / this.maxx)|0 % this.maxy;
			let new_width = new_id ? dp.read_uint16() : 0;
			let new_height = new_id ? dp.read_uint16() : 0;
			let z = ((new_id & 0xFFFFFF) / this.maxx / this.maxy) | 0;
			this.eye_z = z;
			console.debug("  new", new_x, new_y, new_width, new_height);
			if(!new_id) return 0;
			let turf_order : number[] = [];
			let turf_id_ctr = new_id;
			for(let y = new_y; y < new_y+new_height; y++) {
				for(let x = new_x; x < new_x+new_width; x++) {
					if(x < old_x || x >= old_x+old_width || y < old_y || y >= old_y+old_height) {
						turf_order.push(turf_id_ctr);
					}
					turf_id_ctr++;
				}
				turf_id_ctr += this.maxx-new_width
			}
			let l1 = dp.read_rle(turf_order.length);
			let l2 = dp.read_rle(turf_order.length);
			for(let i = 0; i < turf_order.length; i++) {
				let turf = this.get_atom(turf_order[i]);
				turf.appearance = this.appearance_map.get(l1[i]) ?? null;
				turf.loc = l2[i] | 0x04000000;
				turf.mark_dirty();
			}
			if(!dp.reached_end()) {
				console.warn("Did not consume whole turf block!");
			}
			break;
		} case 250: {
			let type = dp.read_uint8();
			let count = dp.read_uint16();
			if(type == 0) {
				for(let i = 0; i < count; i++) {
					let turf = dp.read_uint32as16();
				}
				break;
			}
			let turfs : Atom[] = [];
			for(let i = 0; i < count; i++) {
				turfs.push(this.get_atom(dp.read_uint32as16() | 0x1000000));
			}
			let appearance_ids = dp.read_rle(turfs.length);
			for(let i = 0; i < turfs.length; i++) {
				let turf = turfs[i];
				let appearance = this.appearance_map.get(appearance_ids[i]) ?? null;
				if(turf.appearance != appearance) {
					turf.appearance = appearance;
					turf.mark_dirty();
				}
			}
			let area_ids = dp.read_rle(turfs.length);
			for(let i = 0; i < turfs.length; i++) {
				let turf = turfs[i];
				let area_id = area_ids[i] | 0x4000000;
				if(turf.loc != area_id) {
					turf.loc = area_id;
					turf.mark_dirty();
				}
			}
			break;
		} case 251: {
			this.ui.set_status_overlay(null);
			console.debug("Movable change");
			let flags = dp.read_uint8();
			console.debug(flags.toString(2));
			if(flags & 0x02) {
				dp.read_int16(), dp.read_int16(), dp.read_int16(), dp.read_int16();
				dp.read_uint8(), this.eye_bits = dp.read_uint32(), this.eye_glide_size = dp.read_float();
				this.eye_x = dp.read_int16();
				this.eye_y = dp.read_int16();
				this.gl_holder.camera_pos = this.gl_holder.target_camera_pos;
				this.gl_holder.target_camera_pos = [this.eye_x + 0.5, this.eye_y + 0.5, this.eye_height]
			}
			let had_zoom = !!(this.eye_sight & 0x8000);
			if(flags & 0x20) {
				this.eye_sight = dp.read_uint8();
			}
			if(flags & 0x40) {
				console.debug(this.read_value(dp));
			}
			if(flags & 0x80) {
				let flags2 = dp.read_uint8();
				console.debug("flags2", flags2);
				if(flags2 & 1) {
					console.debug("See in dark:", dp.read_uint8());
				}
				if(flags2 & 2) {
					let new_see_invisible = dp.read_uint8();
					let min = Math.min(new_see_invisible, this.eye_see_invisible);
					let max = Math.max(new_see_invisible, this.eye_see_invisible);
					this.eye_see_invisible = new_see_invisible;
					for(let atom of this.atom_map.values()) {
						if(atom.appearance && atom.appearance.invisibility > min && atom.appearance.invisibility <= max) {
							atom.mark_dirty();
						}
					}
				}
				if(flags2 & 4) {
					// fun fact the actual server-side var only has 16 bits
					this.eye_sight = dp.read_uint32();
				}
				if(flags2 & 8) {
					console.debug("eye pixels:", dp.read_int16(), dp.read_int16(), dp.read_int16(), dp.read_int16());
				}
				if(flags2 & 0x10) {
					console.debug ("eye px:", dp.read_int16(), dp.read_int16());
				}
				if(flags2 & 0x20) {
					console.debug("my px:", dp.read_int16(), dp.read_int16(), dp.read_int16(), dp.read_int16());
				}
			}
			if((this.eye_sight & 0x8000) && !had_zoom) {
				this.gl_holder.camera_zoom = 1;
			}
			this.movable_changes(dp, false);
			break;
		} default:
			console.debug("Message " + msgtype);
			break;
		}
	}

	resolve_control(control : string) : HTMLElement|null {
		if(control.includes(".")) {
			let [part1, part2] = control.split(".");
			return document.querySelector(`#window-${CSS.escape(part1)} #control-${CSS.escape(part2)}`);
		} else {
			return document.getElementById("control-"+control) || document.getElementById("window-"+control);
		}
	}

	last_output : string = "";
	output(str : string, ctrl : string) {
		if(ctrl == "e3d:test_env") {
			this.is_test_env = true;
			return;
		}
		if(ctrl == ":output") {
			this.last_output = str;
		} else {
			let ctrl_split = ctrl.split(":");
			let ctrl_name = ctrl_split[0];
			let ctrl_elem = this.resolve_control(ctrl_name);
			if(ctrl_split.length > 1 && ctrl_elem instanceof HTMLIFrameElement) {
				ctrl_elem.contentWindow?.postMessage(`output:${ctrl_split[1]};${str}`, "*");
			} else if(!ctrl_elem) {
				console.warn("Could not resolve control ", ctrl_name);
			}
		}
	}

	winset_macro(control : string, opts : Map<string, string>) {
		let macro = this.macros.get(control);
		if(!macro && opts.get("parent") == "default") {
			macro = new Map();
			this.macros.set(control, macro);
		}
		if(!macro) return;
		if(opts.get("parent") == "null") {
			this.macros.delete(control);
			return;
		}
		for(let [k,v] of opts) {
			macro.set(k, v);
		}
	}

	winset(control : string, opts : Map<string, string>) {
		if(control.startsWith("default.")) {
			this.winset_macro(control.substring(8), opts);
			return;
		}
		if(this.macros.has(control) || opts.get("parent") == "default") {
			this.winset_macro(control, opts);
			return;
		}
		if(!control) {
			let command = opts.get("command");
			if(command) this.command(command);
			let ui_scale = opts.get("ui-scale");
			if(ui_scale) {
				this.ui.update_zoom(+ui_scale);
			}
			let eye_height = opts.get("e3d-eye-height");
			if(eye_height) {
				this.eye_height = +eye_height;
				this.gl_holder.target_camera_pos[2] = this.eye_height;
			}
		}
		let resolved = this.resolve_control(control);
		if(resolved) {
			console.log("winset", control, ...[...opts].map(a => `${a[0]}=${a[1]}`));
			let pos = opts.get("pos");
			if(pos) {
				let split = pos.split(",");
				let x = +split[0];
				let y = +split[1];
				if(x == x && y == y) {
					x = Math.max(0, Math.min(window.innerWidth-100, x));
					y = Math.max(0, Math.min(window.innerHeight-100, y));
					resolved.style.left = x + "px";
					resolved.style.top = y + "px";
				}
			}
			let size = opts.get("size");
			if(size && size != "0x0") {
				let split = size.split("x");
				let w = +split[0];
				let h = +split[1];
				if(w == w && h == h) {
					resolved.style.width = w+"px";
					resolved.style.height = h+"px";
				}
			}
			let is_visible = opts.get("is-visible");
			if(is_visible) {
				let visibility = is_visible == "true";
				resolved.style.display = visibility ? "unset" : "none";
			}
			let clip_path = opts.get("clip-path");
			if(clip_path) {
				if(control == "browseroutput") {
					resolved.style.setProperty("--nohover-clip", clip_path);
				} else {
					resolved.style.clipPath = clip_path;
				}
			}
		}
	}

	macros = new Map<string, Map<string, string>>();

	winget(control : string, opts : string[]) : Map<string, string> {
		let answer = new Map<string,string>();
		if(control.includes(";")) {
			for(let subcontrol of control.split(";")) {
				for(let [key, val] of this.winget(subcontrol, opts)) {
					answer.set(`${subcontrol}.${key}`, val);
				}
			}
		} else if(control.startsWith("default.")) {
			let macro_id = control.substring(8);
			if(macro_id == "*") {
				for(let macro of this.macros.keys()) {
					for(let [key, val] of this.winget(`default.${macro}`, opts)) {
						answer.set(`default.${macro}.${key}`, val);
					}
				}
			} else {
				let macro = this.macros.get(macro_id);
				if(macro) {
					for(let opt of opts) {
						if(opt == "parent") {
							answer.set(opt, "default");
						} else {
							let val = macro.get(opt);
							answer.set(opt, ""+val);
						}
					}
				}
			}
		} else {
			let ctrl_elem : HTMLElement|null = this.resolve_control(control);
			if(!ctrl_elem) return answer;
			for(let opt of opts) {
				switch(opt) {
					case "type": {
						let type = ctrl_elem.tagName;
						if(ctrl_elem instanceof HTMLIFrameElement) type = "BROWSER";
						else if(ctrl_elem.id.startsWith("window-")) type = "WINDOW";
						answer.set("type", type);
						break;
					}
					case "pos": {
						answer.set("pos.x", (parseInt(ctrl_elem.style.left ?? "0")).toString())
						answer.set("pos.y", (parseInt(ctrl_elem.style.top ?? "0")).toString())
						break;
					}
				}
			}
		}
		return answer;
	}

	browse(file : string, opts : Map<string,string>) {
		if(!+(opts.get("display")??1)) return;
		console.log(file, opts);
		let control = opts.get("window");
		if(!control) return;
		let browserwindow = document.getElementById(`window-${control}`);
		let resolved = browserwindow?.querySelector('#control-browser') as HTMLElement|null;
		if(!resolved) {
			resolved = this.resolve_control(control);
		}
		if(resolved && !(resolved instanceof HTMLIFrameElement)) return;
		let browser : HTMLIFrameElement|null = resolved;
		let isnew = false;
		if(!browser) {
			browser = document.createElement("iframe");
			if(!browserwindow) {
				browserwindow = this.create_window(control);
				document.body.appendChild(browserwindow);
				isnew = true;
			}
			browser.id = `control-browser`;
			browser.style.width = "100%"; browser.style.height = "100%"; browser.style.top = "0px"; browser.style.left = "0px";
			browser.style.border = "none";
			browser.style.position = "absolute";
			browser.style.backgroundColor = "white";
			browserwindow.appendChild(browser);
		}
		if(browserwindow) {
			browserwindow.style.display = "unset";
			let titlebar_prop = opts.get("titlebar");
			if(titlebar_prop) {
				if(titlebar_prop == "1") browserwindow.classList.remove("window-no-titlebar");
				else browserwindow.classList.add("window-no-titlebar");
			}
			let size = opts.get("size");
			if(size) {
				let parts = size.split("x");
				browserwindow.style.width = parts[0] + "px";
				browserwindow.style.height = parts[1] + "px";
			}
			if(isnew) {
				browserwindow.style.left = Math.max(window.innerWidth / 2 - browserwindow.clientWidth / 2 + Math.random()*100-50, 0) + "px";
				browserwindow.style.top = Math.max(window.innerHeight / 2 - browserwindow.clientHeight / 2 + Math.random()*100-50, 0) + "px";
			}
			let can_close = opts.get("can_close");
			if(can_close) {
				if(can_close == "1") browserwindow.classList.remove("window-unclosable");
				if(can_close == "0") browserwindow.classList.add("window-unclosable");
			}
		}
		browser.sandbox.add("allow-scripts");
		browser.sandbox.add("allow-same-origin");
		browser.sandbox.add("allow-forms");
		browser.src = file;
	}

	create_window(id? : string) {
		let w = document.createElement("div");
		if(id) w.id = `window-${id}`;
		w.style.width = "400px";
		w.style.height = "400px";
		w.style.left = "0px";
		w.style.top = "0px";
		w.classList.add("window");
		
		let titlebar = document.createElement("div");
		titlebar.classList.add("titlebar");
		w.appendChild(titlebar);
		let titlebar_text = document.createElement("span");
		titlebar_text.classList.add("titlebar-text");
		titlebar.appendChild(titlebar_text);
		titlebar.addEventListener("mousedown", (e1) => {
			if((e1.target as HTMLElement).closest("button")) return;
			e1.preventDefault();
			document.body.classList.add("dragging");
			let mousemove = (e2 : MouseEvent) => {
				let dx = e2.clientX - e1.clientX;
				let dy = e2.clientY - e1.clientY;
				let x = parseFloat(w.style.left) || 0;
				let y = parseFloat(w.style.top) || 0;
				x += dx;
				y += dy;
				w.style.left = x+"px";
				w.style.top = y+"px";
				e1 = e2;
			};
			let mouseup = () => {
				document.body.classList.remove("dragging");
				window.removeEventListener("mousemove", mousemove);
				window.removeEventListener("mouseup", mouseup);
			};
			window.addEventListener("mousemove", mousemove);
			window.addEventListener("mouseup", mouseup);

		});

		let closer = document.createElement("button");
		closer.classList.add("titlebar-close");
		titlebar.appendChild(closer);
		closer.addEventListener("click", () => {
			w.style.display = "none";
		})
		return w;
	}

	active_images = new Set<Atom>();
	image_changes(dp : DataPointer, is_update : boolean) {
		let id = dp.read_uint32as16() | 0xD000000;
		let appearance = this.appearance_map.get(dp.read_uint32as16());
		let image = this.get_atom(id);
		image.appearance = appearance ?? null;
		image.loc = dp.read_uint32();
		if(image.loc && image.appearance?.plane != 19) this.active_images.add(image);
		else this.active_images.delete(image);
		image.mark_dirty();
	}

	movable_changes(dp : DataPointer, is_screen : boolean) {
		let start_i = dp.i
		let count = dp.read_uint16();
		for(let i = 0; i < count; i++) {
			let flags = is_screen ? dp.read_uint8() : dp.read_uint16();
			let id = dp.read_uint32();
			let atom : Atom|undefined = this.get_atom(id);
			if(atom.type == 1) {
				// vis_contents with turfs causes BYOND to send the ID of the turf
				// when sending the movables within its contents list
				atom = undefined;
			}
			if(!flags) {
				if(atom) {
					if(is_screen) atom.enabled_screen = false;
					else atom.enabled = false;
					atom.mark_dirty();
				}
				continue;
			}
			if(atom) {
				if(is_screen) atom.enabled_screen = true;
				else atom.enabled = true;
				if((flags & 3) == 1) {
					atom.reset(); // 
				}
			}
			if(flags & 4) {
				let loc = dp.read_uint32();
				if(atom) atom.glide_to_loc(loc);
			}
			if(flags & 8) {
				let appearance = dp.read_uint32as16();
				if(atom) atom.appearance = this.appearance_map.get(appearance) ?? null;
			}
			if(flags & 16) {
				let px = dp.read_int16();
				let py = dp.read_int16();
				let pw = dp.read_int16();
				let pz = dp.read_int16();
				if(atom) {
					atom.pixel_x = px;
					atom.pixel_y = py;
					atom.pixel_w = pw;
					atom.pixel_z = pz;
				}
			}
			if(flags & 32) {
				dp.read_int16();
				dp.read_int16();
				dp.read_float();
			}
			if(flags & 64) {
				dp.read_int16();
				dp.read_int16();
				dp.read_uint16();
				dp.read_uint16();
			}
			if(flags & 128) {
				dp.read_uint8();
			}
			if(flags & 256) {
				let vis_contents_len = dp.read_uint16();
				let vis_contents : number[] = [];
				for(let i = 0; i < vis_contents_len; i++) {
					let id = dp.read_uint32();
					vis_contents.push(id);
				}
				if(atom) atom.vis_contents = vis_contents.length ? vis_contents : null;
			}
			if(atom) {
				atom.mark_dirty();
				if(atom.enabled_screen) {
					this.ui.update_atom(atom);
				}
			}
		}
		if(!dp.reached_end()) console.warn("Movable changes - did not reach end", dp, start_i);
	}

	read_value(dp : DataPointer) : ByondValue {
		let type = dp.read_uint8();
		if(type == 0) {
			return null;
		} else if(type == 0x2A) {
			return dp.read_float();
		} else if(type == 2) {
			let id = dp.read_uint32();
			let appearance = dp.read_uint32as16();
			let atom = this.get_atom(id);
			atom.appearance = this.appearance_map.get(appearance) ?? null;
			atom.mark_dirty();
			console.log("read_value ", id.toString(16), appearance, atom);
			return atom;
		} else if(type == 6) {
			return dp.read_utf_string();
		} else if(type == 15) {
			let arr : ByondValue[] = [];
			arr.length = dp.read_uint16();
			for(let i = 0; i < arr.length; i++) {
				arr[i] = this.read_value(dp);
			}
			return arr;
		} else {
			throw new Error("Unrecognized value type " + type);
		}
	}

	command(str : string) : void {
		if(str.startsWith(".output ")) {
			let output_parts = str.split(" ");
			let ctrl = output_parts[1];
			let msg = output_parts.slice(2).join(" ");
			this.output(msg, ctrl);
		}
		this.websocket.send(new MessageBuilder(209).write_string(str).collapse());
	}
	topic(str : string) : void {
		this.websocket.send(new MessageBuilder(129).write_string(str).collapse());
	}

	send_angle = despam_promise(async () => {
		this.command(`.e3d_setangle ${+(this.gl_holder.camera_yaw * 180 / Math.PI).toFixed(1)}`)
		await new Promise(resolve => setTimeout(resolve, 200));
	});

	send_click(event_id : number, atom_id : number, last_atom_id : number = 0, event : MouseEvent, pos? : vec2, screen_pos? : vec2, icon_pos? : vec2, params : string = "") {
		let msg = new MessageBuilder(215);
		msg.write_uint8(0).write_uint8(event_id);
		let flags = event.buttons & 7;
		if(event.shiftKey) flags |= 16;
		if(event.ctrlKey) flags |= 8;
		if(event.altKey) flags |= 32;
		msg.write_uint8(flags);
		msg.write_uint32(atom_id);
		if(event_id == 9) {
			msg.write_int16(Math.round(pos ? pos[0] : 0)).write_int16(Math.round(pos ? pos[1] : 0));
		}
		msg.write_int16(screen_pos ? screen_pos[0] : 32768).write_int16(screen_pos ? screen_pos[1] : 32768);
		msg.write_int16(icon_pos ? icon_pos[0] : 0).write_int16(icon_pos ? icon_pos[1] : 0);
		msg.write_uint8(0);
		msg.write_string("");
		msg.write_string("map");
		msg.write_string(params);
		this.websocket.send(msg.collapse());
	}

	resource_blobs = new Map<string, Promise<Blob>>();
	get_resource_blob(resource : number|string) : Promise<Blob> {
		let promise = this.resource_blobs.get(resource+"");
		if(!promise) {
			promise = fetch("cache/" + resource).then(response => {
				if(!response.ok) return Promise.reject(new Error(`${response.status} ${response.statusText}`));
				return response.blob();
			});
			this.resource_blobs.set(resource+"", promise);
		}
		return promise;
	}

	js_keycode_to_byond(num : number) {
		if((num >= 65 && num <= 90) || (num >= 48 && num <= 57)) {
			return String.fromCharCode(num);
		} else if(num >= 112 && num <= 123) {
			return `F${num-111}`;
		} else if(num >= 96 && num <= 105) {
			return `Numpad${num-96}`;
		}
		else {
			switch(num) {
				case 17:
					return "Ctrl";
				case 18:
					return "Alt";
				case 16:
					return "Shift";
				case 37:
					return "West";
				case 38:
					return "North";
				case 39:
					return "East";
				case 40:
					return "South";
				case 45:
					return "Insert";
				case 46:
					return "Delete";
				case 36:
					return "Northwest";
				case 35:
					return "Southwest";
				case 33:
					return "Northeast";
				case 34:
					return "Southeast";
				case 188:
					return ",";
				case 190:
					return ".";
				case 189:
					return "-";
			}
		}
	}
}

export type ByondValue = number|string|null|Atom|ByondValue[];

new ByondClient();
