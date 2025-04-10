#define RANDOM_EVENT_ADMIN_INTERVENTION_TIME (10 SECONDS)

//this singleton datum is used by the events controller to dictate how it selects events
/datum/round_event_control
	var/name //The human-readable name of the event
	var/description //The description of the event
	var/typepath //The typepath of the event datum /datum/round_event

	var/weight = 10 //The weight this event has in the random-selection process.
									//Higher weights are more likely to be picked.
									//10 is the default weight. 20 is twice more likely; 5 is half as likely as this default.
									//0 here does NOT disable the event, it just makes it extremely unlikely

	var/earliest_start = 20 MINUTES //The earliest world.time that an event can start (round-duration in deciseconds) default: 20 mins
	var/min_players = 0 //The minimum amount of alive, non-AFK human players on server required to start the event.

	var/occurrences = 0 //How many times this event has occured
	var/max_occurrences = 20 //The maximum number of times this event can occur (naturally), it can still be forced.
									//By setting this to 0 you can effectively disable an event.

	var/holidayID = "" //string which should be in the SSgamemodes.holidays list if you wish this event to be holiday-specific
									//anything with a (non-null) holidayID which does not match holiday, cannot run.
	var/wizardevent = FALSE
	var/alert_observers = TRUE //should we let the ghosts and admins know this event is firing
									//should be disabled on events that fire a lot

	/// Minimum wizard rituals at which to trigger this event, inclusive
	var/min_wizard_trigger_potency = NEVER_TRIGGERED_BY_WIZARDS
	/// Maximum wizard rituals at which to trigger this event, inclusive
	var/max_wizard_trigger_potency = NEVER_TRIGGERED_BY_WIZARDS

	/// Datum that will handle admin options for forcing the event.
	/// If there are no options, just leave it as an empty list.
	var/list/datum/event_admin_setup/admin_setup = list()
	/// Flags dictating whether this event should be run on certain kinds of map
	var/map_flags = NONE

	// monkestation start
	/// The typepath to the event group this event is a part of.
	var/datum/event_group/event_group = null
	
	/// if this can only trigger on roundstart
	var/roundstart = FALSE
	
	/// if this event is roundstart, it will set the roll credits icon to this
	var/title_icon = null

	var/cost = 1
	var/reoccurence_penalty_multiplier = 0.75
	var/shared_occurence_type
	var/track = EVENT_TRACK_MODERATE
	/// Last calculated weight that the storyteller assigned this event
	var/calculated_weight = 0
	var/tags = list() 	/// Tags of the event
	/// List of the shared occurence types.
	var/list/shared_occurences = list()
	/// Whether a roundstart event can happen post roundstart. Very important for events which override job assignments.
	var/can_run_post_roundstart = TRUE
	/// If set then the type or list of types of storytellers we are restricted to being trigged by
	var/list/allowed_storytellers
	// monkestation end

/datum/round_event_control/New()
	if(config && !wizardevent) // Magic is unaffected by configs
		earliest_start = CEILING(earliest_start * CONFIG_GET(number/events_min_time_mul), 1)
		min_players = CEILING(min_players * CONFIG_GET(number/events_min_players_mul), 1)
	if(!length(admin_setup))
		return
	var/list/admin_setup_types = admin_setup.Copy()
	admin_setup.Cut()
	for(var/admin_setup_type in admin_setup_types)
		admin_setup += new admin_setup_type(src)

/datum/round_event_control/wizard
	wizardevent = TRUE

/// Returns true if event can run in current map
/datum/round_event_control/proc/valid_for_map()
	if (!map_flags)
		return TRUE
	if (SSmapping.is_planetary())
		if (map_flags & EVENT_SPACE_ONLY)
			return FALSE
	else
		if (map_flags & EVENT_PLANETARY_ONLY)
			return FALSE
	return TRUE

// Checks if the event can be spawned. Used by event controller and "false alarm" event.
// Admin-created events override this.
/datum/round_event_control/proc/canSpawnEvent(players_amt, allow_magic = FALSE, fake_check = FALSE)
	SHOULD_CALL_PARENT(TRUE)
