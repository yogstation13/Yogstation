/datum/round_event_control/garbage_day
	name = "Garbage Day"
	typepath = /datum/round_event/garbage_day
	weight = 10

/datum/round_event/garbage_day
	announceWhen	= 1
	endWhen			= 10

/datum/round_event/garbage_day/announce(fake)
	priority_announce("Looks like the waste collection pipes are clogged, standby while we unclog them.")

/datum/round_event/garbage_day/start()
	endWhen = rand(10,20)
	SSgarbage.can_fire = 0

/datum/round_event/garbage_day/end()
	SSgarbage.can_fire = 1
