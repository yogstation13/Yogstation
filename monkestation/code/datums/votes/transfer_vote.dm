#define CHOICE_CALL		"Call Shuttle"
#define CHOICE_CONTINUE	"Continue Round"

/// If a map vote is called before the emergency shuttle leaves the station, the players can call another vote to re-run the vote on the shuttle leaving.
/datum/vote/shuttle_call
	name = "Call Shuttle"
	message = "Should we go home?"
	default_choices = list(
		CHOICE_CALL,
		CHOICE_CONTINUE,
	)
	player_startable = FALSE
	vote_sound_volume = 150 // Make it loud so people don't miss it.

/datum/vote/shuttle_call/reset()
	. = ..()
	SSautotransfer.doing_transfer_vote = FALSE

/datum/vote/shuttle_call/can_be_initiated(mob/by_who, forced = FALSE)
	. = ..()
	if(!.)
		return FALSE
	if(!SSticker.IsRoundInProgress())
		return FALSE
	if(EMERGENCY_PAST_POINT_OF_NO_RETURN)
		return FALSE
	if(SSautotransfer.doing_transfer_vote)
		return FALSE

/datum/vote/shuttle_call/initiate_vote(initiator, duration)
	. = ..()
	SSautotransfer.doing_transfer_vote = TRUE
	priority_announce(
		text = "The shift has eclipsed its standard duration. If the crew wish to leave, a scheduled shuttle will be sent to the station from Central Command.",
		title = "Crew Transfer Vote",
		has_important_message = TRUE,
		color_override = "green",
	)

/datum/vote/shuttle_call/finalize_vote(winning_option)
	switch(winning_option)
		if(CHOICE_CALL)
			SSautotransfer.crew_transfer_passed()
		if(CHOICE_CONTINUE)
			SSautotransfer.crew_transfer_continue()
		else
			CRASH("[type] wasn't passed a valid winning choice. (Got: [winning_option || "null"])")

/datum/vote/shuttle_call/can_vote(mob/voter = usr)
	. = TRUE
	if(voter.client?.holder)
		return TRUE
	if(isobserver(voter) || voter.stat == DEAD || !(voter.ckey in GLOB.joined_player_list)) // only living crew gets to vote
		return FALSE

/datum/vote/shuttle_call/tiebreaker(list/winners)
	return CHOICE_CONTINUE // Generally, this is less likely to make people mad. It still can, don't get me wrong, but it's safer.

/datum/vote/shuttle_call/get_vote_result(list/non_voters)
	for(var/ckey in non_voters)
		var/client/client = non_voters[ckey]
		if(client?.mob && can_vote(client.mob))
			choices[CHOICE_CONTINUE]++ // Everyone defaults to continue, since they may be in the middle of something when the vote starts.
	if(choices[CHOICE_CALL] + choices[CHOICE_CONTINUE] <= 0) // No-one is alive. Call it.
		return CHOICE_CALL
	return ..()

#undef CHOICE_CONTINUE
#undef CHOICE_CALL
