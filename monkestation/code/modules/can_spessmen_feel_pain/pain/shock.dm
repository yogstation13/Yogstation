// -- Shock from too much pain. --
/datum/disease/advanced/premade/shock
	form = "Condition"
	name = "Shock"
	spread_text = "Neurogenic" // Only model pain shock
	category = DISEASE_SHOCK
	max_stages = 3
	stage_prob = 1
	cure_text = "Keep the patient still and lying down, maintain a high body temperature, stop blood loss, \
		and provide pain relievers while monitoring closely. Epinephrine and Saline-Glucose can also help."
	agent = "Pain"
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "Occurs when a subject enters a state of shock due to high pain, blood loss, heart difficulties, and other injuries. \
		If left untreated, the subject may experience cardiac arrest."
	severity = DISEASE_SEVERITY_DANGEROUS
	disease_flags = NONE
	spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
	visibility_flags = HIDDEN_PANDEMIC
	bypasses_immunity = TRUE
	/// How many conditions do we require to get cured?
	var/conditions_required_to_cure = 4
	/// How many conditions do we need to not get a heart attack?
	var/conditions_required_to_maintain = 3

/datum/disease/advanced/premade/shock/after_add()
	affected_mob.apply_status_effect(/datum/status_effect/low_blood_pressure)
	affected_mob.set_pain_mod(type, 1.2)
	antigen = null

/**
 * Checks which cure conditions we fulfill.
 *
 * returns the total number of conditions we fulfill.
 */
/datum/disease/advanced/premade/shock/proc/check_cure_conditions()
	if(!ishuman(affected_mob))
		return TRUE
	var/mob/living/carbon/human = affected_mob
	if(human.undergoing_cardiac_arrest())
		return FALSE
	if(affected_mob.stat == DEAD)
		return FALSE

	// We require [conditions_required_to_cure] of these to be fulfilled to be cured
	var/conditions_fulfilled = 0

	// Good: Body temperature is stable (not freezing, we don't care about heat)
	if(affected_mob.bodytemperature > affected_mob.bodytemp_cold_damage_limit)
		conditions_fulfilled += 1
	// Good: Sleeping (or unconscious I guess)
	if(affected_mob.IsSleeping() || affected_mob.IsUnconscious())
		conditions_fulfilled += 1
	// Good: Having this trait (from salgu or epinephrine)
	if(HAS_TRAIT(affected_mob, TRAIT_ABATES_SHOCK))
		conditions_fulfilled += 1
	// Good: Having lower pain
	switch(affected_mob.pain_controller.get_average_pain())
		if(-INFINITY to 10)
			// Almost guarantees you fulfill enough conditions if you get this low, assuming you have no major detractors
			// Why? It might confuse some people if the person's like, not experiencing any pain at all
			// but for some reason is still in shock, because they haven't done one of the other conditions arbitrarily
			conditions_fulfilled += (conditions_required_to_cure + 1)
		if(10 to 30)
			conditions_fulfilled += 3
		if(30 to 40)
			conditions_fulfilled += 2
		if(40 to 50)
			conditions_fulfilled += 1

	// Good: Painkillers (while conscious / in soft crit)
	if(affected_mob.stat <= SOFT_CRIT && !affected_mob.can_feel_pain())
		conditions_fulfilled += 1

	// Bad: Bleeding
	if(human.is_bleeding())
		conditions_fulfilled -= 1
	// Very bad: Wounds
	conditions_fulfilled -= min(LAZYLEN(human.all_wounds), 4)
	// Somewhat bad: Standing up
	if(affected_mob.body_position == STANDING_UP)
		conditions_fulfilled -= 2
	// Bad: In deepcrit (dying)
	if(affected_mob.stat > SOFT_CRIT)
		conditions_fulfilled -= 1

	return conditions_fulfilled

/datum/disease/advanced/premade/shock/cure(add_resistance, mob/living/carbon/target)
	affected_mob.remove_status_effect(/datum/status_effect/low_blood_pressure)
	affected_mob.unset_pain_mod(type)
	return ..()

