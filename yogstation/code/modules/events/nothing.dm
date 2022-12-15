/datum/round_event_control/nothing
	name = "Nothing"
	typepath = /datum/round_event/nothing
	weight = 15

/datum/round_event/nothing
	announceWhen = -1

/datum/round_event/nothing/start()
	for (var/mob/M in GLOB.player_list)
		to_chat(M, span_notice("Nothing happens."))
