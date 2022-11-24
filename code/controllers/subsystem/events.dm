#define EVENT_TYPE_MILD 1
#define EVENT_TYPE_SEVERE 2
#define EVENT_TYPE_CATASTROPHIC 3
#define EVENT_TYPE_NULL 0
SUBSYSTEM_DEF(events)
	name = "Events"
	init_order = INIT_ORDER_EVENTS
	runlevels = RUNLEVEL_GAME

	var/datum/event_timer/mild/mild_events
	var/datum/event_timer/severe/severe_events
	var/datum/event_timer/catastrophic/catastrophic_events

	var/list/holidays			//List of all holidays occuring today or null if no holidays
	var/list/all_events = list()
	var/list/running_events = list()
	var/list/currently_running_events = list()
	var/wizardmode = FALSE
	var/multiplier = 1

/datum/event_timer
	var/event_type = EVENT_TYPE_NULL
	var/scheduled = 0			//The next world.time that a naturally occuring random event can be selected.
	var/frequency_lower = 2 MINUTES
	var/frequency_upper = 9 MINUTES
	var/list/events = list()

/datum/event_timer/New()
	. = ..()
	for(var/etype in typesof(/datum/round_event_control))
		var/datum/round_event_control/E = new etype()
		if(!E.typepath)
			continue				//don't want this one! leave it for the garbage collector
		if (E.event_type == event_type)			//If he's just our type
			events += E				//add it to the list of all events (controls)
	reschedule()

/datum/event_timer/proc/TriggerEvent(datum/round_event_control/E)
	. = E.preRunEvent()
	if(. == EVENT_CANT_RUN)//we couldn't run this event for some reason, set its max_occurrences to 0
		E.max_occurrences = 0
	else if(. == EVENT_READY)
		E.random = TRUE
		E.runEvent()

/datum/event_timer/proc/play_event()
	set waitfor = FALSE	//for the admin prompt
	if(!CONFIG_GET(flag/allow_random_events))
		return

	var/gamemode = SSticker.mode.config_tag
	var/players_amt = get_active_player_count(alive_check = 1, afk_check = 1, human_check = 1)
	// Only alive, non-AFK human players count towards this.

	var/sum_of_weights = 0
	for(var/datum/round_event_control/E in events)
		if(!E.canSpawnEvent(players_amt, gamemode))
			continue
		if(E.weight < 0)						//for round-start events etc.
			var/res = TriggerEvent(E)
			if(res == EVENT_INTERRUPTED)
				continue	//like it never happened
			if(res == EVENT_CANT_RUN)
				return
		sum_of_weights += E.weight

	sum_of_weights = rand(0,sum_of_weights)	//reusing this variable. It now represents the 'weight' we want to select

	for(var/datum/round_event_control/E in events)
		if(!E.canSpawnEvent(players_amt, gamemode))
			continue
		sum_of_weights -= E.weight

		if(sum_of_weights <= 0)				//we've hit our goal
			if(TriggerEvent(E))
				return

/datum/event_timer/proc/reschedule()
	var/multiplier = SSevents.multiplier
	if (SSevents.wizardmode)
		multiplier *= 0.5 
	scheduled = world.time + (rand(frequency_lower, max(frequency_lower,frequency_upper)) * 0.5)

/datum/event_timer/proc/check_event()
	if(scheduled <= world.time)
		play_event()
		reschedule()
/datum/event_timer/mild
	event_type = EVENT_TYPE_MILD
	frequency_lower = 2 MINUTES
	frequency_upper = 5 MINUTES

/datum/event_timer/severe
	event_type = EVENT_TYPE_SEVERE
	frequency_lower = 10 MINUTES
	frequency_upper = 20 MINUTES

/datum/event_timer/catastrophic
	event_type = EVENT_TYPE_CATASTROPHIC
	frequency_lower = 20 MINUTES
	frequency_upper = 60 MINUTES

/datum/controller/subsystem/events/Initialize(time, zlevel)
	for(var/etype in typesof(/datum/round_event_control))
		var/datum/round_event_control/E = new etype()
		if(!E.typepath)
			continue				//don't want this one! leave it for the garbage collector
		all_events += E			
	mild_events = new()
	severe_events = new()
	catastrophic_events = new()
	getHoliday()
	return ..()


