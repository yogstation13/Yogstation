// Bodypart extensions to handle pain
// Yes pain is handled on a per-bodypart basis
/obj/item/bodypart
	/// The amount of pain this limb is experiencing (A bit for default)
	var/pain = 15
	/// The min amount of pain this limb can experience
	var/min_pain = 0
	/// The soft cap of pain that this limb can experience
	/// This is not a hard cap, pain can go above this, but beyond this effects will not worsen
	var/soft_max_pain = PAIN_LIMB_MAX
	/// Modifier applied to pain that this part receives
	var/bodypart_pain_modifier = 1
	/// The last type of pain we received. Determines what type of pain we're recieving.
	var/last_received_pain_type = BRUTE

// Adds pain to check-self.
/obj/item/bodypart/check_for_injuries(mob/living/carbon/human/examiner, list/check_list)
	. = ..()
	if(owner != examiner || !owner.can_feel_pain()) // haha you thought
		return

	switch((get_modified_pain() / soft_max_pain) * 100)
		if(10 to 40)
			check_list += "\t [span_danger("Your [name] is experiencing mild pain \
				and [last_received_pain_type == BURN ? "burns" : "hurts"] to the touch.")]"

		if(40 to 70)
			check_list += "\t [span_warning("Your [name] is experiencing moderate pain \
				and [last_received_pain_type == BURN ? "burns" : "hurts"] to the touch!")]"

		if(70 to INFINITY)
			check_list += "\t [span_boldwarning("Your [name] is experiencing severe pain \
				and [last_received_pain_type == BURN ? "burns" : "hurts"] to the touch!")]"

/**
 * Gets our bodypart's effective pain (pain * pain modifiers).
 *
 * Returns our effective pain.
 */
/obj/item/bodypart/proc/get_modified_pain()
	if(owner?.pain_controller)
		return pain * bodypart_pain_modifier * owner.pain_controller.pain_modifier
	else
		return pain * bodypart_pain_modifier

/**
 * Effects on this bodypart has when pain is gained.
 *
 * amount - amount of pain gained
 */
/obj/item/bodypart/proc/on_gain_pain_effects(amount)
	if(!owner)
		return FALSE

	if(get_modified_pain() >= 65 && can_be_disabled && !HAS_TRAIT_FROM(src, TRAIT_PARALYSIS, PAIN_LIMB_PARALYSIS))
		owner.pain_message(
			span_userdanger("Your [plaintext_zone] goes numb from the pain!"),
			span_danger("You can't move your [plaintext_zone]!")
		)
		ADD_TRAIT(src, TRAIT_PARALYSIS, PAIN_LIMB_PARALYSIS)
		update_disabled()

	return TRUE

/**
 * Effects on this bodypart has when pain is lost and some time passes without any pain gain.
 *
 * amount - amount of pain lost
 */
/obj/item/bodypart/proc/on_lose_pain_effects(amount)
	if(!owner)
		return FALSE

	if(get_modified_pain() < 65 && HAS_TRAIT_FROM(src, TRAIT_PARALYSIS, PAIN_LIMB_PARALYSIS))
		owner.pain_message(
			span_green("You can feel your [plaintext_zone] again!"),
			span_green("You can move your [plaintext_zone] again!")
		)
		REMOVE_TRAIT(src, TRAIT_PARALYSIS, PAIN_LIMB_PARALYSIS)
		update_disabled()

	return TRUE

/**
 * Feedback messages from this limb when it is sustaining pain.
 *
 * healing_pain - if TRUE, the bodypart has gone some time without recieving pain, and is healing.
 */
