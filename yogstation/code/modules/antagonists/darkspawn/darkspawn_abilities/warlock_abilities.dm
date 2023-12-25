//////////////////////////////////////////////////////////////////////////
//-------------------------Warlock basic staff--------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/toggle/dark_staff
	name = "Shadow Staff"
	desc = "Pull darkness from the void, knitting it into a staff."
	panel = null
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "pass"
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_CONSCIOUS | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	var/obj/item/gun/magic/darkspawn/staff
	/// Flags used for different effects that apply when a projectile hits something
	var/effect_flags

/datum/action/cooldown/spell/toggle/dark_staff/process()
	active = owner.is_holding_item_of_type(/obj/item/gun/magic/darkspawn)
	. = ..()

/datum/action/cooldown/spell/toggle/dark_staff/can_cast_spell(feedback)
	if(!owner.get_empty_held_indexes() && !active)
		if(feedback)
			to_chat(owner, span_warning("You need an empty hand for this!"))
		return FALSE
	. = ..()

/datum/action/cooldown/spell/toggle/dark_staff/Enable()
	to_chat(owner, span_velvet("Shhouna"))
	owner.visible_message(span_warning("[owner] knits shadows together into a staff!"), span_velvet("You summon your staff."))
	playsound(owner, 'yogstation/sound/magic/pass_create.ogg', 50, 1)
	if(!staff)
		staff = new (owner)
	staff.effect_flags = effect_flags
	owner.put_in_hands(staff)

/datum/action/cooldown/spell/toggle/dark_staff/Disable()
	to_chat(owner, span_velvet("Haoo"))
	owner.visible_message(span_warning("[owner]'s staff dissipates!"), span_velvet("You dispel the staff."))
	playsound(owner, 'yogstation/sound/magic/pass_dispel.ogg', 50, 1)
	staff.moveToNullspace()

//////////////////////////////////////////////////////////////////////////
//---------------------Warlock light eater ability----------------------// little bit of anti-fire too
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/aoe/extinguish
	name = "Extinguish"
	desc = "Extinguish all light around you."
	button_icon = 'icons/mob/actions/actions_clockcult.dmi'
	button_icon_state = "Kindle"
	active_icon_state = "Kindle"
	base_icon_state = "Kindle"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	panel = null
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags =  AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	cooldown_time = 30 SECONDS
	sound = 'yogstation/sound/ambience/antag/veil_mind_gasp.ogg'
	aoe_radius = 7
	var/obj/item/darkspawn_extinguish/bopper
	var/list/seen_things

/datum/action/cooldown/spell/aoe/extinguish/Grant(mob/grant_to)
	. = ..()
	bopper = new(src)
	
/datum/action/cooldown/spell/aoe/extinguish/Remove(mob/living/remove_from)
	qdel(bopper)
	. = ..()

/datum/action/cooldown/spell/aoe/extinguish/cast(atom/cast_on)
	seen_things = view(owner) //cash all things you can see
	. = ..()
	to_chat(owner, span_velvet("Shwooh"))
	to_chat(owner, span_velvet("You extinguish all lights."))

/datum/action/cooldown/spell/aoe/extinguish/cast_on_thing_in_aoe(atom/victim, atom/caster)
	if(isturf(victim)) //no turf hitting
		return
	if(!seen_things)
		return
	if(!(victim in seen_things))//no putting out on the other side of walls
		return
	if(ishuman(victim))//put out any
		var/mob/living/carbon/human/target = victim
		if(target.can_block_magic(antimagic_flags, charge_cost = 1))
			return
		target.extinguish_mob()
		if(is_darkspawn_or_veil(target)) //don't put out or damage any lights carried by allies
			return
	if(isobj(victim))//put out any items too
		var/obj/target = victim
		target.extinguish()
	SEND_SIGNAL(bopper, COMSIG_ITEM_AFTERATTACK, victim, owner, TRUE) //just use a light eater attack on everyone

/obj/item/darkspawn_extinguish
	name = "extinguish"
	desc = "you shouldn't be seeing this, it's just used for the spell and nothing else"

/obj/item/darkspawn_extinguish/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/light_eater)

