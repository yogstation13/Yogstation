import { DataPointer } from "./binary";
import { inflate } from 'pako';

const text_decoder = new TextDecoder();

export class IconState {
	name = "";
	flags = 0;
	num_dirs = 1;
	num_frames = 1;
	loop = 0;
	delays : number[]|null = null;
	icons : number[][] = [];
	total_delay = 0;

	static from_message(dp : DataPointer) {
		let state = new IconState();
		state.name = dp.read_utf_string();
		state.flags = dp.read_uint8();
		state.num_dirs = dp.read_uint8() || 1;
		state.num_frames = dp.read_uint16();
		state.loop = dp.read_uint16();
		if(state.num_frames > 1) {
			state.delays = [];
			state.total_delay = 0;
			for(let i = 0; i < state.num_frames; i++) {
				let delay = dp.read_float();
				state.delays.push(delay);
				state.total_delay += delay;
			}
			if((state.flags & IconState.FLAG_REWIND) !== 0) {
				state.total_delay += state.total_delay - state.delays[0] - state.delays[state.delays.length-1];
			}
		}
		for(let i = 0; i < state.num_dirs; i++) {
			let icon : number[] = [];
			for(let j = 0; j < state.num_frames; j++) {
				icon.push(dp.read_uint16());
			}
			state.icons.push(icon);
		}

		return state;
	}

	get_dir_index(dir : number) {
		if(this.num_dirs == 1) return 0;
		dir = dir & 15;
		if(this.num_dirs <= 4) {
			if(dir & 12) dir &= 12;
		}
		let index = [0,1,0,0,2,6,4,2,3,7,5,3,2,1,0,0][dir] ?? 0;
		return (index & (this.num_dirs-1));
	}

	get_frame_index(time : number, flick_time?:number|null, out_static? : {is_static : boolean}) {
		if(flick_time) {
			time -= flick_time;
		}
		let delays = this.delays;
		if(!(this.num_frames > 1) || !delays) return 0;
		if(out_static) out_static.is_static = false;
		if(!flick_time) time = time % this.total_delay;
		for(let frame = 0; frame < this.num_frames; frame++) {
			if(time < delays[frame]) {
				return frame;
			}
			time -= delays[frame];
		}
		if((this.flags & IconState.FLAG_REWIND) && this.num_frames > 0) {
			for(let frame = this.num_frames-1; frame < this.num_frames; frame++) {
				if(time < delays[frame]) {
					return frame;
				}
				time -= delays[frame];
			}
			return 0;
		} else {
			return this.num_frames-1;
		}
	}

	get_icon(dir : number = 2, time = 0, flick_time? : null|number, out_static? : {is_static : boolean}) {
		return this.icons[this.get_dir_index(dir)][this.get_frame_index(time, flick_time, out_static)];
	}

	static turn_dir_4(dir : number, amt : number) {
		return this.turn_dir_8(dir, amt << 1);
	}
	static turn_dir_8(dir : number, amt : number) {
		return [[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],
		[1,9,6,8,5,1,4,9,10,8,2,1,8,9,4,8],
		[2,8,4,1,1,9,5,10,2,10,6,10,2,8,4,10],
		[8,10,5,9,9,8,1,4,6,2,4,10,8,8,4,10],
		[5,2,1,2,8,10,9,4,4,6,5,6,10,6,1,6],
		[10,6,9,9,10,2,8,5,5,4,1,8,1,5,5,4],
		[1,4,8,8,2,6,10,6,1,5,9,4,8,9,4,5],
		[1,5,10,10,6,4,2,4,9,1,8,6,5,10,5,9]][amt & 7][dir & 0xF]
	}

	static FLAG_REWIND = 1;
}

export class Icon {
	resource : number = 0;
	width = 32;
	height = 32;
	id = 0;
	states : IconState[] = [];
	frames : [number,number][] = [];
	sheet_width = 1;
	sheet_height = 1;
	texture : WebGLTexture|null = null;
	image : HTMLImageElement|(ImageBitmap&{src:string})|null = null;
	image_promise : Promise<HTMLImageElement|(ImageBitmap&{src:string})>|null = null;
	state_map = new Map<string, IconState>();
	default_state : IconState|null = null;
	frame_paths : Map<number, string> = new Map();
	version = 0;

	static from_message(dp : DataPointer) {
		let icon = new Icon();
		icon.resource = dp.read_uint32();
		icon.width = dp.read_uint16();
		icon.height = dp.read_uint16();
		icon.id = dp.read_uint32as16();
		let num_states = dp.read_uint16();
		for(let i = 0; i < num_states; i++) {
			icon.states.push(IconState.from_message(dp));
		}
		for(let state of icon.states) {
			icon.state_map.set(state.name, state);
			if(state.name == "") icon.default_state = state;
		}
		return icon;
	}

	get_icon_state(name : string, include_default = false) {
		for(let state of this.states) {
			if(state.name == name) return state;
		}
		if(include_default) return this.default_state;
		return null;
	}

