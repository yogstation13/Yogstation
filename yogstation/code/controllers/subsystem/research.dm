/datum/controller/subsystem/research
	var/techweb_pixel_size = 0
	var/techweb_legacy = TRUE // basically, if we fail to run the graphvis then fall back to the old style of techweb display

/datum/controller/subsystem/research/initialize_all_techweb_nodes()
	. = ..()
	initialize_techweb_layout()

/datum/controller/subsystem/research/proc/initialize_techweb_layout()
	// do the techweb layout.
	// forgive me please
	techweb_pixel_size = 0
	var/dot_file = "strict digraph {\n"
	for(var/node_id in techweb_nodes)
		if(node_id == "ERROR")
			continue
		var/datum/techweb_node/node = techweb_nodes[node_id]
		node.ui_resolved = initial(node.ui_resolved)
		for(var/unlock_id in node.unlock_ids)
			dot_file += "\t[node_id] -> [unlock_id];\n"
	dot_file += "}"
	fdel("tmp/techweb_in.gv")
	fdel("tmp/techweb_reduced.gv")
	fdel("tmp/techweb_out.txt")
	text2file(dot_file, "tmp/techweb_in.gv")
	var/why_the_fuck_doesnt_windows_support_forward_slashes = world.system_type == MS_WINDOWS ? ".\\tools\\graphvis\\" : "./tools/graphvis/"
	var/list/result = world.shelleo("[why_the_fuck_doesnt_windows_support_forward_slashes]tred ./tmp/techweb_in.gv") // reduce the graph because we know TG put some real redundant shit in there that really doesnt need to be displayed.
	if(result[SHELLEO_ERRORLEVEL])
		world.log << "Error while reducing techweb graph!"
		world.log << result[SHELLEO_STDERR]
		return
	text2file(result[SHELLEO_STDOUT], "tmp/techweb_reduced.gv")
	result = world.shelleo({"[why_the_fuck_doesnt_windows_support_forward_slashes]neato -Nlabel="" -Nwidth="0.333" -Nheight="0.333" -Gsplines=line -Nfixedsize=true -Goverlap=false -Nshape=circle -Tplain -o"./tmp/techweb_out.txt" ./tmp/techweb_reduced.gv"})
	if(result[SHELLEO_ERRORLEVEL])
		world.log << "Error while creating techweb visualisation."
		world.log << result[SHELLEO_STDERR]
		return
	var/list/lines = splittext(file2text("./tmp/techweb_out.txt"), regex("\\r?\\n"))
	for(var/line in lines)
		var/list/split = splittext(line, " ")
		if(split[1] != "node")
			continue
		var/datum/techweb_node/node = techweb_nodes[split[2]]
		if(!node)
			continue
		node.ui_resolved = TRUE
		node.ui_x = text2num(split[3]) * 130
		node.ui_y = text2num(split[4]) * 130
		techweb_pixel_size = max(techweb_pixel_size, abs(node.ui_x))
		techweb_pixel_size = max(techweb_pixel_size, abs(node.ui_y))

	techweb_legacy = FALSE // Success! Let's use the better techweb UI now.
	techweb_pixel_size += 300
	return
