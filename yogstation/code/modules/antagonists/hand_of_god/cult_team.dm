/datum/team/hog_cult
	name = "HoG Cult"
	member_name = "Cultist"
	var/mob/camera/hog_god/god
	var/energy = 0 
	var/max_energy = 0
	var/permanent_regen = 20 // 20 per 2 seconds seems ok
	var/energy_regen = 0
	var/obj/structure/destructible/hog_structure/lance/nexus/nexus 
	var/state = HOG_TEAM_EXISTING
	var/cult_color = "black" 
	var/dudes_amount = 0
	var/hud_entry_num
	var/income_interval = 2 SECONDS
	var/list/objects = list()
	var/recalls = 1
	var/list/research_projects = list()
	var/upgrades = list(/datum/hog_research/advanced_weaponry)
	var/researching = FALSE
	var/conversion_cost = 100
	var/souls = 0
	var/sacrificed_people = 0
	var/can_ascend = FALSE

/datum/team/hog_cult/New(starting_members)
	. = ..()
	GLOB.hog_cults += src
	addtimer(CALLBACK(src, .proc/here_comes_the_money), income_interval)
	for(var/datum/hog_research/R in upgrades)
		R = new
		R.cult = src
	
/datum/team/hog_cult/proc/here_comes_the_money()
	var/income = permanent_regen
	income = += energy_regen
	for(var/obj/structure/destructible/hog_structure/shrine/shrine in objects)
		if(!shrine)
			continue
		if(shrine.cult != src)
			continue
		income += shrine.energy_generation		
	change_energy_amount(income)
	addtimer(CALLBACK(src, .proc/here_comes_the_money), income_interval)	

/datum/team/hog_cult/proc/message_all_dudes(var/message, var/ghosts = FALSE)
	for(var/mob/M in GLOB.mob_list)
		if(!M.mind)
			continue
		if(isobserver(M) && ghosts)
			to_chat(M, "[message]")
		if(M.mind in members)
			var/datum/antagonist/hog/cultie = IS_HOG_CULTIST(M)
			if(cultie && (cultie.cult = src))
				to_chat(M, "[message]")

/datum/team/hog_cult/proc/change_energy_amount(var/amount)
	energy += amount
	if(energy < 0)
		energy = 0
	if(energy > max_energy)
		energy = max_energy

/datum/team/hog_cult/proc/start_researching()
	researching = TRUE
	addtimer(CALLBACK(src, .proc/process_research), 1 SECONDS)

/datum/team/hog_cult/proc/process_research()
	for(var/datum/hog_research_entry/project in research_projects)
		if(!project.lab)
			to_chat(god,span_warning("The researching of [project], has been interupted, due to destruction of researching building!"))
			qdel(project)
		if(world.time <= project.when_finished)
			finish_research(project)
	if(!research_projects.len)
		researching = FALSE
		return
	addtimer(CALLBACK(src, .proc/process_research), 1 SECONDS)

/datum/team/hog_cult/proc/finish_research(var/datum/hog_research_entry/research)
	for(var/datum/hog_research/upgrade in upgrades)	
		if(istype(research.upgrade, upgrade))
			if(upgrade.levels < upgrade.max_level)
				upgrade.levels += 1
				upgrade.on_researched()
				break
	to_chat(god,span_warning("The [research.name] upgrade has been researched!"))
	research_projects -= research
	qdel(research)

/datum/hog_research
	var/levels = 0
	var/max_level = 3
	var/list/affected_objects = list()
	var/datum/team/hog_cult/cult

/datum/hog_research/proc/on_researched()
	for(var/obj/O in cult.objects)
		for(var/obj/E in affected_objects)  ///E
			if(istype(O, E))
				apply_research_effects(O)

/datum/hog_research/proc/apply_research_effects(var/obj/O)	
	var/obj/item/hog_item/upgradeable/item = O
	if(!item)
		return
	if(item.cult != cult)
		return
	item.upgrades += 1
	item.force = initial(item.force) += (item.upgrades * item.force_add)
	item.throwforce = initial(item.throwforce) += (item.upgrades * item.throwforce_add)
	item.max_integrity = initial(item.max_integrity) + (item.integrity_add * item.upgrades)
	item.obj_integrity += item.integrity_add * item.upgrades
	item.armor = list(MELEE = 30 + (item.armor_add * item.upgrades), BULLET = 40 + (item.armor_add * item.upgrades), LASER = 20 + (item.armor_add * item.upgrades), ENERGY = 20 + (item.armor_add * item.upgrades), BOMB = 10 + (item.armor_add * item.upgrades), BIO = 0, RAD = 0, FIRE = 100, ACID = 70)

/datum/hog_research/advanced_weaponry
	affected_objects = list(/obj/item/hog_item/upgradeable/sword)

/datum/hog_research/protection
	affected_objects = list(/obj/item/hog_item/upgradeable/shield)