// monkestation start: event groups and storyteller stuff
	if(event_group && !GLOB.event_groups[event_group].can_run())
		return FALSE
	if(roundstart && ((SSticker.round_start_time && (world.time - SSticker.round_start_time) >= 2 MINUTES) || (SSgamemode.ran_roundstart && !fake_check)))
		return FALSE
	// if(istype(src, /datum/round_event_control/antagonist/solo/from_ghosts) && (SSticker.round_start_time + 85 MINUTES <= world.time))
	// 	return TRUE // we allow all ghost roles to run at this point and dont care about other checks
// monkestation end
	if(occurrences >= max_occurrences)
		return FALSE
	if(earliest_start >= (world.time - SSticker.round_start_time))
		return FALSE
	if(!allow_magic && wizardevent != SSgamemode.wizardmode)
		return FALSE
	if(players_amt < min_players)
		return FALSE
	if(holidayID && !check_holidays(holidayID))
		return FALSE
	if(EMERGENCY_ESCAPED_OR_ENDGAMED)
		return FALSE
	if(ispath(typepath, /datum/round_event/ghost_role) && !(GLOB.ghost_role_flags & GHOSTROLE_MIDROUND_EVENT))
		return FALSE

// monkestation start: storyteller stuff
	if(checks_antag_cap && !roundstart && !SSgamemode.can_inject_antags())
		return FALSE
	if(!check_enemies())
		return FALSE
	if(allowed_storytellers && ((islist(allowed_storytellers) && !is_type_in_list(SSgamemode.storyteller, allowed_storytellers)) || SSgamemode.storyteller.type != allowed_storytellers))
		return FALSE
	if(SSgamemode.storyteller?.disable_distribution || SSgamemode.halted_storyteller)
		return FALSE
// monkestation end

	return TRUE

/datum/round_event_control/proc/preRunEvent(forced = FALSE)
	if(!ispath(typepath, /datum/round_event))
		return EVENT_CANT_RUN

	if (SEND_GLOBAL_SIGNAL(COMSIG_GLOB_PRE_RANDOM_EVENT, src) & CANCEL_PRE_RANDOM_EVENT)
		return EVENT_INTERRUPTED

	var/players_amt = get_active_player_count(alive_check = TRUE, afk_check = TRUE, human_check = TRUE)
	if(!canSpawnEvent(players_amt, fake_check = TRUE) && !forced)
		message_admins("Second pre-condition check for [name] failed, skipping...")
		return EVENT_INTERRUPTED
	if(!canSpawnEvent(players_amt, fake_check = TRUE) && forced)
		message_admins("Second pre-condition check for [name] failed, but event forced, running event regardless this may have issues...")

	return EVENT_READY

/*
Runs the event
* Arguments:
* - random: shows if the event was triggered randomly, or by on purpose by an admin or an item
* - announce_chance_override: if the value is not null, overrides the announcement chance when an admin calls an event
*/
/datum/round_event_control/proc/runEvent(random = FALSE, announce_chance_override = null, admin_forced = FALSE, event_cause)
	/*
	* We clear our signals first so we dont cancel a wanted event by accident,
	* the majority of time the admin will probably want to cancel a single midround spawned random events
	* and not multiple events called by others admins
	* * In the worst case scenario we can still recall a event which we cancelled by accident, which is much better then to have a unwanted event
	*/
	var/datum/round_event/round_event = new typepath(TRUE, src)
	if(round_event.oshan_blocked && SSmapping.config.map_name == "Oshan Station") //we'll use this whenever we have an underwater station
		return
	if(admin_forced && length(admin_setup))
		//not part of the signal because it's conditional and relies on usr heavily
		for(var/datum/event_admin_setup/admin_setup_datum in admin_setup)
			admin_setup_datum.apply_to_event(round_event)
	SEND_SIGNAL(src, COMSIG_CREATED_ROUND_EVENT, round_event)
	round_event.setup()
	round_event.current_players = get_active_player_count(alive_check = 1, afk_check = 1, human_check = 1)
	occurrences++

	if(announce_chance_override != null)
		round_event.announce_chance = announce_chance_override

	testing("[time2text(world.time, "hh:mm:ss")] [round_event.type]")
	log_game("[random ? "Random" : "Forced"] Event triggering: [name] ([typepath]).")

	// monkestation start: event groups
	if(event_group)
		GLOB.event_groups[event_group].on_run(src)
	// monkestation end

	if(alert_observers)
		round_event.announce_deadchat(random, event_cause)

	SSblackbox.record_feedback("tally", "event_ran", 1, "[name]")
	return round_event

