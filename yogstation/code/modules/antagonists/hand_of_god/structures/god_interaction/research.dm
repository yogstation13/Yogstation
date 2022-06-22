/datum/hog_god_interaction/structure/research
	name = "research"
	description = "🤓"
	cost = 115
	var/datum/hog_research_entry/research = /datum/hog_research_entry
	var/time_to_make = 1 SECONDS

/datum/hog_god_interaction/structure/research/New()
	. = ..()
	description = "[description] It will take [time_to_make / 10] seconds be finished."

/datum/hog_god_interaction/structure/research/on_use(var/mob/camera/hog_god/user)
	if(!owner)
		return
	if(!user.cult)
		return
	for(var/datum/hog_research_entry/project in user.cult.research_projects)
		if(istype(project, research))
			to_chat(user,span_warning("This research is alredy in process!"))
			return
	var/datum/hog_research_entry/new_proj = new research
	var/yes = FALSE
	for(var/datum/hog_research/R in cult.upgrades)
		if(istype(new_proj.upgrade, R))
			if(R.levels >= R.max_level)
				to_chat(user,span_warning("This research alredy is on the max level!"))
				qdel(new_proj)
				return
			yes = TRUE
	if(!yes)
		to_chat(user,span_warning("You can't research this for some reason..."))
	new_proj.lab = owner
	user.cult.research_projects += new_proj
	new_proj.when_finished = world.time + time_to_make
	if(!user.cult.researching)
		user.cult.start_researching()

	. = ..()

/datum/hog_research_entry
	var/datum/hog_research/upgrade =  /datum/hog_research
	var/obj/structure/destructible/hog_structure/lab 
	var/when_finished
	var/name = "big chungus"

/datum/hog_god_interaction/structure/research
	name = "Research Advanced Weaponry"
	description = "Increases damage, dealed by meele cult weapons."
	cost = 225
	time_to_make = 120 SECONDS
	research = /datum/hog_research_entry/adv_weapons

/datum/hog_research_entry/adv_weapons
	name = "Advanced Weaponry"
	upgrade = /datum/hog_research/advanced_weaponry


	
