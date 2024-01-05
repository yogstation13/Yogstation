/// Helper macro, for ease of expanding checks for mobs which cannot be blinded
/// There are no reason why these cannot be blinded, it is simply for "design reasons" (these things shouldn't be blinded)

#define CAN_BE_BLIND(mob) (!isanimal(mob) && !isbrain(mob) && !isrevenant(mob))

/// This status effect handles applying a temporary blind to the mob.
/datum/status_effect/temporary_blindness
	id = "temporary_blindness"
	tick_interval = 2 SECONDS
	alert_type = null
	remove_on_fullheal = TRUE

/datum/status_effect/temporary_blindness/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/temporary_blindness/on_apply()
	if(!CAN_BE_BLIND(owner))
		return FALSE

	owner.become_blind(id)
	return TRUE

/datum/status_effect/temporary_blindness/on_remove()
	owner.cure_blind(id)

/datum/status_effect/temporary_blindness/tick(delta_time, times_fired)
	if(owner.stat == DEAD)
		return

	// Temp. blindness heals faster if our eyes are covered
	if(!HAS_TRAIT_FROM(src, TRAIT_BLIND, EYES_COVERED))
		return

	// Knocks 2 seconds off of our duration
	// If we should be deleted, give a message letting them know
	var/mob/living/stored_owner = owner
	if(remove_duration(2 SECONDS))
		to_chat(stored_owner, span_green("Your eyes start to feel better!"))
		return
	// Otherwise add a chance to let them know that it's working
	else if(DT_PROB(5, delta_time))
		var/obj/item/thing_covering_eyes = owner.is_eyes_covered()
		// "Your blindfold soothes your eyes", for example
		to_chat(owner, span_green("Your [thing_covering_eyes?.name || "eye covering"] soothes your eyes."))
