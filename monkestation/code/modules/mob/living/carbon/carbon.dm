/mob/living/carbon/hypnosis_vulnerable()
	if(HAS_MIND_TRAIT(src, TRAIT_UNCONVERTABLE))
		return FALSE
	return ..()

/mob/living/carbon/proc/fumble_throw_item(atom/target, atom/movable/thrown_thing)
	visible_message(span_danger("[src] fumbles [thrown_thing]."), \
					span_danger("You fumble [thrown_thing]."))
	log_message("has failed to throw [thrown_thing]", LOG_ATTACK)
	thrown_thing.safe_throw_at(target, min(thrown_thing.throw_range, 1), 1, src, FALSE, null, null, move_force, gentle=TRUE)
	return FALSE
