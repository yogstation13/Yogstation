/datum/organ_process/reagent_conversion
	name = "Reagent Conversion"
	desc = "Converts reagents in your liver into something else"

	process_flags = ORGAN_LIVER
	var/datum/reagent/converted_reagent
	var/conversion_precent = 0.5

/datum/organ_process/reagent_conversion/New()
	. = ..()
	converted_reagent = /datum/reagent/consumable/ethanol

/datum/organ_process/reagent_conversion/trigger(datum/weakref/host, stability, trigger_value, list/extra_data)
	if(!host)
		return
	var/mob/living/mob = host.resolve()
	if(!mob.reagents)
		return
	var/volume_to_use = trigger_value * conversion_precent
	if(extra_data)
		if("reagent" in extra_data)
			mob.reagents.remove_all_type(extra_data["reagent"], volume_to_use)
		else
			mob.reagents.remove_all(volume_to_use)
	else
		mob.reagents.remove_all(volume_to_use)
	mob.reagents.add_reagent(converted_reagent, volume_to_use)
