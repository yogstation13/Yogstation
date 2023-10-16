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
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION
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
