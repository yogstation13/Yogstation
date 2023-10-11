//Equips umbral tendrils with many uses.
/datum/action/innate/pass
	name = "Pass"
	desc = "Twists an active arm into tendrils with many important uses. Examine the tendrils to see a list of uses."
	button_icon_state = "pass"
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_CONSCIOUS
	var/twin = FALSE

/datum/action/innate/pass/IsAvailable(feedback = FALSE)
	if(istype(owner, /mob/living/simple_animal/hostile/crawling_shadows) || istype(owner, /mob/living/simple_animal/hostile/darkspawn_progenitor) || !owner.get_empty_held_indexes() && !active)
		return
	return ..()

/datum/action/innate/pass/process()
	..()
	active = locate(/obj/item/umbral_tendrils) in owner
	if(twin)
		name = "Twinned Pass"
		desc = "Twists one or both of your arms into tendrils with many uses."

/datum/action/innate/pass/Activate()
	var/mob/living/carbon/C = owner
	if(!(C.mobility_flags & MOBILITY_STAND))
		to_chat(owner, span_warning("Stand up first!"))
		return
	var/list/hands_free = owner.get_empty_held_indexes()
	if(!twin || hands_free.len < 2)
		owner.visible_message(span_warning("[owner]'s arm contorts into tentacles!"), "<span class='velvet bold'>ikna</span><br>\
		[span_notice("You transform your arm into umbral tendrils. Examine them to see possible uses.")]")
		playsound(owner, 'yogstation/sound/magic/pass_create.ogg', 50, 1)
		var/obj/item/umbral_tendrils/T = new(owner, darkspawn)
		owner.put_in_hands(T)
	else
		owner.visible_message(span_warning("[owner]'s arms contort into tentacles!"), "<span class='velvet'><b>ikna ikna</b><br>\
		You transform both arms into umbral tendrils. Examine them to see possible uses.</span>")
		playsound(owner, 'yogstation/sound/magic/pass_create.ogg', 50, TRUE)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), owner, 'yogstation/sound/magic/pass_create.ogg', 50, TRUE), 1)
		for(var/i in 1 to 2)
			var/obj/item/umbral_tendrils/T = new(owner, darkspawn)
			owner.put_in_hands(T)
	return TRUE

/datum/action/innate/pass/Deactivate()
	owner.visible_message(span_warning("[owner]'s tentacles transform back!"), "<span class='velvet bold'>haoo</span><br>\
	[span_notice("You dispel the tendrils.")]")
	playsound(owner, 'yogstation/sound/magic/pass_dispel.ogg', 50, 1)
	for(var/obj/item/umbral_tendrils/T in owner)
		qdel(T)
	return TRUE
