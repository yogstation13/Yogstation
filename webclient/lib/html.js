import {readFileSync} from "fs";
import ejs from "ejs";

function find_chunk(bundle, name) {
	for(let item of Object.values(bundle)) {
		if(item.name.endsWith(name)) return item;
	}
}

function generate_html(bundle, template_path) {
	const template = readFileSync(template_path, "utf8");
	return ejs.render(template, {
		main_bundle: find_chunk(bundle, "main").fileName
	});
}

export default function htmlPlugin() {
	const template_path = "src/client/index.ejs";
	return {
		name: "html-plugin",
		buildStart() {
			this.addWatchFile(template_path);
		},
		async generateBundle(options, bundle) {
			this.emitFile({
				fileName: "index.html",
				type: "asset",
				source: generate_html(bundle, template_path)
			});
		}
	};
}