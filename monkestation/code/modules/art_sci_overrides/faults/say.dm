#define SPEECH_ARTIFACT_COOLDOWN_MIN	(10 SECONDS)
#define SPEECH_ARTIFACT_COOLDOWN_MAX	(25 SECONDS)

/datum/artifact_fault/speech
	name = "Talkative Fault"
	trigger_chance = 25
	research_value = 50
	/// Cooldown to prevent constant chat spam.
	COOLDOWN_DECLARE(spam_cooldown)

/datum/artifact_fault/speech/on_trigger()
	if(!COOLDOWN_FINISHED(src, spam_cooldown))
		return
	var/center_turf = get_turf(our_artifact.parent)

	if(!center_turf)
		CRASH("[src] had attempted to trigger, but failed to find the center turf!")

	var/did_anything = FALSE
	for(var/mob/living/living in viewers(rand(7, 10), center_turf))
		if(living.stat != CONSCIOUS || !living.can_speak() || prob(30))
			continue
		var/speak_over_radio = prob(10) ? "; " : ""
		var/forced_message = pick_list_replacements(ARTIFACT_FILE, "speech_artifact")
		INVOKE_ASYNC(living, TYPE_PROC_REF(/atom/movable, say), speak_over_radio + forced_message, forced = "artifact ([src])")
		did_anything = TRUE
	if(did_anything)
		COOLDOWN_START(src, spam_cooldown, rand(SPEECH_ARTIFACT_COOLDOWN_MIN, SPEECH_ARTIFACT_COOLDOWN_MAX))

#undef SPEECH_ARTIFACT_COOLDOWN_MAX
#undef SPEECH_ARTIFACT_COOLDOWN_MIN
