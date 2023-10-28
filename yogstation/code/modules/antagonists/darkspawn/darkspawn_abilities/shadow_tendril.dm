//Equips umbral tendrils with many uses.
/datum/action/cooldown/spell/toggle/shadow_tendril
	name = "Shadow Tendril"
	desc = "Twists an active arm into a mass of tendrils with many important uses. Examine the tendrils to see a list of uses."
	panel = null
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "pass"
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_CONSCIOUS | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_DARKSPAWN
	var/twin = FALSE

/datum/action/cooldown/spell/toggle/shadow_tendril/can_cast_spell(feedback)
	if(!owner.get_empty_held_indexes())
		if(feedback)
			to_chat(owner, span_warning("You need an empty hand for this!"))
		return FALSE
	. = ..()

/datum/action/cooldown/spell/toggle/shadow_tendril/process()
	active = owner.is_holding_item_of_type(/obj/item/umbral_tendrils)
	if(twin)
		name = "Twinned Shadow Tendrils"
		desc = "Twists one or both of your arms into tendrils with many uses."
	. = ..()

/datum/action/cooldown/spell/toggle/shadow_tendril/Enable()
	var/list/hands_free = owner.get_empty_held_indexes()
	if(!twin || hands_free.len < 2)
		owner.visible_message(span_warning("[owner]'s arm contorts into tentacles!"), "<span class='velvet bold'>ikna</span><br>\
		[span_notice("You transform your arm into umbral tendrils. Examine them to see possible uses.")]")
		playsound(owner, 'yogstation/sound/magic/pass_create.ogg', 50, 1)
		var/obj/item/umbral_tendrils/T = new(owner, isdarkspawn(owner))
		owner.put_in_hands(T)
	else
		owner.visible_message(span_warning("[owner]'s arms contort into tentacles!"), "<span class='velvet'><b>ikna ikna</b><br>\
		You transform both arms into umbral tendrils. Examine them to see possible uses.</span>")
		playsound(owner, 'yogstation/sound/magic/pass_create.ogg', 50, TRUE)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), owner, 'yogstation/sound/magic/pass_create.ogg', 50, TRUE), 1)
		for(var/i in 1 to 2)
			var/obj/item/umbral_tendrils/T = new(owner, isdarkspawn(owner) )
			owner.put_in_hands(T)

/datum/action/cooldown/spell/toggle/shadow_tendril/Disable()
	owner.visible_message(span_warning("[owner]'s tentacles transform back!"), "<span class='velvet bold'>haoo</span><br>\
	[span_notice("You dispel the tendrils.")]")
	playsound(owner, 'yogstation/sound/magic/pass_dispel.ogg', 50, 1)
	for(var/obj/item/umbral_tendrils/T in owner)
		qdel(T)
