/datum/map_template/shipbreaker
	should_place_on_top = FALSE
	returns_created_atoms = TRUE
	keep_cached_map = TRUE

	var/template_id
	var/description
	var/datum/parsed_map/lastparsed



/datum/map_template/shipbreaker/nt_old
	name = "Old NT Ship"
	template_id = "old_nt"
	description = "mapshaker"
	mappath = "_maps/templates/shipbreaker/old_nt.dmm"
