/datum/hog_god_interaction/structure/research
	name = "research"
	description = "🤓"
	cost = 115
	cooldown = 20 SECONDS
	var/datum/hog_research/research = /datum/hog_research

/datum/hog_god_interaction/structure/research/on_use(var/mob/camera/hog_god/user)
	if(!owner)
		return
	if(!user.cult)
		return
	for(var/datum/hog_research_entry/project in user.cult.research_projects)
		if(istype(project, research))
			to_chat(user,span_warning("This reseacrh is alredy in process!"))
			return

	var/datum/hog_research/new_proj = new research
	user.cult.research_projects += new_proj
	new_proj.when_finished = world.time + time_to_make
	new_proj.lab = owner
	if(!cult.researching)
		cult.start_researching()

	. = ..()

/datum/hog_research_entry
	var/name = "big"
	var/description = "chungus"
	var/time_to_make = 1 SECONDS
	var/datum/hog_research =  /datum/hog_research
	var/obj/structure/destructible/hog_structure/lab 
	var/when_finished

	
