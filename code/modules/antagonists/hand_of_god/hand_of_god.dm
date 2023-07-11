/*HOW THIS SHOULD WORK
the gamemode places hog cult role to player, 
pre-setup assigns players to either bloodcult or cockcult
bloodcult antag takes over the blood cultist
clockcult gets special attention as reebe should never be accessed on this gamemode.
configs are stolen from their respective gamemodes and modified
Clockcult config begins on line 50
Bloodcult config begins on line 311

*/
/datum/antagonist/hand_of_god
	name = "Hand of god Cultist"
	roundend_category = "if you see this there is a bug"
	antagpanel_category = "Hands of God"
	job_rank = ROLE_HOG_CULT
	antag_hud_name = "PLACEHOLDER"   //PLACEHOLDER!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	show_to_ghosts = TRUE
	antag_moodlet = /datum/mood_event/cult


/datum/antagonist/hand_of_god/hand_of_ratvar
	name = "Clock Cultist"
	roundend_category = "clock cultists"
	job_rank = ROLE_SERVANT_OF_RATVAR
	antag_hud_name = "clockwork"
	show_to_ghosts = TRUE
	var/datum/action/innate/hierophant/hierophant_network = new()
	var/datum/team/hand_of_god/hand_of_ratvar
	var/make_team = TRUE //This should be only false for tutorial scarabs

/datum/antagonist/hand_of_god/hand_of_narsie
	name = "Cultist"
	roundend_category = "cultists"
	var/datum/action/innate/cult/comm/communion = new
	var/datum/action/innate/cult/mastervote/vote = new
	var/datum/action/innate/cult/blood_magic/magic = new
	preview_outfit = /datum/outfit/cultist
	job_rank = ROLE_CULTIST
	antag_hud_name = "cult"
	var/ignore_implant = FALSE
	var/give_equipment = FALSE
	var/datum/team/hand_of_god/hand_of_narsie
	var/original_eye_color = "000" //this will store the eye color of the cultist so it can be returned if they get deconverted
	show_to_ghosts = TRUE










