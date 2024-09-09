/datum/surgery_step
	/// Moodlet given if a surgery is done without anesthetics
	var/surgery_moodlet = /datum/mood_event/surgery
	/// Pain overlay flashed if a surgery is done without anesthetics
	var/pain_overlay_severity = 1
	/// How much pain this gives (given out in display_pain, so this might be given out twice)
	var/pain_amount = 0
	/// What type of pain this gives
	var/pain_type = BRUTE

// Regex for updating existing display pain calls:
// display_pain\((.+)\) -> display_pain($1, target_zone = target_zone) // NON-MODULE CHANGE
/datum/surgery_step/display_pain(mob/living/carbon/target, pain_message, mechanical_surgery = FALSE, target_zone)
	// Only feels pain if we feels pain
	if(pain_amount <= 0 || isnull(target_zone) || !target.can_feel_pain())
		return FALSE

	// No pain from mechanics but still show the message (usually)
	if(mechanical_surgery)
		if(prob(70))
			target.pain_message(span_userdanger(pain_message))
		return FALSE

	target.cause_pain(target_zone, pain_amount, pain_type)

	if(target.IsSleeping() || target.stat >= UNCONSCIOUS)
		if(target.has_status_effect(/datum/status_effect/grouped/anesthetic))
			target.add_mood_event("surgery", /datum/mood_event/anesthetic)
		return FALSE
	if(ispath(surgery_moodlet))
		target.add_mood_event("surgery", surgery_moodlet)
	if(isnum(pain_overlay_severity))
		target.flash_pain_overlay(pain_overlay_severity)
	// No message if the pain emote fails
	if(!target.pain_emote())
		return FALSE
	if(!target.pain_message(span_userdanger(pain_message)))
		return FALSE
	return TRUE

/datum/surgery_step/brainwash/sleeper_agent
	pain_amount = 36

/datum/surgery_step/sever_limb
	pain_amount = 16 // Losing a limb also applies pain to chest

/datum/surgery_step/repair_bone_hairline
	pain_amount = 16

/datum/surgery_step/reset_compound_fracture
	pain_amount = 24

/datum/surgery_step/fix_brain
	surgery_moodlet = /datum/mood_event/surgery/major
	pain_overlay_severity = 2
	pain_amount = 24

/datum/surgery_step/debride
	pain_amount = 12
	pain_type = BURN

/datum/surgery_step/handle_cavity
	pain_amount = 16

/datum/surgery_step/incise_heart
	surgery_moodlet = /datum/mood_event/surgery/major
	pain_overlay_severity = 2
	// It is extremely unlikely this surgery is done on alive people to feel (most) of this
	pain_amount = 60

/datum/surgery_step/coronary_bypass
	surgery_moodlet = /datum/mood_event/surgery/major
	pain_overlay_severity = 2
	pain_amount = 30

/datum/surgery_step/coronary_bypass/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	. = ..()
	// Reduces pain from surgery a bit on success
	target.cause_pain(target_zone, pain_amount * -0.5, pain_type)

/datum/surgery_step/coronary_bypass/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery)
	. = ..()
	// Double pain from surgery
	target.cause_pain(target_zone, pain_amount, pain_type)

/datum/surgery_step/fix_eyes
	pain_amount = 9

/datum/surgery_step/gastrectomy
	pain_amount = 20

/datum/surgery_step/gastrectomy/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	. = ..()
	// Reduces pain from surgery a bit on success
	target.cause_pain(target_zone, pain_amount * -1.25, pain_type)

/datum/surgery_step/gastrectomy/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery)
	. = ..()
	// Double pain from surgery
	target.cause_pain(target_zone, pain_amount, pain_type)

/datum/surgery_step/heal
	pain_amount = 9

/datum/surgery_step/hepatectomy
	surgery_moodlet = /datum/mood_event/surgery/major
	pain_overlay_severity = 2
	pain_amount = 20

/datum/surgery_step/hepatectomy/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	. = ..()
	// Reduces pain from surgery a bit on success
	target.cause_pain(target_zone, pain_amount * -1.25, pain_type)

/datum/surgery_step/hepatectomy/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery)
	. = ..()
	// Double pain from surgery
	target.cause_pain(target_zone, pain_amount, pain_type)

/datum/surgery_step/extract_implant
	pain_amount = 24

/datum/surgery_step/cut_fat
	pain_amount = 16

/datum/surgery_step/lobectomy
	surgery_moodlet = /datum/mood_event/surgery/major
	pain_overlay_severity = 2
	pain_amount = 20

/datum/surgery_step/incise
	pain_amount = 12

/datum/surgery_step/incise/nobleed
	pain_amount = 3

/datum/surgery_step/clamp_bleeders
	pain_amount = 3

/datum/surgery_step/retract_skin
	pain_amount = 12

/datum/surgery_step/close
	pain_amount = 12
	pain_type = BURN

/datum/surgery_step/saw
	surgery_moodlet = /datum/mood_event/surgery/major
	pain_overlay_severity = 2
	// no pain_amount here because it uses apply_damage, which causes pain

/datum/surgery_step/drill
	pain_amount = 24

/datum/surgery_step/reshape_face
	pain_amount = 16

/datum/surgery_step/repair_innards
	pain_amount = 16

/datum/surgery_step/stomach_pump
	pain_amount = 12

/datum/surgery_step/brainwash
	surgery_moodlet = /datum/mood_event/surgery/major
	pain_overlay_severity = 2
	pain_amount = 40

/datum/surgery_step/lobotomize
	surgery_moodlet = /datum/mood_event/surgery/major
	pain_overlay_severity = 2
	pain_amount = 40

/datum/surgery_step/bionecrosis
	surgery_moodlet = /datum/mood_event/surgery/major
	pain_overlay_severity = 2
	pain_amount = 40

/datum/surgery_step/pacify
	surgery_moodlet = /datum/mood_event/surgery/major
	pain_overlay_severity = 2
	pain_amount = 40

/datum/surgery_step/viral_bond
	pain_amount = 24
	pain_type = BURN

/datum/surgery_step/wing_reconstruction
	pain_amount = 9
	pain_type = BURN

/datum/surgery_step/fold_cortex
	surgery_moodlet = /datum/mood_event/surgery/major
	pain_overlay_severity = 2
	pain_amount = 40

/datum/surgery_step/imprint_cortex
	surgery_moodlet = /datum/mood_event/surgery/major
	pain_overlay_severity = 2
	pain_amount = 40

/datum/surgery_step/reshape_ligaments
	surgery_moodlet = /datum/mood_event/surgery/major
	pain_overlay_severity = 2
	pain_amount = 10
	pain_type = BURN

/datum/surgery_step/reinforce_ligaments
	surgery_moodlet = /datum/mood_event/surgery/major
	pain_overlay_severity = 2
	pain_amount = 10
	pain_type = BURN

/datum/surgery_step/muscled_veins
	surgery_moodlet = /datum/mood_event/surgery/major
	pain_overlay_severity = 2
	pain_amount = 15
	pain_type = BURN

/datum/surgery_step/ground_nerves
	surgery_moodlet = /datum/mood_event/surgery/major
	pain_overlay_severity = 2
	pain_amount = 15
	pain_type = BURN

/datum/surgery_step/splice_nerves
	surgery_moodlet = /datum/mood_event/surgery/major
	pain_overlay_severity = 2
	pain_amount = 15
	pain_type = BURN

/datum/surgery_step/thread_veins
	surgery_moodlet = /datum/mood_event/surgery/major
	pain_overlay_severity = 2
	pain_amount = 15
	pain_type = BURN
