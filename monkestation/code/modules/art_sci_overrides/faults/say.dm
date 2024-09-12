/datum/artifact_fault/speech
	name = "Talkative Fault"
	trigger_chance = 25
	var/list/speech = list("Hello there.","I see you.","I know what you've done.","So hows your shift?","HELP ARTIFACT IS MAKING ME SPEAK","All is one.","One is all.")

	research_value = 50

/datum/artifact_fault/speech/on_trigger()
	if(!length(speech))
		return

	var/center_turf = get_turf(our_artifact.parent)

	if(!center_turf)
		CRASH("[src] had attempted to trigger, but failed to find the center turf!")

	for(var/mob/living/living in range(rand(7, 10), center_turf))
		if(prob(10))
			living.say("; [pick(speech)]")
		else
			living.say("[pick(speech)]")
