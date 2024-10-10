/datum/color_palette/ornithids
	default_color = COLOR_AMETHYST

	var/feather_main
	var/feather_secondary
	var/feather_tri

	var/tail
	var/plummage

/datum/color_palette/ornithids/apply_prefs(datum/preferences/incoming)
	feather_main = incoming.read_preference(/datum/preference/color/feather_color)
	feather_secondary = incoming.read_preference(/datum/preference/color/feather_color_secondary)
	feather_tri = incoming.read_preference(/datum/preference/color/feather_color_tri)
	plummage = incoming.read_preference(/datum/preference/color/plummage_color)
	tail = incoming.read_preference(/datum/preference/color/feather_tail_color)

