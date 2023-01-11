// How potatoey are the yoggers' computers?

export function get_webgl_stats() {
	let canvas = document.createElement("canvas");
	let stats_parts : string[] = [];
	collect_stats(canvas.getContext("webgl"), "gl", stats_parts);
	canvas = document.createElement("canvas");
	collect_stats(canvas.getContext("webgl2"), "gl2", stats_parts);
	return stats_parts.join(";");
}

function collect_stats(gl : WebGLRenderingContext|WebGL2RenderingContext|null, tag : string, stats_parts : string[]) {
	if(gl) {
		stats_parts.push(`supports_${tag}=1`);
		let exts = gl.getSupportedExtensions();
		if(exts) stats_parts.push(`${tag}_extensions=${encodeURIComponent(exts.join(","))}`);
		let vendor = gl.getParameter(gl.VENDOR);
		let renderer = gl.getParameter(gl.RENDERER);
		if(vendor) stats_parts.push(`${tag}_vendor=${encodeURIComponent(vendor)}`);
		if(renderer) stats_parts.push(`${tag}_renderer=${encodeURIComponent(renderer)}`);
		let ext = gl.getExtension("WEBGL_debug_renderer_info");
		if(ext) {
			let unmasked_vendor = gl.getParameter(ext.UNMASKED_VENDOR_WEBGL);
			let unmasked_renderer = gl.getParameter(ext.UNMASKED_RENDERER_WEBGL);
			if(unmasked_vendor) stats_parts.push(`${tag}_unmasked_vendor=${encodeURIComponent(unmasked_vendor)}`);
			if(unmasked_renderer) stats_parts.push(`${tag}_unmasked_renderer=${encodeURIComponent(unmasked_renderer)}`);
		}
	}
}
