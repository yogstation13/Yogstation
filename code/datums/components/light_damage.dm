/datum/component/light_damage
	var/damage_per_second = 0 //Damage per second at FULL LIGHT
	var/heal_per_second = 0 // Heal per second in FULL DARKNESS
	var/threshold = 0.5 // The point at which it switches from heal to damage

	var/ramping_scaler = 1 // Ramping damage modifier. The ramp will be multiplied by this every second

	var/current_ramp = 1

	var/speed_up_in_darkness = 0 // How fast the mob should go in full darkness (additive, negative for faster)
	var/speed_down_in_light = 0 // How slow the mob should go in full light (additive, negative for faster)
	var/list/damage_types = list(CLONE)
	var/list/heal_types = list(BRAIN, CLONE, BRUTE, BURN, TOX, STAMINA)
	var/damage_sound_effect = 'sound/effects/grue_burn.ogg'

	var/damage_enabled = TRUE
	var/healing_enabled = TRUE

/datum/component/light_damage/Initialize(_damage_per_second, _heal_per_second, _ramping_scaler = 1, _speed_up_in_darkness = 0, _speed_down_in_light = 0)
	. = ..()
	if(!isliving(parent)) //Must be a mob
		return COMPONENT_INCOMPATIBLE
	var/mob/living/L = parent

	src.damage_per_second = _damage_per_second
	src.heal_per_second = _heal_per_second
	src.ramping_scaler = _ramping_scaler
	src.speed_up_in_darkness = _speed_up_in_darkness
	src.speed_down_in_light = _speed_down_in_light

	L.add_movespeed_modifier(MOVESPEED_ID_LIGHT_DAMAGE, update = FALSE, priority = 1000, override=TRUE, multiplicative_slowdown=0.0)
	RegisterSignal(parent, COMSIG_LIVING_LIFE, .proc/on_life)


/datum/component/light_damage/proc/on_life(mob/living/source, delta_time, times_fired)
	var/turf/T = get_turf(source)
	var/light_amount = T.get_lumcount() // 0 ---- 1
	var/speed = 0
	var/delta_time_seconds = delta_time / 10

	if (light_amount >= threshold)
		if (damage_enabled)
			//We are damaging
			var/damage = light_amount * (damage_per_second * delta_time_seconds)
			damage /= damage_types.len
			damage *= current_ramp

			current_ramp *= (ramping_scaler * delta_time_seconds)

			for (var/dmgtype in damage_types)
				source.apply_damage_type(damage, dmgtype)
			playsound(src, damage_sound_effect, 50, 1)
		speed = speed_down_in_light * (light_amount)
	else 
		//We are healing
		if (healing_enabled)
			var/heal = (1 - light_amount) * (heal_per_second * delta_time_seconds)
			source.heal_ordered_damage(heal, heal_types)
		current_ramp = initial(current_ramp)
		speed = speed_up_in_darkness * (1 - light_amount)

	source.add_movespeed_modifier(MOVESPEED_ID_LIGHT_DAMAGE, update = TRUE, priority = 1000, override=TRUE, multiplicative_slowdown=speed)


