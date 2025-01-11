/obj/item/processing
	name = "generic"
	desc = "oopsie"
	icon = 'monkestation/code/modules/factory_type_beat/icons/processing.dmi'
	icon_state = "dust"

/obj/item/processing/proc/set_colors()
	for(var/datum/material/material as anything in custom_materials)
		color = material.greyscale_colors
		alpha = material.alpha

/obj/item/processing/refined_dust
	name = "refined dust"
	desc = "After being enriched it has turned into some dust."

	/// Cooldown used to prevents boulders from getting processed back into a machine immediately after being processed.
	COOLDOWN_DECLARE(processing_cooldown)

/**
 * Handles the dust's processing cooldown to check if it's ready to be processed again.
 */
/obj/item/processing/refined_dust/proc/can_get_processed()
	return COOLDOWN_FINISHED(src, processing_cooldown)

/**
 * Starts the dust's processing cooldown.
 */
/obj/item/processing/refined_dust/proc/restart_processing_cooldown()
	COOLDOWN_START(src, processing_cooldown, 2 SECONDS)

/obj/item/processing/dirty_dust
	name = "dirty dust"
	desc = "After crushing some clumps we are left with this."
	icon = 'monkestation/icons/obj/items/drugs.dmi'
	icon_state = "crack"

/obj/item/processing/clumps
	name = "ore clumps"
	desc = "After being purified we are left with some clumps of ore."
	icon_state = "clump"

/obj/item/processing/shards
	name = "ore shards"
	desc = "After being filled with chemicals we are left with some shards of ores."
	icon_state = "shard"

/obj/item/processing/crystals
	name = "ore crystals"
	desc = "After crystalizing some clean slurry we have crystals."
	icon_state = "crystal"

/datum/reagent/processing
	name = "Generic Processing Reagent"
	data = list("materials" = list())
	restricted = TRUE

/datum/reagent/processing/dirty_slurry
	name = "Dirty Slurry"

/datum/reagent/processing/clean_slurry
	name = "Clean Slurry"

/datum/reagent/brine
	name = "Brine"
	restricted = TRUE


/obj/item/processing/amalgam
	name = "ore amalgam"
	desc = "Pretty useless and jams up your processing."
	icon_state = "dust"

/obj/item/processing/ruined_shard
	name = "ruined shard"
	desc = "Pretty useless and jams up your processing."
	icon_state = "dust"
