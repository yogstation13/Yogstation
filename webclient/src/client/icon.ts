import { DataPointer } from "./binary";

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
		return this.image_promise = createImageBitmap(blob, {premultiplyAlpha: "none"}).then(image => {
			this.sheet_width = image.width / this.width;
			this.sheet_height = image.height / this.height;
			return this.image = Object.assign(image, {src: url});
		});
	}
}