/**
 * The pain controller datum.
 *
 * Attatched to a /carbon/human, this datum tracks all the pain values on all their bodyparts and handles updating them.
 * This datum processes on alive humans every 2 seconds.
 */
/datum/pain
	/// The parent mob we're tracking.
	var/mob/living/carbon/parent
	/// Modifier applied to all [adjust_pain] amounts
	var/pain_modifier = 1
	/// Lazy Assoc list [id] to [modifier], all our pain modifiers affecting our final mod
	var/list/pain_mods
	/// Lazy Assoc list [zones] to [references to bodyparts], all the body parts we're tracking
	var/list/body_zones
	/// Natural amount of decay given to each limb per 5 ticks of process, increases over time
	var/natural_pain_decay = -0.8
	/// The base amount of pain decay received.
	var/base_pain_decay = -0.8
	/// Counter to track pain decay. Pain decay is only done once every 5 ticks.
	var/natural_decay_counter = 0
	/// Amount of shock building up from higher levels of pain
	/// When greater than current health, we go into shock
	var/shock_buildup = 0
	/// Tracks how many successful heart attack rolls in a row
	VAR_FINAL/heart_attack_counter = 0
	/// Cooldown to track the last time we lost pain.
	COOLDOWN_DECLARE(time_since_last_pain_loss)
	/// Cooldown to track last time we sent a pain message.
	COOLDOWN_DECLARE(time_since_last_pain_message)
	/// Cooldown to track last time heart attack counter went up.
	COOLDOWN_DECLARE(time_since_last_heart_attack_counter)

#ifdef TESTING
	/// For testing. Does this pain datum print testing messages when it happens?
	var/print_debug_messages = TRUE
	/// For testing. Does this pain datum include ALL test messages, including very small and constant ones (like pain decay)?
	var/print_debug_decay = FALSE
#endif

/datum/pain/New(mob/living/carbon/human/new_parent)
	if(!iscarbon(new_parent) || istype(new_parent, /mob/living/carbon/human/dummy))
		qdel(src) // If we're not a carbon, or a dummy, delete us
		return null

	parent = new_parent

	body_zones = list()
	for(var/obj/item/bodypart/parent_bodypart as anything in parent.bodyparts)
		add_bodypart(parent, parent_bodypart, TRUE)

	if(!length(body_zones))
		stack_trace("Pain datum failed to find any body_zones to track!")
		qdel(src) // If we have no bodyparts, delete us
		return

	register_pain_signals()
	base_pain_decay = natural_pain_decay

	addtimer(CALLBACK(src, PROC_REF(start_pain_processing), 1))

#ifdef TESTING
	if(new_parent.z && !is_station_level(new_parent.z))
		print_debug_messages = FALSE
#endif

/datum/pain/Destroy()
	body_zones = null
	if(parent)
		STOP_PROCESSING(SSpain, src)
		unregister_pain_signals()
		parent = null
	return ..()

/datum/pain/proc/start_pain_processing()
	if(parent.stat != DEAD)
		START_PROCESSING(SSpain, src)

/**
 * Register all of our signals with our parent.
 */
/datum/pain/proc/register_pain_signals()
	RegisterSignal(parent, COMSIG_CARBON_ATTACH_LIMB, PROC_REF(add_bodypart))
	RegisterSignal(parent, COMSIG_CARBON_GAIN_WOUND, PROC_REF(add_wound_pain))
	RegisterSignal(parent, COMSIG_CARBON_LOSE_WOUND, PROC_REF(remove_wound_pain))
	RegisterSignal(parent, COMSIG_CARBON_REMOVE_LIMB, PROC_REF(remove_bodypart))
	RegisterSignal(parent, COMSIG_LIVING_HEALTHSCAN, PROC_REF(on_analyzed))
	RegisterSignal(parent, COMSIG_LIVING_POST_FULLY_HEAL, PROC_REF(on_fully_healed))
	RegisterSignal(parent, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(add_damage_pain))
	RegisterSignal(parent, COMSIG_MOB_STATCHANGE, PROC_REF(on_parent_statchance))
	RegisterSignals(parent, list(SIGNAL_ADDTRAIT(TRAIT_NO_PAIN_EFFECTS), SIGNAL_REMOVETRAIT(TRAIT_NO_PAIN_EFFECTS)), PROC_REF(refresh_pain_attributes))
	RegisterSignal(parent, COMSIG_LIVING_TREAT_MESSAGE, PROC_REF(handle_message))
	RegisterSignal(parent, COMSIG_MOB_FIRED_GUN, PROC_REF(on_mob_fired_gun))
	RegisterSignal(parent, COMSIG_LIVING_REVIVE, PROC_REF(revived))

/**
 * Unregister all of our signals from our parent when we're done, if we have signals to unregister.
 */
/datum/pain/proc/unregister_pain_signals()
	UnregisterSignal(parent, list(
		COMSIG_CARBON_ATTACH_LIMB,
		COMSIG_CARBON_GAIN_WOUND,
		COMSIG_CARBON_LOSE_WOUND,
		COMSIG_CARBON_REMOVE_LIMB,
		COMSIG_LIVING_HEALTHSCAN,
		COMSIG_LIVING_POST_FULLY_HEAL,
		COMSIG_LIVING_REVIVE,
		COMSIG_LIVING_TREAT_MESSAGE,
		COMSIG_MOB_APPLY_DAMAGE,
		COMSIG_MOB_FIRED_GUN,
		COMSIG_MOB_STATCHANGE,
		SIGNAL_ADDTRAIT(TRAIT_NO_PAIN_EFFECTS),
		SIGNAL_REMOVETRAIT(TRAIT_NO_PAIN_EFFECTS),
	))

/**
 * Add a limb to be tracked.
 *
 * source - source of the signal / the mob who is gaining the limb / parent
 * new_limb - the bodypart being attatched
 * special - whether this limb being attatched should have side effects (if TRUE, likely being attatched on initialization)
 */
