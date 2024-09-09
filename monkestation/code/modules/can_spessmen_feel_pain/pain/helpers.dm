// -- Helper procs and hooks for pain. --
/mob/living
	/// The pain controller datum - tracks, processes, and handles pain.
	/// Only intialized on humans (currently), here for ease of access / future compatibillity?
	var/datum/pain/pain_controller

/mob/living/Destroy()
	QDEL_NULL(pain_controller)
	return ..()

/mob/living/carbon/human/Initialize(mapload)
	. = ..()
	var/datum/pain/new_pain_controller = new(src)
	if(!QDELETED(new_pain_controller))
		pain_controller = new_pain_controller

/**
 * Causes pain to this mob.
 *
 * Note that most damage causes pain regardless, but this is still useful for direct pain damage
 *
 * * target_zone - required, which zone or zones to afflict pain to
 * * amount - how much pain to inflict
 * * dam_type - the type of pain to inflict. Only [BRUTE] and [BURN] really matters.
 */
/mob/living/proc/cause_pain(target_zone, amount, dam_type = BRUTE)
	ASSERT(!isnull(target_zone))
	ASSERT(isnum(amount))
	return pain_controller?.adjust_bodypart_pain(target_zone, amount, dam_type)

/**
 * Runs an emote on the pain emote cooldown
 * Emote supplied does NOT need to be a pain emote
 *
 * If no emote is supplied, randomly picks from all pain-related emotes
 *
 * * emote - what emote key to run
 * * cooldown - applies cooldown on doing similar pain related emotes
 */
/mob/living/proc/pain_emote(emote, cooldown)
	return pain_controller?.do_pain_emote(emote, cooldown)

/**
 * Runs a pain message on the pain message cooldown
 *
 * * message - the message to send
 * * painless_message - optional, the message to send if the mob does not feel pain
 * * cooldown - applies cooldown on doing similar pain messages
 */
/mob/living/proc/pain_message(message, painless_message, cooldown)
	return pain_controller?.do_pain_message(message, painless_message, cooldown)

/**
 * Adjust the minimum pain the target zone can experience for a time
 *
 * This means that the target zone will not be able to go below the specified pain amount
 *
 * * target_zone - required, which zone to afflict pain to
 * * amount - how much min pain to increase
 * * time - how long to incease the min pain to
 */
/mob/living/proc/apply_min_pain(target_zone, amount, time)
	ASSERT(!isnull(target_zone))
	ASSERT(isnum(amount))
	ASSERT(isnum(time))
	return apply_status_effect(/datum/status_effect/minimum_bodypart_pain, target_zone, amount, time)

/**
 * Sets the pain modifier of [id] to [amount].
 */
/mob/living/proc/set_pain_mod(id, amount)
	ASSERT(isnum(amount))
	ASSERT(istext(id) || ispath(id))
	return pain_controller?.set_pain_modifier(id, amount)

/**
 * Unsets the pain mod at the supplied [id].
 */
/mob/living/proc/unset_pain_mod(id)
	ASSERT(istext(id) || ispath(id))
	return pain_controller?.unset_pain_modifier(id)

/**
 * Checks if this mob can feel pain.
 *
 * By default mobs cannot feel pain if they have a pain modifier of 0.5 or less.
 */
/mob/living/proc/can_feel_pain()
	return pain_controller?.pain_modifier > 0.5 && !HAS_TRAIT(src, TRAIT_NO_PAIN_EFFECTS)

/**
 * Adjusts the progress of pain shock on the current mob.
 *
 * * amount - the number of ticks of progress to remove. Note that one tick = two seconds for pain.
 * * down_to - the minimum amount of pain shock the mob can have. Defaults to -30, giving the mob a buffer against shock.
 */
/mob/living/proc/adjust_pain_shock(amount, down_to = -30)
	if(isnull(pain_controller))
		return
	if(amount > 0 && HAS_TRAIT(src, TRAIT_NO_SHOCK_BUILDUP))
		return

	ASSERT(isnum(amount))
	pain_controller.shock_buildup = max(pain_controller.shock_buildup + amount, down_to)

/**
 * Cause [amount] of [dam_type] sharp pain to [target_zones].
 * Sharp pain is for sudden spikes of pain that go away after [duration] deciseconds.
 *
 * * target_zones - requried, one or multiple target zones to apply sharp pain to
 * * amount - how much sharp pain to inflict
 * * dam_type - the type of sharp pain to inflict. Only [BRUTE] and [BURN] really matters.
 * * duration - how long the sharp pain lasts for
 */
/mob/living/proc/sharp_pain(target_zones, amount, dam_type = BRUTE, duration = 1 MINUTES)
	if(isnull(pain_controller))
		return
	ASSERT(!isnull(target_zones))
	ASSERT(isnum(amount))

	if(!islist(target_zones))
		target_zones = list(target_zones)
	for(var/zone in target_zones)
		apply_status_effect(/datum/status_effect/sharp_pain, zone, amount, dam_type, duration)

/**
 * Set [id] pain modifier to [amount], and
 * unsets it after [time] deciseconds have elapsed.
 */
/mob/living/proc/set_timed_pain_mod(id, amount, time)
	if(isnull(pain_controller))
		return
	ASSERT(isnum(amount))
	ASSERT(isnum(time))
	ASSERT(istext(id) || ispath(id))
	if(time <= 0)
		// no-op rather than stack trace or anything, so code with variable time can ignore it
		return

	set_pain_mod(id, amount)
	addtimer(CALLBACK(pain_controller, TYPE_PROC_REF(/datum/pain, unset_pain_modifier), id), time)

/**
 * Returns the bodypart pain of [zone].
 * If [get_modified] is TRUE, returns the bodypart's pain multiplied by any modifiers affecting it.
 */
/mob/living/proc/get_bodypart_pain(target_zone, get_modified = FALSE)
	ASSERT(!isnull(target_zone))

	var/obj/item/bodypart/checked_bodypart = pain_controller?.body_zones[target_zone]
	if(isnull(checked_bodypart))
		return 0

	return get_modified ? checked_bodypart.get_modified_pain() : checked_bodypart.pain
