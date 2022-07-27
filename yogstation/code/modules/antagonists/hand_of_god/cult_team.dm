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
	var/upgrades = list(/datum/hog_research/advanced_weaponry, /datum/hog_research/protection)
	var/researching = FALSE
	var/conversion_cost = 100
	var/souls = 0
	var/sacrificed_people = 0
	var/can_ascend = FALSE
	var/datum/hog_objective/cult_objective
	var/list/possible_buildings = list()
	var/summoned_but_died = FALSE

/datum/team/hog_cult/New(starting_members)
	. = ..()
	GLOB.hog_cults += src
	addtimer(CALLBACK(src, .proc/here_comes_the_money), income_interval)
	addtimer(CALLBACK(src, .proc/mission_has_started), 1 MINUTES)
	for(var/datum/hog_research/R in upgrades)
		R = new
		R.cult = src
	for(var/datum/hog_god_interaction/targeted/construction/buildin in typesof(/datum/hog_god_interaction/targeted/construction))
		buildin = new
		src.possible_buildings += buildin
	
/datum/team/hog_cult/proc/here_comes_the_money()
	if(state == HOG_TEAM_DEAD)
		return
	var/income = permanent_regen
	income += energy_regen
	for(var/obj/structure/destructible/hog_structure/shrine/shrine in objects)
		if(shrine?.cult != src)
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
	if(state == HOG_TEAM_DEAD)
		return
	researching = TRUE
	addtimer(CALLBACK(src, .proc/process_research), 1 SECONDS)

/datum/team/hog_cult/proc/process_research()
	if(state == HOG_TEAM_DEAD)
		return
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

/datum/team/hog_cult/proc/die()
	if(state == HOG_TEAM_DEAD)//Already dead
		return 
	state = HOG_TEAM_DEAD
	message_all_dudes("The [name] has been destroyed! Any remaining members are now free from it's influence!", TRUE)
	for(var/datum/mind/M in members)
		var/datum/antagonist/hog/cultie = M.has_antag_datum(/datum/antagonist/hog)
		M.remove_antag_datum(cultie)
	if(god)
		qdel(god)
	if(nexus)
		qdel(nexus)
	for(var/obj/O in objects)
		if(istype(/obj/structure/destructible/hog_structure))
			var/obj/structure/destructible/hog_structure/S = O
			S.handle_team_change(null)
		else if(istype(/obj/item/hog_item))
			var/obj/item/hog_item/I = O
			I.handle_owner_change(null)
		else 
			SEND_SIGNAL(src, COMSIG_HOG_ACT, null)

/datum/team/hog_cult/roundend_report()
	if(!show_roundend_report)
		return

	var/list/report = list()

	report += span_header("[name]:")
	report += "The [member_name]s were:"
	report += printplayerlist(members)

	switch(state)
		if(HOG_TEAM_EXISTING)
			var/escaped = FALSE
			var/datum/objective/cringeshit = new
			for(var/datum/mind/M in members)
				if(cringeshit.considered_escaped(M) || M.has_antag_datum(/datum/antagonist/hog))
					escaped = TRUE
					break
			qdel(cringeshit)
			if(escaped)
				("<span class='neutraltext big'>Neutral Victory</span>")
				report += ("<B>The [name] has failed to free it's god, but it's members had survive and escape on the shuttle.</B>")
			else
				report += ("<span class='redtext big'>Cult Minor Defeat</span>")
				report += ("<B>The [name] has failed to free it's god!</B>")
		if(HOG_TEAM_SUMMONING)
			report += ("<span class='neutraltext big'>Neutral Victory</span>")
			report += ("<B>The [name] had attempted to summon it's god, but didn't do it in time!</B>")
		if(HOG_TEAM_SUMMONED)
			report += ("<span class='greentext big'>Cult Major Victory</span>")
			report += ("<B>The [name] had summoned it's god!</B>")
		if(HOG_TEAM_DEAD)
			if(summoned_but_died)
				report += ("<span class='redtext big'>Cult Minor Defeat</span>")
				report += ("<B>The [name] had summoned it's god, but someone managed to kill it! Be more carefull next time!</B>")
			else
				report += ("<span class='redtext big'>Cult Major Defeat</span>")
				report += ("<B>The [name] was completely annihilated! What a shame!</B>")					

	return "<div class='panel redborder'>[report.Join("<br>")]</div>"

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
	if(istype(O, /obj/item/hog_item/upgradeable))
		var/obj/item/hog_item/upgradeable/item = O
		if(item?.cult != cult)
			return
		item.upgrades++
		item.force = initial(item.force) + (item.upgrades * item.force_add)
		item.throwforce = initial(item.throwforce) + (item.upgrades * item.throwforce_add)
		item.max_integrity = initial(item.max_integrity) + (item.integrity_add * item.upgrades)
		item.obj_integrity += item.integrity_add * item.upgrades
		item.armor = item.armor.setRating(
			melee = initial(item.armor.melee) + (item.armor_add * item.upgrades),
			bullet = initial(item.armor.bullet) + (item.armor_add * item.upgrades),
			laser = initial(item.armor.laser) + (item.armor_add * item.upgrades),
			energy = initial(item.armor.energy) + (item.armor_add * item.upgrades)
		)
	else
		apply_research_effects_special(O)	

/datum/hog_research/proc/apply_research_effects_special(var/obj/O)	
	return

/datum/hog_research/advanced_weaponry
	affected_objects = list(/obj/item/hog_item/upgradeable/sword)

/datum/hog_research/protection
	affected_objects = list(/obj/item/hog_item/upgradeable/shield, /obj/item/clothing/suit/hooded/hog_robe_mage, /obj/item/clothing/suit/hooded/hog_robe_warrior, /obj/item/clothing/head/hooded/hog_robe_warrior, /obj/item/clothing/head/hooded/hog_robe_mage)

/datum/hog_research/protection/apply_research_effects_special(var/obj/O)
	O.armor = O.armor.setRating(
		melee = initial(O.armor.melee) + (6 * levels),
		bullet = initial(O.armor.bullet) + (6 * levels),
		laser = initial(O.armor.laser) + (6 * levels),
		energy = initial(O.armor.energy) + (6 * levels)
	)	
