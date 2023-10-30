GLOBAL_DATUM_INIT(veilnet, /datum/cameranet/darkspawn, new)

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
/datum/action/cooldown/spell/pointed/veil_cam
	name = "Veil net"
	desc = "Call up your boys."
	panel = null
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "sacrament"
	antimagic_flags = NONE
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_CONSCIOUS | AB_CHECK_LYING
	cooldown_time = 1 MINUTES
	spell_requirements = SPELL_REQUIRES_DARKSPAWN
	cast_range = 2
	var/casting = FALSE
	var/cast_time = 2 SECONDS

/datum/action/cooldown/spell/pointed/veil_cam/can_cast_spell(feedback)
	if(casting)
		return FALSE
	. = ..()

/datum/action/cooldown/spell/pointed/veil_cam/before_cast(atom/cast_on)
	. = ..()
	if(cast_on.density)
		return . | SPELL_CANCEL_CAST
	if(casting)
		return . | SPELL_CANCEL_CAST
	if(. & SPELL_CANCEL_CAST)
		return .
	casting = TRUE
	playsound(get_turf(owner), 'yogstation/sound/magic/devour_will_begin.ogg', 50, TRUE)
	if(!do_after(owner, cast_time, cast_on))
		casting = FALSE
		return . | SPELL_CANCEL_CAST
	casting = FALSE
	
/datum/action/cooldown/spell/pointed/veil_cam/cast(atom/cast_on)
	. = ..()
	owner.visible_message(span_warning("[owner] pulled shadows together into an orb!"), span_velvet("You summon your orb"))
	playsound(get_turf(owner), 'yogstation/sound/magic/devour_will_end.ogg', 50, TRUE)
	new /obj/machinery/computer/camera_advanced/darkspawn(get_turf(cast_on))
	
/obj/machinery/computer/camera_advanced/darkspawn
	name = "dark orb"
	desc = "SEND DUDES"
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer"
	special = TRUE
	use_power = NO_POWER_USE
	flags_1 = NODECONSTRUCT_1
	max_integrity = 200
	integrity_failure = 0
	light_power = -1
	light_color = COLOR_DARKSPAWN_PSI
	light_system = MOVABLE_LIGHT //it's not movable, but the new system looks nicer for this purpose
	networks = list(ROLE_DARKSPAWN)
	clicksound = "crawling_shadows_walk"

/obj/machinery/computer/camera_advanced/darkspawn/Initialize(mapload)
	. = ..()
	camnet = GLOB.veilnet

/obj/machinery/computer/camera_advanced/darkspawn/can_use(mob/living/user)
	if(user && !is_darkspawn_or_veil(user))
		return FALSE
	return ..()

/obj/machinery/computer/camera_advanced/darkspawn/CreateEye()
	. = ..()
	eyeobj.nightvision = TRUE

/obj/machinery/computer/camera_advanced/darkspawn/emp_act(severity)
	return

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
	spell_requirements = SPELL_REQUIRES_DARKSPAWN
	/// If the buff also buffs all darkspawns
	var/darkspawns_too = FALSE

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
