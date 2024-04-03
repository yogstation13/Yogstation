//////////////////////////////////////////////////////////////////////////
//-------------------------Warlock basic staff--------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/toggle/dark_staff
	name = "Channeling Staff"
	desc = "Pull darkness from the void, knitting it into a staff."
	panel = "Darkspawn"
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "shadow_staff"
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_CONSCIOUS | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_HUMAN
	/// Staff object stored for the ability
	var/obj/item/gun/magic/darkspawn/staff
	/// Flags used for different effects that apply when a projectile hits something
	var/effect_flags

/datum/action/cooldown/spell/toggle/dark_staff/link_to(Target)
	. = ..()
	if(istype(target, /datum/mind))
		RegisterSignal(target, COMSIG_DARKSPAWN_UPGRADE_ABILITY, PROC_REF(handle_upgrade))
		RegisterSignal(target, COMSIG_DARKSPAWN_DOWNGRADE_ABILITY, PROC_REF(handle_downgrade))
	
/datum/action/cooldown/spell/toggle/dark_staff/proc/handle_upgrade(atom/source, flag)
	effect_flags |= flag
	if(staff)
		staff.effect_flags = effect_flags
		if(effect_flags & STAFF_UPGRADE_LIGHTEATER)
			staff.LoadComponent(/datum/component/light_eater)

/datum/action/cooldown/spell/toggle/dark_staff/proc/handle_downgrade(atom/source, flag)
	effect_flags -= flag
	if(staff)
		staff.effect_flags = effect_flags
		if(flag & STAFF_UPGRADE_LIGHTEATER)
			qdel(staff.GetComponent(/datum/component/light_eater))

/datum/action/cooldown/spell/toggle/dark_staff/process()
	active = owner.is_holding_item_of_type(/obj/item/gun/magic/darkspawn)
	return ..()

/datum/action/cooldown/spell/toggle/dark_staff/can_cast_spell(feedback)
	if(!owner.get_empty_held_indexes() && !active)
		if(feedback)
			to_chat(owner, span_warning("You need an empty hand for this!"))
		return FALSE
	return ..()

/datum/action/cooldown/spell/toggle/dark_staff/Enable()
	owner.balloon_alert(owner, "Shhouna")
	owner.visible_message(span_warning("[owner] knits shadows together into a staff!"), span_velvet("You summon your staff."))
	playsound(owner, 'yogstation/sound/magic/pass_create.ogg', 50, 1)
	if(!staff)
		staff = new (owner)
	if(effect_flags & STAFF_UPGRADE_LIGHTEATER)
		staff.LoadComponent(/datum/component/light_eater)
	staff.effect_flags = effect_flags
	owner.put_in_hands(staff)

/datum/action/cooldown/spell/toggle/dark_staff/Disable()
	owner.balloon_alert(owner, "Haoo")
	owner.visible_message(span_warning("[owner]'s staff dissipates!"), span_velvet("You dispel the staff."))
	playsound(owner, 'yogstation/sound/magic/pass_dispel.ogg', 50, 1)
	staff.moveToNullspace()

//////////////////////////////////////////////////////////////////////////
//---------------------Warlock light eater ability----------------------// little bit of anti-fire too
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/aoe/extinguish
	name = "Extinguish"
	desc = "Extinguish all light around you."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	button_icon_state = "extinguish"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	panel = "Darkspawn"
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags =  AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	psi_cost = 60
	cooldown_time = 30 SECONDS
	sound = 'yogstation/sound/ambience/antag/veil_mind_gasp.ogg'
	aoe_radius = 6
	///Secret item stored in the ability to hit things with to trigger light eater
	var/obj/item/darkspawn_extinguish/bopper
	///List of objects seen at cast
	var/list/seen_things

/datum/action/cooldown/spell/aoe/extinguish/Grant(mob/grant_to)
	. = ..()
	bopper = new(src)
	
/datum/action/cooldown/spell/aoe/extinguish/Remove(mob/living/remove_from)
	QDEL_NULL(bopper)
	return ..()

