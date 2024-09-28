//this is stuff used by antags that's stored on the base gamemode datum
//rework those antags to not need these
/datum/game_mode
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

	// blood cult
	var/list/datum/mind/cult = list()
	var/list/bloodstone_list = list()
	var/anchor_bloodstone
	var/anchor_time2kill = 5 MINUTES
	var/bloodstone_cooldown = FALSE

	//clock cult
	var/list/servants_of_ratvar = list() //The Enlightened servants of Ratvar
	var/clockwork_explanation = "Defend the Ark of the Clockwork Justiciar and free Ratvar." //The description of the current objective

	// iaa
	var/list/target_list = list()
	var/list/late_joining_list = list()

	//vampire
	var/list/datum/mind/vampires = list()
