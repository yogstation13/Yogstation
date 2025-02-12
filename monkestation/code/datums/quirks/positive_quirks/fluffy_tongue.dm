/datum/quirk/fluffy_tongue
	name = "Fluffy Tongue"
	desc = "After spending too much time watching anime you have developed a horrible speech impediment."
	value = 5
	icon = FA_ICON_CAT

/datum/quirk/fluffy_tongue/add()
	RegisterSignal(quirk_holder, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/quirk/fluffy_tongue/remove()
	UnregisterSignal(quirk_holder, COMSIG_MOB_SAY)

/datum/quirk/fluffy_tongue/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER
	if(HAS_TRAIT(source, TRAIT_SIGN_LANG))
		return
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = uwuify_text(message) || message
	speech_args[SPEECH_MESSAGE] = message
