/datum/antagonist/hog/god
	name = "God"   
	roundend_category = "HoG Cultists"
	antagpanel_category = "HoG Cult"
	god_actions = FALSE
	antag_moodlet = /datum/mood_event/hog_god
	is_god = TRUE

/datum/antagonist/hog/god/greet()
	to_chat(owner, span_cultlarge("You are a HoG god!"))
	to_chat(owner, span_cult("You mission is to break free, and to do this you need to activate your nexus and protect it untill it is ready. \
							  But to be able to do this, you need to place your nexus, and complete your cult objective. If your nexus dies, you die. \
							  You can interact with your structures and servants by clicking on them, and you can construct buildings by Ctrl+clicking \
							  floors of your cult color. You are also able to freely move around the station and speak to your servants. You and your \
							  servants need energy to do most of the things they can do, and energy is gained passively over time, and more energy can \
							  be gained by sacrificing people, or building shrines. Also you have some fun interactions with lightbulbs and APCs. \
							  And beware station security and heretical cults, all of them are not to be trusted and are hostile towards you and your cult."))

/datum/antagonist/hog/god/farewell()
	to_chat(owner, span_cultlarge("You are no longer a god. This is strange, and possibly is a bug. Report to github if this happened to you."))

/datum/antagonist/hog/god/equip_cultist()
	return //Gods don't get things. 
