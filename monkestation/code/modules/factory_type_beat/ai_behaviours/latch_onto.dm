
/datum/ai_behavior/hunt_target/latch_onto

/datum/ai_behavior/hunt_target/latch_onto/setup(datum/ai_controller/controller, hunting_target_key, hunting_cooldown_key)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	if(living_pawn.buckled)
		return FALSE

/datum/ai_behavior/hunt_target/latch_onto/target_caught(mob/living/hunter, obj/hunted)
	if(hunter.buckled)
		return FALSE
	if(!hunted.buckle_mob(hunter, force = TRUE))
		return FALSE
	hunted.visible_message(span_notice("[hunted] has been latched onto by [hunter]!"))
	return TRUE
