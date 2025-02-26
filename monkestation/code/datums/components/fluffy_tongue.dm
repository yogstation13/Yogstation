/// This component forces mobs to speak uwu-speak, to their detriment.
/datum/component/fluffy_tongue
	dupe_mode = COMPONENT_DUPE_SOURCES

/datum/component/fluffy_tongue/Initialize()
	. = ..()
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/fluffy_tongue/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/component/fluffy_tongue/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_SAY)

/datum/component/fluffy_tongue/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER
	if(HAS_TRAIT(source, TRAIT_SIGN_LANG))
		return
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		speech_args[SPEECH_MESSAGE] = uwuify_text(message) || message
