/*

VOID PATH SPELLS GO HERE

*/

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/void
	name = "Void Shift"
	desc = "A short range spell that allows you to pass unimpeded through walls."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "voidblink"
	sound = null

	school = SCHOOL_FORBIDDEN
	cooldown_time = 15 SECONDS

	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION | SPELL_REQUIRES_NO_ANTIMAGIC

	exit_jaunt_sound = null
	jaunt_duration = 1.5 SECONDS
	jaunt_in_time = 0.5 SECONDS
	jaunt_out_time = 0.5 SECONDS
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/void_shift
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/void_shift/out

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/void/do_steam_effects()
	return

/obj/effect/temp_visual/dir_setting/void_shift
	name = "void_shift"
	icon = 'icons/mob/mob.dmi'
	icon_state = "void_blink_in"
	duration = 0.5 SECONDS

/obj/effect/temp_visual/dir_setting/void_shift/out
	icon_state = "void_blink_out"

/datum/action/cooldown/spell/pointed/void_phase
	name = "Void Phase"
	desc = "Let's you blink to your pointed destination, causes 3x3 aoe damage bubble \
		around your pointed destination and your current location. \
		It has a minimum range of 3 tiles and a maximum range of 5 tiles."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "voidblink"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS

	invocation = "RE'L'TY PH'S'E."
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION | SPELL_REQUIRES_NO_ANTIMAGIC

	cast_range = 5
	/// The minimum range to cast the phase.
	var/min_cast_range = 3
	/// The radius of damage around the void bubble
	var/damage_radius = 1

/datum/action/cooldown/spell/pointed/void_phase/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	if(owner && get_dist(get_turf(owner), get_turf(cast_on)) < min_cast_range)
		cast_on.balloon_alert(owner, "too close!")
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/pointed/void_phase/cast(atom/cast_on)
	. = ..()
	var/turf/source_turf = get_turf(owner)
	var/turf/targeted_turf = get_turf(cast_on)

	cause_aoe(source_turf, /obj/effect/temp_visual/voidin)
	cause_aoe(targeted_turf, /obj/effect/temp_visual/voidout)

	do_teleport(
		owner,
		targeted_turf,
		precision = 1,
		no_effects = TRUE,
		channel = TELEPORT_CHANNEL_MAGIC,
	)

/// Does the AOE effect of the blink at the passed turf
/datum/action/cooldown/spell/pointed/void_phase/proc/cause_aoe(turf/target_turf, effect_type = /obj/effect/temp_visual/voidin)
	new effect_type(target_turf)
	playsound(target_turf, 'sound/magic/voidblink.ogg', 60, FALSE)
	for(var/mob/living/living_mob in range(damage_radius, target_turf))
		if(IS_HERETIC_OR_MONSTER(living_mob) || living_mob == owner)
			continue
		if(living_mob.can_block_magic(antimagic_flags))
			continue
		living_mob.apply_damage(40, BRUTE, wound_bonus = CANT_WOUND)

/obj/effect/temp_visual/voidin
	icon = 'icons/effects/96x96.dmi'
	icon_state = "void_blink_in"
	alpha = 150
	duration = 6
	pixel_x = -32
	pixel_y = -32

/obj/effect/temp_visual/voidout
	icon = 'icons/effects/96x96.dmi'
	icon_state = "void_blink_out"
	alpha = 150
	duration = 6
	pixel_x = -32
	pixel_y = -32

