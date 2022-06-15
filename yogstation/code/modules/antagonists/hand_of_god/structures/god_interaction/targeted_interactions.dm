///Not actually structure related, but actually interactions. This ones are used when clicking on random dudes and trying to do something with them.

/datum/hog_god_interaction/targeted/recall
	name = "Recall"
	description = "Recalls a cultist to your nexus after 7 seconds delay."
	cost = 250 ///Saving a dude from death or deconversion should be pretty expensive, no?
	cooldown = 7 MINUTES

/datum/hog_god_interaction/targeted/recall/on_targeting(var/mob/camera/hog_god/user, var/atom/target) ///Same as on_use but for targeted ones
	if(!istype(target, mob/living))
		to_chat(user, span_warning("Not a valid target!"))
		qdel(src)
		return
	if(!IS_HOG_CULTIST(target))
		to_chat(user, span_warning("You can target only your servants!"))
		qdel(src)
		return
	var/mob/living/dude = target
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


	
