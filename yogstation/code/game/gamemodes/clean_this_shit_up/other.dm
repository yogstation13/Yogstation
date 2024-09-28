//this is stuff used by antags that's stored on the base gamemode datum
//rework those antags to not need these
/datum/controller/subsystem/gamemode
	var/has_hijackers = FALSE

	//traitor
	var/traitor_name = "traitor"
	var/list/datum/mind/traitors = list()

	var/datum/mind/exchange_red
	var/datum/mind/exchange_blue

	//blood brothers
	var/list/datum/mind/brothers = list()
	var/list/datum/team/brother_team/brother_teams = list()

	//wizards
	var/list/datum/mind/wizards = list()
	var/list/datum/mind/apprentices = list()


	// iaa
	var/list/target_list = list()
	var/list/late_joining_list = list()

	//vampire
	var/list/datum/mind/vampires = list()

	//devils
	var/list/datum/mind/devils = list()
	var/devil_ascended = 0 // Number of arch devils on station

	//nukies
	var/station_was_nuked = FALSE

	// rewrite this to be objective track stuff instead
	var/list/datum/station_goal/station_goals = list()
	
	/// Associative list of current players, in order: living players, living antagonists, dead players and observers.
	var/list/list/current_players = list(CURRENT_LIVING_PLAYERS = list(), CURRENT_LIVING_ANTAGS = list(), CURRENT_DEAD_PLAYERS = list(), CURRENT_OBSERVERS = list())

/datum/controller/subsystem/gamemode/proc/add_devil_objectives(datum/mind/devil_mind, quantity)
	var/list/validtypes = list(/datum/objective/devil/soulquantity, /datum/objective/devil/soulquality, /datum/objective/devil/sintouch, /datum/objective/devil/buy_target)
	var/datum/antagonist/devil/D = devil_mind.has_antag_datum(/datum/antagonist/devil)
	for(var/i = 1 to quantity)
		var/type = pick(validtypes)
		var/datum/objective/devil/objective = new type(null)
		objective.owner = devil_mind
		D.objectives += objective
		if(!istype(objective, /datum/objective/devil/buy_target))
			validtypes -= type //prevent duplicate objectives, EXCEPT for buy_target.
		else
			objective.find_target()


/// Used to remove antag status on borging for some gamemodes
/datum/controller/subsystem/gamemode/proc/remove_antag_for_borging(datum/mind/newborgie)
	SSgamemode.remove_cultist(newborgie, 0, 0)
	var/datum/antagonist/rev/rev = newborgie.has_antag_datum(/datum/antagonist/rev)
	if(rev)
		rev.remove_revolutionary(TRUE)