/datum/action/cooldown/spell/aoe/extinguish/cast(atom/cast_on)
	seen_things = view(owner) //cash all things you can see
	. = ..()
	owner.balloon_alert(owner, "Shwooh")
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
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "null_charge"

	antimagic_flags = NONE
	panel = "Darkspawn"
	check_flags =  AB_CHECK_IMMOBILE|AB_CHECK_CONSCIOUS | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_HUMAN
	invocation_type = INVOCATION_NONE
	cooldown_time = 10 MINUTES
	psi_cost = 200
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
	owner.balloon_alert(owner, "Xlahwa")
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
	var/datum/antagonist/darkspawn/darkspawn = isdarkspawn(owner)
	if(darkspawn)
		darkspawn.block_psi(60 SECONDS, type)
	owner.balloon_alert(owner, "...SHWOOH!")
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
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	button_icon_state = "extract"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	panel = "Darkspawn"
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_HANDS_BLOCKED | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_HUMAN
	ranged_mousepointer = 'icons/effects/mouse_pointers/visor_reticule.dmi'
	cast_range = 7
	///The mob being targeted by the ability
	var/mob/living/channeled
	///The beam visual drawn by the ability
	var/datum/beam/visual
	///The antag datum that psi is being drawn from
	var/datum/antagonist/darkspawn/cost
	///How much psi is taken every process tick (5 times a second)
	var/upkeep_cost = 2
	///How much damage or healing happens every process tick
	var/damage_amount = 2
	///The cooldown duration, only applied when the ability ends
	var/actual_cooldown = 15 SECONDS
	///Boolean, whether or not the spell is healing the target
	var/healing = FALSE
	///counts up each process tick, when reaching 5 prints a balloon alert and resets
	var/balloon_counter = 0

/datum/action/cooldown/spell/pointed/extract/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/datum/action/cooldown/spell/pointed/extract/Grant(mob/grant_to)
	. = ..()
	START_PROCESSING(SSfastprocess, src)
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
		balloon_counter++
		if(!visual || QDELETED(visual))
			cancel()
			return
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
		if(balloon_counter >= 5)
			balloon_counter = 0
			owner.balloon_alert(owner, "...thum...")
		if(healing)
			channeled.heal_ordered_damage(damage_amount, list(STAMINA, BURN, BRUTE, TOX, OXY, CLONE), BODYPART_ANY)
		else
			channeled.apply_damage(damage_amount, BURN)
			if(isliving(owner))
				var/mob/living/healed = owner
				healed.heal_ordered_damage(damage_amount, list(STAMINA, BURN, BRUTE, TOX, OXY, CLONE), BODYPART_ANY)
	build_all_button_icons(UPDATE_BUTTON_STATUS)

/datum/action/cooldown/spell/pointed/extract/Trigger(trigger_flags, atom/target)
	if(cancel())
		return FALSE
	. = ..()
	
/obj/effect/ebeam/darkspawn
	name = "void beam"

/datum/action/cooldown/spell/pointed/extract/cast(mob/living/cast_on)
	. = ..()
	owner.balloon_alert(owner, "Qokxlez")
	visual = owner.Beam(cast_on, "slingbeam", 'yogstation/icons/mob/darkspawn.dmi' , INFINITY, cast_range)
	channeled = cast_on
	healing = is_team_darkspawn(channeled)
	
/datum/action/cooldown/spell/pointed/extract/proc/cancel()
	balloon_counter = 0
	if(visual)
		qdel(visual)
	if(channeled)
		channeled = null
		StartCooldown(actual_cooldown)
		owner.balloon_alert(owner, "...qokshe")
		return TRUE
	return FALSE

//////////////////////////////////////////////////////////////////////////
//------------------Literally just goliath tendrils---------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/pointed/darkspawn_build/abyssal_call
	name = "Abyssal Call"
	desc = "Summon abyssal tendrils from beyond the veil to grasp an enemy."
	button_icon_state = "abyssal_call"
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
	name = "Mass Hallucination"
	desc = "Forces brief delirium on all nearby enemies."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	button_icon_state = "mass_hallucination"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	panel = "Darkspawn"
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags =  AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	psi_cost = 30
	cooldown_time = 30 SECONDS
	sound = 'yogstation/sound/ambience/antag/veil_mind_scream.ogg'
	aoe_radius = 7
	///how many times it hallucinates (1 per second)
	var/hallucination_triggers = 3

/datum/action/cooldown/spell/aoe/mass_hallucination/cast(atom/cast_on)
	. = ..()
	owner.balloon_alert(owner, "H'ellekth'ele")

