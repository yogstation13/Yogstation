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
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	invocation_type = INVOCATION_NONE
	psi_cost = 30
	var/datum/status_effect/tagalong/tagalong
	hand_path = /obj/item/melee/touch_attack/darkspawn

/datum/action/cooldown/spell/touch/umbral_trespass/cast(mob/living/carbon/cast_on)
	if(tagalong)
		var/possessing = FALSE
		if(cast_on.has_status_effect(STATUS_EFFECT_TAGALONG))
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

//////////////////////////////////////////////////////////////////////////
//-------------------Scout and warlock, erase time----------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/erase_time/darkspawn
	name = "Quantum disruption"
	desc = "Disrupt the flow of possibilities, where you are, where you could be."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "time_dilation"
	panel = null
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	psi_cost = 100 //lol
	cooldown_time = 60 SECONDS
	length = 5 SECONDS
	guardian_lock = FALSE

/datum/action/cooldown/spell/erase_time/darkspawn/cast(mob/living/user)
	. = ..()
	if(. && isdarkspawn(owner))
		var/datum/antagonist/darkspawn/shadowling = isdarkspawn(owner)
		shadowling.block_psi(10 SECONDS)

//////////////////////////////////////////////////////////////////////////
//-----------------Scout and warlock, aoe slow and chill----------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/aoe/icyveins //Stuns and freezes nearby people - a bit more effective than a changeling's cryosting
	name = "Icy Veins"
	desc = "Instantly freezes the blood of nearby people, stunning them and causing burn damage while hampering their movement."
	button_icon = 'yogstation/icons/mob/actions.dmi'
	button_icon_state = "icy_veins"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	sound = 'sound/effects/ghost2.ogg'
	aoe_radius = 3
	panel = null
	antimagic_flags = NONE
	check_flags =  AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	cooldown_time = 1 MINUTES

/datum/action/cooldown/spell/aoe/icyveins/cast(atom/cast_on)
	. = ..()
	to_chat(owner, span_velvet("You freeze the nearby air."))

/datum/action/cooldown/spell/aoe/icyveins/cast_on_thing_in_aoe(atom/target, atom/user)
	if(!can_see(user, target))
		return
	if(!isliving(target))
		return
	var/mob/living/victim = target
	if(is_darkspawn_or_veil(victim)) //no friendly fire
		return
	to_chat(victim, span_userdanger("A wave of shockingly cold air engulfs you!"))
	victim.apply_damage(5, BURN)
	if(victim.reagents)
		victim.reagents.add_reagent(/datum/reagent/consumable/frostoil, 5)
		victim.reagents.add_reagent(/datum/reagent/shadowfrost, 5)
