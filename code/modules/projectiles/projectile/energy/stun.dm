/obj/projectile/energy/electrode
	name = "electrode"
	icon_state = "spark"
	color = "#FFFF00"
	/*
	paralyze = 10 SECONDS
	stutter = 10 SECONDS
	jitter = 40 SECONDS
	*/
	hitsound = 'sound/weapons/taserhit.ogg'
	range = 5
	tracer_type = /obj/effect/projectile/tracer/stun
	muzzle_type = /obj/effect/projectile/muzzle/stun
	impact_type = /obj/effect/projectile/impact/stun

/obj/projectile/energy/electrode/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(pierce_hit)
		return .
	do_sparks(1, TRUE, src)
	if(. == BULLET_ACT_BLOCK || !isliving(target) || blocked >= 100)
		visible_message(span_warning("The electrodes fail to shock [target], and fall to the ground."))
		return .

	var/mob/living/tased = target
	if(HAS_TRAIT(target, TRAIT_HULK))
		tased.say(pick(
			";RAAAAAAAARGH!",
			";HNNNNNNNNNGGGGGGH!",
			";GWAAAAAAAARRRHHH!",
			"NNNNNNNNGGGGGGGGHH!",
			";AAAAAAARRRGH!",
		), forced = "hulk")
	if(tased.apply_status_effect(/datum/status_effect/tased, fired_from, firer))
		return .
	visible_message(span_warning("The electrodes fail to shock [target], and fall to the ground."))
	return BULLET_ACT_BLOCK


/obj/projectile/energy/electrode/on_range() //to ensure the bolt sparks when it reaches the end of its range if it didn't hit a target yet
	do_sparks(1, TRUE, src)
	return ..()
