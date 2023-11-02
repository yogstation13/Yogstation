/*

RUST PATH SPELLS GO HERE

*/

/datum/action/cooldown/spell/aoe/rust_conversion
	name = "Aggressive Spread"
	desc = "Spread rust onto nearby turfs, possibly destroying rusted walls."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "corrode"
	sound = 'sound/items/welder.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 25 SECONDS

	invocation = "A'GRSV SPR'D"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION | SPELL_REQUIRES_NO_ANTIMAGIC

	aoe_radius = 3

/datum/action/cooldown/spell/aoe/rust_conversion/get_things_to_cast_on(atom/center)
	var/list/things = list()
	for(var/turf/nearby_turf in range(aoe_radius, center))
		things += nearby_turf

	return things

/datum/action/cooldown/spell/aoe/rust_conversion/cast_on_thing_in_aoe(turf/victim, atom/caster)
	// We have less chance of rusting stuff that's further
	var/distance_to_caster = get_dist(victim, caster)
	var/chance_of_not_rusting = (max(distance_to_caster, 1) - 1) * 100 / (aoe_radius + 1)

	if(prob(chance_of_not_rusting))
		return

	victim.rust_heretic_act()

/datum/action/cooldown/spell/aoe/rust_conversion/small
	name = "Rust Conversion"
	desc = "Spreads rust onto nearby surfaces."
	aoe_radius = 2

// Shoots a straight line of rusty stuff ahead of the caster, what rust monsters get
/datum/action/cooldown/spell/basic_projectile/rust_wave
	name = "Patron's Reach"
	desc = "Fire a rust spreading projectile in front of you, dealing toxin damage to whatever it hits."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "rust_wave"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 35 SECONDS

	invocation = "SPR'D TH' WO'D"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION | SPELL_REQUIRES_NO_ANTIMAGIC

	projectile_type = /obj/projectile/magic/aoe/rust_wave

/obj/projectile/magic/aoe/rust_wave
	name = "Patron's Reach"
	icon_state = "eldritch_projectile"
	alpha = 180
	damage = 30
	damage_type = TOX
	nodamage = FALSE
	hitsound = 'sound/weapons/punch3.ogg'
	ignored_factions = list("heretics")
	range = 15
	speed = 1

/obj/projectile/magic/aoe/rust_wave/Moved(atom/OldLoc, Dir)
	. = ..()
	playsound(src, 'sound/items/welder.ogg', 75, TRUE)
	var/list/turflist = list()
	var/turf/T1
	turflist += get_turf(src)
	T1 = get_step(src,turn(dir,90))
	turflist += T1
	turflist += get_step(T1,turn(dir,90))
	T1 = get_step(src,turn(dir,-90))
	turflist += T1
	turflist += get_step(T1,turn(dir,-90))
	for(var/X in turflist)
		if(!X || prob(25))
			continue
		var/turf/T = X
		T.rust_heretic_act()

/datum/action/cooldown/spell/basic_projectile/rust_wave/short
	name = "Lesser Patron's Reach"
	projectile_type = /obj/projectile/magic/aoe/rust_wave/short

/obj/projectile/magic/aoe/rust_wave/short
	range = 7
	speed = 2

// Shoots out in a wave-like, what rust heretics themselves get
/datum/action/cooldown/spell/cone/staggered/entropic_plume
	name = "Entropic Plume"
	desc = "Spews forth a disorienting plume that causes enemies to strike each other, briefly blinds them(increasing with range) and poisons them(decreasing with range), while also spreading rust in the path of the plume."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "entropic_plume"
	sound = 'sound/magic/forcewall.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS

	invocation = "'NTR'P'C PL'M'"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION | SPELL_REQUIRES_NO_ANTIMAGIC
	
	cone_levels = 5
	respect_density = TRUE

/datum/action/cooldown/spell/cone/staggered/entropic_plume/cast(atom/cast_on)
	. = ..()
	new /obj/effect/temp_visual/dir_setting/entropic(get_step(cast_on, cast_on.dir), cast_on.dir)

/datum/action/cooldown/spell/cone/staggered/entropic_plume/do_turf_cone_effect(turf/target_turf, atom/caster, level)
	target_turf.rust_heretic_act()

/datum/action/cooldown/spell/cone/staggered/entropic_plume/do_mob_cone_effect(mob/living/victim, atom/caster, level)
	. = ..()
	if(victim.can_block_magic() || IS_HERETIC(victim) || IS_HERETIC_MONSTER(victim))
		return
	victim.apply_status_effect(STATUS_EFFECT_AMOK)
	victim.apply_status_effect(STATUS_EFFECT_CLOUDSTRUCK, (level * 1 SECONDS))
	if(iscarbon(victim))
		var/mob/living/carbon/carbon_victim = victim
		carbon_victim.reagents?.add_reagent(/datum/reagent/eldritch, min(1, 6 - level))

/datum/action/cooldown/spell/cone/staggered/entropic_plume/calculate_cone_shape(current_level)
	if(current_level == cone_levels)
		return 5
	else if(current_level == cone_levels - 1)
		return 3
	else
		return 2

