/datum/color_palette/generic_colors
	var/hair_color
	var/mutant_color
	var/mutant_color_secondary
	var/fur_color
	var/ethereal_color

/datum/color_palette/generic_colors/apply_prefs(datum/preferences/incoming)
	hair_color = incoming.read_preference(/datum/preference/color/hair_color)
	mutant_color = incoming.read_preference(/datum/preference/color/mutant_color)
	mutant_color_secondary = incoming.read_preference(/datum/preference/color/mutant_color_secondary)
	fur_color = incoming.read_preference(/datum/preference/color/fur_color)
	ethereal_color =  GLOB.color_list_ethereal[incoming.read_preference(/datum/preference/choiced/ethereal_color)]
