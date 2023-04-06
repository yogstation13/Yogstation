const program_cache = new WeakMap<WebGLRenderingContext, Map<string, ShaderInfo<any,any>>>();

function bind_shader<A extends readonly string[], U extends readonly string[]>(
	gl : WebGLRenderingContext, key : string,
	generator : ()=>[string,string],
	attribs : A,
	uniforms : U,
) : ShaderInfo<A,U> {
	let gl_cache = program_cache.get(gl);
	if(!gl_cache) {
		gl_cache = new Map();
		program_cache.set(gl, gl_cache);
	}
	let shader_info = gl_cache.get(key) as ShaderInfo<A,U>;
	if(!shader_info) {
		let [vcode, fcode] = generator();
		let vs = gl.createShader(gl.VERTEX_SHADER);
		let fs = gl.createShader(gl.FRAGMENT_SHADER);
		let prog = gl.createProgram();
		if(!vs || !fs || !prog) {
			throw new Error("shader creation failed");
		}
		gl.shaderSource(vs, vcode);
		gl.shaderSource(fs, fcode);
		gl.compileShader(vs);
		gl.compileShader(fs);
		gl.attachShader(prog, vs);
		gl.attachShader(prog, fs);
		gl.linkProgram(prog);
		if(!gl.getProgramParameter(prog, gl.LINK_STATUS)) {
			throw new Error(`Could not compile WebGL program\n\n${gl.getProgramInfoLog(prog)}\n${vcode}\n${gl.getShaderInfoLog(vs)}\n${fcode}\n${gl.getShaderInfoLog(fs)}`);
		}
		shader_info = build_shader_info(gl, prog, attribs, uniforms);
		gl_cache.set(key, shader_info);
	}
	gl.useProgram(shader_info.program);
	return shader_info;
}

type ShaderInfo<A extends readonly string[], U extends readonly string[]> = {
	[P in (A[number]|U[number]|"program")] : P extends "program" ? WebGLProgram : (P extends A[number] ? number : WebGLUniformLocation|null);
	/*
	In a way that makes more sense:
	[P in A[number]] : number;
	[P in U[number]] : WebGLUniformLocation|null;
	program: WebGLPRogram;
	*/
};

function build_shader_info<A extends readonly string[], U extends readonly string[]>(
	gl : WebGLRenderingContext,
	prog : WebGLProgram,
	attribs : A,
	uniforms : U,
) : ShaderInfo<A, U> {
	let obj : any = {program: prog};
	for(let attrib of attribs) {
		obj[attrib] = gl.getAttribLocation(prog, attrib);
	}
	for(let uniform of uniforms) {
		obj[uniform] = gl.getUniformLocation(prog, uniform);
	}
	return obj;
}

let uniforms_lighting = [
	"bounds"
] as const;
let attribs_lighting = [
	"aPosition", "aUV", "aColor"
] as const;

function shader_code_lighting() : [string, string] {
	return [
`
precision highp float;

uniform vec4 bounds;
attribute vec2 aPosition;
attribute vec2 aUV;
attribute vec4 aColor;
varying vec4 vColor;
varying vec2 vUV;

void main() {
	gl_Position = vec4(
		(aPosition.x - bounds.x) / (bounds.z - bounds.x) * 2.0 - 1.0,
		(aPosition.y - bounds.y) / (bounds.w - bounds.y) * 2.0 - 1.0,
		0, 1
	);
	vColor = aColor;
	vUV = aUV;
}

`,`

precision mediump float;

varying vec4 vColor;
varying vec2 vUV;

void main() {
	gl_FragColor = clamp(1.0 - length(vUV), 0.0, 1.0) * vColor;
}

`
	]
}

export function bind_shader_lighting(gl : WebGLRenderingContext) {
	return bind_shader(gl, "lighting", () => shader_code_lighting(), attribs_lighting, uniforms_lighting);
}

const SPRITE_MARGIN = 0.003;

let uniforms_3d = [
	"projMatrix", "viewMatrix",
	"sheetWidth","sheetHeight",
	"iconWidth","iconHeight","iconTexture",
	"lightWidth","lightHeight","lightTexture","lightInfluence",
	"blind","cameraPos","drawDist","isIdPass",
	"oLightTexture", "overlayLightBox"] as const;