/datum/pain/proc/add_bodypart(mob/living/carbon/source, obj/item/bodypart/new_limb, special)
	SIGNAL_HANDLER

	if(!istype(new_limb) || QDELING(new_limb)) // pseudo-bodyparts are not tracked for simplicity (chainsaw arms)
		return

	var/obj/item/bodypart/existing = body_zones[new_limb.body_zone]
	if(!QDELETED(existing)) // if we already have a val assigned to this key, remove it
		remove_bodypart(source, existing, FALSE, special)

	body_zones[new_limb.body_zone] = new_limb

	if(special || (HAS_TRAIT(source, TRAIT_LIMBATTACHMENT) && (new_limb.bodytype & BODYTYPE_ROBOTIC)))
		new_limb.pain = 0
	else
		adjust_bodypart_pain(new_limb.body_zone, new_limb.pain)
		adjust_bodypart_pain(BODY_ZONE_CHEST, new_limb.pain / 3)

	RegisterSignal(new_limb, COMSIG_QDELETING, PROC_REF(limb_delete))

/**
 * Remove a limb from being tracked.
 *
 * source - source of the signal / the mob who is losing the limb / parent
 * lost_limb - the bodypart being removed
 * special - whether this limb being removed should have side effects (if TRUE, likely being removed on initialization)
 * dismembered - whether this limb was dismembered
 */
/datum/pain/proc/remove_bodypart(mob/living/carbon/source, obj/item/bodypart/lost_limb, dismembered, special)
	SIGNAL_HANDLER

	var/bad_zone = lost_limb.body_zone
	if(lost_limb != body_zones[bad_zone])
		CRASH("Pain datum tried to remove a bodypart that wasn't being tracked!")

	body_zones -= bad_zone
	UnregisterSignal(lost_limb, COMSIG_QDELETING)

	if(!QDELETED(parent))
		if(!special && !(HAS_TRAIT(source, TRAIT_LIMBATTACHMENT) && (lost_limb.bodytype & BODYTYPE_ROBOTIC)))
			var/limb_removed_pain = (dismembered ? PAIN_LIMB_DISMEMBERED : PAIN_LIMB_REMOVED)
			if(!isnewplayer(usr)) //painful this should be avoided
				adjust_bodypart_pain(BODY_ZONE_CHEST, limb_removed_pain)
				adjust_bodypart_pain(BODY_ZONES_MINUS_CHEST, limb_removed_pain / 3)

	if(!QDELETED(lost_limb))
		lost_limb.pain = initial(lost_limb.pain)
		REMOVE_TRAIT(lost_limb, TRAIT_PARALYSIS, PAIN_LIMB_PARALYSIS)

/datum/pain/proc/limb_delete(obj/item/bodypart/source)
	SIGNAL_HANDLER

	remove_bodypart(source.owner, source, special = TRUE) // Special I guess? Straight up deleted

/**
 * Add a pain modifier and update our overall modifier.
 *
 * key - key of the added modifier
 * amount - multiplier of the modifier
 *
 * returns TRUE if our pain mod actually changed
 */
/datum/pain/proc/set_pain_modifier(key, amount)
	var/existing_key = LAZYACCESS(pain_mods, key)
	if(!isnull(existing_key))
		if(amount > 1 && existing_key >= amount)
			return FALSE
		if(amount < 1 && existing_key <= amount)
			return FALSE
		if(amount == 1)
			return FALSE

	LAZYSET(pain_mods, key, amount)
	refresh_pain_attributes()
	return update_pain_modifier()

/**
 * Remove a pain modifier and update our overall modifier.
 *
 * key - key of the removed modifier
 *
 * returns TRUE if our pain mod actually changed
 */
/datum/pain/proc/unset_pain_modifier(key)
	if(isnull(LAZYACCESS(pain_mods, key)))
		return FALSE

	LAZYREMOVE(pain_mods, key)
	return update_pain_modifier()

/**
 * Update our overall pain modifier.
 * The pain modifier is multiplicative based on all the pain modifiers we have.
 *
 * returns TRUE if our pain modifier was changed after update, FALSE if it remained the same
 */
/datum/pain/proc/update_pain_modifier()
	var/old_pain_mod = pain_modifier
	pain_modifier = 1
	for(var/mod in pain_mods)
		pain_modifier *= pain_mods[mod]
	// Throw alert if a drug specifically is numbing us
	if(pain_modifier < 0.75)
		for(var/datum/reagent/med as anything in parent.reagents.reagent_list)
			if(med.pain_modifier <= 0.5)
				parent.throw_alert("numbed", /atom/movable/screen/alert/numbed)
				break
	else
		parent.clear_alert("numbed")
	return old_pain_mod != pain_modifier

/**
 * Adjust the amount of pain in all [def_zones] provided by [amount] (multiplied by the [pain_modifier] if positive).
 *
 * def_zones - list of all zones being adjusted. Can be passed a non-list.
 * amount - amount of pain being applied to all items in [def_zones]. If posiitve, multiplied by [pain_modifier].
 */
/datum/pain/proc/adjust_bodypart_pain(list/def_zones, amount = 0, dam_type = BRUTE)
	SHOULD_NOT_SLEEP(TRUE) // This needs to be asyncronously called in a lot of places, it should already check that this doesn't sleep but just in case.

	if(!islist(def_zones))
		def_zones = list(def_zones)

	// No pain at all
	if(amount == 0)
		return FALSE
	if(amount > 0 && (parent.status_flags & GODMODE))
		return FALSE

	for(var/zone in shuffle(def_zones))
		var/adjusted_amount = round(amount, 0.01)
		var/obj/item/bodypart/adjusted_bodypart = body_zones[check_zone(zone)]
		if(QDELETED(adjusted_bodypart)) // it's valid - for if we're passed a zone we don't have
			continue

		var/current_amount = adjusted_bodypart.pain

		// Pain is negative (healing)
		if(adjusted_amount < 0)
			// Pain is negative and we're at min pain
			if(current_amount <= adjusted_bodypart.min_pain)
				continue
			// Pain is negative and we're above soft cap, incraese the healing amount greatly
			if(current_amount >= adjusted_bodypart.soft_max_pain)
				adjusted_amount *= 2 * (current_amount / adjusted_bodypart.soft_max_pain)

		// Pain is positive (dealing)
		else
			// Pain is positive and we're at the soft cap, reduce the incoming pain
			if(current_amount >= adjusted_bodypart.soft_max_pain)
				adjusted_amount *= 0.75 * (adjusted_bodypart.soft_max_pain / current_amount)
			adjusted_amount = round(adjusted_amount * pain_modifier * adjusted_bodypart.bodypart_pain_modifier, 0.01)
			// Pain modifiers results in us taking 0 pain
			// (If someone adds a negative pain mod and causes "inverse pain" (which you shouldn't) this needs to go)
			if(adjusted_amount <= 0)
				continue

			// Officially recieving pain at this point
			adjusted_bodypart.last_received_pain_type = dam_type