/datum/action/cooldown/spell/aoe/mass_hallucination/cast_on_thing_in_aoe(atom/victim, atom/caster)
	if(!isliving(victim))
		return
	var/mob/living/target = victim
	if(is_team_darkspawn(target)) //don't fuck with allies
		return
	if(target.can_block_magic(antimagic_flags, charge_cost = 1))
		return
	hallucinate(target)

/datum/action/cooldown/spell/aoe/mass_hallucination/proc/hallucinate(mob/living/target, times = hallucination_triggers)
	if(times <= 0)
		return
	var/datum/hallucination/picked_hallucination = pick(GLOB.hallucination_list)//not using weights
	target.cause_hallucination(picked_hallucination, "mass hallucination")
	addtimer(CALLBACK(src, PROC_REF(hallucinate), target, times--), 1 SECONDS, TIMER_UNIQUE)

//////////////////////////////////////////////////////////////////////////
//---------------------Detain and capture ability-----------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/pointed/seize //Stuns and mutes a human target for 10 seconds
	name = "Seize"
	desc = "Restrain a target's mental faculties, preventing speech and actions of any kind for a moderate duration."
	panel = "Darkspawn"
	button_icon_state = "seize"
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_HANDS_BLOCKED | AB_CHECK_LYING
	spell_requirements = SPELL_CASTABLE_AS_BRAIN
	psi_cost = 35
	cooldown_time = 30 SECONDS
	cast_range = 10
	ranged_mousepointer = 'icons/effects/mouse_pointers/cult_target.dmi'
	///duration of stun when used at close range
	var/stun_duration = 10 SECONDS

/datum/action/cooldown/spell/pointed/seize/before_cast(atom/cast_on)
	. = ..()
	if(!cast_on || !isliving(cast_on))
		return . | SPELL_CANCEL_CAST
	var/mob/living/carbon/target = cast_on
	if(istype(target) && target.stat)
		to_chat(owner, span_warning("[target] must be conscious!"))
		return . | SPELL_CANCEL_CAST
	if(is_team_darkspawn(target))
		to_chat(owner, span_warning("You cannot seize allies!"))
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/pointed/seize/cast(atom/cast_on)
	. = ..()
	if(!isliving(cast_on))
		return

	if(iscarbon(owner))
		var/mob/living/carbon/user = owner
		if(!(user.check_obscured_slots() & ITEM_SLOT_EYES)) //only show if the eyes are visible
			user.visible_message(span_warning("<b>[user]'s eyes flash a deep purple</b>"))

	owner.balloon_alert(owner, "Sskr'aya")

	var/mob/living/target = cast_on
	if(target.can_block_magic(antimagic_flags, charge_cost = 1))
		return
		
	var/distance = get_dist(target, owner)
	if (distance <= 2)
		target.visible_message(span_danger("[target] suddenly collapses..."))
		to_chat(target, span_userdanger("A purple light flashes through your mind, and you lose control of your movements!"))
		target.Paralyze(stun_duration)
		if(iscarbon(target))
			var/mob/living/carbon/M = target
			M.silent += 10
	else //Distant glare
		var/loss = max(120 - (distance * 10), 0)
		target.adjustStaminaLoss(loss)
		target.adjust_stutter(loss)
		to_chat(target, span_userdanger("A purple light flashes through your mind, and exhaustion floods your body..."))

//////////////////////////////////////////////////////////////////////////
//----------------------Basically a fancy jaunt-------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/erase_time/darkspawn
	name = "Quantum disruption"
	desc = "Disrupt the flow of possibilities, where you are, where you could be."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "quantum_disruption"
	panel = "Darkspawn"
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	psi_cost = 80
	cooldown_time = 60 SECONDS
	length = 5 SECONDS

/datum/action/cooldown/spell/erase_time/darkspawn/cast(mob/living/user)
	. = ..()
	var/datum/antagonist/darkspawn/darkspawn = isdarkspawn(owner)
	if(. && darkspawn)
		owner.balloon_alert(owner, "KSH SHOL'NAXHAR!")
		darkspawn.block_psi(20 SECONDS, type)


