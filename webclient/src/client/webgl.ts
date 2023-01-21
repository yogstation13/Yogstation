import { glMatrix, mat4, vec2, vec3, vec4 } from "gl-matrix";
import { ByondClient } from ".";
import { Atom } from "./atom";
import { Icon } from "./icon";
import { LightingHolder } from "./lighting";
import { BatchRenderPlan } from "./render_types";
import { array_to_buffer, bind_shader_3d } from "./shader";

glMatrix.setMatrixArrayType(Array);

export class GlHolder {
	canvas : HTMLCanvasElement;
	gl : WebGLRenderingContext;
	gl2 : WebGL2RenderingContext|null;
	lighting_holder = new LightingHolder(this);
	mouse_framebuffer : WebGLFramebuffer|null;
	stats_elem : HTMLElement;
	constructor(public client : ByondClient) {
		this.canvas = document.createElement("canvas");
		this.canvas.style.backgroundColor = "black";
		this.canvas.style.width = "100%";
		this.canvas.style.height = "100%";
		this.canvas.style.left = "0px";
		this.canvas.style.top = "0px";
		this.canvas.style.position = "absolute";
		document.body.appendChild(this.canvas);
		let gl2 = this.canvas.getContext("webgl2");

		let gl = gl2 ?? this.canvas.getContext("webgl");
		if(!gl) throw new Error("No WebGL!");
		this.gl = gl;
		this.gl2 = gl2;

		this.stats_elem = document.createElement("pre");
		this.stats_elem.style.background = "rgba(0,0,0,0.5)"
		this.stats_elem.style.pointerEvents = "none";
		this.stats_elem.style.position = "absolute";
		this.stats_elem.style.left = "0px";
		this.stats_elem.style.top = "0px";
		this.stats_elem.style.padding = "10px";
		this.stats_elem.style.color = "white";
		document.body.appendChild(this.stats_elem);

		this.mouse_framebuffer = gl.createFramebuffer();
		gl.bindFramebuffer(gl.FRAMEBUFFER, this.mouse_framebuffer);
		let mouse_tex = gl.createTexture();
		gl.bindTexture(gl.TEXTURE_2D, mouse_tex);
		gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, 1, 1, 0, gl.RGBA, gl.UNSIGNED_BYTE, null);
		gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, mouse_tex, 0);
		let mouse_depth = gl.createRenderbuffer();
		gl.bindRenderbuffer(gl.RENDERBUFFER, mouse_depth);
		gl.renderbufferStorage(gl.RENDERBUFFER, gl.DEPTH_COMPONENT16, 1, 1);
		gl.framebufferRenderbuffer(gl.FRAMEBUFFER, gl.DEPTH_ATTACHMENT, gl.RENDERBUFFER, mouse_depth);
		gl.bindRenderbuffer(gl.RENDERBUFFER, null);
		gl.bindTexture(gl.TEXTURE_2D, null);
		gl.bindFramebuffer(gl.FRAMEBUFFER, null);
	}

	last_positions : Float32Array|undefined;

	frame_counter : number = 0;
	frame_accum : number = 0;
	fps : number = 0;
	num_icon_sends : number = 0;

	frame(dt : number) {
		this.frame_counter++;
		this.frame_accum += dt;
		if(this.frame_accum >= 1000) {
			this.fps = this.frame_counter / this.frame_accum * 1000;
			this.frame_accum = 0;
			this.frame_counter = 0;
		}
		let num_drawcalls = 0;
		let target_pos : vec3 = this.target_camera_pos;
		let target_pos_off = Math.max(Math.abs(target_pos[0]-this.camera_pos[0]), Math.abs(target_pos[1]-this.camera_pos[1]), Math.abs(target_pos[2]-this.camera_pos[2]));
		if(target_pos_off > 1.05) {
			this.camera_pos = target_pos;
		} else if(target_pos_off > 0) {
			target_pos = vec3.subtract(vec3.create(), target_pos, this.camera_pos);
			if(this.client.eye_bits & 0x200000) {
				let travelDist = dt/50 * (this.client.eye_glide_size || 1) / 32;
				for(let i = 0; i < 3; i++) {
					target_pos[i] = Math.max(-travelDist, Math.min(travelDist, target_pos[i]));
				}
			} else {
				let dist = vec3.length(target_pos);
				let travelDist = dt / 50 * (this.client.eye_glide_size || 1) / 32;
				if(travelDist < dist) {
					vec3.scale(target_pos, target_pos, travelDist / dist);
				}
			}
			vec3.add(this.camera_pos, this.camera_pos, target_pos);
		}
		let new_secondyaw = this.camera_pitch <= -Math.PI/2 ? Math.max(-0.3, Math.min(0.3, this.camera_secondyaw)) : 0;
		this.camera_yaw += this.camera_secondyaw - new_secondyaw;
		this.camera_pitch = Math.max(-2, Math.min(Math.PI/2, this.camera_pitch));
		if(this.camera_yaw < 0) this.camera_yaw += Math.PI*2;
		if(this.camera_yaw > Math.PI*2) this.camera_yaw -= Math.PI*2;
		this.camera_secondyaw = new_secondyaw;

		const gl = this.gl;
		let canvas_width = Math.floor(this.canvas.clientWidth * devicePixelRatio);
		let canvas_height = Math.floor(this.canvas.clientHeight * devicePixelRatio);
		if(this.canvas.width != canvas_width) this.canvas.width = canvas_width;
		if(this.canvas.height != canvas_height) this.canvas.height = canvas_height;
		
		gl.viewport(0,0,this.gl.drawingBufferWidth, this.gl.drawingBufferHeight);
		gl.clearColor(0,0,0, 1);
		gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
		
		const yFov = 1;

		let proj = this.proj_matrix;
		let view = this.view_matrix;
		let frustumHeight = Math.tan(yFov / 2);
		let frustumWidth = frustumHeight * canvas_width / canvas_height
		mat4.perspective(proj, yFov, canvas_width/canvas_height, 0.2, 1000);
		mat4.rotateX(proj, proj, -Math.PI/2);
		mat4.identity(view);
		mat4.translate(view, view, [0, this.camera_actual_zoom, 0]);
		mat4.rotateZ(view, view, -this.camera_secondyaw);
		mat4.rotateX(view, view, -this.camera_pitch);
		mat4.rotateZ(view, view, -this.camera_yaw);
		mat4.translate(view, view, vec3.scale(vec3.create(), this.camera_pos, -1));
		mat4.invert(this.inv_view_matrix, this.view_matrix);
		let act_camera_pos = this.inv_view_matrix.slice(12, 15) as vec3;

		let instance_lists : Map<number, BatchRenderPlan[]> = new Map();
		let sorted_instance_lists : BatchRenderPlan[] = [];
		let extended_draw_dist = this.draw_dist + 1.9;
		let turf_x1 = Math.floor(this.camera_pos[0]-extended_draw_dist);
		let turf_y1 = Math.floor(this.camera_pos[1]-extended_draw_dist);
		let turf_x2 = Math.ceil(this.camera_pos[0]+extended_draw_dist);
		let turf_y2 = Math.ceil(this.camera_pos[1]+extended_draw_dist);
		let handle_thing = (thing:Atom, x:number, y:number) => {
			let plan = thing.get_render_plan(dt);
			if(!plan) return;
			for(let item of plan) {
				if(item.alpha_sort_focus) {
					item._alpha_sort_dist = vec3.squaredDistance(act_camera_pos, item.alpha_sort_focus) + item.alpha_sort_bias;
					sorted_instance_lists.push(item);
				} else {
					let list = instance_lists.get(item.icon);
					if(!list) {
						list = [];
						instance_lists.set(item.icon, list);
					}
					list.push(item);
				}
			}
		}
		for(let y = turf_y1; y < turf_y2; y++) for(let x = turf_x1; x < turf_x2; x++) {
			let turf = this.client.get_turf(x, y, this.client.eye_z);
			if(!turf) continue;
			handle_thing(turf, x, y);
			if(turf.contents) for(let thing of turf.contents) {
				handle_thing(thing, x, y);
			}
		}

		let combined_lists = [...instance_lists];
		combined_lists.sort((a,b) => (a[0] - b[0]));
		
		{
			sorted_instance_lists.sort((a,b) => ((b._alpha_sort_dist - a._alpha_sort_dist) || (a.icon - b.icon)));
			let current_sorted_batch : [number,BatchRenderPlan[]]|undefined;
			for(let item of sorted_instance_lists) {
				if(!current_sorted_batch || current_sorted_batch[0] != item.icon) {
					current_sorted_batch = [item.icon, [item]];
					combined_lists.push(current_sorted_batch);
				} else {
					current_sorted_batch[1].push(item);
				}
			}
		}

		let info = bind_shader_3d(gl);
		this.update_enabled_vertex_attribs([info.aPosition, info.aNormal, info.aColor, info.aUV, info.aSheetIndex, info.aBits]);
		gl.uniformMatrix4fv(info.viewMatrix, false, this.view_matrix);
		gl.uniformMatrix4fv(info.projMatrix, false, this.proj_matrix);
		gl.uniform3f(info.cameraPos, this.camera_pos[0], this.camera_pos[1], this.camera_pos[2]);
		gl.activeTexture(gl.TEXTURE1);
		gl.bindTexture(gl.TEXTURE_2D, this.lighting_holder.get_updated_texture());
		gl.uniform1i(info.lightTexture, 1);
		gl.uniform1f(info.lightWidth, this.lighting_holder.last_maxx);
		gl.uniform1f(info.lightHeight, this.lighting_holder.last_maxy);
		gl.uniform1f(info.drawDist, this.draw_dist);
		let lighting_pm_color = (this.client.ui.plane_masters.get(15)?.appearance?.color_alpha);
		gl.uniform1f(info.lightInfluence, lighting_pm_color == null ? 1 : ((lighting_pm_color >>> 24) / 255));
		gl.uniform1f(info.blind, +!!this.client.ui.blind_atom);
		gl.activeTexture(gl.TEXTURE0);
		gl.enable(gl.BLEND);
		gl.blendFuncSeparate(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA, gl.ZERO, gl.ONE);
		gl.depthMask(true);
		gl.enable(gl.DEPTH_TEST);
		gl.depthFunc(gl.LEQUAL);
		gl.enable(gl.CULL_FACE);
		gl.uniform1f(info.isIdPass, 0);

		let draw_list : [Icon, WebGLBuffer, number][] = [];

		for(let [icon, items] of combined_lists) {

			let icon_info = this.client.icons.get(icon & 0xFFFFFF);
			if(!icon_info) continue;

			if(!icon_info.texture) {
				let tex = icon_info.texture = gl.createTexture();
				gl.bindTexture(gl.TEXTURE_2D, tex);
				gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
				gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
				gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
				gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
				gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, 1, 1, 0, gl.RGBA, gl.UNSIGNED_BYTE, new Uint8Array([255,255,255,255]));
				this.client.get_resource_blob(icon_info.resource).then(blob => icon_info!.make_image(blob)).then(image => {
					gl.bindTexture(gl.TEXTURE_2D, tex);
					gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, image);
					gl.bindTexture(gl.TEXTURE_2D, null);
				}, () => {
					gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, 4, 4, 0, gl.RGBA, gl.UNSIGNED_BYTE, error_texture);
				})
			}
			gl.bindTexture(gl.TEXTURE_2D, icon_info.texture);

			gl.uniform1i(info.iconTexture, 0);
			gl.uniform1f(info.iconWidth, icon_info.width);
			gl.uniform1f(info.iconHeight, icon_info.height);
			gl.uniform1f(info.sheetWidth, icon_info.sheet_width);
			gl.uniform1f(info.sheetHeight, icon_info.sheet_height);

			let num_triangles = 0;
			for(let item of items) {
				num_triangles += item.triangle_count;
			}
			let attribs = new Float32Array(15*3*num_triangles);
			let iattribs = new Uint32Array(attribs.buffer);
			this.last_positions = attribs;
			let offset = 0;
			for(let item of items) {
				if(item.is_static && item.cached_data) {
					attribs.set(item.cached_data, offset);
					offset += item.cached_data.length;
					continue;
				}
				let prev_offset = offset;
				offset = item.write(attribs, iattribs, offset, icon_info, this.client.time, act_camera_pos, this.camera_yaw);
				if(item.is_static) item.cached_data = attribs.slice(prev_offset, offset);
			}

			let attribs_buf = array_to_buffer(gl, gl.ARRAY_BUFFER, iattribs, gl.STREAM_DRAW);

			if(attribs_buf) {
				gl.bindBuffer(gl.ARRAY_BUFFER, attribs_buf);
				gl.vertexAttribPointer(info.aPosition, 3, gl.FLOAT, false, 15*4, 0);
				gl.vertexAttribPointer(info.aNormal, 3, gl.FLOAT, false, 15*4, 3*4);
				gl.vertexAttribPointer(info.aColor, 4, gl.FLOAT, false, 15*4, 6*4);
				gl.vertexAttribPointer(info.aUV, 2, gl.FLOAT, false, 15*4, 10*4);
				gl.vertexAttribPointer(info.aSheetIndex, 1, gl.FLOAT, false, 15*4, 12*4);
				gl.vertexAttribPointer(info.aBits, 1, gl.FLOAT, false, 15*4, 14*4);
				let num_elems = Math.floor(offset/15/3)*3;
				gl.drawArrays(gl.TRIANGLES, 0, num_elems);
				draw_list.push([icon_info, attribs_buf, num_elems]);
				num_drawcalls++;
			}
		}

		if(!this.reading_mouse_hit) {
			let mousemove = this.client.ui.last_mousemove;
			let mouse_x = 0;
			let mouse_y = 0;
			if(mousemove && document.pointerLockElement != this.canvas) {
				let canvas_rect = this.canvas.getBoundingClientRect();
				mouse_x = ((mousemove.clientX - canvas_rect.x) / canvas_rect.width * 2 - 1) * frustumWidth;
				mouse_y = -((mousemove.clientY - canvas_rect.y) / canvas_rect.height * 2 - 1) * frustumHeight; 
			}
			gl.uniformMatrix4fv(info.viewMatrix, false, mat4.multiply(this.mouse_view_matrix, [
				1, 0, 0, 0,
				-mouse_x, 1, -mouse_y, 0,
				0, 0, 1, 0,
				0, 0, 0, 1
			], this.view_matrix));
			gl.uniform1f(info.isIdPass, 1);
			gl.disable(gl.BLEND);
			gl.bindFramebuffer(gl.FRAMEBUFFER, this.mouse_framebuffer);
			gl.viewport(0, 0, 1, 1);
			gl.clearColor(0,0,0,0);
			gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
			for(let [icon_info, attribs_buf, num_elems] of draw_list) {
				gl.bindTexture(gl.TEXTURE_2D, icon_info.texture);

				gl.uniform1i(info.iconTexture, 0);
				gl.uniform1f(info.iconWidth, icon_info.width);
				gl.uniform1f(info.iconHeight, icon_info.height);
				gl.uniform1f(info.sheetWidth, icon_info.sheet_width);
				gl.uniform1f(info.sheetHeight, icon_info.sheet_height);

				gl.bindBuffer(gl.ARRAY_BUFFER, attribs_buf);
				gl.vertexAttribPointer(info.aPosition, 3, gl.FLOAT, false, 15*4, 0);
				gl.vertexAttribPointer(info.aNormal, 3, gl.FLOAT, false, 15*4, 3*4);
				gl.vertexAttribPointer(info.aColor, 4, gl.UNSIGNED_BYTE, true, 15*4, 13*4);
				gl.vertexAttribPointer(info.aUV, 2, gl.FLOAT, false, 15*4, 10*4);
				gl.vertexAttribPointer(info.aSheetIndex, 1, gl.FLOAT, false, 15*4, 12*4);
				gl.vertexAttribPointer(info.aBits, 1, gl.FLOAT, false, 15*4, 14*4);
				gl.drawArrays(gl.TRIANGLES, 0, num_elems);
			}
			this.reading_mouse_hit = true;
			this.readPixelsAsync(0, 0, 1, 1, gl.RGBA, gl.UNSIGNED_BYTE, new Uint8Array(this.mouse_hit_out.buffer)).then(
				() => {
					this.reading_mouse_hit = false;
					this.client.ui.update_mouse_info();
				},
				() => {this.reading_mouse_hit = false;}
			);
			gl.bindFramebuffer(gl.FRAMEBUFFER, null);
		}

		for(let [icon, attribs_buf] of draw_list) {
			gl.deleteBuffer(attribs_buf);
		}

		gl.bindTexture(gl.TEXTURE_2D, null);

		this.stats_elem.textContent = `${+this.fps.toFixed(1)} fps\n${num_drawcalls} draw calls\n${this.num_icon_sends} icon sends (${this.client.icons.size} unique)`;
	}
	reading_mouse_hit = false;
	mouse_hit_out = new Uint32Array(1);
	get mouse_hit_id() {
		return this.mouse_hit_out[0];
	}

	proj_matrix : mat4 = mat4.create();
	mouse_view_matrix : mat4 = mat4.create();
	view_matrix : mat4 = mat4.create();
	inv_view_matrix : mat4 = mat4.create();

	camera_pos : vec3 = [128,-20,200];
	target_camera_pos : vec3 = vec3.copy(vec3.create(), this.camera_pos);
	camera_pitch = -1;
	camera_yaw = 0;
	camera_secondyaw = 0;
	camera_zoom = 1;
	get camera_actual_zoom() {
		return (this.client.eye_sight & 0x8000) ? this.camera_zoom : 0;
	}
	draw_dist = 7.5;

	current_vertex_attribs : number[] = [];
	update_enabled_vertex_attribs(attribs : number[]) {
		const gl = this.gl;
		for(let attrib of attribs) {
			if(!this.current_vertex_attribs.includes(attrib)) {
				this.current_vertex_attribs.push(attrib);
				gl.enableVertexAttribArray(attrib);
			}
		}
		for(let i = 0; i < this.current_vertex_attribs.length; i++) {
			let attrib = this.current_vertex_attribs[i];
			if(!attribs.includes(attrib)) {
				this.current_vertex_attribs.splice(i, 1);
				i--;
				gl.disableVertexAttribArray(attrib);
			}
		}
	}

	async readPixelsAsync(x:number, y:number, width:number, height:number, format:number, type:number, view:ArrayBufferView) {
		const gl = this.gl2;
		if(!gl) {
			return this.gl.readPixels(x,y,width,height,format,type,view);
		}

		let buf = gl.createBuffer();
		gl.bindBuffer(gl.PIXEL_PACK_BUFFER, buf);
		gl.bufferData(gl.PIXEL_PACK_BUFFER, view.byteLength, gl.STREAM_READ);
		gl.readPixels(x,y,width,height,format,type,0);
		gl.bindBuffer(gl.PIXEL_PACK_BUFFER, null);

		let sync = gl.fenceSync(gl.SYNC_GPU_COMMANDS_COMPLETE, 0);
		if(!sync) {
			return;
		}

		do {
			await new Promise(resolve => setTimeout(resolve, 10));
		} while(gl.clientWaitSync(sync, 0, 0) == gl.TIMEOUT_EXPIRED);

		gl.bindBuffer(gl.PIXEL_PACK_BUFFER, buf);
		gl.getBufferSubData(gl.PIXEL_PACK_BUFFER, 0, view);
		gl.bindBuffer(gl.PIXEL_PACK_BUFFER, null);
		gl.deleteBuffer(buf);
	}
}

const error_texture = new Uint8Array(4*4*4);
for(let i = 0; i < error_texture.length; i += 4) {
	error_texture[i+3] = 255;
	error_texture[i] = error_texture[i+2] = (!(i & 0b000100) == !(i & 0b100000)) ? 255 : 0 
}