//////////////////////////////////////////////////////////////////////////
//---------------------Mess up an APC pretty badly----------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/touch/null_charge
	name = "Null Charge"
	desc = "Meddle with the powergrid via a functioning APC, causing a temporary stationwide power outage. Breaks the APC in the process."
	button_icon = 'yogstation/icons/mob/actions.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "null_charge"

	antimagic_flags = NONE
	panel = null
	check_flags =  AB_CHECK_IMMOBILE|AB_CHECK_CONSCIOUS | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	invocation_type = INVOCATION_NONE
	cooldown_time = 10 MINUTES
	psi_cost = 100
	hand_path = /obj/item/melee/touch_attack/darkspawn

/datum/action/cooldown/spell/touch/null_charge/is_valid_target(atom/cast_on)
	if(!istype(cast_on, /obj/machinery/power/apc))
		return FALSE
	var/obj/machinery/power/apc/target = cast_on
	if(target.stat & BROKEN)
		to_chat(owner, span_danger("This [target] no longer functions enough for access to the power grid."))
		return FALSE
	return TRUE	

/datum/action/cooldown/spell/touch/null_charge/cast_on_hand_hit(obj/item/melee/touch_attack/hand, obj/machinery/power/apc/target, mob/living/carbon/human/caster)
	if(!target || !istype(target))//sanity check
		return FALSE

	//Turn it off for the time being
	to_chat(owner, span_velvet("Xlahwa..."))
	target.set_light(0)
	target.visible_message(span_warning("The [target] flickers and begins to grow dark."))

	to_chat(caster, span_velvet("You dim the APC's screen and carefully begin siphoning its power into the void."))
	if(!do_after(caster, 5 SECONDS, target))
		//Whoops!  The APC's light turns back on
		to_chat(caster, span_velvet("Your concentration breaks and the APC suddenly repowers!"))
		target.set_light(2)
		target.visible_message(span_warning("The [target] begins glowing brightly!"))
		return FALSE

	if(target.stat & BROKEN)
		to_chat(owner, span_danger("This [target] no longer functions enough for access to the power grid."))
		return FALSE

	//We did it
	if(isdarkspawn(owner))
		var/datum/antagonist/darkspawn/darkspawn = isdarkspawn(owner)
		darkspawn.block_psi(60 SECONDS, type)
	to_chat(owner, span_progenitor("...SHWOOH!"))
	priority_announce("Abnormal activity detected in [station_name()]'s powernet. As a precautionary measure, the station's power will be shut off for an indeterminate duration.", "Critical Power Failure", ANNOUNCER_POWEROFF)
	power_fail(30, 40)
	to_chat(caster, span_velvet("You return the APC's power to the void, destroying it and disabling all others."))
	target.set_broken()
	return TRUE
		
//////////////////////////////////////////////////////////////////////////
//-----------------------Drain enemy, heal ally-------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/pointed/extract
	name = "Extract"
	desc = "Drain a target's life force or bestow it to an ally."
	button_icon = 'yogstation/icons/mob/sling.dmi'
	button_icon_state = "slingbeam"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	panel = null
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_HANDS_BLOCKED | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	ranged_mousepointer = 'icons/effects/mouse_pointers/visor_reticule.dmi'
	cast_range = 5
	var/mob/living/channeled
	var/datum/beam/visual
	var/datum/antagonist/darkspawn/cost
	var/upkeep_cost = 2 //happens 5 times a second
	var/damage_amount = 2 //these also happens 5 times a second
	var/actual_cooldown = 15 SECONDS //this only applies when the channel is broken
	var/healing = FALSE

/datum/action/cooldown/spell/pointed/extract/New()
	..()
	START_PROCESSING(SSfastprocess, src)

/datum/action/cooldown/spell/pointed/extract/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/datum/action/cooldown/spell/pointed/extract/Grant(mob/grant_to)
	. = ..()
	if(isdarkspawn(owner))
		cost = isdarkspawn(owner)

/datum/action/cooldown/spell/pointed/extract/is_valid_target(atom/cast_on)
	if(!isliving(cast_on))
		return FALSE
	var/mob/living/living_cast_on = cast_on
	if(living_cast_on.can_block_magic(antimagic_flags, charge_cost = 1))
		return FALSE
	if(living_cast_on.stat == DEAD)
		to_chat(owner, span_warning("[cast_on] is dead!"))
		return FALSE
	if(cast_on == owner)
		to_chat(owner, span_warning("can't cast it on yourself!"))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/pointed/extract/process()
	if(channeled)
		if(!healing && channeled.stat == DEAD)
			cancel()
			return
		if(healing && channeled.health >= channeled.maxHealth)
			cancel()
			return
		if(get_dist(owner, channeled) > cast_range)
			cancel()
			return
		if(cost && (!cost.use_psi(upkeep_cost)))
			cancel()
			return
		if(prob(25))
			to_chat(owner, span_velvet("...thum..."))
		if(healing)
			channeled.heal_ordered_damage(damage_amount, list(STAMINA, BURN, BRUTE, TOX, OXY, CLONE))
		else
			channeled.apply_damage(damage_amount, BURN)
			if(isliving(owner))
				var/mob/living/healed = owner
				healed.heal_ordered_damage(damage_amount, list(STAMINA, BURN, BRUTE, TOX, OXY, CLONE))
	build_all_button_icons(UPDATE_BUTTON_STATUS)

