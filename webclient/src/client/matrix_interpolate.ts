import { mat3 } from "gl-matrix";

function lerp(a=0, b=1, fac=0) {
	return b * fac + a * (1 - fac);
}
function deconstruct(m : number[], out : mat3) : number|undefined {
	mat3.identity(out);
	let x_scale_squared = m[0]*m[0] + m[3]*m[3];
	let y_scale_squared = m[1]*m[1] + m[4]*m[4];
	if(y_scale_squared < 1e-6 || x_scale_squared < 1e-6) {
		return;
	}
	let x_scale = Math.sqrt(x_scale_squared);
	let y_scale = Math.sqrt(y_scale_squared);

	let angle_cos = -1; let angle_sin_sign = 0;
	if(m[0] / x_scale > angle_cos) {
		angle_sin_sign = -m[3];
		angle_cos = m[0] / x_scale;
	}
	if(m[4] / y_scale > angle_cos) {
		angle_sin_sign = m[1];
		angle_cos = m[4] / y_scale;
	}

	if(angle_cos >= 0.9999) {
		out[0] = m[0]; out[1] = m[1];
		out[2] = m[2]; out[3] = m[3];
		out[4] = m[4]; out[5] = m[5];
		return 0;
	} else if(angle_cos <= -0.9999) {
		out[0] = -m[0]; out[1] = -m[1];
		out[2] = -m[2]; out[3] = -m[3];
		out[4] = m[4]; out[5] = m[5];
		return Math.PI;
	}
	if(Math.abs(angle_cos) < 0.0001) {
		angle_cos = 0;
	}
	let angle = Math.acos(angle_cos);
	let angle_sin = Math.sqrt(1 - (angle_cos*angle_cos));
	if(angle_sin_sign < 0) {
		angle = -angle;
		angle_sin = -angle_sin;
	}
	out[0] = m[0]; out[1] = m[1];
	out[3] = m[3]; out[4] = m[4];
	mat3.multiply(out, [angle_cos, -angle_sin, 0, angle_sin, angle_cos, 0, 0, 0, 1], out);
	out[2] = m[2]; out[5] = m[5];
	return angle;
}
export function matrix_interpolate(a : number[], b : number[], fac : number, linear = false) : number[] {
	if(linear) {
		return [
			lerp(a[0], b[0], fac),
			lerp(a[1], b[1], fac),
			lerp(a[2], b[2], fac),
			lerp(a[3], b[3], fac),
			lerp(a[4], b[4], fac),
			lerp(a[5], b[5], fac)
		];
	}
	let sst1 : mat3 = mat3.create();
	let sst2 : mat3 = mat3.create();
	let angle1 = deconstruct(a, sst1);
	let angle2 = deconstruct(b, sst2);
	if(angle1 == undefined || angle2 == undefined) {
		return matrix_interpolate(a, b, fac, true);
	}

	let ang_diff = angle2-angle1;
	ang_diff = (((ang_diff + Math.PI) % (Math.PI*2)) + (Math.PI*2)) % (Math.PI*2) - Math.PI;
	if(Math.abs(ang_diff) >= 0.0001 && Math.abs(ang_diff) < Math.PI-0.0001) {
		let angle = angle1 + fac*ang_diff;
		let out : mat3 = [
			lerp(sst1[0], sst2[0], fac),
			lerp(sst1[1], sst2[1], fac),
			0,
			lerp(sst1[3], sst2[3], fac),
			lerp(sst1[4], sst2[4], fac),
			0,
			0, 0, 1
		];
		let angle_cos = Math.cos(angle);
		let angle_sin = Math.sin(angle);
		mat3.multiply(out, [angle_cos, angle_sin, 0, -angle_sin, angle_cos, 0, 0, 0, 1], out);
		out[2] = lerp(sst1[2], sst2[2], fac);
		out[5] = lerp(sst1[5], sst2[5], fac);
		return out.slice(0, 6);
	} else {
		return matrix_interpolate(a, b, fac, true);
	}
}