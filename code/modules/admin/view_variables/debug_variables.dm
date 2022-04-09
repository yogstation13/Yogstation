#define VV_HTML_ENCODE(thing) ( sanitize ? html_encode(thing) : thing )
/// Get displayed variable in VV variable list
/proc/debug_variable(name, value, level, datum/DA = null, sanitize = TRUE)
	var/header
	if(DA && !isappearance(DA))
		if (islist(DA))
			var/index = name
			if (value)
				name = DA[name] //name is really the index until this line
			else
				value = DA[name]
			header = "<li style='backgroundColor:white'>([VV_HREF_TARGET_1V(DA, VV_HK_LIST_EDIT, "E", index)]) ([VV_HREF_TARGET_1V(DA, VV_HK_LIST_CHANGE, "C", index)]) ([VV_HREF_TARGET_1V(DA, VV_HK_LIST_REMOVE, "-", index)]) "
		else
			header = "<li style='backgroundColor:white'>([VV_HREF_TARGET_1V(DA, VV_HK_BASIC_EDIT, "E", name)]) ([VV_HREF_TARGET_1V(DA, VV_HK_BASIC_CHANGE, "C", name)]) ([VV_HREF_TARGET_1V(DA, VV_HK_BASIC_MASSEDIT, "M", name)]) "
	else
		header = "<li>"

	var/item
	if (isnull(value))
		item = "[VV_HTML_ENCODE(name)] = [span_value("null")]"

	else if (istext(value))
		item = "[VV_HTML_ENCODE(name)] = [span_value("\"[VV_HTML_ENCODE(value)]\"")]"

	else if (isicon(value))
		#ifdef VARSICON
		var/icon/I = new/icon(value)
		var/rnd = rand(1,10000)
		var/rname = "tmp[REF(I)][rnd].png"
		usr << browse_rsc(I, rname)
		item = "[VV_HTML_ENCODE(name)] = ([span_value("[value]")]) <img class=icon src=\"[rname]\">"
		#else
		item = "[VV_HTML_ENCODE(name)] = /icon ([span_value("[value]")])"
		#endif

	else if (isfile(value))
		item = "[VV_HTML_ENCODE(name)] = [span_value("'[value]'")]"

	else if(istype(value,/matrix)) // Needs to be before datum
		var/matrix/M = value
		item = {"[VV_HTML_ENCODE(name)] = <span class='value'>
			<table class='matrixbrak'><tbody><tr><td class='lbrak'>&nbsp;</td><td>
			<table class='matrix'>
			<tbody>
				<tr><td>[M.a]</td><td>[M.d]</td><td>0</td></tr>
				<tr><td>[M.b]</td><td>[M.e]</td><td>0</td></tr>
				<tr><td>[M.c]</td><td>[M.f]</td><td>1</td></tr>
			</tbody>
			</table></td><td class='rbrak'>&nbsp;</td></tr></tbody></table></span>"} //TODO link to modify_transform wrapper for all matrices

	else if(isappearance(value))
		var/image/I = value
		item = "<a href='?_src_=vars;[HrefToken()];Vars=[REF(value)]'>[VV_HTML_ENCODE(name)] [REF(value)]</a> = appearance([span_value("[I.icon]")], [span_value("\"[I.icon_state]\"")])"

	else if (istype(value, /datum))
		var/datum/D = value
		if ("[D]" != "[D.type]") //if the thing as a name var, lets use it.
			item = "<a href='?_src_=vars;[HrefToken()];Vars=[REF(value)]'>[VV_HTML_ENCODE(name)] [REF(value)]</a> = [D] [D.type]"
		else
			item = "<a href='?_src_=vars;[HrefToken()];Vars=[REF(value)]'>[VV_HTML_ENCODE(name)] [REF(value)]</a> = [D.type]"

	else if (islist(value))
		var/list/L = value
		var/list/items = list()

		if (L.len > 0 && !(L.len > (IS_NORMAL_LIST(L) ? 50 : 150)))
			for (var/i in 1 to L.len)
				var/key = L[i]
				var/val
				if (IS_NORMAL_LIST(L) && !isnum(key))
					val = L[key]
				if (isnull(val))	// we still want to display non-null false values, such as 0 or ""
					val = key
					key = i

				items += debug_variable(key, val, level + 1, sanitize = sanitize)

			item = "<a href='?_src_=vars;[HrefToken()];Vars=[REF(value)]'>[VV_HTML_ENCODE(name)] = /list ([L.len])</a><ul>[items.Join()]</ul>"
		else
			item = "<a href='?_src_=vars;[HrefToken()];Vars=[REF(value)]'>[VV_HTML_ENCODE(name)] = /list ([L.len])</a>"

	else if (name in GLOB.bitfields)
		var/list/flags = list()
		for (var/i in GLOB.bitfields[name])
			if (value & GLOB.bitfields[name][i])
				flags += i
			item = "[VV_HTML_ENCODE(name)] = [VV_HTML_ENCODE(jointext(flags, ", "))]"
	else
		item = "[VV_HTML_ENCODE(name)] = [span_value("[VV_HTML_ENCODE(value)]")]"

	return "[header][item]</li>"

#undef VV_HTML_ENCODE
