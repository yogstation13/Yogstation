let base = document.head.querySelector("base");
// Base is bad. Go away.
if(base) {
	base.parentElement?.removeChild(base);
}

const elementMouseDownEvents = new Map<EventListenerOrEventListenerObject, EventListener>();
const originalElementAddEventListener = Element.prototype.addEventListener;
const originalElementRemoveEventListener = Element.prototype.removeEventListener;
const originalDocumentAddEventListener = document.addEventListener;
const originalDocumentRemoveEventListener = document.removeEventListener;
Element.prototype.addEventListener = function(...args: Parameters<Element["addEventListener"]>) {
	if (args[0] == "mousedown") {
		args[0] = "pointerdown";

		const originalHandler = args[1];
		args[1] = ((e: PointerEvent) => {
			e.preventDefault();
			document.documentElement.setPointerCapture(e.pointerId)
			if("handleEvent" in originalHandler) originalHandler.handleEvent(e);
			else originalHandler(e);
		}) as EventListener
		elementMouseDownEvents.set(originalHandler, args[1]);
	}

	originalElementAddEventListener.apply(this, args);
}
Element.prototype.removeEventListener = function(...args: Parameters<Element["removeEventListener"]>) {
	if (args[0] == "mousedown") {
		args[0] = "pointerdown";

		const originalHandler = args[1];
		args[1] = elementMouseDownEvents.get(originalHandler) ?? originalHandler;
		elementMouseDownEvents.delete(originalHandler);
	}

	originalElementRemoveEventListener.apply(this, args);
}
document.addEventListener = function(...args: Parameters<Document["addEventListener"]>) {
	if (args[0].startsWith("mouse")) {
		args[0] = args[0].replace("mouse", "pointer");
	}
	originalDocumentAddEventListener.apply(this, args);
}
document.removeEventListener = function(...args: Parameters<Document["removeEventListener"]>) {
	if (args[0].startsWith("mouse")) {
		args[0] = args[0].replace("mouse", "pointer");
	}
	originalDocumentRemoveEventListener.apply(this, args);
}

let window_output_map = Object.create(null) as any;
for(let thing = window; thing != null && thing != Object.getPrototypeOf(thing); thing = Object.getPrototypeOf(thing)) {
	for(let key of Object.getOwnPropertyNames(thing)) {
		window_output_map[key] = {
			get() {return undefined;}
		}
	}
}
let window_output_target = Object.create(window, window_output_map);

// @ts-ignore
const byond = window.byond = {
	fixjs(fun : () => void) {
		if(typeof fun != "function") throw new Error("non-function passed to fixjs");
		try {eval("");} catch(e) {
			console.warn("Eval is disabled - skipping browser fill");
			fun();
			return;
		}
		let str = fun.toString();
		let start = str.indexOf("{") + 1;
		let end = str.lastIndexOf("}");
		str = str.substring(start, end);
		str = str.replace(/window\.location/g, "window.__location_proxy");
		let tgui_patch_match = str.match(/\w.setupDrag\s*=\s*(\w);/);
		if (tgui_patch_match) {
			let setupDrag = tgui_patch_match[1];
			str = str.replace(/drag start(?:\n|.)*?,/, x => x + `${setupDrag}(),`)
			str = str.replace(/drag end(?:\n|.)*?,/, x => x + `${setupDrag}(),`)
		}
		str = str.replace("isStyleSheetLoaded(node, url)", "true")
		window.eval(str);
	},
	outputtarget: window_output_target,
	go(str : string) {
		window.parent.postMessage("go:" + str, "*");
	}
};

window.addEventListener("message", (e) => {
	if(e.source != window.parent) return;
	let str = ""+e.data;
	if(str.startsWith("output:")) {
		let part = str.substring(7);
		let bits = part.split(/[&;]/g).map(x => decodeURIComponent(x.replace(/\+/g, ' ')));
		let fun = byond.outputtarget[bits[0]];
		if(typeof fun == "function") {
			fun(...bits.slice(1));
		}
	} else if (str.startsWith("callback:")) {
		let {callback, data}: { callback: string, data: string } = JSON.parse(str.substring(str.indexOf(":") + 1))
		//language=js
		eval(`${callback}(JSON.parse("${data.replace(/"/g, '\\"')}"))`)
		console.log(str, `${callback}(JSON.parse("${data.replace(/"/g, '\\"')}"))`);
	}
});

window.addEventListener("click", (e) => {
	let link = (e.target as HTMLElement).closest("a");
	if(link && !e.defaultPrevented) {
		e.preventDefault();
		byond.go(link.href);
	}
});

window.addEventListener("submit", (e) => {
	if(!e.defaultPrevented) {
		let form = (e.target as HTMLElement).closest("form");
		if(!form) return;
		let data = new FormData(form);
		let params = new URLSearchParams(data as any);
		let href = form.action;
		if(href.includes("?")) {
			href = href.substring(0, href.indexOf("?"));
		}
		href += "?";
		href += params.toString();
		byond.go(href);
		e.preventDefault();
	}
})

let location_proxy = Object.create(window.location, {
	href: {
		get() {
			return window.location.href;
		},
		set(href : string) {
			byond.go(href);
		}
	}
});

Object.defineProperty(window, "__location_proxy", {
	get() {
		return location_proxy;
	},
	set(str : string) {
		byond.go(str);
	}
});
