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
	spell_requirements = SPELL_REQUIRES_DARKSPAWN
	hand_path = /obj/item/melee/touch_attack/veil_mind

/datum/action/cooldown/spell/touch/veil_mind/is_valid_target(atom/cast_on)
	return ishuman(cast_on)

/datum/action/cooldown/spell/touch/veil_mind/cast_on_hand_hit(obj/item/melee/touch_attack/hand, mob/living/carbon/human/target, mob/living/carbon/human/caster)
	if(!target.mind)
		to_chat(owner, "This mind is too feeble to even be worthy of veiling.")
		return
	owner.visible_message(span_warning("[owner]'s sigils flare as they inhale..."), "<span class='velvet bold'>dawn kqn okjc...</span><br>[span_notice("You take a deep breath...")]")
	playsound(owner, 'yogstation/sound/ambience/antag/veil_mind_gasp.ogg', 25)
	if(!do_after(owner, 2 SECONDS, owner))
		return FALSE
	owner.visible_message(span_boldwarning("[owner] lets out a chilling cry!"), "<span class='velvet bold'>...wjz oanra</span><br>[span_notice("You veil the minds of [target].")]")
	playsound(owner, 'yogstation/sound/ambience/antag/veil_mind_scream.ogg', 100)
	if(isveil(target))
		target.revive(1)
	else
		if(target.has_status_effect(STATUS_EFFECT_BROKEN_WILL) && target.add_veil())
			to_chat(owner, span_velvet("<b>[target.real_name]</b> has become a veil!"))
		else
			to_chat(owner, span_velvet("[target]'s will is still too strong to veil"))
			return FALSE
	return TRUE

/obj/item/melee/touch_attack/veil_mind
	name = "Veiling hand"
	desc = "Concentrated psionic power, primed to toy with mortal minds."
	icon_state = "flagellation"
	item_state = "hivemind"

//////////////////////////////////////////////////////////////////////////
//--------------------------Veil Camera System--------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/pointed/darkspawn_trap/veil_cam
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
	if(isdarkspawn(owner))
		var/datum/antagonist/darkspawn/antag = isdarkspawn(owner)
		var/darkspawns_too = FALSE //change this to check for a special darkspawn variable

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
