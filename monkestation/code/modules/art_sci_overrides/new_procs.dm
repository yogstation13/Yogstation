/proc/random_rgb_pairlists(list/red_pairs, list/green_pairs, list/blue_pairs, list/alpha_pairs)
	if(!length(red_pairs) || !length(blue_pairs) || !length(green_pairs) || !length(alpha_pairs))
		return COLOR_CULT_RED

	if(!length(red_pairs) >= 2)
		red_pairs[2] = 255
	if(!length(blue_pairs) >= 2)
		blue_pairs[2] = 255
	if(!length(green_pairs) >= 2)
		green_pairs[2] = 255
	if(!length(alpha_pairs) >= 2)
		alpha_pairs[2] = 255

	var/red = rand(red_pairs[1], red_pairs[2])
	var/green = rand(green_pairs[1], green_pairs[2])
	var/blue = rand(blue_pairs[1], blue_pairs[2])
	var/alpha = rand(alpha_pairs[1], alpha_pairs[2])

	return rgb(red, green, blue, alpha)

///Spawn a new artifact
/proc/spawn_artifact(turf/loc, forced_origin = null, forced_effect = null)
	if (!loc)
		return
	if(!length(GLOB.artifact_effect_rarity))
		build_weighted_rarities()

	var/obj/type_of_artifact = pick_weight(list(
		/obj/structure/artifact = 70,
		/obj/item/artifact_item = 10,
		/obj/item/artifact_item_tiny = 10,
		/obj/item/stock_parts/cell/artifact = 2.5,
		/obj/item/gun/magic/artifact = 2.5,
		/obj/item/melee/artifact = 2.5,
		/obj/machinery/power/generator_artifact = 2.5
	))

	var/obj/A = new type_of_artifact(loc,forced_origin,forced_effect)
	return A


/proc/build_weighted_rarities()
	GLOB.artifact_effect_rarity["all"] = list() ///this needs to be created first for indexing sake
	for(var/datum/artifact_origin/origin as anything in subtypesof(/datum/artifact_origin))
		GLOB.artifact_effect_rarity[initial(origin.type_name)] = list()

	for(var/datum/artifact_effect/artifact_effect as anything in subtypesof(/datum/artifact_effect))
		var/weight = initial(artifact_effect.weight)
		if(!weight)
			continue
		GLOB.artifact_effect_rarity["all"][artifact_effect] = weight
		for(var/origin in GLOB.artifact_effect_rarity)
			if(origin in initial(artifact_effect.valid_origins))
				GLOB.artifact_effect_rarity[origin][artifact_effect] = weight