//////////////////////////////////////////////////////////////////////////
//----------------I stole blood beam from blood cultists----------------// (and made it better)
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/pointed/shadow_beam
	name = "Void beam"
	desc = "After a short delay, fire a huge beam of void terrain across the entire station."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	button_icon_state = "shadow_beam"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	panel = "Darkspawn"
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags =  AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	cooldown_time = 90 SECONDS
	psi_cost = 100 //big fuckin layzer
	sound = null
	ranged_mousepointer = 'icons/effects/mouse_pointers/visor_reticule.dmi'
	cast_range = INFINITY //lol
	///boolean, whether or not the spell is being charged
	var/charging = FALSE
	///how many times the charge sound effect plays, also affects delay, sorta like a cast time
	var/charge_ticks = 2 //1 second per tick
	///turf of the caster at the moment of casting starting
	var/turf/targets_from
	///turf targeted for the center of the beam
	var/turf/targets_to

/datum/action/cooldown/spell/pointed/shadow_beam/can_cast_spell(feedback)
	if(charging)
		return
	return ..()

/datum/action/cooldown/spell/pointed/shadow_beam/cast(atom/cast_on)
	. = ..()
	if(charging)
		return
	
	targets_from = get_turf(owner)
	targets_to = get_turf(cast_on)

	owner.balloon_alert(owner, "Qwo...")
	to_chat(owner, span_velvet("You start building up psionic energy."))
	charging = TRUE
	INVOKE_ASYNC(src, PROC_REF(start_beam), owner) //so the reticle doesn't continue to show even after clicking

/datum/action/cooldown/spell/pointed/shadow_beam/proc/start_beam(mob/user)
	charging = TRUE
	INVOKE_ASYNC(src, PROC_REF(charge), user) //visual effect
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
	if(!targets_from || !targets_to) //sanity check
		return
	user.balloon_alert(user, "...GX'KSHA!")
	if(isdarkspawn(user))
		var/datum/antagonist/darkspawn/darkspawn = isdarkspawn(user)
		darkspawn.block_psi(30 SECONDS, type)

	playsound(user, 'yogstation/sound/magic/devour_will_end.ogg', 100, FALSE, 30)
	//split in two so the targeted tile is always in the center of the beam
	for(var/turf/step_target in getline(targets_from, targets_to))
		spawn_ground(step_target)

	//extrapolate a new end target along the line using an angle
	var/turf/distant_target = get_turf_in_angle(get_angle(targets_from, targets_to), targets_to, 100) //100 tiles past the end point, roughly following the angle of the original line

	for(var/turf/step_target in getline(targets_to, distant_target))
		spawn_ground(step_target)

/datum/action/cooldown/spell/pointed/shadow_beam/proc/spawn_ground(turf/target)
	for(var/turf/realtile in RANGE_TURFS(1, target)) //bit of aoe around the line (probably super fucking intensive lol)
		var/obj/effect/temp_visual/darkspawn/chasm/effect = locate() in realtile.contents
		if(!effect) //to prevent multiple visuals from appearing on the same tile and doing more damage than intended
			effect = new(realtile)

/obj/effect/temp_visual/darkspawn
	name = "echoing void"
	icon = 'yogstation/icons/effects/effects.dmi'
	icon_state = "nothing"

/obj/effect/temp_visual/darkspawn/chasm //a slow field that eventually explodes
	icon_state = "consuming"
	duration = 4 SECONDS //functions as the delay until the explosion, just make sure it's not shorter than 1.1 seconds or it fucks up the animation
	plane = WALL_PLANE
	layer = ABOVE_OPEN_TURF_LAYER
	alpha = 0

/obj/effect/temp_visual/darkspawn/chasm/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered)
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	animate(src, 1.1 SECONDS, alpha = 255) //fade into existence

/obj/effect/temp_visual/darkspawn/chasm/proc/on_entered(datum/source, atom/movable/AM, ...)
	if(isliving(AM))
		var/mob/living/target = AM
		if(!is_team_darkspawn(target))
			target.apply_status_effect(STATUS_EFFECT_SPEEDBOOST, 3, 1 SECONDS, type) //slow field, makes it harder to escape

/obj/effect/temp_visual/darkspawn/chasm/Destroy()
	new/obj/effect/temp_visual/darkspawn/detonate(get_turf(src))
	return ..()