#ifdef TESTING
		if(print_debug_messages)
			testing("[amount] was adjusted down to [adjusted_amount]. (Modifiers: [pain_modifier], [adjusted_bodypart.bodypart_pain_modifier])")
#endif

		// Actually do the pain addition / subtraction here
		adjusted_bodypart.pain = max(current_amount + adjusted_amount, adjusted_bodypart.min_pain)

		if(adjusted_amount > 0)
			INVOKE_ASYNC(src, PROC_REF(on_pain_gain), adjusted_bodypart, amount, dam_type)
		else if(adjusted_amount <= -1.5 || COOLDOWN_FINISHED(src, time_since_last_pain_loss))
			INVOKE_ASYNC(src, PROC_REF(on_pain_loss), adjusted_bodypart, amount, dam_type)

#ifdef TESTING
		if(print_debug_messages && (print_debug_decay || abs(adjusted_amount) > 1))
			testing("PAIN DEBUG: [parent] recived [adjusted_amount] pain to [adjusted_bodypart]. Part pain: [adjusted_bodypart.pain]")
#endif

	return TRUE

/**
 * Set the minimum amount of pain in all [def_zones] by [amount].
 *
 * def_zones - list of all zones being adjusted. Can be passed a non-list.
 * amount - amount of pain being all items in [def_zones] are set to.
 */
/datum/pain/proc/adjust_bodypart_min_pain(list/def_zones, amount = 0)
	if(!amount)
		return

	if(!islist(def_zones))
		def_zones = list(def_zones)

	for(var/zone in def_zones)
		var/obj/item/bodypart/adjusted_bodypart = body_zones[zone]
		if(QDELETED(adjusted_bodypart)) // it's valid - for if we're passed a zone we don't have
			continue
		adjusted_bodypart.min_pain = max(adjusted_bodypart.min_pain + amount, 0) // Negative min pain is a neat idea ("banking pain") but not today
		adjusted_bodypart.pain = max(adjusted_bodypart.pain, adjusted_bodypart.min_pain)

	return TRUE

/**
 * Called when pain is gained to apply side effects.
 * Calls [affected_part]'s [on_gain_pain_effects] proc with arguments [amount].
 * Sends signal [COMSIG_CARBON_PAIN_GAINED] with arguments [mob/living/carbon/parent, obj/item/bodypart/affected_part, amount].
 *
 * affected_part - the bodypart that gained the pain
 * amount - amount of pain that was gained, post-[pain_modifier] applied
 */
/datum/pain/proc/on_pain_gain(obj/item/bodypart/affected_part, amount, dam_type)
	affected_part.on_gain_pain_effects(amount, dam_type)
	refresh_pain_attributes()
	SEND_SIGNAL(parent, COMSIG_CARBON_PAIN_GAINED, affected_part, amount, dam_type)
	COOLDOWN_START(src, time_since_last_pain_loss, 60 SECONDS)
	if(amount > PAIN_LIMB_MAX * 0.25)
		parent.pain_emote("scream", 5 SECONDS)
		parent.flash_pain_overlay(2)

	else if(amount > PAIN_LIMB_MAX * 0.1)
		parent.pain_emote(pick("wince", "gasp", "grimace", "inhale_s", "exhale_s", "flinch"), 3 SECONDS)
		parent.flash_pain_overlay(1)

/**
 * Called when pain is lost, if the mob did not lose pain in the last 60 seconds.
 * Calls [affected_part]'s [on_lose_pain_effects] proc with arguments [amount].
 * Sends signal [COMSIG_CARBON_PAIN_LOST] with arguments [mob/living/carbon/parent, obj/item/bodypart/affected_part, amount].
 *
 * affected_part - the bodypart that lost pain
 * amount - amount of pain that was lost
 */
/datum/pain/proc/on_pain_loss(obj/item/bodypart/affected_part, amount, type)
	affected_part.on_lose_pain_effects(amount)
	refresh_pain_attributes()
	SEND_SIGNAL(parent, COMSIG_CARBON_PAIN_LOST, affected_part, amount, type)

/**
 * Hook into [/mob/living/proc/apply_damage] proc via signal and apply pain based on how much damage was gained.
 *
 * source - source of the signal / the mob being damaged / parent
 * damage - the amount of damage sustained
 * damagetype - the type of damage sustained
 * def_zone - the limb being targeted with damage (either a bodypart zone or an obj/item/bodypart)
 */
