//Equips umbral tendrils with many uses.
/datum/action/cooldown/spell/toggle/pass
	name = "Pass"
	desc = "Twists an active arm into tendrils with many important uses. Examine the tendrils to see a list of uses."
	panel = null
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "pass"
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_CONSCIOUS | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_DARKSPAWN
	var/twin = FALSE

/datum/action/cooldown/spell/toggle/pass/process()
	. = ..()
	active = locate(/obj/item/umbral_tendrils) in owner
	if(twin)
		name = "Twinned Pass"
		desc = "Twists one or both of your arms into tendrils with many uses."

/datum/action/cooldown/spell/toggle/pass/Enable()
	var/list/hands_free = owner.get_empty_held_indexes()
	if(!twin || hands_free.len < 2)
		owner.visible_message(span_warning("[owner]'s arm contorts into tentacles!"), "<span class='velvet bold'>ikna</span><br>\
		[span_notice("You transform your arm into umbral tendrils. Examine them to see possible uses.")]")
		playsound(owner, 'yogstation/sound/magic/pass_create.ogg', 50, 1)
		var/obj/item/umbral_tendrils/T = new(owner, owner.mind?.has_antag_datum(ANTAG_DATUM_DARKSPAWN))
		owner.put_in_hands(T)
	else
		owner.visible_message(span_warning("[owner]'s arms contort into tentacles!"), "<span class='velvet'><b>ikna ikna</b><br>\
		You transform both arms into umbral tendrils. Examine them to see possible uses.</span>")
		playsound(owner, 'yogstation/sound/magic/pass_create.ogg', 50, TRUE)
		addtimer(CALLBACK(GLOBAL_PROC, PROC_REF(playsound), owner, 'yogstation/sound/magic/pass_create.ogg', 50, TRUE), 1)
		for(var/i in 1 to 2)
			var/obj/item/umbral_tendrils/T = new(owner, owner.mind?.has_antag_datum(ANTAG_DATUM_DARKSPAWN))
			owner.put_in_hands(T)

/datum/action/cooldown/spell/toggle/pass/Disable()
	owner.visible_message(span_warning("[owner]'s tentacles transform back!"), "<span class='velvet bold'>haoo</span><br>\
	[span_notice("You dispel the tendrils.")]")
	playsound(owner, 'yogstation/sound/magic/pass_dispel.ogg', 50, 1)
	for(var/obj/item/umbral_tendrils/T in owner)
		qdel(T)
