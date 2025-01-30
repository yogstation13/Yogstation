SUBSYSTEM_DEF(autotransfer)
	name = "Autotransfer Vote"
	flags = SS_KEEP_TIMING | SS_BACKGROUND
	wait = 1 MINUTES
	runlevels = RUNLEVEL_GAME

	var/doing_transfer_vote = FALSE
	COOLDOWN_DECLARE(next_transfer_vote)

/datum/controller/subsystem/autotransfer/Initialize(timeofday)
	if(!CONFIG_GET(number/transfer_vote_time))
		flags |= SS_NO_FIRE
		return SS_INIT_NO_NEED
	SSticker.OnRoundstart(CALLBACK(src, PROC_REF(crew_transfer_setup)))
	return SS_INIT_SUCCESS

/datum/controller/subsystem/autotransfer/Recover()
	next_transfer_vote = SSautotransfer.next_transfer_vote

/datum/controller/subsystem/autotransfer/fire()
	if(can_run_transfer_vote())
		SSvote.initiate_vote(/datum/vote/shuttle_call, "automatic shuttle vote", forced = TRUE)
		start_subsequent_vote_cooldown()

/datum/controller/subsystem/autotransfer/proc/start_subsequent_vote_cooldown()
	var/subsequent_transfer_vote_time = CONFIG_GET(number/subsequent_transfer_vote_time)
	if(subsequent_transfer_vote_time)
		COOLDOWN_START(src, next_transfer_vote, subsequent_transfer_vote_time + CONFIG_GET(number/vote_period))
	else
		next_transfer_vote = 0

/datum/controller/subsystem/autotransfer/proc/can_run_transfer_vote()
	. = TRUE
	if(doing_transfer_vote)
		return FALSE
	if(!CONFIG_GET(number/transfer_vote_time))
		return FALSE
	if(!next_transfer_vote || !COOLDOWN_FINISHED(src, next_transfer_vote))
		return FALSE
	if(SSvote.current_vote)
		return FALSE
	if(EMERGENCY_PAST_POINT_OF_NO_RETURN)
		return FALSE
	if(SSshuttle.supermatter_cascade)
		return FALSE

/datum/controller/subsystem/autotransfer/proc/crew_transfer_setup()
	COOLDOWN_START(src, next_transfer_vote, CONFIG_GET(number/transfer_vote_time))

/datum/controller/subsystem/autotransfer/proc/crew_transfer_passed()
	if(!SSticker.IsRoundInProgress())
		CRASH("Somehow tried to initiate crew transfer, even tho there is not ongoing round!")
	SSshuttle.admin_emergency_no_recall = TRUE
	if(SSshuttle.emergency?.mode == SHUTTLE_DISABLED || EMERGENCY_PAST_POINT_OF_NO_RETURN)
		return
	if(EMERGENCY_IDLE_OR_RECALLED)
		SSshuttle.emergency.request(
			red_alert = (SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED)
		)
	crew_transfer_continue() // safety measure

/datum/controller/subsystem/autotransfer/proc/crew_transfer_continue()
	SSgamemode.point_gain_multipliers[EVENT_TRACK_ROLESET]++
