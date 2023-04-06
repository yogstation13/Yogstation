import { vec4 } from "gl-matrix";
import { Appearance } from "./appearance";
import { Atom } from "./atom";
import { bind_shader_lighting } from "./shader";
import { GlHolder } from "./webgl";

const O_LIGHTMAP_SIZE = 256;

export class LightingHolder {
	last_maxx = 0;
	last_maxy = 0;
	last_z = -1;
	data : Uint8Array = new Uint8Array(0);
	lightmap_texture : WebGLTexture|null = null;
	lightmap_dirty = false;
	need_webgl_resize = false;
	dirty_turfs = new Set<Atom>();
	constructor(public gl_holder : GlHolder) {
		const gl = gl_holder.gl;
		this.o_lightmap_texture = gl.createTexture();
		this.o_lightmap_framebuffer = gl.createFramebuffer();
		gl.bindFramebuffer(gl.FRAMEBUFFER, this.o_lightmap_framebuffer);
		gl.bindTexture(gl.TEXTURE_2D, this.o_lightmap_texture);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
		gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, O_LIGHTMAP_SIZE, O_LIGHTMAP_SIZE, 0, gl.RGBA, gl.UNSIGNED_BYTE, null);
		gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, this.o_lightmap_texture, 0);
		gl.bindFramebuffer(gl.FRAMEBUFFER, null);
		gl.bindTexture(gl.TEXTURE_2D, null);
	}
	check() {
		if(this.last_maxx != this.gl_holder.client.maxx || this.last_maxy != this.gl_holder.client.maxy) {
			this.last_maxx = this.gl_holder.client.maxx;
			this.last_maxy = this.gl_holder.client.maxy;
			this.need_webgl_resize = true;
			this.data = new Uint8Array((this.last_maxx+1) * (this.last_maxy+1) * 4);
			this.last_z = -1;
		}
		if(this.last_z != this.gl_holder.client.eye_z) {
			this.last_z = this.gl_holder.client.eye_z;
			if(!this.need_webgl_resize) {
				this.data = new Uint8Array((this.last_maxx+1) * (this.last_maxy+1) * 4);
				for(let i = 3; i < this.data.length; i++) {
					this.data[i] = 80;
				}
			}
			this.dirty_turfs.clear();
			for(let y = 0; y < this.last_maxy; y++) for(let x = 0; x < this.last_maxx; x++) {
				let turf = this.gl_holder.client.get_turf(x, y, this.last_z);
				if(turf) this.update_turf(turf);
			}
		} else if(this.dirty_turfs.size) {
			for(let turf of this.dirty_turfs) {
				this.update_turf(turf);
			}
		}
	}
	private update_turf(turf : Atom) {
		this.dirty_turfs.delete(turf);
		if(turf.type != 1) return;
		let id = turf.id;
		let x = id % this.last_maxx;
		id = (id / this.last_maxx)|0;
		let y = id % this.last_maxy;
		let z = (id / this.last_maxy)|0;
		if(z != this.last_z) return;
		let alpha_index = (y * (this.last_maxx+1) + x) * 4 + 3;
		let appearance = turf.appearance;
		let underlay_appearance : Appearance|undefined;
		let is_camera_static = false;
		if(appearance?.underlays) for(let underlay of appearance.underlays) {
			if(underlay.plane == 15) {
				underlay_appearance = underlay;
				break;
			}
		}
		if(turf.images) for(let image of turf.images) {
			if(image.appearance?.plane == 19) is_camera_static = true;
		}
		if(is_camera_static) {
			if(this.data[alpha_index] != 0) {
				this.data[alpha_index] = 0;
				this.lightmap_dirty = true;
			}
		} else if(underlay_appearance?.icon_state == "adark") {
			if(this.data[alpha_index] != 255) {
				this.data[alpha_index] = 255;
				this.lightmap_dirty = true;
			}
		} else if(underlay_appearance?.color_matrix) {
			for(let c = 0; c < 4; c++) {
				let cx = x + +!!(c & 1);
				let cy = y + +!!(c & 2);
				let matrix_base = c << 2;
				let cm = underlay_appearance.color_matrix;
				let color_index = (cy * (this.last_maxx+1) + cx) * 4;
				let red = Math.max(0, Math.min(255, cm[matrix_base] * 255));
				let green = Math.max(0, Math.min(255, cm[matrix_base+1] * 255));
				let blue = Math.max(0, Math.min(255, cm[matrix_base+2] * 255));
				if(red != this.data[color_index] || green != this.data[color_index+1] || blue != this.data[color_index+2]) {
					this.data[color_index] = red;
					this.data[color_index+1] = green;
					this.data[color_index+2] = blue;
					this.lightmap_dirty = true;
				}
			}
			if(this.data[alpha_index] != 160) {
				this.data[alpha_index] = 160;
				this.lightmap_dirty = true;
			}
		} else {
			if(this.data[alpha_index] != 80) {
				this.data[alpha_index] = 80;
				this.lightmap_dirty = true;
			}
		}
	}
	get_updated_texture() {
		const gl = this.gl_holder.gl;
		this.check();
		if(this.lightmap_dirty || this.need_webgl_resize) {
			if(!this.lightmap_texture) {
				this.lightmap_texture = gl.createTexture();
				if(!this.lightmap_texture) return null;
				gl.bindTexture(gl.TEXTURE_2D, this.lightmap_texture);
				gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
				gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
				gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
				gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
			} else {
				gl.bindTexture(gl.TEXTURE_2D, this.lightmap_texture);
			}
			if(this.need_webgl_resize) {
				gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, this.last_maxx+1, this.last_maxy+1, 0, gl.RGBA, gl.UNSIGNED_BYTE, this.data);
			} else {
				gl.texSubImage2D(gl.TEXTURE_2D, 0, 0, 0, this.last_maxx+1, this.last_maxy+1, gl.RGBA, gl.UNSIGNED_BYTE, this.data);
			}
			gl.bindTexture(gl.TEXTURE_2D, null);
		}
		return this.lightmap_texture;
	}

	o_lightmap_texture : WebGLTexture|null = null;
	o_lightmap_framebuffer : WebGLFramebuffer|null = null;
	o_lightmap_box : vec4 = [0,0,1,1];
	update_o_lightmap(lights : LightingRenderPlan[]) {
		if(!this.o_lightmap_framebuffer || !this.o_lightmap_texture) return null;
		let is_first = true;
		for(let light of lights) {
			if(is_first) {
				is_first = false;
				this.o_lightmap_box = [
					light.x-light.range,
					light.y-light.range,
					light.x+light.range,
					light.y+light.range,
				]
			} else {
				this.o_lightmap_box[0] = Math.min(this.o_lightmap_box[0], light.x-light.range);
				this.o_lightmap_box[1] = Math.min(this.o_lightmap_box[1], light.y-light.range);
				this.o_lightmap_box[2] = Math.max(this.o_lightmap_box[2], light.x+light.range);
				this.o_lightmap_box[3] = Math.max(this.o_lightmap_box[3], light.y+light.range);
			}
		}

		let attribs = new Float32Array(5*6*lights.length);
		let iattribs = new Uint32Array(attribs.buffer);
		let offset = 0;
		for(let light of lights) {
			offset = light.write(offset, attribs, iattribs);
		}

		const gl = this.gl_holder.gl;
		gl.bindFramebuffer(gl.FRAMEBUFFER, this.o_lightmap_framebuffer);
		gl.viewport(0, 0, O_LIGHTMAP_SIZE, O_LIGHTMAP_SIZE);
		const shader = bind_shader_lighting(gl);
		this.gl_holder.update_enabled_vertex_attribs([shader.aColor, shader.aPosition, shader.aUV]);
		gl.uniform4fv(shader.bounds, this.o_lightmap_box);
		let buf = gl.createBuffer();
		gl.bindBuffer(gl.ARRAY_BUFFER, buf);
		gl.bufferData(gl.ARRAY_BUFFER, attribs, gl.STREAM_DRAW);
		gl.vertexAttribPointer(shader.aPosition, 2, gl.FLOAT, false, 5*4, 0);
		gl.vertexAttribPointer(shader.aUV, 2, gl.FLOAT, false, 5*4, 2*4);
		gl.vertexAttribPointer(shader.aColor, 4, gl.UNSIGNED_BYTE, true, 5*4, 4*4);
		gl.clearColor(0,0,0,0);
		gl.clear(gl.COLOR_BUFFER_BIT);
		gl.enable(gl.BLEND);
		gl.blendFunc(gl.ONE, gl.ONE_MINUS_SRC_ALPHA);
		gl.disable(gl.DEPTH_TEST);
		gl.drawArrays(gl.TRIANGLES, 0, 6*lights.length);
		gl.bindBuffer(gl.ARRAY_BUFFER, null);
		gl.deleteBuffer(buf);
		gl.bindFramebuffer(gl.FRAMEBUFFER, null);

		return this.o_lightmap_texture;
	}
}

export class LightingRenderPlan {
	constructor(public x : number, public y : number, public range : number = 0.5, public color_alpha : number = -1) {
		
	}

	write(offset : number, attribs : Float32Array, iattribs : Uint32Array) {
		for(let vi = 0; vi < 6; vi++) {
			let vx = [0,1,0,0,1,1][vi];
			let vy = [0,0,1,1,0,1][vi];
			let dx = vx*2-1; let dy = vy*2-1;
			attribs[offset++] = dx*this.range+this.x;
			attribs[offset++] = dy*this.range+this.y;
			attribs[offset++] = dx;
			attribs[offset++] = dy;
			iattribs[offset++] = this.color_alpha;
		}
		return offset;
	}
}
