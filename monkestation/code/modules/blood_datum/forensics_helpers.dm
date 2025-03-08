/datum/forensics
	/// Cached mixed color of all blood DNA on us
	var/cached_blood_dna_color

/atom/proc/get_blood_dna_color()
	if(forensics?.cached_blood_dna_color)
		return forensics.cached_blood_dna_color

	var/list/colors = list()
	var/list/all_dna = GET_ATOM_BLOOD_DNA(src)
	for(var/dna_sample in all_dna)
		colors += GLOB.blood_types[all_dna[dna_sample]]?.color
	list_clear_nulls(colors)
	var/final_color = COLOR_BLOOD
	if(length(colors))
		final_color = pop(colors)
		for(var/color in colors)
			final_color = BlendRGB(final_color, color, 0.5)
	forensics?.cached_blood_dna_color = final_color
	return final_color

/obj/effect/decal/cleanable/blood/get_blood_dna_color()
	return ..() || COLOR_BLOOD

/obj/effect/decal/cleanable/blood/drip/get_blood_dna_color()
	var/list/all_dna = GET_ATOM_BLOOD_DNA(src)
	return GLOB.blood_types[all_dna[all_dna[1]]]?.color || COLOR_BLOOD

/obj/effect/decal/cleanable/blood/add_blood_DNA(list/blood_DNA_to_add)
	var/first_dna = GET_ATOM_BLOOD_DNA_LENGTH(src)
	if(!..())
		return FALSE

	if(dried)
		return TRUE
	// Imperfect, ends up with some blood types being double-set-up, but harmless (for now)
	for(var/new_blood in blood_DNA_to_add)
		var/datum/blood_type/blood = GLOB.blood_types[blood_DNA_to_add[new_blood]]
		if(!blood)
			continue
		blood.set_up_blood(src, first_dna == 0)
	update_appearance()
	return TRUE
