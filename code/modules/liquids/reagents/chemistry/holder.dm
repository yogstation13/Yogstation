/// Like add_reagent but you can enter a list. Adds them with no_react = TRUE. Format it like this: list(/datum/reagent/toxin = 10, "beer" = 15)
/datum/reagents/proc/add_noreact_reagent_list(list/list_reagents, list/data=null)
	for(var/r_id in list_reagents)
		var/amt = list_reagents[r_id]
		add_reagent(r_id, amt, data, no_react = TRUE)

/proc/reagent_process_flags_valid(mob/processor, datum/reagent/reagent)
	/*
	if(ishuman(processor))
		
		var/mob/living/carbon/human/human_processor = processor
		//Check if this mob's species is set and can process this type of reagent
		//If we somehow avoided getting a species or reagent_flags set, we'll assume we aren't meant to process ANY reagents
		if(human_processor.dna && human_processor.dna.species.reagent_flags)
			var/processor_flags = human_processor.dna.species.reagent_flags
			if((reagent.process_flags & REAGENT_SYNTHETIC) && (processor_flags & PROCESS_SYNTHETIC))		//SYNTHETIC-oriented reagents require PROCESS_SYNTHETIC
				return TRUE
			if((reagent.process_flags & REAGENT_ORGANIC) && (processor_flags & PROCESS_ORGANIC))		//ORGANIC-oriented reagents require PROCESS_ORGANIC
				return TRUE
		return FALSE
	else if(reagent.process_flags == REAGENT_SYNTHETIC)
		//We'll assume that non-human mobs lack the ability to process synthetic-oriented reagents (adjust this if we need to change that assumption)
		return FALSE
	*/
	return TRUE