let attribs_3d = ["aPosition", "aNormal", "aColor","aUV","aSheetIndex","aBits"] as const;
function shader_code_3d() : [string, string] {
	return [
`
precision highp float;

uniform mat4 projMatrix;
uniform mat4 viewMatrix;

uniform mediump float sheetWidth;
uniform mediump float sheetHeight;

attribute vec3 aPosition;
attribute vec3 aNormal;
attribute vec4 aColor;
attribute vec2 aUV;
attribute float aSheetIndex;
attribute float aBits;

varying vec3 vNormal;
varying vec4 vColor;
varying vec2 vUV;
varying vec2 vSheetPos;
varying vec2 vXYPos;
varying float vBits;
void main() {
	vNormal = aNormal;
	vColor = aColor;
	float sheetY = floor((aSheetIndex + 0.5) / sheetWidth);
	float sheetX = floor(aSheetIndex + 0.5 - sheetY*sheetWidth);
	vSheetPos = vec2(sheetX, sheetY);
	vUV = aUV;
	vXYPos = (aPosition + aNormal * 0.05).xy;
	vBits = aBits;
	gl_Position = projMatrix * viewMatrix * vec4(aPosition, 1.0);
}
`,`
precision mediump float;

varying vec3 vNormal;
varying vec4 vColor;
varying vec2 vUV;
varying vec2 vSheetPos;
varying vec2 vXYPos;
varying float vBits;
uniform float sheetWidth;
uniform float sheetHeight;
uniform float iconWidth;
uniform float iconHeight;
uniform float lightWidth;
uniform float lightHeight;
uniform vec4 overlayLightBox;
uniform float isIdPass;
uniform float lightInfluence;
uniform float blind;
uniform float drawDist;
uniform vec3 cameraPos;
uniform sampler2D iconTexture;
uniform sampler2D lightTexture;
uniform sampler2D oLightTexture;
void main() {
	
	float dist = max(abs(cameraPos.x - vXYPos.x), abs(cameraPos.y - vXYPos.y));
	if(dist > drawDist) discard;

	if(vUV.x < ${-SPRITE_MARGIN} || vUV.y < ${-SPRITE_MARGIN} || vUV.x > ${1+SPRITE_MARGIN} || vUV.y > ${1+SPRITE_MARGIN}) discard;

	vec4 color = vec4(vec3(1.0,1.0,1.0) * (0.8 + clamp(vNormal.z, 0.0, 1.0) * 0.2 + 0.1 * vNormal.x + 0.05 * vNormal.y), 1.0) * vColor;
	vec2 uv = vUV;
	uv.y = 1.0 - uv.y;
	uv = clamp(uv, vec2(0.5 / iconWidth, 0.5 / iconHeight), vec2(1.0 - 0.5 / iconWidth, 1.0 - 0.5 / iconHeight));
	uv *= vec2(1.0/sheetWidth, 1.0/sheetHeight);
	uv += vSheetPos * vec2(1.0/sheetWidth, 1.0/sheetHeight);
	if(isIdPass > 0.5) color = texture2D(iconTexture, uv);
	else {
		color *= texture2D(iconTexture, uv);
		if(color.a < 0.01) discard; // Deal with this now - lots of overlays was causing fillrate issues
	}
	vec2 lightPos = clamp(vXYPos, vec2(0,0), vec2(lightWidth-0.01, lightHeight-0.01));
	vec2 lightSizeScale = vec2(1.0/(lightWidth+1.0),1.0/(lightHeight+1.0));
	float lightAlpha = texture2D(lightTexture, (floor(lightPos) + vec2(0.5)) * lightSizeScale).a;
	if(lightAlpha < 0.25) discard;
	float feelPass = clamp((1.0 - distance(cameraPos.xy, vXYPos) / 1.8), 0.0, 1.0);
	if(blind > 0.5) {
		if(feelPass <= 0.01) discard;
	}
	if(color.a < (0.01 - isIdPass * 0.008)) discard;
	if(isIdPass < 0.5) {
		if(!${extract_bit("vBits", 0)}) {
			vec3 lighting = vec3(1.0,1.0,1.0);
			if(lightAlpha > 0.5 && lightInfluence > 0.001) {
				if(lightAlpha > 0.75) {
					lighting = vec3(0.0);
				} else {
					lighting = texture2D(lightTexture, (lightPos + vec2(0.5)) * lightSizeScale).rgb;
				}
				lighting = min(lighting + vec3(feelPass) * 0.11, vec3(1.0));
			}
			if(
				vXYPos.x >= overlayLightBox.x
				&& vXYPos.y >= overlayLightBox.y
				&& vXYPos.x <= overlayLightBox.z
				&& vXYPos.y <= overlayLightBox.w
			) {
				vec4 oLight = texture2D(oLightTexture, vec2(
					(vXYPos.x - overlayLightBox.x) / (overlayLightBox.z - overlayLightBox.x),
					(vXYPos.y - overlayLightBox.y) / (overlayLightBox.w - overlayLightBox.y)
				));
				lighting = lighting * (1.0 - oLight.a) + oLight.rgb;
			}
			lighting = vec3(1.0) - (vec3(1.0) - lighting) * lightInfluence;
			color.rgb *= lighting;
		}
		if(blind > 0.5) color.rgb *= feelPass;
		color.rgb *= clamp(drawDist - dist, 0.0, 1.0);
	}
	if(isIdPass > 0.5) gl_FragColor = vColor;
	else gl_FragColor = color;
}
`
	]
}

export function bind_shader_3d(gl : WebGLRenderingContext) {
	return bind_shader(gl, "3d", () => shader_code_3d(), attribs_3d, uniforms_3d);
}

export function array_to_buffer(gl : WebGLRenderingContext, type : number, array : Uint8Array|Float32Array|Uint32Array, usage = gl.STATIC_DRAW) {
	let buffer = gl.createBuffer();
	if(!buffer) {
		console.error("Failed to create WebGL buffer!");
		return undefined;
	}
	gl.bindBuffer(type, buffer);
	gl.bufferData(type, array, usage);
	return buffer;
}

function extract_bit(varname : string, bit : number) {
	return `(fract((${varname} + 0.5) / ${(2<<bit).toFixed(1)}) > 0.5)`;
}
function extract_bit_branchless(varname : string, bit : number) {
	return `round(fract((${varname} + 0.5) / ${(2<<bit).toFixed(1)}))`;
}
