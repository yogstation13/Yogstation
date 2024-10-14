/datum/artifact_fault/speech
	name = "Talkative Fault"
	trigger_chance = 25
	research_value = 50

/datum/artifact_fault/speech/on_trigger()
	var/center_turf = get_turf(our_artifact.parent)

	if(!center_turf)
		CRASH("[src] had attempted to trigger, but failed to find the center turf!")

	for(var/mob/living/living in viewers(rand(7, 10), center_turf))
		if(living.stat != CONSCIOUS || !living.can_speak())
			continue
		var/speak_over_radio = prob(10) ? "; " : ""
		var/forced_message = pick_list_replacements(ARTIFACT_FILE, "speech_artifact")
		living.say(speak_over_radio + forced_message, forced = "artifact ([src])")
