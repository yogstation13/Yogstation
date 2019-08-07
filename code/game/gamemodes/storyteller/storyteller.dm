

/* Nich's Grand TODO List:
	1. Categorize all the random events into the 4 different categories
	3. Make more antag events, basically one for every type of antag
	2. Either make a 5th category for wizard events or make the summon wizard events spell just stuff em in the other 4
	3. Add a random antag pick to roundstart, basically just picking one of the antag events
	4. Add ways for the station to impact point generation (not directly, but things like antags dieing raising it, crewmembers dying lowering it)
	5. Add the actual structure for the game_mode to run events, including game mode specific can_trigger procs for most of them, so we check whether there's an AI before we make it malf
	6. Figure out what the hell I'm gonna do regarding antag rep in this gamemode, probably gonna completely disregard it
	7. Overhaul uplink code so it's no longer restricted on a gamemode basis, but on an antag_datum basis
	8. Figure out whether I'm gonna completely forget that hivemind/overthrow exists for this gamemode
	9. Should I end the round if revs are successfull, or do I just let the station exist in a post-revolutionary world? o7
	10. Maybe block conversion antags like revs and cultists from converting each other so you have both antag datums (deconversion sigil? make revflash deconvert on first use?)
	Could also just make it so that antags like revs and cultists stop other antags from happening while they're running, and then they all deconvert once they win?
	11. Make events that are all anti-loyalty-implant (revs, gangs) mutually exclusive, so you don't get a rev event immediately after the gangs lose because everyone was converted
	12. Probably gonna have to gimp a few of the gamemodes (gangs and cultists in particular) so they aren't too strong considering there'll be more than one antag group (guess I can use winrates)
	13. Make a gimped version of old clock cult for this gamemode (was tempted to have new on roundstart, old as a mid-round thing, but new clock-cult kinda messes up the flow
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


/datum/game_mode/storyteller/pre_setup()//where we setup the storyteller and choose our first antags
	for(var/S in subtypesof(/datum/storyteller))
		var/datum/storyteller/T = new S()
		storytellers[T] = T.probability

	storyteller = pickweight(storytellers)

	SSevents.scheduled = INFINITY //stops SSevents from running any events on its own