/obj/item/bodypart/proc/pain_feedback(seconds_per_tick, healing_pain)
	var/list/feedback_phrases = list()
	var/static/list/healing_phrases = list(
		"but is improving",
		"but is starting to dull",
		"but the stinging is stopping",
		"but feels faint",
	)

	switch(pain)
		if(10 to 25)
			owner.flash_pain_overlay(1)
			feedback_phrases += list("aches", "feels sore", "stings slightly", "tingles", "twinges")
		if(25 to 50)
			owner.flash_pain_overlay(1)
			feedback_phrases += list("hurts", "feels sore", "stings", "throbs", "pangs", "cramps", "feels wrong", "feels loose")
			if(last_received_pain_type == BURN)
				feedback_phrases += list("stings to the touch", "burns")
		if(50 to 65)
			if(SPT_PROB(4, seconds_per_tick))
				owner.pain_emote()
			owner.flash_pain_overlay(2)
			feedback_phrases += list("really hurts", "is losing feeling", "throbs painfully", "is in agony", "anguishes", "feels broken", "feels terrible")
			if(last_received_pain_type == BURN)
				feedback_phrases += list("burns to the touch", "burns", "singes")
		if(65 to INFINITY)
			if(SPT_PROB(8, seconds_per_tick))
				var/bonus_emote = pick(PAIN_EMOTES)
				owner.pain_emote(pick("groan", "scream", bonus_emote))
			owner.flash_pain_overlay(2, 2 SECONDS)
			feedback_phrases += list("is numb from the pain")

	if(feedback_phrases.len)
		owner.pain_message(span_danger("Your [plaintext_zone] [pick(feedback_phrases)][healing_pain ? ", [pick(healing_phrases)]." : "!"]"))
	return TRUE

// --- Chest ---
/obj/item/bodypart/chest
	soft_max_pain = PAIN_CHEST_MAX

/obj/item/bodypart/chest/robot
	// Augmented limbs start with maximum pain as a trade-off for becoming almost immune to it
	// The idea being that the roboticist installing augments should take care of their patient
	// following the period after they're augmented - anesthetic, rest, painkillers (from medbay)
	pain = PAIN_CHEST_MAX
	// As a trade off for starting with maximum pain,
	// augmented limbs lose pain very rapidly and take very little in the way of pain.
	// Why not a 0 modifier? I feel like it'll be unfun if they can just completely ignore the system.
	bodypart_pain_modifier = 0.2

/obj/item/bodypart/chest/pain_feedback(seconds_per_tick, healing_pain)
	var/list/feedback_phrases = list()
	var/list/side_feedback = list()
	var/static/list/healing_phrases = list(
		"but is improving",
		"but is starting to dull",
		"but the stinging is stopping",
		"but feels faint",
		"but is settling",
		"but it subsides",
	)

	switch(pain)
		if(10 to 40)
			owner.flash_pain_overlay(1)
			feedback_phrases += list("aches", "feels sore", "stings slightly", "tingles", "twinges")
		if(40 to 75)
			owner.flash_pain_overlay(1, 2 SECONDS)
			feedback_phrases += list("hurts", "feels sore", "stings", "throbs", "pangs", "cramps", "feels tight")
			side_feedback += list("Your side hurts", "Your side pangs", "Your ribs hurt", "Your ribs pang", "Your neck stiffs")
		if(75 to 110)
			if(SPT_PROB(8, seconds_per_tick))
				owner.pain_emote()
			owner.flash_pain_overlay(2, 2 SECONDS)
			feedback_phrases += list("really hurts", "is losing feeling", "throbs painfully", "stings to the touch", "is in agony", "anguishes", "feels broken", "feels tight")
			side_feedback += list("You feel a sharp pain in your side", "Your ribs feel broken")
		if(110 to INFINITY)
			if(SPT_PROB(12, seconds_per_tick))
				var/bonus_emote = pick(PAIN_EMOTES)
				owner.pain_emote(pick("groan", "scream", bonus_emote))
			owner.flash_pain_overlay(2, 3 SECONDS)
			feedback_phrases += list("hurts madly", "is in agony", "is anguishing", "burns to the touch", "feels terrible", "feels constricted")
			side_feedback += list("You feel your ribs jostle in your [plaintext_zone]")

	if(side_feedback.len && last_received_pain_type == BRUTE && SPT_PROB(50, seconds_per_tick))
		owner.pain_message(span_danger("[pick(side_feedback)][healing_pain ? ", [pick(healing_phrases)]." : "!"]"))
	else if(feedback_phrases.len)
		owner.pain_message(span_danger("Your [plaintext_zone] [pick(feedback_phrases)][healing_pain ? ", [pick(healing_phrases)]." : "!"]"))

	return TRUE

// --- Head ---
/obj/item/bodypart/head
	soft_max_pain = PAIN_HEAD_MAX

