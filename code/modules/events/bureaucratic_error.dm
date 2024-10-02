/datum/round_event_control/bureaucratic_error
	name = "Bureaucratic Error"
	typepath = /datum/round_event/bureaucratic_error
	max_occurrences = 1
	weight = 2
	description = "Randomly changes the overflow role."
	track = EVENT_TRACK_MAJOR // if you've ever dealt with 10 mimes you understand why.
	tags = list(TAG_COMMUNAL)
	event_group = /datum/event_group/error

/datum/round_event/bureaucratic_error
	announce_when = 1

/datum/round_event/bureaucratic_error/announce(fake)
	priority_announce("A recent bureaucratic error in the Organic Resources Department may result in personnel shortages in some departments and redundant staffing in others.", "Paperwork Mishap Alert")

/datum/round_event/bureaucratic_error/start()
	SSjob.set_overflow_role(pick(get_all_jobs()))
