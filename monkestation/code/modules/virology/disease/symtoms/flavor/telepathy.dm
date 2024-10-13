GLOBAL_LIST_INIT(disease_hivemind_users, list())
/datum/symptom/telepathic
	name = "Abductor Syndrome"
	desc = "Repurposes a portion of the users brain, making them incapable of normal speech but allows you to talk into a hivemind."
	stage = 3
	max_count = 1
	badness = EFFECT_DANGER_FLAVOR

/datum/symptom/telepathic/first_activate(mob/living/carbon/mob)
	GLOB.disease_hivemind_users |= mob
	RegisterSignal(mob, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/symptom/telepathic/deactivate(mob/living/carbon/mob)
	GLOB.disease_hivemind_users -= mob
	UnregisterSignal(mob, COMSIG_MOB_SAY)

/datum/symptom/telepathic/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER
	var/message = speech_args[SPEECH_MESSAGE]
	var/mob/living/carbon/human/mob = source
	mob.log_talk(message, LOG_SAY, tag="HIVEMIND DISEASE")
	for(var/mob/living/living as anything in GLOB.disease_hivemind_users)
		if(!isliving(living))
			continue
		to_chat(living, span_abductor("<b>[mob.real_name]:</b>[message]"))

	for(var/mob/dead_mob in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(dead_mob, mob)
		to_chat(dead_mob, "<b>[mob.real_name][link]:</b>[message]")

	speech_args[SPEECH_MESSAGE] = "" //yep we dont speak anymore
