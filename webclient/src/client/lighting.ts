import { Appearance } from "./appearance";
import { Atom } from "./atom";
import { GlHolder } from "./webgl";

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
}