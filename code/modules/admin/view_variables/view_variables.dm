/client/proc/debug_variables(datum/D in world)
	set category = "Misc.Server Debug"
	set name = "View Variables"
	//set src in world
	var/static/cookieoffset = rand(1, 9999) //to force cookies to reset after the round.

	if(!usr.client || !usr.client.holder) //The usr vs src abuse in this proc is intentional and must not be changed
		to_chat(usr, span_danger("You need to be an administrator to access this."), confidential = TRUE)
		return

	if(!D)
		return

	var/islist = islist(D)
	var/isappearance = isappearance(D)
	if (!islist && !istype(D) && !isappearance)
		return

	var/title = ""
	var/refid = REF(D)
	var/icon/sprite
	var/hash

	var/type = /list
	if (isappearance)
		type = /image
	else if (!islist)
		type = D.type



	if(istype(D, /atom) || isappearance)
		var/atom/AT = D
		if(AT.icon && AT.icon_state)
			sprite = new /icon(AT.icon, AT.icon_state)
			hash = md5(AT.icon)
			hash = md5(hash + AT.icon_state)
			src << browse_rsc(sprite, "vv[hash].png")

	title = "[D] ([REF(D)]) = [type]"
	var/formatted_type = replacetext("[type]", "/", "<wbr>/")

	var/sprite_text
	if(sprite)
		sprite_text = "<img src='vv[hash].png'></td><td>"
	var/list/header = islist(D)? list("<b>/list</b>") : D.vv_get_header()

	var/marked_line
	if(holder && holder.marked_datum && holder.marked_datum == D)
		marked_line = VV_MSG_MARKED
	var/varedited_line
	if(!isappearance && !islist && (D.datum_flags & DF_VAR_EDITED))
		varedited_line = VV_MSG_EDITED
	var/deleted_line
	if(!isappearance && !islist && D.gc_destroyed)
		deleted_line = VV_MSG_DELETED

	var/list/dropdownoptions = list()
	if (islist)
		dropdownoptions = list(
			"---",
			"Add Item" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_LIST_ADD),
			"Remove Nulls" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_LIST_ERASE_NULLS),
			"Remove Dupes" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_LIST_ERASE_DUPES),
			"Set len" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_LIST_SET_LENGTH),
			"Shuffle" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_LIST_SHUFFLE),
			"Show VV To Player" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_EXPOSE),
			"---"
			)
		for(var/i in 1 to length(dropdownoptions))
			var/name = dropdownoptions[i]
			var/link = dropdownoptions[name]
			dropdownoptions[i] = "<option value[link? "='[link]'":""]>[name]</option>"
	else if (!isappearance)
		dropdownoptions = D.vv_get_dropdown()

	var/list/names = list()
	if (!islist && !isappearance)
		for (var/V in D.vars)
			names += V
	sleep(0.1 SECONDS)//For some reason, without this sleep, VVing will cause client to disconnect on certain objects.

	var/list/variable_html = list()
	if (islist)
		var/list/L = D
		for (var/i in 1 to L.len)
			var/key = L[i]
			var/value
			if (IS_NORMAL_LIST(L) && !isnum(key))
				value = L[key]
			variable_html += debug_variable(i, value, 0, D)
	else if(isappearance(D))
		variable_html += debug_variable("type", D:type, 0, D)
		variable_html += debug_variable("name", D:name, 0, D)
		variable_html += debug_variable("desc", D:desc, 0, D)
		variable_html += debug_variable("suffix", D:suffix, 0, D)
		variable_html += debug_variable("text", D:text, 0, D)
		variable_html += debug_variable("icon", D:icon, 0, D)
		variable_html += debug_variable("icon_state", D:icon_state, 0, D)
		variable_html += debug_variable("visibility", D:visibility, 0, D)
		variable_html += debug_variable("luminosity", D:luminosity, 0, D)
		variable_html += debug_variable("opacity", D:opacity, 0, D)
		variable_html += debug_variable("density", D:density, 0, D)
		variable_html += debug_variable("verbs", D:verbs, 0, D)
		variable_html += debug_variable("dir", D:dir, 0, D)
		variable_html += debug_variable("gender", D:gender, 0, D)
		variable_html += debug_variable("tag", D:tag, 0, D)
		variable_html += debug_variable("overlays", D:overlays, 0, D)
		variable_html += debug_variable("underlays", D:underlays, 0, D)
		variable_html += debug_variable("layer", D:layer, 0, D)
		variable_html += debug_variable("parent_type", D:parent_type, 0, D)
		variable_html += debug_variable("mouse_over_pointer", D:mouse_over_pointer, 0, D)
		variable_html += debug_variable("mouse_drag_pointer", D:mouse_drag_pointer, 0, D)
		variable_html += debug_variable("mouse_drop_pointer", D:mouse_drop_pointer, 0, D)
		variable_html += debug_variable("mouse_drop_zone", D:mouse_drop_zone, 0, D)
		variable_html += debug_variable("animate_movement", D:animate_movement, 0, D)
		variable_html += debug_variable("screen_loc", D:screen_loc, 0, D)
		variable_html += debug_variable("infra_luminosity", D:infra_luminosity, 0, D)
		variable_html += debug_variable("invisibility", D:invisibility, 0, D)
		variable_html += debug_variable("mouse_opacity", D:mouse_opacity, 0, D)
		variable_html += debug_variable("pixel_x", D:pixel_x, 0, D)
		variable_html += debug_variable("pixel_y", D:pixel_y, 0, D)
		variable_html += debug_variable("pixel_step_size", D:pixel_step_size, 0, D)
		variable_html += debug_variable("pixel_z", D:pixel_z, 0, D)
		variable_html += debug_variable("override", D:override, 0, D)
		variable_html += debug_variable("glide_size", D:glide_size, 0, D)
		variable_html += debug_variable("maptext", D:maptext, 0, D)
		variable_html += debug_variable("maptext_width", D:maptext_width, 0, D)
		variable_html += debug_variable("maptext_height", D:maptext_height, 0, D)
		variable_html += debug_variable("transform", D:transform, 0, D)
		variable_html += debug_variable("alpha", D:alpha, 0, D)
		variable_html += debug_variable("color", D:color, 0, D)
		variable_html += debug_variable("blend_mode", D:blend_mode, 0, D)
		variable_html += debug_variable("appearance", D:appearance, 0, D)
		variable_html += debug_variable("maptext_x", D:maptext_x, 0, D)
		variable_html += debug_variable("maptext_y", D:maptext_y, 0, D)
		variable_html += debug_variable("plane", D:plane, 0, D)
		variable_html += debug_variable("appearance_flags", D:appearance_flags, 0, D)
		variable_html += debug_variable("pixel_w", D:pixel_w, 0, D)
		variable_html += debug_variable("render_source", D:render_source, 0, D)
		variable_html += debug_variable("render_target", D:render_target, 0, D)
	else
		names = sortList(names)
		for (var/V in names)
			if(D.can_vv_get(V))
				variable_html += D.vv_get_var(V)

	var/html = {"
<html>
	<head>
		<meta charset='UTF-8'>
		<title>[title]</title>
		<link rel="stylesheet" type="text/css" href="view_variables.css">
	</head>
	<body onload='selectTextField()' onkeydown='return handle_keydown()' onkeyup='handle_keyup()'>
		<script type="text/javascript">
			// onload
			function selectTextField() {
				var filter_text = document.getElementById('filter');
				filter_text.focus();
				filter_text.select();
				var lastsearch = getCookie("[refid][cookieoffset]search");
				if (lastsearch) {
					filter_text.value = lastsearch;
					updateSearch();
				}
			}
			function getCookie(cname) {
				var name = cname + "=";
				var ca = document.cookie.split(';');
				for(var i=0; i<ca.length; i++) {
					var c = ca\[i];
					while (c.charAt(0)==' ') c = c.substring(1,c.length);
					if (c.indexOf(name)==0) return c.substring(name.length,c.length);
				}
				return "";
			}

			// main search functionality
			var last_filter = "";
			function updateSearch() {
				var filter = document.getElementById('filter').value.toLowerCase();
				var vars_ol = document.getElementById("vars");

				if (filter === last_filter) {
					// An event triggered an update but nothing has changed.
					return;
				} else if (filter.indexOf(last_filter) === 0) {
					// The new filter starts with the old filter, fast path by removing only.
					var children = vars_ol.childNodes;
					for (var i = children.length - 1; i >= 0; --i) {
						try {
							var li = children\[i];
							if (li.innerText.toLowerCase().indexOf(filter) == -1) {
								vars_ol.removeChild(li);
							}
						} catch(err) {}
					}
				} else {
					// Remove everything and put back what matches.
					while (vars_ol.hasChildNodes()) {
						vars_ol.removeChild(vars_ol.lastChild);
					}

					for (var i = 0; i < complete_list.length; ++i) {
						try {
							var li = complete_list\[i];
							if (!filter || li.innerText.toLowerCase().indexOf(filter) != -1) {
								vars_ol.appendChild(li);
							}
						} catch(err) {}
					}
				}

				last_filter = filter;
				document.cookie="[refid][cookieoffset]search="+encodeURIComponent(filter);

				var lis_new = vars_ol.getElementsByTagName("li");
				for (var j = 0; j < lis_new.length; ++j) {
					lis_new\[j].style.backgroundColor = (j == 0) ? "#ffee88" : "white";
				}
			}

			// onkeydown
			function handle_keydown() {
				if(event.keyCode == 116) {  //F5 (to refresh properly)
					document.getElementById("refresh_link").click();
					event.preventDefault ? event.preventDefault() : (event.returnValue = false);
					return false;
				}
				return true;
			}

			// onkeyup
			function handle_keyup() {
				if (event.keyCode == 13) {  //Enter / return
					var vars_ol = document.getElementById('vars');
					var lis = vars_ol.getElementsByTagName("li");
					for (var i = 0; i < lis.length; ++i) {
						try {
							var li = lis\[i];
							if (li.style.backgroundColor == "#ffee88") {
								alist = lis\[i].getElementsByTagName("a");
								if(alist.length > 0) {
									location.href=alist\[0].href;
								}
							}
						} catch(err) {}
					}
				} else if(event.keyCode == 38){  //Up arrow
					var vars_ol = document.getElementById('vars');
					var lis = vars_ol.getElementsByTagName("li");
					for (var i = 0; i < lis.length; ++i) {
						try {
							var li = lis\[i];
							if (li.style.backgroundColor == "#ffee88") {
								if (i > 0) {
									var li_new = lis\[i-1];
									li.style.backgroundColor = "white";
									li_new.style.backgroundColor = "#ffee88";
									return
								}
							}
						} catch(err) {}
					}
				} else if(event.keyCode == 40) {  //Down arrow
					var vars_ol = document.getElementById('vars');
					var lis = vars_ol.getElementsByTagName("li");
					for (var i = 0; i < lis.length; ++i) {
						try {
							var li = lis\[i];
							if (li.style.backgroundColor == "#ffee88") {
								if ((i+1) < lis.length) {
									var li_new = lis\[i+1];
									li.style.backgroundColor = "white";
									li_new.style.backgroundColor = "#ffee88";
									return
								}
							}
						} catch(err) {}
					}
				} else {
					updateSearch();
				}
			}

			// onchange
			function handle_dropdown(list) {
				var value = list.options\[list.selectedIndex].value;
				if (value !== "") {
					location.href = value;
				}
				list.selectedIndex = 0;
				document.getElementById('filter').focus();
			}

			// byjax
			function replace_span(what) {
				var idx = what.indexOf(':');
				document.getElementById(what.substr(0, idx)).innerHTML = what.substr(idx + 1);
			}
		</script>
		<div align='center'>
			<table width='100%'>
				<tr>
					<td width='50%'>
						<table align='center' width='100%'>
							<tr>
								<td>
									[sprite_text]
									<div align='center'>
										[header.Join()]
									</div>
								</td>
							</tr>
						</table>
						<div align='center'>
							<b><font size='1'>[formatted_type]</font></b>
							<span id='marked'>[marked_line]</span>
							<span id='varedited'>[varedited_line]</span>
							<span id='deleted'>[deleted_line]</span>
						</div>
					</td>
					<td width='50%'>
						<div align='center'>
							<a id='refresh_link' href='?_src_=vars;[HrefToken()];datumrefresh=[refid]'>Refresh</a>
							<form>
								<select name="file" size="1"
									onchange="handle_dropdown(this)"
									onmouseclick="this.focus()"
									style="background-color:#ffffff">
									<option value selected>Select option</option>
									[dropdownoptions.Join()]
								</select>
							</form>
						</div>
					</td>
				</tr>
			</table>
		</div>
		<hr>
		<font size='1'>
			<b>E</b> - Edit, tries to determine the variable type by itself.<br>
			<b>C</b> - Change, asks you for the var type first.<br>
			<b>M</b> - Mass modify: changes this variable for all objects of this type.<br>
		</font>
		<hr>
		<table width='100%'>
			<tr>
				<td width='20%'>
					<div align='center'>
						<b>Search:</b>
					</div>
				</td>
				<td width='80%'>
					<input type='text' id='filter' name='filter_text' value='' style='width:100%;'>
				</td>
			</tr>
		</table>
		<hr>
		<ol id='vars'>
			[variable_html.Join()]
		</ol>
		<script type='text/javascript'>
			var complete_list = \[\];
			var lis = document.getElementById("vars").children;
			for(var i = lis.length; i--;) complete_list\[i\] = lis\[i\];
		</script>
	</body>
</html>
"}
	src << browse(html, "window=variables[refid];size=475x650")

/client/proc/vv_update_display(datum/D, span, content)
	src << output("[span]:[content]", "variables[REF(D)].browser:replace_span")
