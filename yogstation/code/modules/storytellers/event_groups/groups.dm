/datum/event_group/anomalies
	name = "Anomalies"
	cooldown_time = list(10 MINUTES, 25 MINUTES)

/datum/event_group/comms
	name = "Communications"
	cooldown_time = list(15 MINUTES, 45 MINUTES)
	max_occurrences = 3

/// Represents small-scale technical difficulties - might annoy some people, but not everyone will notice or be affected,
/// If the event directly affects the entire crew, use [/datum/event_group/bsod].
/// If the main effect involves telecommunications, use [/datum/event_group/comms].
/datum/event_group/error
	name = "Technical Difficulties (small scale)"
	cooldown_time = list(2.5 MINUTES, 7.5 MINUTES)

/// Represents large-scale technical difficulties - stuff that affects the whole crew.
/// If the main effect involves telecommunications, use [/datum/event_group/comms].
/datum/event_group/bsod
	name = "Technical Difficulties (large scale)"
	cooldown_time = list(15 MINUTES, 25 MINUTES)
	max_occurrences = 5

/datum/event_group/debris
	name = "Space Debris"
	cooldown_time = list(2 MINUTES, 10 MINUTES)

/datum/event_group/meteors
	name = "Meteors"
	cooldown_time = 20 MINUTES
	max_occurrences = 3

// needs a better name - this is basically for events focused around spawning some sort of NPCs,
// i.e vines, wisdom cow, carp, etc.
/datum/event_group/guests
	name = "Guests"
	cooldown_time = list(7.5 MINUTES, 20 MINUTES)

// These event groups are somewhat specific to a single event,
// but we're using event groups to share cooldowns/occurrences between SSevents and storytellers
/datum/event_group/scrubber_overflow
	name = "Scrubber Overflows"
	cooldown_time = list(25 MINUTES, 45 MINUTES)
	max_occurrences = 2
