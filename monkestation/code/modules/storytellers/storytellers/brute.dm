/datum/storyteller/brute
	name = "The Brute"
	desc = "While the brute will hit hard, it tires quickly."
	starting_point_multipliers = list(
		EVENT_TRACK_MUNDANE = 1,
		EVENT_TRACK_MODERATE = 1,
		EVENT_TRACK_MAJOR = 1,
		EVENT_TRACK_ROLESET = 1.2,
		EVENT_TRACK_OBJECTIVES = 1,
		)
	point_gains_multipliers = list(
		EVENT_TRACK_MUNDANE = 0.8,
		EVENT_TRACK_MODERATE = 0.8,
		EVENT_TRACK_MAJOR = 0.8,
		EVENT_TRACK_ROLESET = 0.3,
		EVENT_TRACK_OBJECTIVES = 1,
		)
	population_min = 40 // If crew is gonna get hit hard have the numbers to survive it. Somewhat...
	weight = 1
