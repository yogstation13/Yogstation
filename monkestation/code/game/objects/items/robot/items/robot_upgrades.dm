// Monkestation change: UwU-speak module for borgs because I hate borg players
/obj/item/borg/upgrade/uwu
	name = "cyborg UwU-speak \"upgrade\""
	desc = "As if existence as an artificial being wasn't torment enough for the unit OR the crew."
	icon_state = "cyborg_upgrade"

/obj/item/borg/upgrade/uwu/action(mob/living/silicon/robot/robutt, user = usr)
	. = ..()
	if(.)
		RegisterSignal(robutt, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/obj/item/borg/upgrade/uwu/deactivate(mob/living/silicon/robot/robutt, user = usr)
	UnregisterSignal(robutt, COMSIG_MOB_SAY)

/obj/item/borg/upgrade/uwu/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER
	var/message = speech_args[SPEECH_MESSAGE]

	if(message[1] != "*")
		message = uwuify_text(message) || message
	speech_args[SPEECH_MESSAGE] = message
