/datum/round_event_control/high_priority_bounty
	name = "High Priority Bounty"
	description = "provides a high priority cargo bounty."
	typepath = /datum/round_event/high_priority_bounty
	weight = 20
	max_occurrences = 1 //only one a round, but it's very valuable to do
	earliest_start = 0
	track = EVENT_TRACK_OBJECTIVES
	tags = list(TAG_COMMUNAL, TAG_POSITIVE)

/datum/round_event/high_priority_bounty/announce(fake)
	priority_announce("Central Command has issued a high-priority cargo bounty. Details have been sent to all bounty consoles.", "Nanotrasen Bounty Program")

/datum/round_event/high_priority_bounty/start()
	var/datum/bounty/B
	for(var/attempts = 0; attempts < 50; ++attempts)
		B = random_bounty()
		if(!B)
			continue
		B.mark_high_priority(5) //5x the reward
		if(try_add_bounty(B))
			break

