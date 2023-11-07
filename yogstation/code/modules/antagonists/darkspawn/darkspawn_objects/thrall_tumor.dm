//Snowflake spot for putting sling organ related stuff
/obj/item/organ/shadowtumor
	name = "black tumor"
	desc = "A tiny black mass with red tendrils trailing from it. It seems to shrivel in the light."
	icon_state = "blacktumor"
	w_class = 1
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_BRAIN_TUMOR
	var/organ_health = 3

/obj/item/organ/shadowtumor/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/organ/shadowtumor/Destroy()
	STOP_PROCESSING(SSobj, src)
	..()

/obj/item/organ/shadowtumor/process()
	if(!isveil(owner) && !owner.add_veil())
		qdel(src)
	if(isturf(loc))
		var/turf/T = loc
		var/light_count = T.get_lumcount()
		if(light_count > SHADOW_SPECIES_BRIGHT_LIGHT && organ_health > 0) //Die in the light
			organ_health--
		else if(light_count < SHADOW_SPECIES_BRIGHT_LIGHT && organ_health < 3) //Heal in the dark
			organ_health = min(organ_health + 1, 3)
		if(organ_health <= 0)
			visible_message(span_warning("[src] collapses in on itself!"))
			qdel(src)
	else
		organ_health = min(organ_health+0.5, 3)

/obj/item/organ/shadowtumor/on_find(mob/living/finder)
	. = ..()
	finder.visible_message(span_danger("[finder] opens up [owner]'s skull, revealing a pulsating black mass, with red tendrils attaching it to [owner.p_their()] brain."))

/obj/item/organ/shadowtumor/Remove(mob/living/carbon/M, special)
	// if(M.stat != DEAD) //Empowered thralls cannot be deconverted
	// 	to_chat(M, span_velvet("<b><i>NOT LIKE THIS!</i></b>"))
	// 	M.visible_message(span_danger("[M] suddenly slams upward and knocks down everyone!"))
	// 	M.resting = FALSE //Remove all stuns
	// 	M.SetAllImmobility(0, TRUE)
	// 	for(var/mob/living/user in range(2, src))
	// 		if(is_veil_or_darkspawn(user))
	// 			return
	// 		if(iscarbon(user))
	// 			var/mob/living/carbon/C = user
	// 			C.Knockdown(6)
	// 			C.adjustBruteLoss(20)
	// 		else if(issilicon(user))
	// 			var/mob/living/silicon/S = user
	// 			S.Knockdown(8)
	// 			S.adjustBruteLoss(20)
	// 			playsound(S, 'sound/effects/bang.ogg', 50, 1)
	// 	return FALSE
	. = ..()
	if(isturf(loc))//only do this if the tumor is removed from the head, not if the head gets cut off
		M.remove_veil()
		M.update_sight()
		M.visible_message(span_warning("A strange black mass falls from [M]'s head!"))
