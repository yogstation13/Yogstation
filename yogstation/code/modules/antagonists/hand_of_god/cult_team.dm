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

/datum/team/hog_cult/proc/message_all_dudes(var/message, var/ghosts = FALSE)
	for(var/mob/M in GLOB.mob_list)
		if(isobserver(M) && ghosts)
			to_chat(M, "[message]")
		if(M in members)
			var/datum/antagonist/hog/cultie = IS_HOG_CULTIST(M)
			if(cultie && (cultie.cult = src))
				to_chat(M, "[message]")
	
