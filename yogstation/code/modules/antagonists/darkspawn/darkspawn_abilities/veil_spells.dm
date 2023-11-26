GLOBAL_DATUM_INIT(thrallnet, /datum/cameranet/darkspawn, new)

//////////////////////////////////////////////////////////////////////////
//-----------------------------Veil Creation----------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/touch/veil_mind
	name = "Veil mind"
	desc = "Consume 2 willpower to veil a target's mind. To be eligible, they must be alive and recently drained by Devour Will."
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
	psi_cost = 100
	hand_path = /obj/item/melee/touch_attack/darkspawn
	var/willpower_cost = 2

/datum/action/cooldown/spell/touch/veil_mind/is_valid_target(atom/cast_on)
	return ishuman(cast_on)

/datum/action/cooldown/spell/touch/veil_mind/cast_on_hand_hit(obj/item/melee/touch_attack/hand, mob/living/carbon/human/target, mob/living/carbon/human/caster)
	if(!isdarkspawn(caster))//sanity check
		return
	if(!target.mind && !target.last_mind)
		to_chat(owner, "This mind is too feeble to even be worthy of veiling.")
		return
	if(!target.getorganslot(ORGAN_SLOT_BRAIN))
		to_chat(owner, span_danger("[target]'s brain is missing, you lack the conduit to control them."))
		return FALSE
	if(isdarkspawn(target))
		to_chat(owner, span_velvet("You will never be strong enough to control the will of another."))
		return
	var/datum/antagonist/darkspawn/master = isdarkspawn(caster)
	if(!isveil(target))
		if(!target.has_status_effect(STATUS_EFFECT_BROKEN_WILL))
			to_chat(owner, span_velvet("[target]'s will is still too strong to veil."))
			return FALSE
		if(master.willpower < willpower_cost)
			to_chat(owner, span_velvet("You do not have enough will to veil [target]."))
			return FALSE

	to_chat(owner, span_velvet("Krx'lna tyhx graha..."))
	to_chat(owner, span_velvet("You begin to channel your psionic powers through [target]'s mind."))
	playsound(owner, 'yogstation/sound/ambience/antag/veil_mind_gasp.ogg', 25)
	if(!do_after(owner, 2 SECONDS, owner))
		return FALSE
	playsound(owner, 'yogstation/sound/ambience/antag/veil_mind_scream.ogg', 100)
	if(isveil(target))
		to_chat(owner, span_velvet("...tia"))
		to_chat(owner, span_velvet("You revitalize your veil [target.real_name]."))
		target.revive(TRUE, TRUE)
		target.grab_ghost()
	else if(target.add_veil())
		if(master.willpower < willpower_cost) //sanity check
			to_chat(owner, span_velvet("You do not have enough will to veil [target]."))
			return FALSE
		master.willpower -= willpower_cost
		to_chat(owner, span_velvet("...xthl'kap"))
		to_chat(owner, span_velvet("<b>[target.real_name]</b> has become a veil!"))
	else
		to_chat(owner, span_velvet("Your power is incapable of controlling <b>[target].</b>"))
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
	if(unveiled.current.remove_veil())
		to_chat(owner, span_velvet("Fk'koht"))
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
	language_final = "kxmiv'ixnce"

//////////////////////////////////////////////////////////////////////////
//-----Shoots a projectile, but can be used through the cam system------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/pointed/mindblast
	name = "Mind blast"
	desc = "Blast a single ray of concentrated mental energy at a target, dealing high brute damage if they are caught in it"
	button_icon = 'icons/obj/hand_of_god_structures.dmi'
	button_icon_state = "ward-red"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"

	cast_range = INFINITY //lol
	cooldown_time = 15 SECONDS
	panel = null
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags =  AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	ranged_mousepointer = 'icons/effects/mouse_pointers/visor_reticule.dmi'

	invocation = null
	invocation_type = INVOCATION_NONE

	var/body_range = 8 //how far the projectile can shoot from a body

/datum/action/cooldown/spell/pointed/mindblast/cast(atom/cast_on)
	. = ..()

	var/mob/shooter
	var/closest_dude_dist = body_range
	if(get_dist(owner, cast_on) > body_range)
		for(var/mob/living/dude in range(body_range, cast_on))
			if(is_darkspawn_or_veil(dude))
				if(!isturf(dude.loc))
					continue
				if(get_dist(cast_on, dude) < closest_dude_dist)//always only get the closest dude
					shooter = dude
					closest_dude_dist = get_dist(cast_on, dude)
	else
		shooter = owner
	if(!shooter)
		to_chat(owner, span_warning("There is no one nearby to channel your power through."))
		on_deactivation(owner, refund_cooldown = TRUE)
		return FALSE
	fire_projectile(cast_on, shooter)
	to_chat(owner, span_velvet("Vyk'thunak"))
	playsound(get_turf(shooter), 'sound/weapons/resonator_blast.ogg', 50, 1)

