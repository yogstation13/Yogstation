/**
  * # Department goal
  *
  * Goals that a department can complete for monetary (or other) rewards.
  *
  * Can be either do-once-and-complete goals that you just need to do once, or continuous goals that check every specified interval, and reward the department if they're still true.
  * You shouldn't make direct subtypes of [/datum/department_goal], instead make subtypes of each subtype, IE [/datum/department_goal/sec] or [/datum/department_goal/eng].
  *
  * Each subtype is already preset to payout and show to the correct accounts, if you want to add more, you need to update [/datum/controller/subsystem/Yogs/proc/getDepartmentFromAccount].
  */
/datum/department_goal
	/// The name of the goal - Should be kept short
	var/name = "Be nice."
	/// The description of the goal - Describe how to accomplish it
	var/desc = "Be nice to each other for once."
	/// If true, this goal will only be checked at round-end, otherwise it'll get checked every time [SSYogs][/datum/controller/subsystem/Yogs] fires
	var/endround = FALSE
	/// Whether its already been completed. If true, [SSYogs][/datum/controller/subsystem/Yogs] won't check it again
	var/completed = FALSE

	/// Whether the goal can be completed multiple times with multiple payouts, or just once. Will be 0 if it's completed-once, otherwise it'll be the amount of time inbetween checks
	var/continuous = 0 // If on-going, this will be the minimum time required between completions
	/// If false, it'll stop checking once failed, otherwise it'll keep checking but only reward when it's completed
	var/fail_if_failed = FALSE

	/// The account that the goal is tied to. Should probably not be fiddled with as most things rely on it. 
	var/account // See code/__DEFINES/economy.dm
	/// If defined, this will be paid in to the given account on completion. Otherwise, define your own reward in [/datum/department_goal/proc/complete]
	var/reward // should be a number, if it's defined then it will just be given as a cash reward on complete()

/**
  * Creates the new goal.
  *
  * Adds the goal to the list of goals in [SSYogs][/datum/controller/subsystem/Yogs], and if the game is currently running, messages players. See: [/datum/department_goal/proc/message_players]
  */
/datum/department_goal/New()
	SSYogs.department_goals += src
	if(SSticker.current_state == GAME_STATE_PLAYING)
		message_players("new")
	return ..()

/**
  * Destroys the goal.
  * 
  * Removes the goal from the list of goals in [SSYogs][/datum/controller/subsystem/Yogs], and if the game is currently running, messages players. See: [/datum/department_goal/proc/message_players]
  */
/datum/department_goal/Destroy()
	SSYogs.department_goals -= src
	if(SSticker.current_state == GAME_STATE_PLAYING)
		message_players("ded")
	return ..()

/**
  * Returns true if the goal is available to be run, returns false otherwise. Used for conditional goals. See [/datum/department_goal/eng/additional_singularity]
  */
/datum/department_goal/proc/is_available()
	return TRUE

/**
  * Whether the goal is completed. On subtypes, contains all the logic for determining whether it's complete.
  */
/datum/department_goal/proc/check_complete()
	return FALSE

/**
  * Called to complete the goal. If a reward is set, it doles it out automatically. Otherwise, put your own reward in it.
  *
  * Arguments:
  * * endOfRound - Whether or not this was called at the end of the round. If it was, it completes the objective regardless of continuous status
  */
/datum/department_goal/proc/complete(endOfRound = FALSE)
	if(!continuous || endOfRound)
		completed = TRUE
		if(!endOfRound)
			message_players("complet")
	else if(continuous)
		continuing()
	if(reward && account)
		var/datum/bank_account/D = SSeconomy.get_dep_account(account)
		D.adjust_money(reward)

/**
  * Called at the end of the round, returns a string saying either `completed` or `not completed`
  */
/datum/department_goal/proc/get_result()
	if(!completed && check_complete())
		complete(TRUE)
	return "<li>[name] : <span class='[completed ? "greentext'>C" : "redtext'>Not c"]ompleted</span></li>"

/**
  * Returns a string containing the name and the description of the goal
  */
/datum/department_goal/proc/get_name()
	return "<li>[name] : [desc]</li>"

/**
  * Messages the players of the goal's department, dependent on input
  *
  * Arguments:
  * * message - Can be either "ded", "new", or "complet". Will output either that the objective has been deleted, created, or completed.
  */
/datum/department_goal/proc/message_players(message)
	var/string = "Your department's goals have been updated, please have another look at them."
	switch(message)
		if("ded")
			string = "Your department no longer has the goal: " + name
		if("new")
			string = "Your department now has the goal: " + name
		if("complet")
			string = "Your department completed the goal: " + name
			
	var/list/occupationsToSendTo = list()
	for(var/datum/job/j in SSjob.occupations)
		if(j.paycheck_department == account)
			occupationsToSendTo += j.title

	for(var/obj/item/pda/p in GLOB.PDAs)
		if(p.ownjob in occupationsToSendTo)
			var/datum/signal/subspace/messaging/pda/signal = new(src, list(
				"name" = "Central Command",
				"job" = "Central Command",
				"message" = string,
				"language" = /datum/language/common, // NT only uses galactic common.
				"targets" = list("[p.owner] ([p.ownjob])")
			))
			var/obj/machinery/telecomms/message_server/linkedServer
			for(var/obj/machinery/telecomms/message_server/S in GLOB.telecomms_list)
				linkedServer = S
			linkedServer.receive_information(signal, null)

/**
  * If the goal is continuous, this will set the timer to now + how-ever-long-the-timer-is
  */
/datum/department_goal/proc/continuing()
	SSYogs.department_goals[src] = world.time + continuous
