/// An associative list of singleton event groups, in the format of [type] = instance.
GLOBAL_LIST_INIT_TYPED(event_groups, /datum/event_group, initialize_event_groups())

/datum/event_group
	/// The name of the event group.
	var/name
	/// If set, this will limit the amount of times events in this group can run.
	var/max_occurrences
	/// If set, whenever an event in this group runs, no other events in this group
	/// will be able to run for the specified amount of time.
	/// Can be either a number for a static cooldown, or a list containing 2 numbers,
	/// for a random cooldown between the given numbers, which will bias towards the upper bound
	/// the more the event group has occured.
	var/cooldown_time
	/// The amount of time events in this group have ran.
	VAR_FINAL/occurrences = 0
	/// If [cooldown_time] is set, this will be set to the minimum world.time where the next event in this group can run.
	COOLDOWN_DECLARE(event_cooldown)

/datum/event_group/Destroy(force)
	if(!force && GLOB.event_groups[type] == src)
		stack_trace("Something is trying to destroy the event group ([type]), which is a singleton! This is super duper bad!")
		return QDEL_HINT_LETMELIVE
	return ..()

/datum/event_group/proc/get_cooldown_time() as num
	if(isnum(cooldown_time))
		return cooldown_time
	var/min_cooldown = cooldown_time[1]
	var/max_cooldown = cooldown_time[2]

	if (max_occurrences)
		var/occurrence_ratio = min(1, occurrences / max_occurrences)
		return min_cooldown + (max_cooldown - min_cooldown) * occurrence_ratio
	else
		// If max_occurrences is not set, use a simple exponential increase
		return min_cooldown + (max_cooldown - min_cooldown) * (occurrences / (occurrences + 1))

/datum/event_group/proc/can_run() as num
	. = TRUE
	if(cooldown_time && !COOLDOWN_FINISHED(src, event_cooldown))
		return FALSE
	if(max_occurrences && occurrences >= max_occurrences)
		return FALSE

/datum/event_group/proc/on_run(datum/round_event_control/running_event)
	if(cooldown_time)
		var/cooldown = get_cooldown_time()
		COOLDOWN_START(src, event_cooldown, cooldown)
		for(var/datum/scheduled_event/scheduled_event in SSgamemode.scheduled_events)
			if(scheduled_event.event == running_event || scheduled_event.event?.event_group != type || !scheduled_event.start_time || (scheduled_event.start_time > src.event_cooldown) || (scheduled_event.start_time <= world.time))
				continue
			var/old_start_time = scheduled_event.start_time
			scheduled_event.start_time += cooldown
			message_admins("Scheduled event [scheduled_event.event.name] start time pushed back by [DisplayTimeText(cooldown)] ([DisplayTimeText(COOLDOWN_TIMELEFT(scheduled_event, start_time))] from now) due to event group [name] running.")
			log_storyteller("Scheduled event [scheduled_event.event.name] start time pushed back by [DisplayTimeText(cooldown)] ([old_start_time] -> [scheduled_event.start_time]) due to event group [name] running.", list("group" = "[name]", "cooldown" = cooldown))
	occurrences++
	SSblackbox.record_feedback("tally", "event_group_ran", 1, "[name]")

/proc/initialize_event_groups() as /list
	RETURN_TYPE(/list)
	. = list()
	for(var/datum/event_group/event_group as anything in subtypesof(/datum/event_group))
		if(!event_group::name)
			continue
		.[event_group] = new event_group
