#define CHOICE_CALL_SHUTTLE "Call emergency shuttle"
#define CHOICE_NO_CALL_SHUTTLE "Don't call emergency shuttle"

/datum/vote/transfer_vote
	name = "Transfer"
	message = "Vote for whether the emergency shuttle should be called for crew transfer!"
	default_choices = list(
		CHOICE_CALL_SHUTTLE,
		CHOICE_NO_CALL_SHUTTLE
	)
	player_startable = FALSE
	var/transfer_percentage = 60
	var/result

/datum/vote/transfer_vote/get_vote_result(list/non_voters)
	RETURN_TYPE(/list)
	var/list/winners = list()
	result = choices_by_ckey.len>0 ? (choices[CHOICE_NO_CALL_SHUTTLE]/(choices[CHOICE_CALL_SHUTTLE]+choices[CHOICE_NO_CALL_SHUTTLE]))*100 : 0
	if(world.time >= 2.5 HOURS)
		transfer_percentage = 80
	if(result<=transfer_percentage)
		winners += CHOICE_CALL_SHUTTLE
	else
		winners += CHOICE_NO_CALL_SHUTTLE
	return winners

/datum/vote/transfer_vote/finalize_vote(winning_option)
	if(winning_option == CHOICE_CALL_SHUTTLE)
		priority_announce("Dispatching shuttle for scheduled crew transfer.")
		message_admins("Shuttle called after successful transfer vote ([result]% voted to stay, requirement is [transfer_percentage]%)")
		SSshuttle.emergency_no_recall = TRUE //No, you aren't allowed to reverse a vote
		SSshuttle.emergency.request(null)
	else
		message_admins("Transfer vote failed ([result]% voted to stay, requirement is [transfer_percentage]%)")

#undef CHOICE_CALL_SHUTTLE
#undef CHOICE_NO_CALL_SHUTTLE
