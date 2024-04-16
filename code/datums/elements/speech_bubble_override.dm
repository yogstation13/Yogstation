/datum/element/speech_bubble_override
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH_ON_HOST_DESTROY
	argument_hash_start_idx = 2
	var/bubble_type

/datum/element/speech_bubble_override/Attach(datum/target, bubble_type)
	. = ..()
	if(!ismob(target))
		return ELEMENT_INCOMPATIBLE

	src.bubble_type = bubble_type

	RegisterSignal(target, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	RegisterSignal(target, COMSIG_MOB_CREATE_TYPING_INDICATOR, PROC_REF(handle_typing_indicator))

/datum/element/speech_bubble_override/Detach(datum/source, ...)
	UnregisterSignal(source, COMSIG_MOB_SAY)
	UnregisterSignal(source, COMSIG_MOB_CREATE_TYPING_INDICATOR)
	return ..()

/datum/element/speech_bubble_override/proc/handle_speech(mob/target, list/speech_args)
	SIGNAL_HANDLER
	speech_args[SPEECH_BUBBLE_TYPE] = bubble_type

/datum/element/speech_bubble_override/proc/handle_typing_indicator(mob/target, list/bubble_args)
	SIGNAL_HANDLER
	bubble_args[BUBBLE_ICON_STATE] = bubble_type