/datum/action/cooldown/spell/pointed/mindblast/proc/fire_projectile(atom/target, mob/shooter)
	var/obj/projectile/magic/mindblast/to_fire = new ()
	ready_projectile(to_fire, target, shooter)
	SEND_SIGNAL(owner, COMSIG_MOB_SPELL_PROJECTILE, src, target, to_fire)
	to_fire.fire()

/datum/action/cooldown/spell/pointed/mindblast/proc/ready_projectile(obj/projectile/to_fire, atom/target, mob/shooter)
	to_fire.firer = owner
	to_fire.fired_from = shooter
	to_fire.preparePixelProjectile(target, shooter)

	if(istype(to_fire, /obj/projectile/magic))
		var/obj/projectile/magic/magic_to_fire = to_fire
		magic_to_fire.antimagic_flags = antimagic_flags

/obj/projectile/magic/mindblast
	name ="mindbolt"
	icon_state= "chronobolt"
	damage = 30
	armour_penetration = 100
	speed = 1
	eyeblur = 0
	damage_type = BRUTE
	pass_flags = PASSTABLE
	range = 8
	color = COLOR_VELVET

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
	var/language_output = "DEBUGIFY"

/datum/action/cooldown/spell/veilbuff/before_cast(atom/cast_on)
	. = ..()
	darkspawns_too = HAS_TRAIT(owner, TRAIT_DARKSPAWN_BUFFALLIES)

/datum/action/cooldown/spell/veilbuff/cast(atom/cast_on)
	. = ..()
	to_chat(owner, span_velvet("[language_output]"))
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
					if(target == owner)//no self buffing
						continue
					empower(target)
	
/datum/action/cooldown/spell/veilbuff/proc/empower(mob/living/carbon/human/target)
	return

////////////////////////////Global AOE heal//////////////////////////
/datum/action/cooldown/spell/veilbuff/heal
	name = "Heal veils"
	desc = "Heals all veils for an amount of brute and burn."
	var/heal_amount = 20
	language_output = "Plyn othra"

/datum/action/cooldown/spell/veilbuff/heal/empower(mob/living/carbon/human/target)
	target.heal_overall_damage(heal_amount, heal_amount, 0, BODYPART_ANY)

////////////////////////////Temporary speed boost//////////////////////////
/datum/action/cooldown/spell/veilbuff/speed
	name = "Expedite veils"
	desc = "Give all veils a temporary movespeed bonus."
	language_output = "Vyzthun"

/datum/action/cooldown/spell/veilbuff/speed/empower(mob/living/carbon/human/target)
	target.apply_status_effect(STATUS_EFFECT_SPEEDBOOST, -0.5, 5 SECONDS, type)

//////////////////////////////////////////////////////////////////////////
//----------------Single target global ally giga buff-------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/pointed/elucidate
	name = "Elucidate"
	desc = "Channel significant power through an ally, greatly healing them, cleansing all CC and providing a speed boost."
	panel = null
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	ranged_mousepointer = 'icons/effects/mouse_pointers/visor_reticule.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "veil_sigils"
	cast_range = INFINITY //lol
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	cooldown_time = 5 MINUTES //it's REALLY strong
	psi_cost = 100 //it's REALLY strong

/datum/action/cooldown/spell/pointed/elucidate/is_valid_target(atom/cast_on)
	if(!iscarbon(cast_on))
		return FALSE
	var/mob/living/carbon/target = cast_on
	if(!is_darkspawn_or_veil(target))
		return FALSE
	if(target.stat == DEAD)
		to_chat(owner, span_velvet("This one is beyond our help at such a range"))
		return FALSE
	. = ..()

/datum/action/cooldown/spell/pointed/elucidate/cast(atom/cast_on)
	. = ..()
	if(!iscarbon(cast_on))
		return FALSE
	var/mob/living/carbon/target = cast_on
	target.fully_heal()
	target.resting = FALSE
	target.SetAllImmobility(0, TRUE)
	target.apply_status_effect(STATUS_EFFECT_SPEEDBOOST, -0.5, 10 SECONDS, type)
	to_chat(owner, span_progenitor("CKKREM!"))
	target.visible_message(span_danger("Streaks of velvet light crack out of [target]'s skin."), span_velvet("Power roars through you like a raging storm, pushing you to your absolute limits."))
	var/obj/item/cuffs = target.get_item_by_slot(ITEM_SLOT_HANDCUFFED)
	var/obj/item/legcuffs = target.get_item_by_slot(ITEM_SLOT_LEGCUFFED)
	if(target.handcuffed || target.legcuffed)
		target.clear_cuffs(cuffs, TRUE, TRUE)
		target.clear_cuffs(legcuffs, TRUE, TRUE)
	playsound(get_turf(target),'yogstation/sound/creatures/darkspawn_death.ogg', 80, 1)
	if(isdarkspawn(owner))
		var/datum/antagonist/darkspawn/darkspawn = isdarkspawn(owner)
		darkspawn.block_psi(30 SECONDS, type)
	
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
	owner.see_in_dark = 10

/datum/action/cooldown/spell/toggle/nightvision/Disable()
	owner.lighting_alpha = initial(owner.lighting_alpha)
	owner.see_in_dark = initial(owner.see_in_dark)
	owner.update_sight()
