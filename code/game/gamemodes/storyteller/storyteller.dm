

/* Nich's Grand TODO List:
	1. Categorize all the random events into the 4 different categories
	2. Make more antag events, basically one for every type of antag
	3. I'm stuffing wizard events in the other 4 types after summon events
	4. Add a random antag pick to roundstart, basically just picking one of the antag events
	5. Add ways for the station to impact point generation (not directly, but things like antags dieing raising it, crewmembers dying lowering it)
	6. Add the actual structure for the game_mode to run events, including game mode specific can_trigger procs for most of them, so we check whether there's an AI before we make it malf
	7. Figure out what the hell I'm gonna do regarding antag rep in this gamemode, probably gonna completely disregard it
	8. Overhaul uplink code so it's no longer restricted on a gamemode basis, but on an antag_datum basis
	9. Figure out whether I'm gonna completely forget that hivemind/overthrow exists for this gamemode
	10. Should I end the round if revs are successfull, or do I just let the station exist in a post-revolutionary world? o7
	11. Maybe block conversion antags like revs and cultists from converting each other so you have both antag datums (deconversion sigil? make revflash deconvert on first use?)
	Could also just make it so that antags like revs and cultists stop other antags from happening while they're running, and then they all deconvert once they win?
	12. Make events that are all anti-loyalty-implant (revs, gangs) mutually exclusive, so you don't get a rev event immediately after the gangs lose because everyone was converted
	13. Probably gonna have to gimp a few of the gamemodes (gangs and cultists in particular) so they aren't too strong considering there'll be more than one antag group (guess I can use winrates)
	14. Make a gimped version of old clock cult for this gamemode (was tempted to have new on roundstart, old as a mid-round thing, but new clock-cult kinda messes up the flow
	15. Should events be weighted or not?
*/



/datum/game_mode/storyteller //Concept blatantly stolen from CEV Eris, as is the general setup (having 4 different categories of points and events, and having different storytellers), but all code is ours
	name = "storyteller"
	config_tag = "storyteller"
	report_type = "storyteller"

	var/datum/storyteller
	var/list/storytellers = list()

	var/list/minor_events = list()		//minor events like anomalies or aurora caelus
	var/list/medium_events = list()		//medium events like ion storms and heart attacks
	var/list/major_events = list()		//major events like space vines and meteor showers
	var/list/antag_events = list()		//events that make antags, such as xenoes or traitors

	var/minor_points = 0				//amount of minor points we currently have
	var/medium_points = 0				//amount of medium points we currently have
	var/major_points = 0				//amount of major points we currently have
	var/antag_points = 0				//amount of antag points we currently have

	var/minor_point_requirement = 0		//amount of minor points needed to trigger a minor event
	var/medium_point_requirement = 0	//amount of medium points needed to trigger a medium event
	var/major_point_requirement = 0		//amount of major points needed to trigger a major event
	var/antag_point_requirement = 0		//amount of antag points needed to trigger an antag event

	var/list/wizard_events = list()		//list of wizard events, if summon events is triggered they'll get dissipated into the other 4 lists


/datum/game_mode/storyteller/pre_setup()//where we setup the storyteller and choose our first antags
	for(var/S in subtypesof(/datum/storyteller))
		var/datum/storyteller/T = new S()
		storytellers[T] = T.probability

	storyteller = pickweight(storytellers)

	SSevents.scheduled = INFINITY //stops SSevents from running any events on its own

	for(var/datum/round_event_control/event in SSevents.control)
		if(event.wizardevent)
			wizard_events += event
			continue

		switch(event.storyteller_type)
			if(EVENT_TYPE_MINOR)
				minor_events += event
			if(EVENT_TYPE_MEDIUM)
				medium_events += event
			if(EVENT_TYPE_MAJOR)
				major_events += event
			if(EVENT_TYPE_ANTAG)
				antag_events += event