/datum/action/cooldown/spell/pointed/extract/Trigger(trigger_flags, atom/target)
	if(cancel())
		return FALSE
	. = ..()
	
/obj/effect/ebeam/darkspawn
	name = "void beam"

/datum/action/cooldown/spell/pointed/extract/cast(mob/living/cast_on)
	. = ..()
	to_chat(owner, span_velvet("Qokxlez..."))
	visual = owner.Beam(cast_on, "slingbeam", 'yogstation/icons/mob/sling.dmi' , INFINITY, cast_range)
	channeled = cast_on
	healing = is_darkspawn_or_veil(channeled)
	
/datum/action/cooldown/spell/pointed/extract/proc/cancel()
	if(visual)
		qdel(visual)
	if(channeled)
		channeled = null
		StartCooldown(actual_cooldown)
		to_chat(owner, span_velvet("...qokshe"))
		return TRUE
	return FALSE

//////////////////////////////////////////////////////////////////////////
//------------------Literally just goliath tendrils---------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/pointed/darkspawn_build/abyssal_call
	name = "Abyssal call"
	desc = "OOOOOOOOOOOOOOOO spooky"
	cast_range = 10
	cast_time = 0
	object_type = /obj/effect/temp_visual/goliath_tentacle/darkspawn/original
	cooldown_time = 10 SECONDS
	can_density = TRUE
	language_final = "Xylt'he kkxla'thamara"

//////////////////////////////////////////////////////////////////////////
//--------------Gives everyone nearby a random hallucination------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/aoe/mass_hallucination
	name = "Mass hallucination"
	desc = "Mass hallucination."
	button_icon = 'icons/mob/actions/actions_clockcult.dmi'
	button_icon_state = "Kindle"
	active_icon_state = "Kindle"
	base_icon_state = "Kindle"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	panel = null
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags =  AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	cooldown_time = 30 SECONDS
	sound = 'yogstation/sound/ambience/antag/veil_mind_scream.ogg'
	aoe_radius = 7

/datum/action/cooldown/spell/aoe/mass_hallucination/cast(atom/cast_on)
	. = ..()
	to_chat(owner, span_velvet("H'ellekth'ele"))

/datum/action/cooldown/spell/aoe/mass_hallucination/cast_on_thing_in_aoe(atom/victim, atom/caster)
	if(!isliving(victim))
		return
	if(!can_see(caster, victim, aoe_radius)) //no putting out on the other side of walls
		return
	var/mob/living/target = victim
	if(is_darkspawn_or_veil(target)) //don't fuck with allies
		return
	if(target.can_block_magic(antimagic_flags, charge_cost = 1))
		return
	var/datum/hallucination/picked_hallucination = pick(GLOB.hallucination_list)//not using weights
	target.cause_hallucination(picked_hallucination, "mass hallucination")

//////////////////////////////////////////////////////////////////////////
//----------------I stole blood beam from blood cultists----------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/pointed/shadow_beam
	name = "Shadow beam"
	desc = "Focus psionic energy briefly to tear a portion of reality into the void for a short duration."
	button_icon = 'icons/mob/actions/actions_clockcult.dmi'
	button_icon_state = "Kindle"
	active_icon_state = "Kindle"
	base_icon_state = "Kindle"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	panel = null
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags =  AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	cooldown_time = 1 MINUTES
	psi_cost = 100 //big fuckin layzer
	sound = null
	ranged_mousepointer = 'icons/effects/mouse_pointers/visor_reticule.dmi'
	cast_range = INFINITY //lol
	var/charging = FALSE
	var/angle
	var/charge_ticks = 3 //1 second per tick
	var/turf/targets_from

/datum/action/cooldown/spell/pointed/shadow_beam/can_cast_spell(feedback)
	if(charging)
		return
	. = ..()

