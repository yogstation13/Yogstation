/datum/map_template/holodeck
	should_place_on_top = FALSE
	returns_created_atoms = TRUE
	keep_cached_map = TRUE

	var/template_id
	var/description
	var/datum/parsed_map/lastparsed

	///Boolean if the holodeck is restricted to only being ran when emagged.
	var/restricted = NONE
	///The minimum security level required for the program to be ran.
	var/minimum_sec_level = SEC_LEVEL_GREEN

/datum/map_template/holodeck/offline
	name = "Holodeck - Offline"
	template_id = "holodeck_offline"
	description = "benis"
	mappath = "_maps/templates/holodeck/holodeck_offline.dmm"

/datum/map_template/holodeck/emptycourt
	name = "Holodeck - Empty Court"
	template_id = "holodeck_emptycourt"
	description = "benis"
	mappath = "_maps/templates/holodeck/holodeck_emptycourt.dmm"

/datum/map_template/holodeck/dodgeball
	name = "Holodeck - Dodgeball Court"
	template_id = "holodeck_dodgeball"
	description = "benis"
	mappath = "_maps/templates/holodeck/holodeck_dodgeball.dmm"

/datum/map_template/holodeck/basketball
	name = "Holodeck - Basketball Court"
	template_id = "holodeck_basketball"
	description = "benis"
	mappath = "_maps/templates/holodeck/holodeck_basketball.dmm"

/datum/map_template/holodeck/thunderdome
	name = "Holodeck - Thunderdome Arena"
	template_id = "holodeck_thunderdome"
	description = "benis"
	mappath = "_maps/templates/holodeck/holodeck_thunderdome.dmm"

/datum/map_template/holodeck/beach
	name = "Holodeck - Beach"
	template_id = "holodeck_beach"
	description = "benis"
	mappath = "_maps/templates/holodeck/holodeck_beach.dmm"

/datum/map_template/holodeck/lounge
	name = "Holodeck - Lounge"
	template_id = "holodeck_lounge"
	description = "benis"
	mappath = "_maps/templates/holodeck/holodeck_lounge.dmm"

/datum/map_template/holodeck/petpark
	name = "Holodeck - Pet Park"
	template_id = "holodeck_petpark"
	description = "benis"
	mappath = "_maps/templates/holodeck/holodeck_petpark.dmm"

/datum/map_template/holodeck/firingrange
	name = "Holodeck - Firing Range"
	template_id = "holodeck_firingrange"
	description = "benis"
	mappath = "_maps/templates/holodeck/holodeck_firingrange.dmm"

/datum/map_template/holodeck/anime_school
	name = "Holodeck - Anime School"
	template_id = "holodeck_animeschool"
	description = "benis"
	mappath = "_maps/templates/holodeck/holodeck_animeschool.dmm"

/datum/map_template/holodeck/chapelcourt
	name = "Holodeck - Chapel Courtroom"
	template_id = "holodeck_chapelcourt"
	description = "benis"
	mappath = "_maps/templates/holodeck/holodeck_chapelcourt.dmm"

/datum/map_template/holodeck/spacechess
	name = "Holodeck - Space Chess"
	template_id = "holodeck_spacechess"
	description = "benis"
	mappath = "_maps/templates/holodeck/holodeck_spacechess.dmm"

/*
/datum/map_template/holodeck/spacecheckers
	name = "Holodeck - Space Checkers"
	template_id = "holodeck_spacecheckers"
	description = "benis"
	mappath = "_maps/templates/holodeck/holodeck_spacecheckers.dmm"
*/

/*
/datum/map_template/holodeck/kobayashi
	name = "Holodeck - Kobayashi Maru"
	template_id = "holodeck_kobayashi"
	description = "benis"
	mappath = "_maps/templates/holodeck/holodeck_kobayashi.dmm"
*/

/datum/map_template/holodeck/winterwonderland
	name = "Holodeck - Winter Wonderland"
	template_id = "holodeck_winterwonderland"
	description = "benis"
	mappath = "_maps/templates/holodeck/holodeck_winterwonderland.dmm"

/*
/datum/map_template/holodeck/photobooth
	name = "Holodeck - Photobooth"
	template_id = "holodeck_photobooth"
	description = "benis"
	mappath = "_maps/templates/holodeck/holodeck_photobooth.dmm"
*/

/*
/datum/map_template/holodeck/skatepark
	name = "Holodeck - Skatepark"
	template_id = "holodeck_skatepark"
	description = "benis"
	mappath = "_maps/templates/holodeck/holodeck_skatepark.dmm"
*/

/*
/datum/map_template/holodeck/microwave
	name = "Holodeck - Microwave Paradise"
	template_id = "holodeck_microwave"
	description = "benis"
	mappath = "_maps/templates/holodeck/holodeck_microwave.dmm"
/*

*/
/datum/map_template/holodeck/baseball
	name = "Holodeck - Baseball Field"
	template_id = "holodeck_baseball"
	description = "benis"
	mappath = "_maps/templates/holodeck/holodeck_baseball.dmm"
/*

*/
/datum/map_template/holodeck/card_battle
	name = "Holodeck - TGC Battle Arena"
	template_id = "holodeck_card_battle"
	description = "An arena for playing Tactical Game Cards."
	mappath = "_maps/templates/holodeck/holodeck_card_battle.dmm"
*/

//bad evil no good programs

/datum/map_template/holodeck/medicalsim
	name = "Holodeck - Emergency Medical"
	template_id = "holodeck_medicalsim"
	description = "benis"
	mappath = "_maps/templates/holodeck/holodeck_medicalsim.dmm"
//	restricted = TRUE //yogs edit: Medical is not restricted, we instead require red-alert.
	minimum_sec_level = SEC_LEVEL_RED

/datum/map_template/holodeck/thunderdome1218
	name = "Holodeck - 1218 AD"
	template_id = "holodeck_thunderdome1218"
	description = "benis"
	mappath = "_maps/templates/holodeck/holodeck_thunderdome1218.dmm"
	restricted = TRUE

/* //disabled because the lava immediately destroys the holodeck
/datum/map_template/holodeck/burntest
	name = "Holodeck - Atmospheric Burn Test"
	template_id = "holodeck_burntest"
	description = "benis"
	mappath = "_maps/templates/holodeck/holodeck_burntest.dmm"
	restricted = TRUE
*/

/datum/map_template/holodeck/wildlifesim
	name = "Holodeck - Wildlife Simulation"
	template_id = "holodeck_wildlifesim"
	description = "benis"
	mappath = "_maps/templates/holodeck/holodeck_wildlifesim.dmm"
	restricted = TRUE

/datum/map_template/holodeck/holdoutbunker
	name = "Holodeck - Holdout Bunker"
	template_id = "holodeck_holdoutbunker"
	description = "benis"
	mappath = "_maps/templates/holodeck/holodeck_holdoutbunker.dmm"
	restricted = TRUE

/datum/map_template/holodeck/anthophillia
	name = "Holodeck - Anthophillia"
	template_id = "holodeck_anthophillia"
	description = "benis"
	mappath = "_maps/templates/holodeck/holodeck_anthophillia.dmm"
	restricted = TRUE

/datum/map_template/holodeck/refuelingstation
	name = "Holodeck - Refueling Station"
	template_id = "holodeck_refuelingstation"
	description = "benis"
	mappath = "_maps/templates/holodeck/holodeck_refuelingstation.dmm"
	restricted = TRUE