/obj/item/bodypart/head/robot
	pain = PAIN_HEAD_MAX
	bodypart_pain_modifier = 0.2

/obj/item/bodypart/head/on_gain_pain_effects(amount)
	. = ..()
	if(!.)
		return FALSE

	if(amount >= 10)
		// Large amounts of head pain causes minor brain damage
		owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, min(pain / 5, 10), 50)

	return TRUE

/obj/item/bodypart/head/pain_feedback(seconds_per_tick, healing_pain)
	var/list/feedback_phrases = list()
	var/list/side_feedback = list()
	var/static/list/healing_phrases = list(
		"but is improving",
		"but is starting to dull",
		"but the stinging is stopping",
		"but the tension is stopping",
		"but is settling",
		"but it subsides",
		"but the pressure fades",
	)

	switch(pain)
		if(10 to 30)
			owner.flash_pain_overlay(1)
			feedback_phrases += list("aches", "feels sore", "stings slightly", "tingles", "twinges")
			side_feedback += list("Your neck feels sore", "Your eyes feel tired")
		if(30 to 60)
			owner.flash_pain_overlay(1)
			feedback_phrases += list("hurts", "feels sore", "stings", "throbs", "pangs")
			side_feedback += list("Your neck aches badly", "Your eyes hurt", "You feel a migrane coming on", "You feel a splitting headache")
		if(60 to 90)
			owner.flash_pain_overlay(2)
			feedback_phrases += list("really hurts", "is losing feeling", "throbs painfully", "is in agony", "anguishes", "feels broken", "feels terrible")
			side_feedback += list("Your neck stiffs", "You feel pressure in your [plaintext_zone]", "The back of your eyes begin hurt", "You feel a terrible migrane")
		if(90 to INFINITY)
			var/bonus_emote = pick(PAIN_EMOTES)
			owner.pain_emote(pick("groan", bonus_emote))
			owner.flash_pain_overlay(2, 2 SECONDS)
			feedback_phrases += list("hurts madly", "is in agony", "is anguishing", "feels terrible", "is in agony", "feels tense")
			side_feedback += list("You feel a splitting migrane", "Pressure floods your [plaintext_zone]", "Your [plaintext_zone] feels as if it's being squeezed", "Your eyes hurt to keep open")

	if(side_feedback.len && last_received_pain_type == BRUTE && SPT_PROB(50, seconds_per_tick))
		owner.pain_message(span_danger("[pick(side_feedback)][healing_pain ? ", [pick(healing_phrases)]." : "!"]"))
	else if(feedback_phrases.len)
		owner.pain_message(span_danger("Your [plaintext_zone] [pick(feedback_phrases)][healing_pain ? ", [pick(healing_phrases)]." : "!"]"))

	return TRUE

// --- Legs ---
/obj/item/bodypart/leg/on_gain_pain_effects(amount)
	. = ..()
	if(!.)
		return

	if(get_modified_pain() < 40)
		return
	if(amount < 5) // only big bursts of pain will cause a limp
		return
	owner.apply_status_effect(/datum/status_effect/limp/pain, src)

// --- Right Leg ---
/obj/item/bodypart/leg/right/robot
	pain = PAIN_LIMB_MAX * 0.5
	bodypart_pain_modifier = 0.2

/obj/item/bodypart/leg/right/robot/surplus
	pain = 0
	bodypart_pain_modifier = 0.8

// --- Left Leg ---
/obj/item/bodypart/leg/left/robot
	pain = PAIN_LIMB_MAX * 0.5
	bodypart_pain_modifier = 0.2

/obj/item/bodypart/leg/left/robot/surplus
	pain = 0
	bodypart_pain_modifier = 0.8


// --- Right Arm ---
/obj/item/bodypart/arm/right/robot
	pain = PAIN_LIMB_MAX * 0.5
	bodypart_pain_modifier = 0.2

/obj/item/bodypart/arm/right/robot/surplus
	pain = 0
	bodypart_pain_modifier = 0.8

// --- Left Arm ---
/obj/item/bodypart/arm/right/robot
	pain = PAIN_LIMB_MAX * 0.5
	bodypart_pain_modifier = 0.2

/obj/item/bodypart/arm/left/robot/surplus
	pain = 0
	bodypart_pain_modifier = 0.8