/datum/disease/advanced/premade/shock/activate(seconds_per_tick, times_fired)
	. = ..()
	if(!ishuman(affected_mob))
		return

	if(check_cure_conditions() >= conditions_required_to_cure)
		cure()
		return
	var/mob/living/carbon/human = affected_mob
	if(!.)
		return

	if(isnull(affected_mob.pain_controller))
		cure()
		return FALSE

	if(affected_mob.stat == DEAD)
		cure()
		return FALSE

	var/cure_level = check_cure_conditions()
	testing("[affected_mob] undergoing shock: [cure_level] cure conditions achieved.")

	// Having a few cure conditions present ([conditions_required_to_maintain]) will keep us below stage 3
	if(stage > 2 && cure_level >= conditions_required_to_maintain)
		update_stage(2)

	// If we have enough conditions present to cure us, roll for a cure
	if(stage <= 2 && has_cure(cure_level) && SPT_PROB(cure_level, seconds_per_tick))
		to_chat(affected_mob, span_bold(span_green("Your body feels awake and active again!")))
		cure()
		return FALSE

	switch(stage)
		// compensated (or nonprogressive) - still able to sustain themselves
		// - agitation, anxiety
		// - nausea or vomiting
		// - chills
		if(1)
			cure_text = "Subject is in stage one of shock. \
				Provide immediate pain relief and stop blood loss to prevent worsening condition. \
				Keep the patient still and lying down, and be sure to moderate their temprature. \
				Supply epinephrine and saline-glucose if condition worsens."
			if(SPT_PROB(0.5, seconds_per_tick))
				to_chat(affected_mob, span_danger("Your chest feels uncomfortable."))
				affected_mob.pain_emote(pick("mumble", "grumble"))
				affected_mob.flash_pain_overlay(1)
			if(SPT_PROB(1, seconds_per_tick))
				to_chat(affected_mob, span_danger("You feel nauseous."))
				if(prob(50))
					affected_mob.vomit(35)
			if(SPT_PROB(2, seconds_per_tick))
				to_chat(affected_mob, span_danger("You feel anxious."))
				affected_mob.adjust_jitter(rand(12 SECONDS, 16 SECONDS))
			if(SPT_PROB(6, seconds_per_tick))
				to_chat(affected_mob, span_danger("You feel cold."))
				affected_mob.pain_emote("shiver", 3 SECONDS)
			affected_mob.adjust_bodytemperature(-5 * seconds_per_tick, min_temp = affected_mob.bodytemp_cold_damage_limit + 5) // Not lethal

		// decompensated (or progressive) - unable to maintain themselves
		// - mental issues
		// - difficulty breathing / high heart rate
		// - decrease in body temperature
		if(2)
			cure_text = "Subject is in stage one of shock. \
				Provide immediate pain relief and stop blood loss to prevent cardiac arrest. \
				Keep the patient still and lying down, and be sure to moderate their temprature. \
				Supply epinephrine and saline-glucose if condition worsens."

			if(SPT_PROB(10, seconds_per_tick))
				affected_mob.adjust_stutter_up_to(10 SECONDS, 120 SECONDS)
			if(SPT_PROB(1, seconds_per_tick))
				to_chat(affected_mob, span_danger("Your chest feels wrong!"))
				affected_mob.pain_emote(pick("mumble", "grumble"))
				affected_mob.flash_pain_overlay(2)
			if(SPT_PROB(2, seconds_per_tick))
				to_chat(affected_mob, span_danger("You can't focus on anything!"))
				affected_mob.adjust_confusion(rand(4 SECONDS, 8 SECONDS))
			if(SPT_PROB(2, seconds_per_tick))
				to_chat(affected_mob, span_danger("You're having difficulties breathing!"))
				affected_mob.losebreath = clamp(affected_mob.losebreath + 4, 0, 12)
			if(SPT_PROB(2, seconds_per_tick))
				to_chat(affected_mob, span_danger("You skip a breath!"))
				affected_mob.pain_emote("gasp", 3 SECONDS)
				affected_mob.apply_damage(rand(5, 15), OXY)
			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.emote("faint")
			if(SPT_PROB(8, seconds_per_tick))
				to_chat(affected_mob, span_danger("You feel freezing!"))
				affected_mob.pain_emote("shiver", 3 SECONDS)
			affected_mob.adjust_bodytemperature(-10 * seconds_per_tick, min_temp = affected_mob.bodytemp_cold_damage_limit - 5) // uh oh

		// irreversible - point of no return, system failure
		// cardiac arrest
		if(3)
			cure_text = "Subject is in stage three of shock. Cardiac arrest is imminent - urgent action is needed. \
				Prepare a defibrillator on standby and moderate their body temperature."
			if(SPT_PROB(10, seconds_per_tick))
				affected_mob.adjust_stutter_up_to(10 SECONDS, 120 SECONDS)
			if(SPT_PROB(8, seconds_per_tick))
				affected_mob.adjust_slurring_up_to(10 SECONDS, 36 SECONDS)
			if(SPT_PROB(2, seconds_per_tick))
				affected_mob.emote("faint")
			if(SPT_PROB(33, seconds_per_tick))
				if(human.can_heartattack())
					to_chat(affected_mob, span_userdanger("Your heart stops!"))
					affected_mob.visible_message(span_danger("[affected_mob] grabs at their chest and collapses!"), ignored_mobs = affected_mob)
					human.set_heartattack(TRUE)
					cure()
					return FALSE
				else
					affected_mob.losebreath += 10
			else if(SPT_PROB(10, seconds_per_tick))
				to_chat(affected_mob, span_userdanger(pick("You feel your heart skip a beat...", "You feel your body shutting down...", "You feel your heart beat irregularly...")))
			affected_mob.adjust_bodytemperature(-10 * seconds_per_tick, min_temp = affected_mob.bodytemp_cold_damage_limit - 20) // welp