/datum/action/cooldown/spell/cone/staggered/cone_of_cold/void
	name = "Void Blast"
	desc = "Fires a cone of chilling void in front of you, freezing everything in its path. \
		Enemies in the cone of the blast will be damaged slightly, slowed, and chilled overtime. \
		The ground hit will be iced over and slippery - \
		though they may thaw shortly if used in room temperature."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon_state = "icebeam"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS

	invocation = "FR'ZE!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION | SPELL_REQUIRES_NO_ANTIMAGIC

	// In room temperature, the ice won't last very long
	// ...but in space / freezing rooms, it will stick around
	turf_freeze_type = TURF_WET_PERMAFROST
	unfreeze_turf_duration = 15 SECONDS
	// Applies an "infinite" version of basic void chill
	// (This stacks with mansus grasp's void chill)
	frozen_status_effect_path = /datum/status_effect/void_chill/lasting
	unfreeze_mob_duration = 15 SECONDS
	// Does a smidge of damage
	on_freeze_brute_damage = 12
	on_freeze_burn_damage = 10
	// Also freezes stuff (Which will likely be unfrozen similarly to turfs)
	unfreeze_object_duration = 15 SECONDS

/datum/action/cooldown/spell/cone/staggered/cone_of_cold/void/do_mob_cone_effect(mob/living/target_mob, atom/caster, level)
	if(IS_HERETIC_OR_MONSTER(target_mob))
		return

	return ..()

/datum/action/cooldown/spell/aoe/slip/void
	name = "Diamond Dust"
	desc = "Causes the floor within 2 tiles to become frozen."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/humble/actions_humble.dmi'
	button_icon_state = "blind"

	invocation = "OBL'VION!"
	invocation_type = INVOCATION_SHOUT

	cooldown_time = 50 SECONDS
	aoe_radius = 2
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION | SPELL_REQUIRES_NO_ANTIMAGIC

/datum/action/cooldown/spell/aoe/slip/void/cast_on_thing_in_aoe(turf/open/target)
	target.MakeSlippery(TURF_WET_PERMAFROST, 15 SECONDS, 15 SECONDS)

/datum/action/cooldown/spell/aoe/void_pull
	name = "Void Pull"
	desc = "Calls the void, damaging, knocking down, and stunning people nearby. \
		Distant foes are also pulled closer to you (but not damaged)."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "voidpull"
	sound = 'sound/magic/voidblink.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 40 SECONDS

	invocation = "BR'NG F'RTH TH'M T' M'."
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION | SPELL_REQUIRES_NO_ANTIMAGIC

	aoe_radius = 7
	/// The radius of the actual damage circle done before cast
	var/damage_radius = 1
	/// The radius of the stun applied to nearby people on cast
	var/stun_radius = 4

// Before the cast, we do some small AOE damage around the caster
/datum/action/cooldown/spell/aoe/void_pull/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	new /obj/effect/temp_visual/voidin(get_turf(cast_on))

	// Before we cast the actual effects, deal AOE damage to anyone adjacent to us
	for(var/mob/living/nearby_living as anything in get_things_to_cast_on(cast_on, damage_radius))
		nearby_living.apply_damage(30, BRUTE, wound_bonus = CANT_WOUND)

/datum/action/cooldown/spell/aoe/void_pull/get_things_to_cast_on(atom/center, radius_override = 1)
	var/list/things = list()
	for(var/mob/living/nearby_mob in view(radius_override || aoe_radius, center))
		if(nearby_mob == owner || nearby_mob == center)
			continue
		// Don't grab people who are tucked away or something
		if(!isturf(nearby_mob.loc))
			continue
		if(IS_HERETIC_OR_MONSTER(nearby_mob))
			continue
		if(nearby_mob.can_block_magic(antimagic_flags))
			continue

		things += nearby_mob

	return things

// For the actual cast, we microstun people nearby and pull them in
/datum/action/cooldown/spell/aoe/void_pull/cast_on_thing_in_aoe(mob/living/victim, atom/caster)
	// If the victim's within the stun radius, they're stunned / knocked down
	if(get_dist(victim, caster) < stun_radius)
		victim.AdjustKnockdown(3 SECONDS)
		victim.AdjustParalyzed(0.5 SECONDS)

	// Otherwise, they take a few steps closer
	for(var/i in 1 to 3)
		victim.forceMove(get_step_towards(victim, caster))