	make_image(blob : Blob) {
		if(this.image) return Promise.resolve(this.image);
		if(this.image_promise) return this.image_promise;
		let url = URL.createObjectURL(blob);
		/*return this.image_promise = new Promise<HTMLImageElement>((resolve, reject) => {
			
			let image = new Image();
			image.src = url;
			image.onload = () => {
				this.sheet_width = image.width / this.width;
				this.sheet_height = image.height / this.height;
				resolve(image);
			};
			image.onerror = () => {
				reject(image);
			}
		});*/
		this.reparse_dmi(blob);
		return this.image_promise = createImageBitmap(blob, {premultiplyAlpha: "none"}).then(image => {
			this.sheet_width = image.width / this.width;
			this.sheet_height = image.height / this.height;
			return this.image = Object.assign(image, {src: url});
		});
	}

	private async reparse_dmi(blob : Blob) {
		let array_buffer = await blob.arrayBuffer();
		let dv = new DataView(array_buffer);

		// A quick and dirty PNG decoder
		if(dv.getUint32(0, false) != 0x89504e47 || dv.getUint32(4, false) != 0x0d0a1a0a) throw new Error("Not a valid PNG");
		let desc : string|undefined = undefined;
		let chunk_ptr = 8;
		let image_width = 0;
		let image_height = 0;
		while(chunk_ptr < dv.byteLength) {
			let chunk_length = dv.getUint32(chunk_ptr, false);
			let chunk_type = dv.getUint32(chunk_ptr+4, false);
			if(chunk_type == 0x49484452) {// IHDR
				image_width = dv.getUint32(chunk_ptr+8, false);
				image_height = dv.getUint32(chunk_ptr+12, false);
			} else if(chunk_type == 0x7a545874) {// zTXt
				let label_ptr = chunk_ptr + 8;
				while(label_ptr < dv.byteLength && dv.getUint8(label_ptr)) label_ptr++;
				let label = text_decoder.decode(new Uint8Array(array_buffer, chunk_ptr+8, label_ptr-chunk_ptr-8));
				if(label == "Description") {
					let compression_method = dv.getUint8(label_ptr+1);
					if(compression_method != 0) throw new Error("Invalid compression method " + compression_method);
					let compressed_data = new Uint8Array(array_buffer, label_ptr+2, chunk_ptr+8+chunk_length-label_ptr-2);
					desc = text_decoder.decode(inflate(compressed_data));
					break;
				}
			}
			chunk_ptr += 12 + chunk_length;
		}
		let icon_width = image_width;
		let icon_height = image_height;
		let frame_index = 0;

		if(desc) {
			let split = desc.split('\n');
			let parsing : IconState|undefined = undefined;
			let is_movement_state = false;
			const push_state = () => {
				if(!parsing) throw new Error("Pushing null state");
				let base = frame_index;
				frame_index += parsing.num_dirs*parsing.num_frames;
				for(let i = 0; i < parsing.num_dirs; i++) {
					let frames : number[] = [];
					for(let j = 0; j < parsing.num_frames; j++) {
						frames.push(base + j*parsing.num_dirs+i);
					}
					parsing.icons.push(frames);
				}
				
				this.states.push(parsing);

				parsing = undefined;
			}
			for(let i = 0; i < split.length; i++) {
				let regexResult = /\t?([a-zA-Z0-9]+) ?= ?(.+)/.exec(split[i]);
				if(!regexResult)
					continue;
				let key = regexResult[1];
				let val = regexResult[2];
				if(key == 'width') {
					icon_width = +val;
				} else if(key == 'height') {
					icon_height = +val;
				} else if(key == 'state') {
					if(parsing) {
						push_state();
					}
					is_movement_state = false;
					parsing = new IconState();
					parsing.name = JSON.parse(val);
					parsing.num_frames = 1;
					is_movement_state = false;
				} else if(key == 'dirs') {
					if(!parsing) throw new Error("No icon state");
					parsing.num_dirs = +val;
				} else if(key == 'frames') {
					if(!parsing) throw new Error("No icon state");
					parsing.num_frames = +val;
				} else if(key == 'movement') {
					is_movement_state = !!+val;
				} else if(key == 'delay') {
					if(!parsing) throw new Error("No icon state");
					parsing.delays = JSON.parse('[' + val + ']');
					parsing.total_delay = 0;
					for(let delay of parsing.delays as number[]) parsing.total_delay += delay;
				}
			}
			if(parsing) {
				push_state();
			}

			if(!icon_width && !icon_height && frame_index) {
				icon_height = image_height;
				icon_width = image_width / frame_index;
			}
		} else {
			let state = new IconState();
			state.icons = [[0]];
			state.num_dirs = 1;
			state.num_frames = 1;
			state.name = "";
			this.states.push(state);
		}

		this.default_state = null;
		this.state_map.clear();
		
		for(let state of this.states) {
			this.state_map.set(state.name, state);
			if(state.name == "") this.default_state = state;
		}
		this.version++;
	}
}