// Key passthrough - so you can still do spaceman things when focused on a browser window

if(document.addEventListener && window.location) { // hey maybe some bozo is still using mega-outdated IE
	let anti_spam = []; // wow I wish I could use e.repeat but IE is dumb and doesn't have it.
	document.addEventListener("keydown", function(e) {
		if(e.target && (e.target.localName == "input" || e.target.localName == "textarea"))
			return;
		if(e.defaultPrevented)
			return; // do e.preventDefault() to prevent this behavior.
		if(e.which) {
			if(!anti_spam[e.which]) {
				anti_spam[e.which] = true;
				let href = "?__keydown=" + e.which;
				if(e.ctrlKey === false) href += "&ctrlKey=0"
				else if(e.ctrlKey === true) href += "&ctrlKey=1"
				window.location.href = href;
			}
		}
	});
	document.addEventListener("keyup", function(e) {
		if(e.target && (e.target.localName == "input" || e.target.localName == "textarea"))
			return;
		if(e.defaultPrevented)
			return;
		if(e.which) {
			anti_spam[e.which] = false;
			let href = "?__keyup=" + e.which;
			if(e.ctrlKey === false) href += "&ctrlKey=0"
			else if(e.ctrlKey === true) href += "&ctrlKey=1"
			window.location.href = href;
		}
	});
}