/datum/pain/proc/add_damage_pain(
	mob/living/carbon/source,
	damage,
	damagetype,
	def_zone,
	blocked = 0,
	wound_bonus = 0,
	bare_wound_bonus = 0,
	sharpness = NONE,
	attack_direction,
	obj/item/attacking_item,
)

	SIGNAL_HANDLER

	if(damage <= 2.5 || (parent.status_flags & GODMODE))
		return
	if(isbodypart(def_zone))
		var/obj/item/bodypart/targeted_part = def_zone
		def_zone = targeted_part.body_zone
	else
		def_zone = check_zone(def_zone)

	// By default pain is calculated based on damage and wounding
	// Attacks with a wound bonus add additional pain (usually, like 2-5)
	// (Note that if they also succeed in applying a wound, more pain comes from that)
	// Also, sharp attacks apply a smidge extra pain
	var/pain = ((100 - blocked) / 100) * ((10 * damage) ** 0.66 + (0.2 * max(wound_bonus + bare_wound_bonus - parent.getarmor(def_zone, WOUND), 0))) * (sharpness ? 1.2 : 1)
	switch(damagetype)
		// Brute pain is dealt to the target zone
		// pain is just divided by a random number, for variance
		if(BRUTE)
			pain *= pick(0.6, 0.7, 0.8)

		// Burn pain is dealt to the target zone
		// pain is lower for weaker burns, but scales up for more damaging burns
		if(BURN)
			switch(damage)
				if(1 to 10)
					pain *= 0.25
				if(10 to 20)
					pain *= 0.5
				if(20 to INFINITY)
					pain *= 0.75

		// Toxins pain is dealt to the chest (stomach and liver)
		// Pain is determined by the liver's tox tolerance, liver damage, and stomach damage
		// having a high amount of toxloss also adds additional pain
		//
		// Note: 99% of sources of toxdamage is done through adjusttoxloss, and as such doesn't go through this
		if(TOX)
			if(HAS_TRAIT(parent, TRAIT_TOXINLOVER) || HAS_TRAIT(parent, TRAIT_TOXIMMUNE))
				return
			def_zone = BODY_ZONE_CHEST
			var/obj/item/organ/internal/liver/our_liver = source.get_organ_slot(ORGAN_SLOT_LIVER)
			var/obj/item/organ/internal/stomach/our_stomach = source.get_organ_slot(ORGAN_SLOT_STOMACH)
			if(our_liver)
				pain = damage / our_liver.toxTolerance
				switch(our_liver.damage)
					if(20 to 50)
						pain += 1
					if(50 to 80)
						pain += 2
					if(80 to INFINITY)
						pain += 3
			else if(HAS_TRAIT(parent, TRAIT_LIVERLESS_METABOLISM))
				pain = 1
			else
				pain = damage * 2

			if(our_stomach)
				switch(our_stomach.damage)
					if(20 to 50)
						pain += 1
					if(50 to 80)
						pain += 2
					if(80 to INFINITY)
						pain += 3
			else if(HAS_TRAIT(parent, TRAIT_NOHUNGER))
				pain = 1
			else
				pain += 3

			switch(source.getToxLoss())
				if(33 to 66)
					pain += 1
				if(66 to INFINITY)
					pain += 3

		// Oxy pain is dealt to the head and chest
		// pain is increasd based on lung damage and overall oxyloss
		//
		// Note: 99% of sources of oxydamage is done through adjustoxyloss, and as such doesn't go through this
		if(OXY)
			return

		// No pain from stamina loss
		// In the future stamina can probably cause very sharp pain and replace stamcrit,
		// but the system will require much finer tuning before then
		if(STAMINA, PAIN)
			return

		// Head pain causes brain damage, so brain damage causes no pain (to prevent death spirals)
		if(BRAIN)
			return

	if(!def_zone || !pain)
#ifdef TESTING
		if(print_debug_messages)
			testing("PAIN DEBUG: [parent] recieved damage but no pain. ([def_zone ? "Nullified to [pain]" : "No def zone"])")
#endif
		return

#ifdef TESTING
	if(print_debug_messages)
		testing("PAIN DEBUG: [parent] is recieving [pain] of type [damagetype] to the [parse_zone(def_zone)]. (Original amount: [damage])")
#endif

	adjust_bodypart_pain(def_zone, pain, damagetype)

/**
 * Add pain in from a received wound based on severity.
 *
 * source - source of the signal / the mob being wounded / parent
 * applied_wound - the wound being applied
 * wounded_limb - the limb being wounded
 */
/datum/pain/proc/add_wound_pain(mob/living/carbon/source, datum/wound/applied_wound, obj/item/bodypart/wounded_limb)
	SIGNAL_HANDLER

#ifdef TESTING
	if(print_debug_messages)
		testing("PAIN DEBUG: [parent] is recieving a wound of level [applied_wound.severity] to the [parse_zone(wounded_limb.body_zone)].")
#endif

	adjust_bodypart_min_pain(wounded_limb.body_zone, applied_wound.severity * 5)
	adjust_bodypart_pain(wounded_limb.body_zone, applied_wound.severity * 7.5)

/**
 * Remove pain from a healed wound.
 *
 * source - source of the signal / the mob being wounded / parent
 * removed_wound - the wound being healed
 * wounded_limb - the limb that was wounded
 */
/datum/pain/proc/remove_wound_pain(mob/living/carbon/source, datum/wound/removed_wound, obj/item/bodypart/wounded_limb)
	SIGNAL_HANDLER

	adjust_bodypart_min_pain(wounded_limb.body_zone, -removed_wound.severity * 5)
	adjust_bodypart_pain(wounded_limb.body_zone, -removed_wound.severity * 5)

/**
 * The process proc for pain.
 *
 * Applies and removes pain modifiers as they come and go.
 * Causes various side effects based on pain.
 *
 * Triggers once every 2 seconds.
 * Handles natural pain decay, which happens once every 5 processes (every 10 seconds)
 */