/datum/round_event //NOTE: Times are measured in master controller ticks!
	var/processing = TRUE
	var/datum/round_event_control/control

	/// When in the lifetime to call start().
	/// This is in seconds - so 1 = ~2 seconds in.
	var/start_when = 0
	/// When in the lifetime to call announce(). If you don't want it to announce use announce_chance, below.
	/// This is in seconds - so 1 = ~2 seconds in.
	var/announce_when = 0
	/// Probability of announcing, used in prob(), 0 to 100, default 100. Called in process, and for a second time in the ion storm event.
	var/announce_chance = 100
	/// When in the lifetime the event should end.
	/// This is in seconds - so 1 = ~2 seconds in.
	var/end_when = 0

	/// How long the event has existed. You don't need to change this.
	var/activeFor = 0
	/// Amount of of alive, non-AFK human players on server at the time of event start
	var/current_players = 0
	/// Can be faked by fake news event.
	var/fakeable = TRUE
	/// Whether a admin wants this event to be cancelled
	var/cancel_event = FALSE
	//monkestation vars starts
	///canceled on oshan
	var/oshan_blocked = FALSE
	/// Whether the event called its start() yet or not.
	var/has_started = FALSE
	///have we finished setup?
	var/setup = FALSE
	//monkestation vars end

//Called first before processing.
//Allows you to setup your event, such as randomly
//setting the start_when and or announce_when variables.
//Only called once.
//EDIT: if there's anything you want to override within the new() call, it will not be overridden by the time this proc is called.
//It will only have been overridden by the time we get to announce() start() tick() or end() (anything but setup basically).
//This is really only for setting defaults which can be overridden later when New() finishes.
/datum/round_event/proc/setup()
	SHOULD_CALL_PARENT(FALSE)
	setup = TRUE
	return

///Annouces the event name to deadchat, override this if what an event should show to deadchat is different to its event name.
/datum/round_event/proc/announce_deadchat(random, cause)
	deadchat_broadcast(" has just been[random ? " randomly" : ""] triggered[cause ? " by [cause]" : ""]!", "<b>[control.name]</b>", message_type=DEADCHAT_ANNOUNCEMENT) //STOP ASSUMING IT'S BADMINS!

//Called when the tick is equal to the start_when variable.
//Allows you to start before announcing or vice versa.
//Only called once.
/datum/round_event/proc/start()
	SHOULD_CALL_PARENT(FALSE)
	return

//monkestation addition starts - STORYTELLERS
/// This section of event processing is in a proc because roundstart events may get their start invoked.
/datum/round_event/proc/try_start()
	if(has_started)
		return
	has_started = TRUE
	processing = FALSE
	start()
	processing = TRUE

/datum/round_event_control/roundstart
	roundstart = TRUE
	earliest_start = 0

///Adds an occurence. Has to use the setter to properly handle shared occurences
/datum/round_event_control/proc/add_occurence()
	if(shared_occurence_type)
		if(!shared_occurences[shared_occurence_type])
			shared_occurences[shared_occurence_type] = 0
		shared_occurences[shared_occurence_type]++
	occurrences++

///Subtracts an occurence. Has to use the setter to properly handle shared occurences
/datum/round_event_control/proc/subtract_occurence()
	if(shared_occurence_type)
		if(!shared_occurences[shared_occurence_type])
			shared_occurences[shared_occurence_type] = 0
		shared_occurences[shared_occurence_type]--
	occurrences--

///Gets occurences. Has to use the getter to properly handle shared occurences
/datum/round_event_control/proc/get_occurences()
	if(shared_occurence_type)
		if(!shared_occurences[shared_occurence_type])
			shared_occurences[shared_occurence_type] = 0
		return shared_occurences[shared_occurence_type]
	return occurrences

