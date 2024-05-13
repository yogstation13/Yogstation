/datum/map_template/shipbreaker
	should_place_on_top = FALSE
	returns_created_atoms = TRUE
	keep_cached_map = TRUE

	var/template_id
	var/description
	var/datum/parsed_map/lastparsed


/datum/map_template/shipbreaker/syndicate_old
	name = "Old Syndicate Ship"
	template_id = "old_syndicate"
	description = "mapshaker"
	mappath = "_maps/templates/shipbreaker/old_syndicate.dmm"