/obj/effect/temp_visual/darkspawn/detonate //the explosion effect, applies damage when it disappears
	icon_state = "detonate"
	plane = WALL_PLANE
	layer = ABOVE_OPEN_TURF_LAYER
	duration = 2

/obj/effect/temp_visual/darkspawn/detonate/Destroy()
	var/turf/tile_location = get_turf(src)
	for(var/mob/living/victim in tile_location.contents)
		if(is_team_darkspawn(victim))
			victim.heal_ordered_damage(90, list(BURN, BRUTE, TOX, OXY, CLONE, STAMINA), BODYPART_ANY)
		else if(!victim.can_block_magic(MAGIC_RESISTANCE_MIND))
			victim.take_overall_damage(10, 50, 200) //skill issue if you don't dodge it (won't crit if you're full hp)
			victim.emote("scream")
	return ..()
	
//////////////////////////////////////////////////////////////////////////
//-------------------I stole heirophant's burst ability-----------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/pointed/null_burst
	name = "Null Burst"
	desc = "After a short delay, create an explosion of void terrain at the targeted location."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	button_icon_state = "null_burst"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	panel = "Darkspawn"
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags =  AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	cooldown_time = 90 SECONDS
	psi_cost = 100 //big fuckin boom
	sound = null
	ranged_mousepointer = 'icons/effects/mouse_pointers/visor_reticule.dmi'
	cast_range = INFINITY //lol
	///boolean, whether or not the ability is actively being casted
	var/charging = FALSE
	///how many times the charge sound effect plays, also affects delay, sorta like a cast time
	var/charge_ticks = 2 //1 second per tick
	///the targeted location for the burst
	var/turf/targets_to
	///radius of the burst aoe
	var/burst_range = 4
	///modifies the delay between waves in the burst
	var/spread_speed = 1

/datum/action/cooldown/spell/pointed/null_burst/can_cast_spell(feedback)
	if(charging)
		return
	return ..()

/datum/action/cooldown/spell/pointed/null_burst/is_valid_target(atom/cast_on) //can target yourself if you really want to
	return TRUE

/datum/action/cooldown/spell/pointed/null_burst/cast(atom/cast_on)
	. = ..()
	if(charging)
		return
	
	targets_to = get_turf(cast_on)

	owner.balloon_alert(owner, "Qwo...")
	to_chat(owner, span_velvet("You start building up psionic energy."))
	charging = TRUE
	INVOKE_ASYNC(src, PROC_REF(start_beam), owner) //so the reticle doesn't continue to show even after clicking

/datum/action/cooldown/spell/pointed/null_burst/proc/start_beam(mob/user)
	charging = TRUE
	INVOKE_ASYNC(src, PROC_REF(charge), user) //visual effect
	if(do_after(user, charge_ticks SECONDS, user))
		INVOKE_ASYNC(src, PROC_REF(burst), user)
	charging = FALSE

/datum/action/cooldown/spell/pointed/null_burst/proc/charge(mob/user, times = charge_ticks, first = TRUE)
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

/datum/action/cooldown/spell/pointed/null_burst/proc/burst(mob/user)
	if(!targets_to)
		return

	user.balloon_alert(user, "...GWO'KSHA!")
	if(isdarkspawn(user))
		var/datum/antagonist/darkspawn/darkspawn = isdarkspawn(user)
		darkspawn.block_psi(30 SECONDS, type)

	playsound(user, 'yogstation/sound/magic/devour_will_end.ogg', 100, FALSE, 30)
	playsound(targets_to,'yogstation/sound/magic/divulge_end.ogg', 70, TRUE, burst_range)

	var/last_dist = 0
	var/real_delay = 0
	for(var/t in spiral_range_turfs(burst_range, targets_to))
		var/turf/T = t
		if(!T)
			continue
		var/dist = get_dist(targets_to, T)
		if(dist > last_dist)
			last_dist = dist
			real_delay += (0.1 SECONDS) + (min(burst_range - last_dist, 1.2 SECONDS) * spread_speed) //gets faster as it gets further out
		addtimer(CALLBACK(src, PROC_REF(spawn_ground), T), real_delay) //spawns turf with a callback to avoid using sleep() in a loop like heiro does

/datum/action/cooldown/spell/pointed/null_burst/proc/spawn_ground(turf/target)
	new /obj/effect/temp_visual/darkspawn/chasm(target)
