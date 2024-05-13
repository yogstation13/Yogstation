/datum/map_template/shipbreaker
	should_place_on_top = TRUE
	returns_created_atoms = TRUE
	keep_cached_map = TRUE

	var/template_id
	var/description
	var/datum/parsed_map/lastparsed


/datum/map_template/shipbreaker/syndicate_old
	name = "Old Syndicate Ship"
	template_id = "old_syndicate"
	description = "mapshaker_syndicate"
	mappath = "_maps/templates/shipbreaker/old_syndicate.dmm"


/datum/map_template/shipbreaker/nt_old
	name = "Old NT Medical Ship"
	template_id = "old_NT_Med"
	description = "mapshaker_NT_Med"
	mappath = "_maps/templates/shipbreaker/old_nt.dmm"

/datum/map_template/shipbreaker/robotics_old
	name = "Old Robotics Ship"
	template_id = "old_Robo"
	description = "mapshaker_old_robo"
	mappath = "_maps/templates/shipbreaker/old_robotics.dmm"
