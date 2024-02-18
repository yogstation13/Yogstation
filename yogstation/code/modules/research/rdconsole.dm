/obj/machinery/computer/rdconsole/Initialize(mapload)
	.=..()
	light_color = LIGHT_COLOR_PURPLE

/obj/machinery/computer/rdconsole/ui_techweb()
	// I fucking hate internet explorer so fucking much.
	if(ui_mode != RDCONSOLE_UI_MODE_NORMAL || SSresearch.techweb_legacy)
		return ..()
	var/list/l = list()
	l += "<div id='techweb-container' unselectable='on'><div id='techweb'>[RDSCREEN_NOBREAK]"
	for (var/node_ in stored_research.tiers)
		var/datum/techweb_node/node = SSresearch.techweb_node_by_id(node_)
		var/class = ""
		if(stored_research.researched_nodes[node_])
			class = ""
		else if(stored_research.available_nodes[node_])
			if(stored_research.can_afford(node.get_price(stored_research)))
				class = "available"
			else
				class = "too-expensive"
		else
			class = "unavailable"
		var/datum/design/displayed_design = SSresearch.techweb_design_by_id(node.design_ids.len ? node.design_ids[1] : null)
		l += {"
			<div class='technode-web-container'
			style='left:[node.ui_x]px;top:[node.ui_y]px'
			data-tooltip='[node.display_name] [node.price_display(stored_research)][!do_node_drag ? "" : " ([node.ui_x],[node.ui_y])"]'
			><div
			class='technode-web [class]'
			data-nodeid='[node_]'
			>[displayed_design.icon_html(usr)]</div></div>[RDSCREEN_NOBREAK]"}
		// now for the LINES
		for(var/prereq_id in node.prereq_ids)
			var/datum/techweb_node/prereq = SSresearch.techweb_node_by_id(prereq_id)
			var/line_class = ""
			if(stored_research.researched_nodes[prereq_id])
				line_class = "researched"
			var/dx = node.ui_x - prereq.ui_x
			var/dy = node.ui_y - prereq.ui_y
			var/len = sqrt(dx*dx+dy*dy) - 44
			var/angle = 90 - ATAN2(dy, dx)
			l += {"<div class='line [line_class] node-[node_] node-[prereq_id]'
				style='
					left:[prereq.ui_x]px;
					top:[prereq.ui_y]px;
					width:[len]px;
					transform: rotate([angle]deg) translate(22px,0px);
					-ms-transform: rotate([angle]deg) translate(22px, 0px);
				'
				data-outputfor="[prereq_id]"
				></div>[RDSCREEN_NOBREAK]"}
	l += "</div></div>[RDSCREEN_NOBREAK]"
	l += {"<script>
		var do_node_drag = [do_node_drag];
		var techweb = document.getElementById("techweb");
		var techweb_container = document.getElementById("techweb-container");
		var curr_px = 0;
		var curr_py = 0;
		if(sessionStorage) {
			curr_px = +sessionStorage.techweb_px || curr_px;
			curr_py = +sessionStorage.techweb_py || curr_py;
		}
		techweb.style.left = curr_px + "px";
		techweb.style.top = curr_py + "px";
		techweb_container.addEventListener("mousedown", function(e) {
			var nodeid = null;
			var nodeel = e.target;
			if(do_node_drag) {
				while(nodeel) {
					if(nodeel.getAttribute) {
						nodeid = nodeel.getAttribute("data-nodeid");
						if(nodeid) break;
					}
					nodeel = nodeel.parentNode;
				}
			}
			var nodecontainer;
			if(nodeid) nodecontainer = nodeel.parentNode;
			var curr_x = e.screenX;
			var curr_y = e.screenY;
			document.addEventListener("mousemove", mousemove);
			document.addEventListener("mouseup", mouseup);
			function mousemove(e) {
				if(nodeid) {
					nodecontainer.style.left = (parseInt(nodecontainer.style.left) + (e.screenX - curr_x)) + "px";
					nodecontainer.style.top = (parseInt(nodecontainer.style.top) + (e.screenY - curr_y)) + "px";
				} else {
					curr_px += e.screenX - curr_x;
					curr_py += e.screenY - curr_y;
					curr_px = Math.max(Math.min(curr_px, [SSresearch.techweb_pixel_size]), [-SSresearch.techweb_pixel_size]);
					curr_py = Math.max(Math.min(curr_py, [SSresearch.techweb_pixel_size]), [-SSresearch.techweb_pixel_size]);
					techweb.style.left = curr_px + "px";
					techweb.style.top = curr_py + "px";
				}
				curr_x = e.screenX;
				curr_y = e.screenY;
				if(sessionStorage) {
					sessionStorage.techweb_px = curr_px;
					sessionStorage.techweb_py = curr_py;
				}
			}
			function mouseup(e) {
				document.removeEventListener("mousemove", mousemove);
				document.removeEventListener("mouseup", mouseup);
				if(nodeid) {
					location = "?src=[REF(src)];move_node=" + nodeid + ";back_screen=[screen];ui_x=" + parseInt(nodecontainer.style.left) + ";ui_y=" + parseInt(nodecontainer.style.top);
					e.preventDefault();
				}
			}
		});
		techweb_container.addEventListener("wheel", function(e) {e.preventDefault();});
		function add_listeners(node) {
			var nodeid = node.getAttribute("data-nodeid");
			node.addEventListener("click", function(e) {
				if(do_node_drag) return;
				var verb = "view";
				if(e.altKey || e.button == 1)
					verb = "research";
				location = "?src=[REF(src)];" + verb + "_node=" + nodeid + ";back_screen=[screen]";
			});
			var lines = document.querySelectorAll(".node-" + nodeid);
			node.addEventListener("mouseover", function() {
				for(var i = 0; i < lines.length; i++) {
					lines\[i].setAttribute("data-showing", "true");
					if(lines\[i].getAttribute("data-outputfor") == nodeid)
						lines\[i].setAttribute("data-outputting", "true")
				}
			});
			node.addEventListener("mouseout", function() {
				for(var i = 0; i < lines.length; i++) {
					lines\[i].setAttribute("data-showing", "false");
					lines\[i].setAttribute("data-outputting", "false")
				}
			});
		}
		var nodes = document.querySelectorAll(".technode-web");
		for (var i = 0; i < nodes.length; i++) {
			add_listeners(nodes\[i]);
		}
	</script>[RDSCREEN_NOBREAK]"}
	return l

/obj/machinery/computer/rdconsole/proc/techweb_to_text()
	var/text = ""
	for (var/node_ in stored_research.tiers)
		var/datum/techweb_node/node = SSresearch.techweb_node_by_id(node_)
		text += "[node.type]\n\tui_x = [node.ui_x]\n\tui_y = [node.ui_y]\n\n"
	return text	