/datum/pain/process(seconds_per_tick)
	if(!HAS_TRAIT(parent, TRAIT_ANALGESIA))
		var/has_pain = FALSE
		var/just_cant_feel_anything = !parent.can_feel_pain()
		var/no_recent_pain = COOLDOWN_FINISHED(src, time_since_last_pain_loss)
		for(var/part in shuffle(body_zones))
			var/obj/item/bodypart/checked_bodypart = body_zones[part]
			if(QDELETED(checked_bodypart))
				continue
			if(checked_bodypart.pain <= 0)
				continue
			has_pain = TRUE
			if(just_cant_feel_anything || !COOLDOWN_FINISHED(src, time_since_last_pain_message))
				continue
			// 1% chance per 8 pain being experienced to get a feedback message every second
			if(!SPT_PROB(checked_bodypart.get_modified_pain() / 8, seconds_per_tick))
				continue
			if(checked_bodypart.pain_feedback(seconds_per_tick, no_recent_pain))
				COOLDOWN_START(src, time_since_last_pain_message, 12 SECONDS)

		if(!has_pain && (shock_buildup <= -30) && !HAS_TRAIT_FROM(parent, TRAIT_LABOURED_BREATHING, PAINSHOCK))
			// no-op if none of our bodyparts are in pain
			return

		var/shock_mod = max(pain_modifier, 0.33)
		if(HAS_TRAIT(parent, TRAIT_ABATES_SHOCK))
			shock_mod *= 0.5
		if(parent.health > 0)
			shock_mod *= 0.25
		if(parent.health <= parent.maxHealth * -2 || (!HAS_TRAIT(parent, TRAIT_NOBLOOD) && parent.blood_volume < BLOOD_VOLUME_BAD))
			shock_mod *= 1.5
		if(parent.health <= parent.maxHealth * -4 || (!HAS_TRAIT(parent, TRAIT_NOBLOOD) && parent.blood_volume < BLOOD_VOLUME_SURVIVE))
			shock_mod *= 2 // stacks with above
		var/curr_pain = get_total_pain()
		if(curr_pain < PAIN_LIMB_MAX * 0.5)
			parent.adjust_pain_shock(-24 * seconds_per_tick) // staying out of pain for a while gives you a small resiliency to shock (~1 minute)
		else if(curr_pain < PAIN_LIMB_MAX)
			parent.adjust_pain_shock(-6 * seconds_per_tick)
		else if(curr_pain < PAIN_LIMB_MAX * 2)
			if(shock_buildup <= 120)
				parent.adjust_pain_shock(0.5 * shock_mod * seconds_per_tick)
		else if(curr_pain < PAIN_LIMB_MAX * 4)
			if(shock_buildup <= 195)
				parent.adjust_pain_shock(1 * shock_mod * seconds_per_tick)
			if(SPT_PROB(2, seconds_per_tick))
				do_pain_message(span_userdanger(pick("It hurts.")))
		else
			parent.adjust_pain_shock(clamp(round(0.5 * (curr_pain / PAIN_LIMB_MAX), 0.1), 1.5, 8) * shock_mod * seconds_per_tick)
			if(SPT_PROB(2, seconds_per_tick))
				do_pain_message(span_userdanger(pick("Stop the pain!", "It hurts!")))

		switch(shock_buildup * 0.25)
			if(10 to 60)
				parent.adjust_bodytemperature(-5 * seconds_per_tick, min_temp = parent.bodytemp_cold_damage_limit + 5)
			if(60 to 120)
				if(SPT_PROB(2, seconds_per_tick))
					do_pain_message(span_bolddanger(pick("It hurts.", "You really need some painkillers.")))
				if(SPT_PROB(4, seconds_per_tick))
					do_pain_message(span_warning(pick("You feel cold!", "You feel sweaty!")))
					parent.pain_emote("shiver", 3 SECONDS)
				parent.adjust_bodytemperature(-10 * seconds_per_tick, min_temp = parent.bodytemp_cold_damage_limit - 5)
			if(120 to 180)
				if(SPT_PROB(2, seconds_per_tick))
					do_pain_message(span_userdanger(pick("Stop the pain!", "It hurts!", "You need painkillers now!")))
				if(SPT_PROB(4, seconds_per_tick))
					do_pain_message(span_warning("You feel freezing!"))
					parent.pain_emote("shiver", 3 SECONDS)
				parent.adjust_bodytemperature(-20 * seconds_per_tick, min_temp = parent.bodytemp_cold_damage_limit - 20)

		if((shock_buildup >= 60 || curr_pain >= PAIN_LIMB_MAX) && !just_cant_feel_anything)
			if(SPT_PROB(min(curr_pain / 5, 24), seconds_per_tick))
				parent.adjust_jitter_up_to(5 SECONDS * pain_modifier, 30 SECONDS)
			if(SPT_PROB(min(curr_pain / 10, 12), seconds_per_tick))
				parent.adjust_dizzy_up_to(5 SECONDS * pain_modifier, 30 SECONDS)
			if(SPT_PROB(min(curr_pain / 20, 6), seconds_per_tick)) // pain applies its own stutter
				parent.adjust_stutter_up_to(5 SECONDS * pain_modifier, 30 SECONDS)

		if(shock_buildup >= 120 && parent.stat != HARD_CRIT)
			if(SPT_PROB(shock_buildup / 60, seconds_per_tick))
				//parent.vomit(VOMIT_CATEGORY_KNOCKDOWN, lost_nutrition = 7.5)
				parent.Knockdown(rand(3 SECONDS, 6 SECONDS))

		if(shock_buildup >= 180 || curr_pain >= PAIN_CHEST_MAX)
			if(SPT_PROB(shock_buildup / 20, seconds_per_tick) && !parent.IsParalyzed() && parent.Paralyze(rand(2 SECONDS, 8 SECONDS)))
				parent.visible_message(
					span_warning("[parent]'s body falls limp!"),
					span_warning("Your body [just_cant_feel_anything ? "goes" : "falls"] limp!"),

				)
			if(SPT_PROB(shock_buildup / 60, seconds_per_tick))
				parent.adjust_confusion_up_to(8 SECONDS * pain_modifier, 24 SECONDS)

		if((shock_buildup >= 360 || curr_pain >= PAIN_CHEST_MAX * 2) && SPT_PROB(shock_buildup / 120, seconds_per_tick) && parent.stat != HARD_CRIT)
			if(!parent.IsUnconscious() && parent.Unconscious(rand(4 SECONDS, 16 SECONDS)))
				parent.visible_message(
					span_warning("[parent] falls unconscious!"),
					span_warning(pick("You black out!", "You feel like you're about to die!", "You lose consciousness!")),

				)

		// This is death
		if(shock_buildup >= 360 && !parent.undergoing_cardiac_arrest())
			var/heart_attack_prob = 0
			if(parent.health <= parent.maxHealth * -1)
				heart_attack_prob += abs(parent.health + parent.maxHealth) * 0.1
			if(shock_buildup >= 540)
				heart_attack_prob += (shock_buildup * 0.1 * 0.25)
			if(SPT_PROB(min(20, heart_attack_prob), seconds_per_tick))
				if(!COOLDOWN_FINISHED(src, time_since_last_heart_attack_counter))
					parent.losebreath += 1
				else if(!parent.can_heartattack())
					parent.losebreath += 4
				else if(heart_attack_counter >= 3)
					to_chat(parent, span_userdanger("Your heart stops!"))
					if(!parent.incapacitated())
						parent.visible_message(span_danger("[parent] grabs at [parent.p_their()] chest!"), ignored_mobs = parent)
					parent.set_heartattack(TRUE)
					heart_attack_counter = -2
				else
					COOLDOWN_START(src, time_since_last_heart_attack_counter, 6 SECONDS)
					parent.losebreath += 1
					heart_attack_counter += 1
					switch(heart_attack_counter)
						if(-INFINITY to 0)
							pass()
						if(1)
							to_chat(parent, span_userdanger("You feel your heart beat irregularly."))
						if(2)
							to_chat(parent, span_userdanger("You feel your heart skip a beat."))
						else
							to_chat(parent, span_userdanger("You feel your body shutting down!"))
		else
			heart_attack_counter = 0

		// This is where "soft crit" is now
		if(shock_buildup >= 270)
			if(!HAS_TRAIT_FROM(parent, TRAIT_LABOURED_BREATHING, PAINSHOCK))
				ADD_TRAIT(parent, TRAIT_LABOURED_BREATHING, PAINSHOCK)
				set_pain_modifier(PAINSHOCK, 1.2)
				parent.apply_status_effect(/datum/status_effect/low_blood_pressure)
				parent.add_traits(list(TRAIT_LABOURED_BREATHING), PAINSHOCK)

		else
			if(HAS_TRAIT_FROM(parent, TRAIT_LABOURED_BREATHING, PAINSHOCK))
				unset_pain_modifier(PAINSHOCK)
				parent.remove_status_effect(/datum/status_effect/low_blood_pressure)
				parent.remove_traits(list(TRAIT_LABOURED_BREATHING), PAINSHOCK)

		// This is "pain crit", it's where stamcrit has moved and is also applied by extreme shock
		if(curr_pain >= PAIN_LIMB_MAX * 3 || shock_buildup >= 450)
			parent.adjust_jitter_up_to(5 SECONDS * pain_modifier, 60 SECONDS)
			if(!HAS_TRAIT_FROM(parent, TRAIT_LABOURED_BREATHING, PAINCRIT))
				var/is_standing = parent.body_position == STANDING_UP
				parent.add_traits(list(TRAIT_LABOURED_BREATHING, TRAIT_INCAPACITATED, TRAIT_IMMOBILIZED, TRAIT_FLOORED, TRAIT_HANDS_BLOCKED), PAINCRIT)
				if(is_standing && parent.body_position != STANDING_UP)
					parent.visible_message(
						span_warning("[parent] collapses!"),
						span_userdanger("You collapse, unable to stand!"),

					)
				else
					parent.visible_message(
						span_warning("[parent] slumps against the ground!"),
						span_userdanger("You go limp, unable to get up!"),

					)

		else if(HAS_TRAIT_FROM(parent, TRAIT_LABOURED_BREATHING, PAINCRIT))
			parent.Paralyze(2 SECONDS)
			parent.remove_traits(list(TRAIT_LABOURED_BREATHING, TRAIT_INCAPACITATED, TRAIT_IMMOBILIZED, TRAIT_FLOORED, TRAIT_HANDS_BLOCKED), PAINCRIT)

	// Finally, handle pain decay over time
	if(parent.on_fire || parent.stat == DEAD)
		return

	// Decay every 3 ticks / 6 seconds, or 1 ticks / 2 seconds if "sleeping"
	var/every_x_ticks = HAS_TRAIT(parent, TRAIT_KNOCKEDOUT) ? 1 : 3

	natural_decay_counter++
	if(natural_decay_counter % every_x_ticks != 0)
		return

	natural_decay_counter = 0
	if(COOLDOWN_FINISHED(src, time_since_last_pain_loss) && parent.stat == CONSCIOUS)
		// 0.16 per 10 seconds, ~0.1 per minute, 10 minutes for ~1 decay
		natural_pain_decay = max(natural_pain_decay - 0.12, -4)
	else
		natural_pain_decay = base_pain_decay

	// modify our pain decay by our pain modifier (ex. 0.5 pain modifier = 2x natural pain decay, capped at ~3x)
	var/pain_modified_decay = round(natural_pain_decay * (1 / max(pain_modifier, 0.33)), 0.01)
	adjust_bodypart_pain(BODY_ZONES_ALL, pain_modified_decay)