/datum/action/cooldown/spell/pointed/shadow_beam/cast(atom/cast_on)
	. = ..()
	if(charging)
		return

	if(!ishuman(owner))
		return

	var/mob/living/carbon/human/user = owner	
	targets_from = get_turf(user)
	angle = get_angle(user, get_turf(cast_on))

	to_chat(user, span_velvet("Qwo..."))
	to_chat(user, span_velvet("You start building up psionic energy."))
	charging = TRUE
	INVOKE_ASYNC(src, PROC_REF(charge), user)
	if(do_after(user, charge_ticks SECONDS, user))
		INVOKE_ASYNC(src, PROC_REF(fire_beam), user)
	charging = FALSE

/datum/action/cooldown/spell/pointed/shadow_beam/proc/charge(mob/user, times = charge_ticks, first = TRUE)
	if(!charging)
		return
	if(times <= 0)
		return
	var/power = charge_ticks - times //grow in sound volume and added sound range as it charges
	var/volume = min(10 + (power * 20), 60)
	playsound(user, 'sound/effects/magic.ogg', volume, TRUE, power)
	playsound(user, 'yogstation/sound/magic/devour_will_begin.ogg', volume, TRUE, power)
	if(first)
		new /obj/effect/temp_visual/cult/rune_spawn/rune1(user.loc, 2 SECONDS, "#21007F")
	else
		new /obj/effect/temp_visual/cult/rune_spawn/rune1/reverse(user.loc, 2 SECONDS, "#21007F")
	addtimer(CALLBACK(src, PROC_REF(charge), user, times - 1, !first), 1 SECONDS)

/obj/effect/temp_visual/cult/rune_spawn/rune1/reverse //spins the other way, that's it
	turnedness = 179

/datum/action/cooldown/spell/pointed/shadow_beam/proc/fire_beam(mob/user)
	if(!angle || !targets_from) //sanity check
		return
	to_chat(user, span_progenitor("...GX'KSHA!"))
	if(isdarkspawn(user))
		var/datum/antagonist/darkspawn/darkspawn = isdarkspawn(user)
		darkspawn.block_psi(30 SECONDS, type)

	playsound(user, 'yogstation/sound/magic/devour_will_end.ogg', 100, FALSE, 20)
	var/turf/temp_target = get_turf_in_angle(angle, targets_from, 200) //cross the entire map, lol
	for(var/turf/T in getline(targets_from,temp_target))
		for(var/turf/realtile in range(1, T)) //bit of aoe around the line (probably super fucking intensive lol)
			var/obj/effect/temp_visual/darkspawn/chasm/effect = locate() in realtile.contents
			if(!effect) //to prevent multiple visuals from appearing on the same tile and doing more than intended
				effect = new(realtile)

/obj/effect/temp_visual/darkspawn
	name = "echoing void"
	icon = 'yogstation/icons/effects/effects.dmi'
	icon_state = "nothing"

/obj/effect/temp_visual/darkspawn/chasm
	icon_state = "consuming"
	duration = 6 SECONDS //can be almost any number for balance, just make sure it's not shorter than 1.1 seconds or it fucks up the animation
	layer = ABOVE_OPEN_TURF_LAYER

/obj/effect/temp_visual/darkspawn/chasm/Crossed(atom/movable/AM, oldloc)
	. = ..()
	if(isliving(AM))
		var/mob/living/target = AM
		if(!is_darkspawn_or_veil(target))
			target.apply_status_effect(STATUS_EFFECT_SPEEDBOOST, 4, 1 SECONDS, type) //slow field, makes it harder to escape

/obj/effect/temp_visual/darkspawn/chasm/Destroy()
	new/obj/effect/temp_visual/darkspawn/detonate(get_turf(src))
	. = ..()

/obj/effect/temp_visual/darkspawn/detonate
	icon_state = "detonate"
	layer = ABOVE_OPEN_TURF_LAYER
	duration = 2

/obj/effect/temp_visual/darkspawn/detonate/Destroy()
	var/turf/T = get_turf(src)
	for(var/mob/living/L in T.contents)
		if(is_darkspawn_or_veil(L))
			L.heal_ordered_damage(90, list(STAMINA, BURN, BRUTE, TOX, OXY, CLONE))
		else
			L.take_overall_damage(33, 66) //skill issue if you don't dodge it (won't crit if you're full hp)
			L.emote("scream")
	. = ..()
