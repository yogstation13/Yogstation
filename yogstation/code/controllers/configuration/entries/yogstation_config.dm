/datum/config_entry/flag/mentors_mobname_only


/datum/config_entry/flag/mentor_legacy_system	//Defines whether the server uses the legacy mentor system with mentors.txt or the SQL system
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/autopanicbunker // Defines whether the automatic panic bunker is activated when GLOB.player_list.len > CONFIG_GET(autopanic_players)

/datum/config_entry/number/autopanic_players // Ditto to autopanicbunker
	config_entry_value = 75
	min_val = 1