/**
 * Whenever we buckle to something or lie down, get a pain bodifier.
 */
/datum/pain/proc/check_lying_pain_modifier(datum/source, new_buckled)
	SIGNAL_HANDLER

	var/buckled_lying_modifier = 1
	if(parent.body_position == LYING_DOWN)
		buckled_lying_modifier -= 0.1

	if(new_buckled)
		buckled_lying_modifier -= 0.1

	if(buckled_lying_modifier < 1)
		set_pain_modifier(PAIN_MOD_LYING, buckled_lying_modifier)
	else
		unset_pain_modifier(PAIN_MOD_LYING)

/// Affect accuracy of fired guns while in pain.
/datum/pain/proc/on_mob_fired_gun(mob/living/carbon/human/user, obj/item/gun/gun_fired, target, params, zone_override, list/bonus_spread_values)
	SIGNAL_HANDLER
	var/obj/item/bodypart/shooting_with = user.get_active_hand()
	var/obj/item/bodypart/chest = user.get_bodypart(BODY_ZONE_CHEST)
	var/obj/item/bodypart/head = user.get_bodypart(BODY_ZONE_HEAD)

	var/penalty = 0
	// Basically averaging the pain of the shooting hand, chest, and head, with the hand being weighted more
	penalty += shooting_with?.get_modified_pain()
	penalty += chest?.get_modified_pain() * 0.5
	penalty += head?.get_modified_pain() * 0.5
	penalty /= 3
	// Then actually making it into the final value
	penalty = floor(penalty / 5)
	// Applying min and max
	/*
	bonus_spread_values[MIN_BONUS_SPREAD_INDEX] += penalty
	bonus_spread_values[MAX_BONUS_SPREAD_INDEX] += penalty * 3
	*/

