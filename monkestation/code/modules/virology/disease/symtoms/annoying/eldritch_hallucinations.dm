/datum/symptom/wendigo_hallucination
	name = "Eldritch Mind Syndrome"
	desc = "UNKNOWN"
	badness = EFFECT_DANGER_ANNOYING
	severity = 2
	stage = 3


/datum/symptom/wendigo_hallucination/first_activate(mob/living/carbon/mob)
	RegisterSignal(mob, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/symptom/wendigo_hallucination/deactivate(mob/living/carbon/mob)
	UnregisterSignal(mob, COMSIG_MOB_SAY)

/datum/symptom/wendigo_hallucination/activate(mob/living/carbon/mob)
	if(!ishuman(mob))
		return
	var/mob/living/carbon/human/H = mob
	H.adjust_jitter(10 SECONDS)

	//creepy sounds copypasted from hallucination code
	var/list/possible_sounds = list(
		'monkestation/code/modules/virology/sounds/ghost.ogg', 'monkestation/code/modules/virology/sounds/ghost2.ogg', 'monkestation/code/modules/virology/sounds/heart_beat_single.ogg', 'monkestation/code/modules/virology/sounds/ear_ring_single.ogg', 'monkestation/code/modules/virology/sounds/screech.ogg',\
		'monkestation/code/modules/virology/sounds/behind_you1.ogg', 'monkestation/code/modules/virology/sounds/behind_you2.ogg', 'monkestation/code/modules/virology/sounds/far_noise.ogg', 'monkestation/code/modules/virology/sounds/growl1.ogg', 'monkestation/code/modules/virology/sounds/growl2.ogg',\
		'monkestation/code/modules/virology/sounds/growl3.ogg', 'monkestation/code/modules/virology/sounds/im_here1.ogg', 'monkestation/code/modules/virology/sounds/im_here2.ogg', 'monkestation/code/modules/virology/sounds/i_see_you1.ogg', 'monkestation/code/modules/virology/sounds/i_see_you2.ogg',\
		'monkestation/code/modules/virology/sounds/look_up1.ogg', 'monkestation/code/modules/virology/sounds/look_up2.ogg', 'monkestation/code/modules/virology/sounds/over_here1.ogg', 'monkestation/code/modules/virology/sounds/over_here2.ogg', 'monkestation/code/modules/virology/sounds/over_here3.ogg',\
		'monkestation/code/modules/virology/sounds/turn_around1.ogg', 'monkestation/code/modules/virology/sounds/turn_around2.ogg', 'monkestation/code/modules/virology/sounds/veryfar_noise.ogg', 'monkestation/code/modules/virology/sounds/wail.ogg')
	mob.playsound_local(mob.loc, pick(possible_sounds))



/datum/symptom/wendigo_hallucination/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	message = replacetext(message,"I","we")
	message = replacetext(message,"me","us")
	speech_args[SPEECH_MESSAGE] = message
