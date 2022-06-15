///Not actually structure related, but actually interactions. This ones are used when clicking on random dudes and trying to do something with them.

/datum/hog_god_interaction/targeted/recall
	name = "Recall"
	description = "Recalls a cultist to your nexus after 7 seconds delay."
	cost = 250 ///Saving a dude from death or deconversion should be pretty expensive, no?
	cooldown = 7 MINUTES

/datum/hog_god_interaction/targeted/recall/on_targeting(var/mob/camera/hog_god/user, var/atom/target) ///Same as on_use but for targeted ones
	if(!istype(target, /mob/living))
		to_chat(user, span_warning("Not a valid target!"))
		qdel(src)
		return
	var/mob/living/dude = target
	if(!IS_HOG_CULTIST(dude))
		to_chat(user, span_warning("You can target only your servants!"))
		qdel(src)
		return
	if(!dude)
		qdel(src)
		return
	if(!user.recall(dude))
		to_chat(user, span_notice("You fail to recall [target]..."))
		qdel(src)
		return
	else
		to_chat(dude, span_notice("You suddenly appear near your cult's nexus..."))
		to_chat(user, span_notice("You sucessfully recall [target]..."))	

	. = ..()

	qdel(src)

/datum/hog_god_interaction/targeted/purge
	name = "Purge"
	description = "Removes heretical reagents from your servant's body. Usefull to prevent deconvertion." ///Removes holy, unholy water and eldritch essence
	cost = 75
	cooldown = 3 MINUTES

/datum/hog_god_interaction/targeted/purge/on_targeting(var/mob/camera/hog_god/user, var/atom/target) ///Same as on_use but for targeted ones
	if(!iscarbon(target))
		to_chat(user, span_warning("Not a valid target!"))
		qdel(src)
		return
	var/mob/living/carbon/dude = target
	if(!IS_HOG_CULTIST(dude))
		to_chat(user, span_warning("You can target only your servants!"))
		qdel(src)
		return
	if(!dude)
		qdel(src)
		return
	to_chat(user, span_warning("You purge heretical reagents from [dude]'s blood!"))
	to_chat(dude, span_warning("You feel your god's light cleaning your bloodstream!"))
	dude.remove_reagent(/datum/reagent/water/holywater, 60)
	dude.remove_reagent(/datum/reagent/fuel/unholywater, 60)
	dude.remove_reagent(/datum/reagent/eldritch, 60)       


	. = ..()

	qdel(src)

	
