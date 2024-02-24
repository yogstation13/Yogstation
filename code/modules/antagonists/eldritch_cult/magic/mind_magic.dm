/*

MIND PATH SPELLS GO HERE

*/
/datum/action/cooldown/spell/jaunt/ethereal_jaunt/mind
	name = "Mental Obfuscation"
	desc = "A short range spell that allows you to pass unimpeded through walls."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "mansus_link"
	sound = null

	school = SCHOOL_FORBIDDEN
	cooldown_time = 15 SECONDS

	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION | SPELL_REQUIRES_NO_ANTIMAGIC

	exit_jaunt_sound = null
	jaunt_duration = 2 SECONDS
	jaunt_in_time = 0.5 SECONDS
	jaunt_out_time = 0.5 SECONDS
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/mind_shift
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/mind_shift/out

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/mind/do_steam_effects()
	return

/obj/effect/temp_visual/dir_setting/mind_shift
	name = "knock_shift"
	icon = 'icons/effects/cult_effects.dmi'
	icon_state = "cultin"
	duration = 0.5 SECONDS

/obj/effect/temp_visual/dir_setting/mind_shift/out
	icon_state = "cultout"

/datum/action/cooldown/spell/aoe/immobilize/famished_roar
	name = "Famished Roar"
	desc = "An AOE roar spell that immobilizes all nearby people."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/humble/actions_humble.dmi'
	button_icon_state = "void_magnet"
	sound = 'yogstation/sound/magic/demented_outburst_scream.ogg'
	var/obj/effect/sparkle_path = /obj/effect/temp_visual/gravpush
	school = SCHOOL_FORBIDDEN
	invocation = "GR' RO'AR"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION | SPELL_REQUIRES_NO_ANTIMAGIC
	aoe_radius = 4

	cooldown_time = 1 MINUTES

/datum/action/cooldown/spell/aoe/immobilize/famished_roar/get_things_to_cast_on(atom/center)
	var/list/things = list()
	for(var/atom/movable/nearby_movable in view(aoe_radius, center))
		if(nearby_movable == owner || nearby_movable == center)
			continue
		if(nearby_movable.anchored)
			continue

		things += nearby_movable

	return things

/datum/action/cooldown/spell/aoe/immobilize/famished_roar/cast_on_thing_in_aoe(atom/movable/victim, atom/caster)
	if(ismob(victim))
		var/mob/victim_mob = victim
		if(victim_mob.can_block_magic(antimagic_flags))
			return

	var/dist_from_caster = get_dist(victim, caster)

	if(dist_from_caster == 0)
		if(isliving(victim))
			var/mob/living/victim_living = victim
			victim_living.Immobilize(6 SECONDS)
			victim_living.adjustBruteLoss(25)
			victim_living.adjustEarDamage(30)
			to_chat(victim, span_userdanger("Your body shakes with fear infront of [caster]!"))
	else
		if(sparkle_path)
			// Created sparkles will disappear on their own
			new sparkle_path(get_turf(victim), get_dir(caster, victim))

		if(isliving(victim))
			var/mob/living/victim_living = victim
			victim_living.Immobilize(3 SECONDS)
			victim_living.adjustBruteLoss(5)
			victim_living.adjustEarDamage(30)
			to_chat(victim, span_userdanger("You're frozen in fear of [caster]!"))


/datum/action/cooldown/spell/pointed/projectile/lightningbolt/eldritchbolt
	name = "Eldritch Bolt"
	desc = "Fire a bolt of Eldritch energy that will strike the target, dealing moderate burn damage."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon_state = "lightning"
	active_overlay_icon_state = "bg_spell_border_active_yellow"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	sound = 'sound/magic/lightningbolt.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS

	invocation = "EL'RICH BL'AS'T"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION | SPELL_REQUIRES_NO_ANTIMAGIC

	base_icon_state = "lightning"
	active_msg = "You energize your hands with raw power!"
	deactive_msg = "You let the energy flow out of your hands back into yourself..."
	projectile_type = /obj/projectile/magic/aoe/lightning/eldritch
	
	bolt_range = 7
	bolt_power = 1000


// /datum/action/cooldown/spell/pointed/phase_jump/obfuscation
// 	name = "Mental Obfuscation"
// 	desc = "A short range targeted teleport."
// 	background_icon_state = "bg_heretic"
// 	overlay_icon_state = "bg_heretic_border"
// 	button_icon = 'icons/mob/actions/actions_ecult.dmi'
// 	button_icon_state = "mansus_link"
// 	ranged_mousepointer = 'icons/effects/mouse_pointers/phase_jump.dmi'

// 	school = SCHOOL_FORBIDDEN

// 	cooldown_time = 25 SECONDS
// 	cast_range = 7
// 	invocation = "PH'ASE"
// 	invocation_type = INVOCATION_WHISPER
// 	active_msg = span_notice("You prepare to warp everyone's vision.")
// 	deactive_msg = span_notice("You relax your mind.")
// 	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION | SPELL_REQUIRES_NO_ANTIMAGIC

/datum/action/cooldown/spell/pointed/projectile/assault
	name = "Amygdala Assault"
	desc = "Blast a single ray of concentrated mental energy at a target, dealing high brute damage if they are caught in it"
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/obj/hand_of_god_structures.dmi'
	button_icon_state = "ward-red"

	sound = 'sound/weapons/resonator_blast.ogg'
	cast_range = 7
	cooldown_time = 25 SECONDS
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION | SPELL_REQUIRES_NO_ANTIMAGIC

	invocation = "D'O'DGE TH'IS!"
	invocation_type = INVOCATION_SHOUT

	projectile_type = /obj/projectile/heretic_assault
