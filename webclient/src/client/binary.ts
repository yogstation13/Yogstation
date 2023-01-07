export class DataPointer {
	dv:DataView
	i = 0;
	constructor(public data : Uint8Array) {
		this.data = data;
		this.dv = new DataView(data.buffer, data.byteOffset, data.byteLength);
	}

	reached_end() {
		return this.i >= this.dv.byteLength;
	}
	read_float(le = true)  {
		let n = this.dv.getFloat32(this.i, le);
		this.i += 4;
		return n;
	}
	read_int32(le = true)  {
		let n = this.dv.getInt32(this.i, le);
		this.i += 4;
		return n;
	}
	read_uint32(le = true) {
		let n = this.dv.getUint32(this.i, le);
		this.i += 4;
		return n;
	}
	read_int16(le = true)  {
		let n = this.dv.getInt16(this.i, le);
		this.i += 2;
		return n;
	}
	read_uint16(le = true) {
		let n = this.dv.getUint16(this.i, le);
		this.i += 2;
		return n;
	}
	read_uint8() {
		let n = this.data[this.i];
		this.i++;
		return n;
	}
	read_uint32as16() {
		let val = this.read_uint16();
		if(val & 0x8000) {
			val &= 0x7FFF;
			val |= (this.read_uint16() << 15);
		}
		return val >>> 0;
	}
	read_string() {
		let start = this.i;
		while(!this.reached_end() && this.data[this.i]) this.i++;
		let subarr = this.data.subarray(start, this.i);
		this.i++;
		return new TextDecoder().decode(subarr);
	}
	read_utf_string() {
		let strlen = this.read_uint16();
		if(strlen == 0xFFFF) {
			strlen = this.read_uint32();
		}
		let subarr = this.data.subarray(this.i, this.i + strlen);
		this.i += strlen;
		return new TextDecoder().decode(subarr);
	}
	read_rle(count:number) {
		let arr = new Array<number>(count);
		let repeat = 0;
		let id = 0;
		for(let i = 0; i < count; i++) {
			if(repeat == 0) {
				let next = this.read_uint32as16();
				if(next == 0x7FFFFFFF) {
					repeat = this.read_uint8();
				} else {
					id = next;
				}
			} else {
				repeat--;
			}
			arr[i] = id;
		}
		return arr;
	}
	toString() {
		return `(0x${this.i.toString(16)})`;
	}
}

export class MessageBuilder {
	length = 0; parts : ((dv:DataView,pos:number)=>number)[] = [];
	constructor(type = 0) {
		this.parts.push((dv, pos) => {dv.setUint16(pos, type, false); return pos+2;});
		this.length += 2;
		return this;
	}
	write_uint8(num:number) {
		this.parts.push((dv, pos) => {dv.setUint8(pos, num); return pos+1;});
		this.length += 1;
		return this;
	}
	write_uint16(num:number) {
		this.parts.push((dv, pos) => {dv.setUint16(pos, num, true); return pos+2;});
		this.length += 2;
		return this;
	}
	write_int16(num:number) {
		this.parts.push((dv, pos) => {dv.setInt16(pos, num, true); return pos+2;});
		this.length += 2;
		return this;
	}
	write_uint32(num:number) {
		this.parts.push((dv, pos) => {dv.setUint32(pos, num, true); return pos+4;});
		this.length += 4;
		return this;
	}
	write_uint32as16(num:number) {
		if(num & 0xFFFF8000) {
			return this.write_uint32((num & 0x7FFF) | ((num << 1) & 0xFFFF0000) | 0x8000)
		} else {
			return this.write_uint16(num);
		}
	}
	write_string(str:string) {
		let buf = new TextEncoder().encode(str);
		this.parts.push((dv, pos) => {
			let arr = new Uint8Array(dv.buffer, pos, buf.length);
			arr.set(buf);
			pos += buf.length;
			dv.setUint8(pos, 0);
			pos += 1;
			return pos;
		});
		this.length += buf.length+1;
		return this;
	}
	write_utf_string(str : string) {
		let buf = new TextEncoder().encode(str);
		this.write_uint16(Math.min(0xFFFF, buf.length));
		if(buf.length >= 0xFFFF) {
			this.write_uint32(buf.length);
		}
		this.parts.push((dv, pos) => {
			let arr = new Uint8Array(dv.buffer, pos, buf.length);
			arr.set(buf);
			pos += buf.length;
			return pos;
		});
		this.length += buf.length;
	}

	collapse() {
		let dv = new DataView(new ArrayBuffer(this.length));
		let ptr = 0;
		for(let part of this.parts) {
			ptr = part(dv, ptr);
		}
		return dv.buffer;
	}
}
