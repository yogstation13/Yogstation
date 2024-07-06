/datum/status_effect/holy_fire
	id = "doubledown"
	duration = 5 SECONDS
	tick_interval = 1 //10 times per second
	status_type = STATUS_EFFECT_REFRESH
	var/total_damage = 180
	var/damage_per_tick = 1

/datum/status_effect/holy_fire/on_apply()
	. = ..()
	if(.)
		damage_per_tick = total_damage / (duration / tick_interval) //we do it this way for easier balancing
		owner.add_emitter(/obj/emitter/fire/holy, "holy_fire")
		owner.add_emitter(/obj/emitter/sparks/fire, "holy_sparks")
		owner.apply_damage(damage_per_tick, BURN) //apply damage here too so it actually does the full total expected damage rather than 1 less tick of damage

/datum/status_effect/holy_fire/tick(delta_time, times_fired)
	. = ..()
	owner.apply_damage(damage_per_tick, BURN)

/datum/status_effect/holy_fire/on_remove()
	owner.remove_emitter("holy_fire")
	owner.remove_emitter("holy_sparks")
