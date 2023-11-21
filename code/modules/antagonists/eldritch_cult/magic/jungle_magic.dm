/*

JUNGLE PATH SPELLS GO HERE

*/

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/jungle
	name = "Vine Passage"
	desc = "A short range spell that allows you to pass unimpeded through walls."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "ash_shift"
	sound = null

	school = SCHOOL_FORBIDDEN
	cooldown_time = 15 SECONDS

	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION | SPELL_REQUIRES_NO_ANTIMAGIC

	exit_jaunt_sound = null
	jaunt_duration = 1.5 SECONDS
	jaunt_in_time = 0.5 SECONDS
	jaunt_out_time = 0.5 SECONDS
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/ash_shift
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/ash_shift/out
	

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/jungle/do_steam_effects()
	return

/obj/effect/temp_visual/dir_setting/ash_shift
	name = "ash_shift"
	icon = 'icons/mob/mob.dmi'
	icon_state = "ash_shift2"
	duration = 0.5 SECONDS

/obj/effect/temp_visual/dir_setting/ash_shift/out
	icon_state = "ash_shift"

/datum/action/cooldown/spell/conjure_item/eldritch_bola
	name = "Xibulba's Caress"
	desc = "A powerful spell, allowing you to summon an eldritch bola at will."
	school = SCHOOL_FORBIDDEN
	cooldown_time = 1 MINUTES

	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION | SPELL_REQUIRES_NO_ANTIMAGIC

	item_type = /obj/item/restraints/legcuffs/bola/eldritch
	delete_old = TRUE

/datum/action/cooldown/spell/conjure_item/eldritch_bola/Remove(mob/living/remove_from)
	var/obj/item/existing = remove_from.is_holding_item_of_type(item_type)
	if(existing)
		qdel(existing)

	return ..()

// Because enchanted guns self-delete and regenerate themselves,
// override make_item here and let's not bother with tracking their weakrefs.
/datum/action/cooldown/spell/conjure_item/eldritch_bola/make_item()
	return new item_type()


/datum/action/cooldown/spell/forcewall/vines
	name = "Vine wall"
	desc = "This spell creates a temporary wall of vines to shield yourself from incoming fire."
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"

	button_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "cultforcewall"

	cooldown_time = 40 SECONDS
	invocation_type = INVOCATION_NONE

	wall_type = /obj/effect/forcefield/wizard/vines


/datum/action/cooldown/spell/pointed/projectile/spell_cards/thorns
	name = "Thorn Shot"
	desc = "Blazing hot rapid-fire homing cards. Send your foes to the shadow realm with their mystical power!"
	button_icon_state = "spellcard"

	school = SCHOOL_EVOCATION
	cooldown_time = 5 SECONDS

	invocation = "Sigi'lu M'Fan 'Tasia!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	cast_range = 40
	projectile_type = /obj/projectile/magic/thorn
	projectile_amount = 3
	projectiles_per_fire = 7


/datum/action/cooldown/spell/cone/staggered/fire_breath/xibalba
	name = "Toxic Breath"
	desc = "You breathe a cone of fire directly in front of you."
	button_icon_state = "fireball"
	sound = 'sound/magic/demon_dies.ogg' //horrifying lizard noises

	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS
	invocation_type = INVOCATION_NONE
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION | SPELL_REQUIRES_NO_ANTIMAGIC

	cone_levels = 10
	respect_density = TRUE
	/// The range our user is thrown backwards after casting the spell
	self_throw_range = 0

/datum/action/cooldown/spell/cone/staggered/fire_breath/xibalba/calculate_cone_shape(current_level)
	// This makes the cone shoot out into a 3 wide column of flames.
	// You may be wondering, "that equation doesn't seem like it'd make a 3 wide column"
	// well it does, and that's all that matters.
	return (4 * current_level) - 1

/datum/action/cooldown/spell/cone/staggered/fire_breath/xibalba/do_mob_cone_effect(mob/living/target_mob, atom/caster, level)
	// Further out targets take less immediate burn damage and get less fire stacks.
	// The actual burn damage application is not blocked by fireproofing, like space dragons.
	target_mob.apply_damage(max(40, 40 - (5 * level)), TOX)
	target_mob.adjust_fire_stacks(max(2, 5 - level))
	target_mob.ignite_mob()

/datum/action/cooldown/spell/aoe/repulse/xibalba
	name = "Xibalba's Scream"
	desc = "This spell throws everything around the user away."
	button_icon_state = "repulse"
	sound = 'sound/magic/demon_dies.ogg'

	school = SCHOOL_EVOCATION
	aoe_radius = 7
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION | SPELL_REQUIRES_NO_ANTIMAGIC

	cooldown_time = 60 SECONDS
	