/// The fear of swear words. Those who hear or read them (or even use them) will find themselves
/// anxious and upset.
///
/// The name is taken from <https://phobia.fandom.com/wiki/Kakologophobia>, and is derived from the
/// Greek words *kakos* (meaning "bad") and *logos* (meaning "word").
/datum/quirk/kakologophobia
	name = "Kakologophobia"
	desc = "You have an intense fear of swear words."
	value = -8
	// Gain text and lose text is handled by the phobia brain trauma that the quirk holder gains.
	medical_record_text = "Patient has an irrational fear of swear words."
	icon = FA_ICON_COMMENT_MEDICAL

/datum/quirk/kakologophobia/add(client/client_source)
	var/mob/living/carbon/human_holder = quirk_holder
	if(istype(human_holder))
		human_holder.gain_trauma(new /datum/brain_trauma/mild/phobia/swearing, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/kakologophobia/remove()
	var/mob/living/carbon/human_holder = quirk_holder
	if(istype(human_holder))
		human_holder.cure_trauma_type(new /datum/brain_trauma/mild/phobia/swearing, TRAUMA_RESILIENCE_ABSOLUTE)

/// A variant on Kakologophobia, which replaces the trauma with a mood debuff.
///
/// This variant is programmed similarly to a `/datum/brain_trauma/mild/phobia`, but is deliberately
/// not implemented in terms of that system, as we only want to give a mood debuff, rather than
/// shutting down the character entirely.
/datum/quirk/easily_offended
	name = "Easily Offended"
	desc = "You hate it when others use swear words."
	value = -1
	gain_text = span_danger("You wish people didn't have such dirty mouths.")
	lose_text = span_notice("You wish more people had dirty mouths.")
	medical_record_text = "Patient became noticably upset when a nearby doctor cursed in response to stubbing their toe."
	icon = FA_ICON_HASHTAG

	var/static/regex/trigger_regex

/datum/quirk/easily_offended/New()
	trigger_regex = GLOB.phobia_regexes["swearing"]

/datum/quirk/easily_offended/add(client/client_source)
	RegisterSignal(src.quirk_holder, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	RegisterSignal(src.quirk_holder, COMSIG_MOVABLE_HEAR, PROC_REF(handle_hearing))

/datum/quirk/easily_offended/remove()
	UnregisterSignal(src.quirk_holder, COMSIG_MOB_SAY)
	UnregisterSignal(src.quirk_holder, COMSIG_MOVABLE_HEAR)

/datum/quirk/easily_offended/proc/handle_hearing(datum/source, list/hearing_args)
	// If the owner can't hear...
	// Or if the speaker is the owner (we don't want to double-dip)...
	// Or if the owner doesn't understand the speaker's language...
	// Then don't bother checking if we're hearing a curse word.
	if(!src.quirk_holder.can_hear() || src.quirk_holder == hearing_args[HEARING_SPEAKER] || !src.quirk_holder.has_language(hearing_args[HEARING_LANGUAGE]))
		return

	// If we hear a swear...
	if(trigger_regex.Find(hearing_args[HEARING_RAW_MESSAGE]))
		// then apply a debuff.
		new /obj/effect/temp_visual/annoyed(src.quirk_holder.loc)
		src.quirk_holder.add_mood_event(
			"kakologophobia_heard_swear",
			/datum/mood_event/heard_swear
		)

// If the quirk holder is the one that used the curse word, give them a bigger mood debuff than
// normal.
/datum/quirk/easily_offended/proc/handle_speech(datum/source, list/speech_args)
	// If we're saying a swear...
	if(trigger_regex.Find(speech_args[SPEECH_MESSAGE]))
		// then apply a debuff
		// TODO: Replace this with an "embarrassed" visual
		new /obj/effect/temp_visual/annoyed(src.quirk_holder.loc)
		if(speech_args[SPEECH_FORCED])
			// if it's forced, add a less major debuff
			src.quirk_holder.add_mood_event(
				"kakologophobia_said_swear_forced",
				/datum/mood_event/said_swear/forced
			)
		else
			src.quirk_holder.add_mood_event(
				"kakologophobia_said_swear",
				/datum/mood_event/said_swear
			)

/datum/mood_event/heard_swear
	description = "Why do people need to have potty mouths?"
	mood_change = -3
	timeout = 3 MINUTES

/datum/mood_event/said_swear
	description = "I shouldn't use that language!"
	mood_change = -5
	timeout = 4 MINUTES

// Special variant if they were forced to say the swear word (i.e. through tourettes)
/datum/mood_event/said_swear/forced
	description = "Why did I use that language?!"
	mood_change = -3
