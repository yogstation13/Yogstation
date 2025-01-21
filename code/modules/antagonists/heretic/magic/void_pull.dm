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
	cooldown_time = 30 SECONDS

	invocation = "BR'NG F'RTH TH'M T' M'."
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	aoe_radius = 7
	/// The radius of the actual damage circle done before cast
	var/damage_radius = 1
	/// The radius of the stun applied to nearby people on cast
	var/stun_radius = 4

/datum/action/cooldown/spell/aoe/void_pull/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	new /obj/effect/temp_visual/voidin(get_turf(cast_on))

/datum/action/cooldown/spell/aoe/void_pull/get_things_to_cast_on(atom/center)
	var/list/things = list()
	for(var/mob/living/nearby_mob in view(aoe_radius, center))
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

/datum/action/cooldown/spell/aoe/void_pull/cast_on_thing_in_aoe(mob/living/victim, atom/caster)
	var/distance = get_dist(victim, caster)
	if(distance > stun_radius)
		for(var/i in 1 to 3)
			victim.forceMove(get_step_towards(victim, caster))
		return
	if(distance <= damage_radius)
		victim.apply_damage(30, BRUTE, wound_bonus = CANT_WOUND)
	victim.AdjustKnockdown(3 SECONDS)
	victim.AdjustParalyzed(0.5 SECONDS)
