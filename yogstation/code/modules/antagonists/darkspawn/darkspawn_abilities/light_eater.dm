/datum/action/cooldown/spell/toggle/light_eater
	name = "Light Eater"
	desc = "Twists an active arm blade of all-consuming shadow."
	panel = null
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "pass"
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_CONSCIOUS | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_DARKSPAWN

/datum/action/cooldown/spell/toggle/light_eater/process()
	active = owner.is_holding_item_of_type(/obj/item/light_eater)
	. = ..()

/datum/action/cooldown/spell/toggle/light_eater/can_cast_spell(feedback)
	if(!owner.get_empty_held_indexes())
		if(feedback)
			to_chat(owner, span_warning("You need an empty hand for this!"))
		return FALSE
	. = ..()

/datum/action/cooldown/spell/toggle/light_eater/Enable()
	var/list/hands_free = owner.get_empty_held_indexes()
	if(hands_free.len)
		owner.visible_message(span_warning("[owner]'s arm contorts into tentacles!"), "<span class='velvet bold'>ikna</span><br>\
		[span_notice("You transform your arm into umbral tendrils. Examine them to see possible uses.")]")
		playsound(owner, 'yogstation/sound/magic/pass_create.ogg', 50, 1)
		var/obj/item/light_eater/T = new(owner, owner.mind?.has_antag_datum(ANTAG_DATUM_DARKSPAWN))
		owner.put_in_hands(T)

/datum/action/cooldown/spell/toggle/light_eater/Disable()
	owner.visible_message(span_warning("[owner]'s tentacles transform back!"), "<span class='velvet bold'>haoo</span><br>\
	[span_notice("You dispel the tendrils.")]")
	playsound(owner, 'yogstation/sound/magic/pass_dispel.ogg', 50, 1)
	for(var/obj/item/light_eater/T in owner)
		qdel(T)
