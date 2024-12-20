/// Returns a list of the lighting level of each open turf on a z-level.
/proc/encode_lighting_levels(z) as /list
	RETURN_TYPE(/list)
	if(!isnum(z) || !ISINRANGE(z, 1, world.maxz))
		z = SSmapping.levels_by_trait(ZTRAIT_STATION)[1]
		stack_trace("Invalid z-level given, defaulting to first station z-level ([z])")
	var/list/lighting = new(world.maxx, world.maxy)
	for(var/turf/open/floor/floor in Z_TURFS(z))
		lighting[floor.x][floor.y] = floor.is_softly_lit() ? 0 : floor.get_lumcount()
		CHECK_TICK
	return lighting

/client/proc/export_lighting_info()
	set name = "Export Lighting Info"
	set desc = "Exports a JSON file containing info about the lighting level of all floor turfs on a given Z-level."
	set category = "Mapping"

	if(!check_rights(R_DEBUG))
		return
	var/list/options = list("All Station Z-Levels")
	var/turf/our_turf = get_turf(mob)
	if(!isnewplayer(mob) && !isnull(our_turf))
		options += "Current Z-Level"
	var/list/zs
	switch(tgui_alert(src, "What Z-levels would you like to export lighting info for?", "Select Z Levels", options + list("Cancel")))
		if("All Station Z-Levels")
			zs = SSmapping.levels_by_trait(ZTRAIT_STATION)
		if("Current Z-Level")
			zs = list(our_turf.z)
		else
			return

	var/list/lighting_info = list()
	switch(length(zs))
		if(1)
			lighting_info = encode_lighting_levels(zs[1])
		if(2 to INFINITY)
			for(var/z in zs)
				lighting_info["[z]"] = encode_lighting_levels(z)
		else
			to_chat(src, span_warning("No Z-levels selected!"))
			return

	var/file_name = "[ckey]_lighting_info_[time2text(world.timeofday, "MMM_DD_YYYY_hh-mm-ss")].json"
	var/json_file = file("tmp/[file_name]")
	WRITE_FILE(json_file, json_encode(lighting_info))
	DIRECT_OUTPUT(src, ftp(json_file, file_name))