/// Apply or remove pain various modifiers from pain (mood, action speed, movement speed) based on the [average_pain].
/datum/pain/proc/refresh_pain_attributes(...)
	SIGNAL_HANDLER

	var/avg_pain = get_average_pain()

	// Pain is halved if you can't feel pain (but ignore pain modifier for now)
	if(avg_pain && parent.stat != DEAD && !parent.can_feel_pain(TRUE))
		avg_pain *= 0.5

	// Pain is set to 0 fully if you can't feel pain OR pain modifier <= 0.5 (numbness threshold)
	if(avg_pain && (parent.stat == DEAD || !parent.can_feel_pain(FALSE)))
		avg_pain = 0

	switch(avg_pain)
		if(-INFINITY to 20)
			parent.mob_surgery_speed_mod = initial(parent.mob_surgery_speed_mod)
			parent.outgoing_damage_mod = initial(parent.outgoing_damage_mod)
			parent.remove_movespeed_modifier(MOVESPEED_ID_PAIN)
			parent.remove_actionspeed_modifier(ACTIONSPEED_ID_PAIN)
			parent.clear_mood_event(PAIN)
		if(20 to 40)
			parent.mob_surgery_speed_mod = 0.9
			parent.outgoing_damage_mod = 0.9
			parent.add_movespeed_modifier(/datum/movespeed_modifier/pain/light)
			parent.add_actionspeed_modifier(/datum/actionspeed_modifier/pain/light)
			parent.add_mood_event(PAIN, /datum/mood_event/light_pain)
		if(40 to 60)
			parent.mob_surgery_speed_mod = 0.75
			parent.outgoing_damage_mod = 0.75
			parent.add_movespeed_modifier(/datum/movespeed_modifier/pain/medium)
			parent.add_actionspeed_modifier(/datum/actionspeed_modifier/pain/medium)
			parent.add_mood_event(PAIN, /datum/mood_event/med_pain)
		if(60 to 80)
			parent.mob_surgery_speed_mod = 0.6
			parent.outgoing_damage_mod = 0.6
			parent.add_movespeed_modifier(/datum/movespeed_modifier/pain/heavy)
			parent.add_actionspeed_modifier(/datum/actionspeed_modifier/pain/heavy)
			parent.add_mood_event(PAIN, /datum/mood_event/heavy_pain)
		if(80 to INFINITY)
			parent.mob_surgery_speed_mod = 0.5
			parent.outgoing_damage_mod = 0.5
			parent.add_movespeed_modifier(/datum/movespeed_modifier/pain/crippling)
			parent.add_actionspeed_modifier(/datum/actionspeed_modifier/pain/crippling)
			parent.add_mood_event(PAIN, /datum/mood_event/crippling_pain)

/**
 * Run a pain related emote, if a few checks are successful.
 *
 * emote - string, what emote we're running
 * cooldown - what cooldown to set our emote cooldown to
 *
 * returns TRUE if successful.
 */
/datum/pain/proc/do_pain_emote(emote = pick(PAIN_EMOTES), cooldown = 3 SECONDS)
	ASSERT(istext(emote))
	if(!parent.can_feel_pain())
		return FALSE
	if(cooldown && !COOLDOWN_FINISHED(src, time_since_last_pain_message))
		return FALSE
	if(parent.stat >= UNCONSCIOUS || parent.incapacitated(IGNORE_RESTRAINTS|IGNORE_GRAB))
		return FALSE

	INVOKE_ASYNC(parent, TYPE_PROC_REF(/mob, emote), emote)
	COOLDOWN_START(src, time_since_last_pain_message, cooldown)
	return TRUE

/**
 * Run a pain related message, if a few checks are successful.
 *
 * message - string, what message we're sending
 * painless_message - optional string, what message we're sending if the mob doesn't "feel" pain
 * cooldown - what cooldown to set our message cooldown to
 *
 * returns TRUE if successful.
 * Returns FALSE if we failed to send a message, even if painless_message was provided and sent.
 */
/datum/pain/proc/do_pain_message(message, painless_message, cooldown = 0 SECONDS)
	ASSERT(istext(message))

	if(parent.client?.prefs)
		if(parent.client.prefs.read_preference(/datum/preference/toggle/pain_messages))
			return FALSE

	if(!parent.can_feel_pain())
		if(painless_message)
			to_chat(parent, painless_message)
		return FALSE
	if(parent.stat >= UNCONSCIOUS)
		return FALSE
	if(cooldown && !COOLDOWN_FINISHED(src, time_since_last_pain_message))
		return FALSE

	to_chat(parent, message)
	COOLDOWN_START(src, time_since_last_pain_message, cooldown)
	return TRUE

/**
 * Get the average pain of all bodyparts as a percent of the total pain.
 */
/datum/pain/proc/get_average_pain()
	var/max_total_pain = 0
	var/total_pain = 0
	for(var/zone in body_zones)
		var/obj/item/bodypart/adjusted_bodypart = body_zones[zone]
		if(QDELETED(adjusted_bodypart))
			continue
		total_pain += adjusted_bodypart.pain
		max_total_pain += adjusted_bodypart.soft_max_pain

	return round(100 * total_pain / max_total_pain, 0.01)

/// Get the total pain of all bodyparts.
/datum/pain/proc/get_total_pain()
	var/total_pain = 0
	for(var/zone in body_zones)
		var/obj/item/bodypart/adjusted_bodypart = body_zones[zone]
		if(QDELETED(adjusted_bodypart))
			continue
		total_pain += adjusted_bodypart.pain

	return total_pain

