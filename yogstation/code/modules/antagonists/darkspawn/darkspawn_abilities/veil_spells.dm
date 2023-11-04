GLOBAL_DATUM_INIT(thrallnet, /datum/cameranet/darkspawn, new)

//////////////////////////////////////////////////////////////////////////
//-----------------------------Veil Creation----------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/touch/veil_mind
	name = "Veil mind"
	desc = "Consume a lucidity to veil a target's mind. To be eligible, they must be alive and recently drained by Devour Will."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "veil_mind"
	antimagic_flags = NONE
	panel = null
	check_flags =  AB_CHECK_IMMOBILE|AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	invocation_type = INVOCATION_NONE
	hand_path = /obj/item/melee/touch_attack/darkspawn

/datum/action/cooldown/spell/touch/veil_mind/is_valid_target(atom/cast_on)
	return ishuman(cast_on)

/datum/action/cooldown/spell/touch/veil_mind/cast_on_hand_hit(obj/item/melee/touch_attack/hand, mob/living/carbon/human/target, mob/living/carbon/human/caster)
	if(!target.mind)
		to_chat(owner, "This mind is too feeble to even be worthy of veiling.")
		return
	if(!target.has_status_effect(STATUS_EFFECT_BROKEN_WILL) && !isveil(target))
		to_chat(owner, span_velvet("[target]'s will is still too strong to veil"))
		return FALSE
	to_chat(owner, span_velvet("You begin to channel your psionic powers through [target]'s mind."))
	playsound(owner, 'yogstation/sound/ambience/antag/veil_mind_gasp.ogg', 25)
	if(!do_after(owner, 2 SECONDS, owner))
		return FALSE
	playsound(owner, 'yogstation/sound/ambience/antag/veil_mind_scream.ogg', 100)
	if(isveil(target))
		to_chat(owner, span_velvet("You revitalize your thrall [target.real_name]."))
		target.revive(1)
	else if(target.add_veil())
		to_chat(owner, span_velvet("<b>[target.real_name]</b> has become a veil!"))
	return TRUE

//////////////////////////////////////////////////////////////////////////
//----------------------------Get rid of a thrall-----------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/unveil_mind
	name = "Release veil"
	desc = "Release a veil from your control, freeing your power to be redistributed."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "veil_mind"
	antimagic_flags = NONE
	panel = null
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_DARKSPAWN

/datum/action/cooldown/spell/unveil_mind/can_cast_spell(feedback)
	if(!LAZYLEN(SSticker.mode.veils))
		if(feedback)
			to_chat(owner, "You have no veils to release.")
		return
	. = ..()
	
/datum/action/cooldown/spell/unveil_mind/cast(atom/cast_on)
	. = ..()
	var/loser = tgui_input_list(owner, "Select a veil to release from your control.", "Release a veil", SSticker.mode.veils)
	if(!loser || !istype(loser, /datum/mind))
		return
	var/datum/mind/unveiled = loser
	if(!unveiled.current)
		return
	unveiled.current.remove_veil()
	to_chat(owner, span_velvet("You release your control over [unveiled]"))

//////////////////////////////////////////////////////////////////////////
//--------------------------Veil Camera System--------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/pointed/darkspawn_build/veil_cam
	name = "Panopticon"
	desc = "Watch what your allies and servants are doing at all times."
	button_icon_state = "sacrament"
	cooldown_time = 1 MINUTES
	cast_time = 2 SECONDS
	object_type = /obj/machinery/computer/camera_advanced/darkspawn

//////////////////////////////////////////////////////////////////////////
//-----------------------Global AOE Buff spells-------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/veilbuff
	name = "Empower veil"
	desc = "buffs all veils with some sort of effect."
	panel = null
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "veil_sigils"
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 1 MINUTES
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	/// If the buff also buffs all darkspawns
	var/darkspawns_too = FALSE

/datum/action/cooldown/spell/veilbuff/before_cast(atom/cast_on)
	. = ..()
	/*
	if(isdarkspawn(owner))
		var/datum/antagonist/darkspawn/antag = isdarkspawn(owner)
		darkspawns_too = antag.buff_darkspawn					//change this to check for a special darkspawn variable
	*/

/datum/action/cooldown/spell/veilbuff/cast(atom/cast_on)
	. = ..()
	for(var/datum/antagonist/veil/lackey in GLOB.antagonists)
		if(lackey.owner?.current && ishuman(lackey.owner.current))
			var/mob/living/carbon/human/target = lackey.owner.current
			if(target && istype(target))//sanity check
				empower(target)
	if(darkspawns_too)
		for(var/datum/antagonist/darkspawn/ally in GLOB.antagonists)
			if(ally.owner?.current && ishuman(ally.owner.current))
				var/mob/living/carbon/human/target = ally.owner.current
				if(target && istype(target))//sanity check
					empower(target)
	
/datum/action/cooldown/spell/veilbuff/proc/empower(mob/living/carbon/human/target)
	return

////////////////////////////Global AOE heal//////////////////////////
/datum/action/cooldown/spell/veilbuff/heal
	name = "Heal veils"

/datum/action/cooldown/spell/veilbuff/empower(mob/living/carbon/human/target)
	target.heal_overall_damage(25, 25, 0, BODYPART_ANY)


//////////////////////////////////////////////////////////////////////////
//----------------------Abilities that thralls get----------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/pointed/glare/lesser //a defensive ability, nothing else. can't be used to stun people, steal tasers, etc. Just good for escaping
	name = "Lesser Glare"
	desc = "Makes a single target dizzy for a bit."
	button_icon = 'yogstation/icons/mob/actions.dmi'
	button_icon_state = "glare"
	ranged_mousepointer = 'icons/effects/mouse_pointers/cult_target.dmi'

	cooldown_time = 45 SECONDS
	spell_requirements = SPELL_REQUIRES_HUMAN
	strong = FALSE

/datum/action/cooldown/spell/toggle/nightvision
	name = "Nightvision"
	desc = "Grants sight in the dark."
	panel = null
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "pass"
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = NONE

/datum/action/cooldown/spell/toggle/nightvision/Enable()
	owner.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	owner.see_in_dark = 8

/datum/action/cooldown/spell/toggle/nightvision/Disable()
	owner.lighting_alpha = initial(owner.lighting_alpha)
	owner.see_in_dark = initial(owner.see_in_dark)
	owner.update_sight()
