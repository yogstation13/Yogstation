//////////////////////////////////////////////////////////////////////////
//-------------------Abilities that only two classes get----------------//
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//-------------------Scout and warlock, hide in person------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/touch/umbral_trespass
	name = "Umbral trespass"
	desc = "Melds with a target's shadow, causing you to invisibly follow them. Only works in lit areas, and you will be forced out if you hold any items. Costs 30 Psi."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "tagalong"
	panel = null
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_HANDS_BLOCKED | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_DARKSPAWN
	psi_cost = 30
	var/datum/status_effect/tagalong/tagalong
	hand_path = /obj/item/melee/touch_attack/umbral_trespass

/datum/action/cooldown/spell/touch/umbral_trespass/cast(mob/living/carbon/cast_on)
	if(tagalong)
		var/possessing = FALSE
		if(caster.has_status_effect(STATUS_EFFECT_TAGALONG))
			possessing = TRUE
		QDEL_NULL(tagalong)
		if(possessing)
			return //only return if the user is actually still hiding
	. = ..()
	
/datum/action/cooldown/spell/touch/umbral_trespass/cast_on_hand_hit(obj/item/melee/touch_attack/hand, mob/living/carbon/human/target, mob/living/carbon/human/caster)
	tagalong = caster.apply_status_effect(STATUS_EFFECT_TAGALONG, target)
	to_chat(caster, span_velvet("<b>iahz</b><br>You slip into [target]'s shadow. This will last five minutes, until canceled, or you are forced out."))
	caster.forceMove(target)
	return TRUE

/obj/item/melee/touch_attack/umbral_trespass
	name = "Veiling hand"
	desc = "Concentrated psionic power, primed to toy with mortal minds."
	icon_state = "flagellation"
	item_state = "hivemind"