/// Adds a custom stammer to people under the effects of pain.
/datum/pain/proc/handle_message(datum/source, list/message_args)
	SIGNAL_HANDLER

	var/phrase = html_decode(message_args[TREAT_MESSAGE_MESSAGE])
	if(!length(phrase))
		return

	var/num_repeats = get_average_pain() * pain_modifier
	if(HAS_TRAIT(parent, TRAIT_NO_PAIN_EFFECTS) && shock_buildup < 90)
		num_repeats *= 0.5

	num_repeats = floor(num_repeats / 20)
	if(num_repeats <= 1)
		return
	var/static/regex/no_stammer = regex(@@[ ""''()[\]{}.!?,:;_`~-]@)
	var/static/regex/half_stammer = regex(@@[aeiouAEIOU]@)
	var/final_phrase = ""
	var/original_char = ""
	for(var/i = 1, i <= length(phrase), i += length(original_char))
		original_char = phrase[i]
		if(no_stammer.Find(original_char))
			final_phrase += original_char
			continue
		if(half_stammer.Find(original_char))
			if(num_repeats <= 2)
				final_phrase += original_char
				continue
			final_phrase += repeat_string(ceil(num_repeats / 2), original_char)
			continue
		final_phrase += repeat_string(num_repeats, original_char)

	message_args[TREAT_MESSAGE_MESSAGE] = sanitize(final_phrase)

/datum/pain/proc/on_fully_healed(datum/source, heal_flags)
	SIGNAL_HANDLER
	// Ideally pain would have its own heal flag but we live in a society
	if(heal_flags & (HEAL_ADMIN|HEAL_WOUNDS|HEAL_STATUS))
		remove_all_pain()

/**
 * Remove all pain, pain paralysis, side effects, etc. from our mob after we're fully healed by something (like an adminheal)
 */
/datum/pain/proc/remove_all_pain()
	SIGNAL_HANDLER

	for(var/zone in body_zones)
		var/obj/item/bodypart/healed_bodypart = body_zones[zone]
		if(QDELETED(healed_bodypart))
			continue
		adjust_bodypart_min_pain(zone, -INFINITY)
		adjust_bodypart_pain(zone, -INFINITY)
		// Shouldn't be necessary but you never know!
		REMOVE_TRAIT(healed_bodypart, TRAIT_PARALYSIS, PAIN_LIMB_PARALYSIS)

	clear_pain_attributes()
	shock_buildup = 0
	natural_pain_decay = base_pain_decay

/**
 * Determines if we should be processing or not.
 */
/datum/pain/proc/on_parent_statchance(mob/source)
	SIGNAL_HANDLER

	if(source.stat == DEAD)
		if(datum_flags & DF_ISPROCESSING)
			STOP_PROCESSING(SSpain, src)
	else
		START_PROCESSING(SSpain, src)

/// When we are revived, reduced shock
/datum/pain/proc/revived(...)
	SIGNAL_HANDLER

	shock_buildup /= 3

/// Used to get the effect of pain on the parent's heart rate.
/datum/pain/proc/get_heartrate_modifier()
	var/base_amount = 0
	switch(get_average_pain()) // pain raises it a bit
		if(25 to 50)
			base_amount += 5
		if(50 to 75)
			base_amount += 10
		if(75 to INFINITY)
			base_amount += 15

	switch(pain_modifier) // numbness lowers it a bit
		if(0.25 to 0.5)
			base_amount -= 15
		if(0.5 to 0.75)
			base_amount -= 10
		if(0.75 to 1)
			base_amount -= 5

	return base_amount

/**
 * Signal proc for [COMSIG_LIVING_HEALTHSCAN]
 * Reports how much pain [parent] is sustaining to [user].
 *
 * Note, this report is relatively vague intentionally -
 * rather than sending a detailed report of which bodyparts are in pain and how much,
 * the patient is encouraged to elaborate on which bodyparts hurt the most, and how much they hurt.
 * (To encourage a bit more interaction between the doctors.)
 */
/datum/pain/proc/on_analyzed(datum/source, list/render_list, advanced, mob/user, mode, tochat)
	SIGNAL_HANDLER

	if(parent.stat == DEAD)
		return

	var/in_shock = HAS_TRAIT_FROM(parent, TRAIT_LABOURED_BREATHING, PAINSHOCK)

	var/amount = ""
	var/tip = ""
	var/amount_text = ""
	var/shock_text = ""

	switch(get_average_pain())
		if(5 to 15)
			amount = "minor"
			tip += "Pain should subside in time."
		if(15 to 30)
			amount = "moderate"
			tip += "Pain should subside in time and can be quickened with rest or painkilling medication."
		if(30 to 50)
			amount = "major"
			tip += "Treat wounds and abate pain with rest, cryogenics, and painkilling medication."
		if(50 to 80)
			amount = "severe"
			if(!in_shock)
				tip += span_bold("Alert: Potential of neurogenic shock. ")
			tip += "Treat wounds and abate pain with long rest, cryogenics, and moderate painkilling medication."
		if(80 to INFINITY)
			amount = "extreme"
			if(!in_shock)
				tip += span_bold("Alert: High potential of neurogenic shock. ")
			tip += "Treat wounds and abate pain with long rest, cryogenics, and heavy painkilling medication."

	if(!amount)
		return

	amount_text = span_danger("Subject is experiencing [amount] pain.")
	if(tochat && tip)
		amount_text = span_tooltip(tip, amount_text)

	if(in_shock)
		shock_text = span_bold("Neurogenic shock has begun and should be treated urgently.")
	if(shock_text && tochat)
		shock_text = span_tooltip("Provide immediate pain relief, epinephrine, and moderate body temperature. \
			[in_shock ? "Monitor closely for worsening condition or cardiac arrest. " : ""]Cryogenics may also aid in recovery.", shock_text)

	render_list += "<span class='alert ml-1'>"
	if(shock_text)
		render_list += "[shock_text] / "
	render_list += amount_text
	render_list += "</span>\n"

#ifdef TESTING
	debug_print_pain()
#endif

// ------ Pain debugging stuff. ------
/datum/pain/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("debug_pain", "Debug Pain")
	VV_DROPDOWN_OPTION("set_limb_pain", "Adjust Limb Pain")
	VV_DROPDOWN_OPTION("refresh_mod", "Refresh Pain Mod")

/datum/pain/vv_do_topic(list/href_list)
	. = ..()
	if(href_list["debug_pain"])
		debug_print_pain()
	if(href_list["set_limb_pain"])
		admin_adjust_bodypart_pain()
	if(href_list["refresh_mod"])
		update_pain_modifier()

/datum/pain/proc/debug_print_pain()

	var/list/final_print = list()
	final_print += "<div class='examine_block'><span class='info'>DEBUG PRINTOUT PAIN: [REF(src)]"
	final_print += "[parent] has an average pain of [get_average_pain()]."
	final_print += "[parent] has a pain modifier of [pain_modifier]."
	final_print += " - - - - "
	final_print += "[parent] bodypart printout: (min / current / soft max)"
	for(var/part in body_zones)
		var/obj/item/bodypart/checked_bodypart = body_zones[part]
		if(!QDELETED(checked_bodypart))
			final_print += "[checked_bodypart.name]: [checked_bodypart.min_pain] / [checked_bodypart.pain] / [checked_bodypart.soft_max_pain]"

	final_print += " - - - - "
	final_print += "[parent] pain modifier printout:"
	for(var/mod in pain_mods)
		final_print += "[mod]: [pain_mods[mod]]"

	final_print += "</span></div>"
	to_chat(usr, final_print.Join("\n"))

/datum/pain/proc/admin_adjust_bodypart_pain()
	var/zone = input(usr, "Which bodypart") as null|anything in BODY_ZONES_ALL + "All"
	var/amount = input(usr, "How much?") as null|num

	if(isnull(amount) || isnull(zone))
		return
	if(zone == "All")
		zone = BODY_ZONES_ALL

	amount = clamp(amount, -200, 200)
	adjust_bodypart_pain(zone, amount)


/**
 * Clears all pain related attributes
 */
/datum/pain/proc/clear_pain_attributes()
	parent.mob_surgery_speed_mod = initial(parent.mob_surgery_speed_mod)
	parent.remove_movespeed_modifier(MOVESPEED_ID_PAIN)
	parent.remove_actionspeed_modifier(ACTIONSPEED_ID_PAIN)
	parent.clear_mood_event("pain")