/// Prints the action buttons for this event.
/datum/round_event_control/proc/get_href_actions()
	if(SSticker.HasRoundStarted())
		if(roundstart)
			if(!can_run_post_roundstart)
				return "<a class='linkOff'>Force Now</a><br><a class='linkOff'>Schedule</a>"
			return "<a href='byond://?src=[REF(src)];action=force_now'>Force Now</a><br><a href='byond://?src=[REF(src)];action=schedule'>Schedule</a>"
		else
			return "<a href='byond://?src=[REF(src)];action=force_now'>Force Now</a><br><a href='byond://?src=[REF(src)];action=force_next'>Force Next</a><br><a href='byond://?src=[REF(src)];action=schedule'>Schedule</a>"
	else
		if(roundstart)
			return "<a href='byond://?src=[REF(src)];action=force_next'>Force Roundstart</a><br><a href='byond://?src=[REF(src)];action=schedule'>Add Roundstart</a>"
		else
			return "<a class='linkOff'>Force Now</a><br><a class='linkOff'>Force Next</a><br><a class='linkOff'>Schedule</a>"


/datum/round_event_control/Topic(href, href_list)
	. = ..()
	if(QDELETED(src))
		return
	switch(href_list["action"])
		if("schedule")
			message_admins("[key_name_admin(usr)] scheduled event [src.name].")
			log_admin_private("[key_name(usr)] scheduled [src.name].")
			SSgamemode.storyteller.buy_event(src, src.track)
		if("force_next")
			if(length(src.admin_setup))
				for(var/datum/event_admin_setup/admin_setup_datum in src.admin_setup)
					if(admin_setup_datum.prompt_admins() == ADMIN_CANCEL_EVENT)
						return
			message_admins("[key_name_admin(usr)] forced scheduled event [src.name].")
			log_admin_private("[key_name(usr)] forced scheduled event [src.name].")
			SSgamemode.forced_next_events[src.track] = src
		if("force_now")
			if(length(src.admin_setup))
				for(var/datum/event_admin_setup/admin_setup_datum in src.admin_setup)
					if(admin_setup_datum.prompt_admins() == ADMIN_CANCEL_EVENT)
						return
			message_admins("[key_name_admin(usr)] forced event [src.name].")
			log_admin_private("[key_name(usr)] forced event [src.name].")
			runEvent(random = FALSE, admin_forced = TRUE)

//monkestation addition ends - STORYTELLERS

//Called after something followable has been spawned by an event
//Provides ghosts a follow link to an atom if possible
//Only called once.
/datum/round_event/proc/announce_to_ghosts(atom/atom_of_interest)
	if(control.alert_observers)
		if (atom_of_interest)
			notify_ghosts(
				"[control.name] has an object of interest: [atom_of_interest]!",
				source = atom_of_interest,
				action = NOTIFY_ORBIT,
				header = "Something's Interesting!",
			)
	return

//Called when the tick is equal to the announce_when variable.
//Allows you to announce before starting or vice versa.
//Only called once.
/datum/round_event/proc/announce(fake)
	return

//Called on or after the tick counter is equal to start_when.
//You can include code related to your event or add your own
//time stamped events.
//Called more than once.
/datum/round_event/proc/tick()
	return

//Called on or after the tick is equal or more than end_when
//You can include code related to the event ending.
//Do not place spawn() in here, instead use tick() to check for
//the activeFor variable.
//For example: if(activeFor == myOwnVariable + 30) doStuff()
//Only called once.
/datum/round_event/proc/end()
	return



//Do not override this proc, instead use the appropiate procs.
//This proc will handle the calls to the appropiate procs.
/datum/round_event/process()
	SHOULD_NOT_OVERRIDE(TRUE)
	if(!setup)
		return
	if(!processing)
		return

	if(activeFor == start_when)
		processing = FALSE
		start()
		processing = TRUE

	if(activeFor == announce_when && prob(announce_chance))
		processing = FALSE
		announce(FALSE)
		processing = TRUE

	if(start_when < activeFor && activeFor < end_when)
		processing = FALSE
		tick()
		processing = TRUE

	if(activeFor == end_when)
		processing = FALSE
		end()
		processing = TRUE

	// Everything is done, let's clean up.
	if(activeFor >= end_when && activeFor >= announce_when && activeFor >= start_when)
		processing = FALSE
		kill()

	activeFor++


//Garbage collects the event by removing it from the global events list,
//which should be the only place it's referenced.
//Called when start(), announce() and end() has all been called.
/datum/round_event/proc/kill()
	SSgamemode.running -= src


//Sets up the event then adds the event to the the list of running events
/datum/round_event/New(my_processing = TRUE, datum/round_event_control/event_controller)
	control = event_controller
	processing = my_processing
	SSgamemode.running += src
	return ..()

#undef RANDOM_EVENT_ADMIN_INTERVENTION_TIME
