/datum/dna
	///this is our list of color palettes we care about
	///this is typically just for species
	var/list/color_palettes

/datum/dna/New(mob/living/new_holder)
	. = ..()
	for(var/datum/species/listed_species as anything in typesof(/datum/species))
		if(!initial(listed_species.color_palette))
			continue
		var/datum/species/created = new listed_species
		color_palettes = list()
		color_palettes += created.color_palette
		var/datum/color_palette/new_palette = new created.color_palette
		if(holder?.client?.prefs)
			new_palette.apply_prefs(holder.client.prefs)
		color_palettes[created.color_palette] = new_palette

	var/static/list/generic_colors = list(/datum/color_palette/generic_colors)
	for(var/datum/color_palette/palette as anything in generic_colors)
		color_palettes += palette
		var/datum/color_palette/new_palette = new palette
		if(holder?.client?.prefs)
			new_palette.apply_prefs(holder.client.prefs)
		color_palettes[palette] = new_palette

/datum/dna/proc/apply_color_palettes(datum/preferences/applied)
	for(var/datum/species/listed_species as anything in typesof(/datum/species))
		if(!initial(listed_species.color_palette))
			continue
		var/datum/species/created = new listed_species
		color_palettes = list()
		color_palettes += created.color_palette
		var/datum/color_palette/new_palette = new created.color_palette
		new_palette.apply_prefs(applied)
		color_palettes[created.color_palette] = new_palette

	var/static/list/generic_colors = list(/datum/color_palette/generic_colors)
	for(var/datum/color_palette/palette as anything in generic_colors)
		color_palettes += palette
		var/datum/color_palette/new_palette = new palette
		new_palette.apply_prefs(applied)
		color_palettes[palette] = new_palette
