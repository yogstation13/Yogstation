/datum/team/hog_cult
	name = "HoG Cult"
	member_name = "Cultist"
	var/mob/camera/hog_god/god
	var/energy = 0 
	var/max_energy = 0
	var/permanent_regen = 20 // 20 per 2 seconds seems ok
	var/nexus 
	var/state = HOG_TEAM_EXISTING
	var/cult_color = "black" 
	var/dudes_amount = 0
	var/hud_entry_num
	var/income_interval = 2 SECONDS

/datum/team/hog_cult/New(starting_members)
	. = ..()
	GLOB.hog_cults += src
	addtimer(CALLBACK(src, .proc/here_comes_the_money), income_interval)
	
/datum/team/hog_cult/proc/here_comes_the_money()
	energy += permanent_regen
	addtimer(CALLBACK(src, .proc/here_comes_the_money), income_interval)	


	
