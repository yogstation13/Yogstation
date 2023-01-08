import { mat4 } from "gl-matrix";
import { ByondClient } from ".";
import { DataPointer } from "./binary";

const SOUND_CACHE_TIME = 5*60*1000;

const SOUND_MUTE = 1;
const SOUND_PAUSED = 2;
const SOUND_STREAM = 4;
const SOUND_UPDATE = 16;

export class SoundPlayer {
	ctx = new AudioContext();
	constructor(public client : ByondClient) {
	}

	play_sound(cmd : SoundCommand) {
		if(cmd.channel != 0) {
			let existing = this.channeled_sounds.get(cmd.channel);
			if(existing && (cmd.status & SOUND_UPDATE)) {
				existing.update(cmd);
			} else {
				if(existing) {
					existing.stop();
					this.channeled_sounds.delete(cmd.channel);
				}
				this.channeled_sounds.set(cmd.channel, new PlayingSound(this, cmd));

			}
		} else if(cmd.resource) {
			new PlayingSound(this, cmd);
		}
	}

	frame() {
		let mat = mat4.create();
		mat4.invert(mat, this.client.gl_holder.view_matrix);
		
		let l = this.ctx.listener;
		if(l.forwardX) {
			l.forwardX.value = mat[4];
			l.forwardY.value = mat[6];
			l.forwardZ.value = -mat[5];
			l.upX.value = mat[8];
			l.upY.value = mat[10];
			l.upZ.value = -mat[9];
		} else {
			// firefox god damn it
			l.setOrientation(
				mat[4],
				mat[6],
				-mat[5],
				mat[8],
				mat[10],
				-mat[9]
			);
		}
	}

	channeled_sounds = new Map<number, PlayingSound>();
	
	sound_cache = new Map<string, {buf: Promise<AudioBuffer>, timeout: any}>();
	get_sound_buffer(resource : string) {
		let cached = this.sound_cache.get(resource);
		if(cached) {
			clearTimeout(cached.timeout);
			cached.timeout = setTimeout(() => {
				this.sound_cache.delete(resource);
			}, SOUND_CACHE_TIME);
			return cached.buf;
		} else {
			let promise = this.client.get_resource_blob(resource)
				.then(blob => blob.arrayBuffer())
				.then(buffer => this.ctx.decodeAudioData(buffer));
			this.sound_cache.set(resource, cached = {
				buf: promise,
				timeout: setTimeout(() => {
					this.sound_cache.delete(resource);
				}, SOUND_CACHE_TIME)
			});
			return promise;
		}
	}
}

export class PlayingSound {
	constructor(public player : SoundPlayer, sound : SoundCommand) {
		this.source_target = player.ctx.destination;
		
		this.resource = sound.resource;
		
		this.gain = player.ctx.createGain();
		this.gain.connect(this.source_target);
		this.source_target = this.gain;

		if(sound.pan) {
			this.stereo_panner = player.ctx.createStereoPanner();
			this.stereo_panner.connect(this.source_target);
			this.source_target = this.stereo_panner;
		}
		if(sound.x || sound.y || sound.z) {
			this.panner = player.ctx.createPanner();
			this.panner.connect(this.source_target);
			this.panner.panningModel = "HRTF";
			this.source_target = this.panner;
		}

		this.update(sound);
	}

	resource : string|null = null;
	buffer? : AudioBuffer;
	source? : AudioBufferSourceNode;
	source_target : AudioNode;

	gain : GainNode;
	stereo_panner? : StereoPannerNode;
	panner? : PannerNode;

	async update(sound : SoundCommand) {
		if(!this.resource) return;
		if(!this.buffer) {
			this.buffer = await this.player.get_sound_buffer(this.resource);
		}
		let buffer = this.buffer;
		let rate = 1;
		if(sound.frequency && sound.frequency <= 100 && sound.frequency >= -100) {
			rate = sound.frequency;
		} else if(sound.frequency) {
			rate = sound.frequency / this.buffer.sampleRate;
		}

		this.gain.gain.value = (sound.status & SOUND_MUTE) ? 0 : (sound.volume / 100);
		if(this.stereo_panner) {
			this.stereo_panner.pan.value = sound.pan / 100;
		}
		if(this.panner) {
			this.panner.positionX.value = sound.x;
			this.panner.positionY.value = sound.y;
			this.panner.positionZ.value = -sound.z;
			this.panner.refDistance = sound.falloff;
		}
		if(!this.source) {
			this.source = this.player.ctx.createBufferSource();
			this.source.buffer = buffer;
			this.source.connect(this.source_target);
			if(sound.repeat) this.source.loop = true;
			this.source.start();
		}
		this.source.playbackRate.value = rate;
	}

	stopped = false;
	stop() {
		this.stopped = true;
		this.source?.stop();
		this.source = undefined;
	}
}



export class SoundCommand {
	resource: string|null=null;
	repeat = 0;
	wait = false;
	status = 0;
	channel = 0;
	volume = 100;
	frequency = 0;
	pan = 0;
	x = 0;
	y = 0;
	z = 0;
	falloff = 1;

	static from_msg(dp : DataPointer) : SoundCommand {
		let snd = new SoundCommand();
		let resource = dp.read_uint32();
		let ext = dp.read_string();
		if(resource != 0xFFFFFFFF) {
			snd.resource = resource + ext;
		}
		snd.repeat = dp.read_uint8();
		snd.wait = !!dp.read_uint8();
		snd.channel = dp.read_uint16();
		snd.volume = dp.read_uint8() / 255 * 100;
		let flags = dp.read_uint8();
		if(flags & 1) {
			snd.pan = dp.read_uint8() - 128;
			snd.frequency = dp.read_float();
			dp.read_uint8(); // priority
			snd.status = dp.read_uint8();
		}
		if(flags & 2) {
			snd.x = dp.read_float();
			snd.y = dp.read_float();
			snd.z = dp.read_float();
			snd.falloff = dp.read_float();
		}
		return snd;
	}
}