/datum/controller/subsystem/events/fire(resumed = 0)
	if(!resumed)
		checkEvent() //only check these if we aren't resuming a paused fire
		src.currently_running_events = running_events.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currently_running_events

	while(currentrun.len)
		var/datum/thing = currentrun[currentrun.len]
		currentrun.len--
		if(thing)
			thing.process()
		else
			running_events.Remove(thing)
		if (MC_TICK_CHECK)
			return

//checks if we should select a random event yet, and reschedules if necessary
/datum/controller/subsystem/events/proc/checkEvent()
	mild_events.check_event()
	severe_events.check_event()
	catastrophic_events.check_event()

//allows a client to trigger an event
//aka Badmin Central
// > Not in modules/admin
// REEEEEEEEE
/client/proc/forceEvent()
	set name = "Trigger Event"
	set category = "Admin.Round Interaction"

	if(!holder ||!check_rights(R_FUN))
		return

	holder.forceEvent()

/datum/admins/proc/forceEvent()
	var/dat 	= ""
	var/normal 	= ""
	var/magic 	= ""
	var/holiday = ""
	for(var/datum/round_event_control/E in SSevents.all_events)
		dat = "<BR><A href='?src=[REF(src)];[HrefToken()];forceevent=[REF(E)]'>[E]</A>"
		if(E.holidayID)
			holiday	+= dat
		else if(E.wizardevent)
			magic 	+= dat
		else
			normal 	+= dat

	dat = normal + "<BR>" + magic + "<BR>" + holiday

	var/datum/browser/popup = new(usr, "forceevent", "Force Random Event", 300, 750)
	popup.set_content(dat)
	popup.open()


/*
//////////////
// HOLIDAYS //
//////////////
//Uncommenting ALLOW_HOLIDAYS in config.txt will enable holidays

//It's easy to add stuff. Just add a holiday datum in code/modules/holiday/holidays.dm
//You can then check if it's a special day in any code in the game by doing if(SSevents.holidays["Groundhog Day"])

//You can also make holiday random events easily thanks to Pete/Gia's system.
//simply make a random event normally, then assign it a holidayID string which matches the holiday's name.
//Anything with a holidayID, which isn't in the holidays list, will never occur.

//Please, Don't spam stuff up with stupid stuff (key example being april-fools Pooh/ERP/etc),
//And don't forget: CHECK YOUR CODE!!!! We don't want any zero-day bugs which happen only on holidays and never get found/fixed!

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//ALSO, MOST IMPORTANTLY: Don't add stupid stuff! Discuss bonus content with Project-Heads first please!//
//////////////////////////////////////////////////////////////////////////////////////////////////////////
*/

//sets up the holidays and holidays list
/datum/controller/subsystem/events/proc/getHoliday()
	if(!CONFIG_GET(flag/allow_holidays))
		return		// Holiday stuff was not enabled in the config!

	var/YY = text2num(time2text(world.timeofday, "YY")) 	// get the current year
	var/MM = text2num(time2text(world.timeofday, "MM")) 	// get the current month
	var/DD = text2num(time2text(world.timeofday, "DD")) 	// get the current day
	var/DDD = time2text(world.timeofday, "DDD")	// get the current weekday
	var/W = weekdayofthemonth()	// is this the first monday? second? etc.

	for(var/H in subtypesof(/datum/holiday))
		var/datum/holiday/holiday = new H()
		if(holiday.shouldCelebrate(DD, MM, YY, W, DDD))
			holiday.celebrate()
			if(!holidays)
				holidays = list()
			holidays[holiday.name] = holiday
		else
			qdel(holiday)

	if(holidays)
		holidays = shuffle(holidays)
		// regenerate station name because holiday prefixes.
		set_station_name(new_station_name())
		world.update_status()

/datum/controller/subsystem/events/proc/toggleWizardmode()
	wizardmode = !wizardmode
	message_admins("Summon Events has been [wizardmode ? "enabled" : "disabled"]!")
	log_game("Summon Events was [wizardmode ? "enabled" : "disabled"]!")
