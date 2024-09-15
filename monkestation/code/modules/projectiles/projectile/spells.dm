/obj/projectile/magic/fire_ball
	name = "fire ball"
	icon = 'monkestation/icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "fire_ball"
	damage = 20
	damage_type = BURN
	hitsound = null
	projectile_piercing = PASSMOB

	ricochets_max = 4
	ricochet_chance = 100
	ricochet_decay_chance = 1
	ricochet_decay_damage = 1
	ricochet_incidence_leeway = 0
	ricochet_shoots_firer = FALSE
	///A weakref to our "true" firer because ricochet changes firer
	var/datum/weakref/true_firer

/obj/projectile/magic/fire_ball/fire(angle, atom/direct_target)
	. = ..()
	if(firer)
		true_firer = WEAKREF(firer)

/obj/projectile/magic/fire_ball/prehit_pierce(atom/target)
	. = ..()
	if(. != PROJECTILE_DELETE_WITHOUT_HITTING || !ismob(target))
		return
	true_firer = WEAKREF(target)
	handle_bounce(target)
	visible_message(span_warning("[src] bounces off the aura around [target]!"))
	return PROJECTILE_PIERCE_PHASE

/obj/projectile/magic/fire_ball/Impact(atom/A)
	. = ..()
	if(.)
		playsound(src, 'sound/items/dodgeball.ogg', 200, channel = CHANNEL_SOUND_EFFECTS) //this is a very quiet sound

/obj/projectile/magic/fire_ball/on_hit(mob/living/target, blocked, pierce_hit)
	if(target == true_firer?.resolve()) //we do this here instead of on_hit_target due to us having specific logic here with handle_bounce()
		handle_bounce(target)
		return BULLET_ACT_BLOCK

	. = ..()
	if(. != BULLET_ACT_HIT || !istype(target) )
		return

	if(pierces >= ricochets_max)
		projectile_piercing = NONE
	target.adjust_fire_stacks(2)
	target.ignite_mob()
	target.Knockdown(3 SECONDS)
	target.Paralyze(0.5 SECONDS)
	handle_bounce(target)

/obj/projectile/magic/fire_ball/check_ricochet_flag(atom/A)
	return !ismob(A) //we handle mobs ourselves but besides that can ALWAYS ricochet

/obj/projectile/magic/fire_ball/check_ricochet(atom/A)
	return TRUE //this handles the prob checks which is always 100, so lets just skip the step to save resources

///Find a tile within 1 range() of a valid mob in our view, if we cant find any then return FALSE
/obj/projectile/magic/fire_ball/proc/get_new_target()
	var/list/possible_targets = list()
	var/mob/resolved_true_firer = true_firer?.resolve()
	for(var/mob/living/possible_target in view())
		if(possible_target == resolved_true_firer || impacted[possible_target])
			continue
		possible_targets += possible_target

	if(!length(possible_targets))
		return FALSE
	return pick(RANGE_TURFS(1, get_turf(pick(possible_targets))))

/obj/projectile/magic/fire_ball/proc/handle_bounce(atom/target)
	var/new_target = get_new_target()
	if(new_target)
		set_angle_centered(get_angle(target, new_target))
	else
		reflect(target)
