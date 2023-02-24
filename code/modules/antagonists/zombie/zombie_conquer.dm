#define MUTATION_TIER_0 0
#define MUTATION_TIER_1 2 
#define MUTATION_TIER_2 4 //currently unimplemented
#define MUTATION_TIER_3 8

/datum/antagonist/zombie
	name = "Zombie"
	roundend_category = "zombies"
	antagpanel_category = "Zombie"

	var/datum/action/innate/zombie/zomb/zombify = new

	var/datum/action/innate/zombie/talk/talk_action = new

	var/datum/action/innate/zombie/menu/ui_interact = new

	//EVOLUTION
	var/evolutionTime = 0 //When can we evolve?

	//GENERAL ABILITIES
	var/datum/action/innate/zombie/uncuff/uncuff = new

	job_rank = ROLE_ZOMBIE

	var/datum/team/zombie/team
	var/hud_type = "zombie"

	var/class_chosen = null //class chosen on first evolve
	var/class_chosen_2 = null //class chosen on second evolve, currently unused

	var/zombified = FALSE //if have become a zombie or not

	var/mutation_rate = 0 //progress to new evolution

	var/mutation_points = 0 //points to buy new abilities and upgrades

	var/infection = 100 //points used on abilities

	var/infection_max = 100 //max you can have of infection

	var/current_tier = MUTATION_TIER_0 //current mutation tier (based on evolve)

	var/list/zombie_abilities = list() //abilities
	var/list/zombie_mutations = list() //upgrades

/datum/antagonist/zombie/special
	name = "Special Zombie"

/datum/antagonist/zombie/create_team(datum/team/zombie/new_team)
	if(!new_team)
		for(var/HU in GLOB.zombies)
			var/datum/antagonist/zombie/H = HU
			if(!H.owner)
				continue
			if(H.team)
				team = H.team
				return
		team = new /datum/team/zombie
		team.setup_objectives()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	team = new_team

/datum/antagonist/zombie/proc/add_objectives()
	objectives |= team.objectives

/datum/antagonist/zombie/Destroy()
	QDEL_NULL(zombify)
	return ..()

/datum/antagonist/zombie/greet()
	to_chat(owner.current, "<B><font size=3 color=red>You have infected a suitlabe host! In 10 minutes you will be able to transform [owner.current.p_them()] into a potent zombie.</font><B>")
	to_chat(owner.current, "<b>Use the button at the top of the screen (When it appears) to activate the infection. It will kill you, but you will rise as a zombie shortly after!<b>") //Yogs
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ling_aler.ogg', 100, FALSE, pressure_affected = FALSE)//subject to change
	owner.announce_objectives()

/datum/antagonist/zombie/on_gain()
	. = ..()
	var/mob/living/current = owner.current
	add_objectives()
	GLOB.zombies += owner

	current.log_message("has been made a zombie!", LOG_ATTACK, color="#960000")

	var/datum/atom_hud/antag/zombie_hud = GLOB.huds[ANTAG_HUD_ZOMBIE]
	zombie_hud.join_hud(current)
	set_antag_hud(current, hud_type)
	owner.current.hud_used.infection_display.invisibility = 0
	update_infection_hud()

/datum/antagonist/zombie/on_removal()
	GLOB.zombies -= owner

	var/datum/atom_hud/antag/zombie_hud = GLOB.huds[ANTAG_HUD_ZOMBIE]
	zombie_hud.leave_hud(owner.current)
	set_antag_hud(owner.current, null)
	owner.current.hud_used.infection_display.invisibility = initial(owner.current.hud_used.infection_display.invisibility)
	owner.current.hud_used.infection_display.maptext = ""
	. = ..()

/datum/antagonist/zombie/apply_innate_effects()
	. = ..()
	var/mob/living/current = owner.current
	current.faction |= "zombies"
	ui_interact.Grant(current)
	talk_action.Grant(current)

/datum/antagonist/zombie/remove_innate_effects()
	. = ..()
	var/mob/living/current = owner.current
	current.faction -= "zombies"
	ui_interact.Remove(current)
	talk_action.Remove(current)

/*
* from yogstation\code\modules\antagonists\darkspawn\darkspawn.dm
*/
/datum/antagonist/zombie/proc/has_mutation(id)
	return zombie_mutations[id]

/datum/antagonist/zombie/proc/add_mutation(id, silent, no_cost)
	if(has_mutation(id))
		return
	for(var/datum/zombie_mutation/mutation_data as anything in subtypesof(/datum/zombie_mutation))
		if(initial(mutation_data.id) == id)
			var/datum/zombie_mutation/mutation = new mutation_data(src)
			zombie_mutations[id] = TRUE
			if(!silent)
				to_chat(owner.current, span_notice("You have adapted \"[mutation.name]\"."))
			if(!no_cost)
				mutation_points = max(0, mutation_points - initial(mutation.mutation_cost))
			mutation.on_purchase()

/*
* + for spending, - for gaining
*/
/datum/antagonist/zombie/proc/manage_infection(amt)
	if(infection < amt)
		return FALSE
	infection -= amt
	update_infection_hud()
	return TRUE

/datum/antagonist/zombie/proc/manage_mutation(amt)
	if(mutation_points < amt)
		return FALSE
	mutation_points -= amt
	return TRUE

/datum/antagonist/zombie/proc/advance_progress()
	mutation_rate++
	switch(mutation_rate)
		if(MUTATION_TIER_1)
			var/datum/action/innate/zombie/choose_class/evolution = new
			evolution.Grant(owner.current)

/datum/antagonist/zombie/proc/advance_mutation_tier()
	var/new_tier
	switch(current_tier)
		if(MUTATION_TIER_0)
			new_tier = MUTATION_TIER_1
		if(MUTATION_TIER_1)
			new_tier = MUTATION_TIER_2
		if(MUTATION_TIER_2)
			new_tier = MUTATION_TIER_3
		if(MUTATION_TIER_3)
			return
	current_tier = new_tier
	

/datum/antagonist/zombie/proc/update_infection_hud()
	var/atom/movable/screen/counter = owner?.current?.hud_used?.infection_display
	if(!counter)
		return
	if(class_chosen)
		counter.add_overlay("overlay_[class_chosen]")
	counter.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:7px'><font color='#E6E6C6'>[round(infection, 1)]</font></div>"

/datum/antagonist/zombie/ui_state(mob/user)
	return GLOB.always_state

/datum/antagonist/zombie/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "EvolutionMenu", "Host Genetic Management")
		ui.open()

/datum/antagonist/zombie/ui_data(mob/user)
	var/list/data = list()
	var/list/abilities = list()
	var/list/mutations = list()
	var/mob/living/carbon/human/H = user
	data["name"] = user.real_name
	data["mutation_rate"] = mutation_rate
	data["mutation_points"] = mutation_points
	data["current_status"] = user.stat
	data["current_host"] = ishuman(user) ? H.dna.species : user.type
	data["class"] = class_chosen

	for(var/datum/action/innate/zombie/ability_raw as anything in subtypesof(/datum/action/innate/zombie) - /datum/action/innate/zombie/default) //exclude these, get the subtypes
		if(!locate(ability_raw) in zombie_abilities)
			continue
		if(!length(initial(ability_raw.name)) || !length(initial(ability_raw.desc)))
			continue
		var/list/ability_processed = list()
		ability_processed["type"] = initial(ability_raw.ability_type)
		ability_processed["name"] = initial(ability_raw.name)
		ability_processed["desc"] = initial(ability_raw.desc)
		ability_processed["is_default"] = istype(ability_raw, /datum/action/innate/zombie/default)
		var/datum/action/innate/zombie/default/default_ability_raw = ability_raw
		ability_processed["cost"] = istype(ability_raw, /datum/action/innate/zombie/default) ? "Cost: [initial(default_ability_raw.cost)]" : ""
		ability_processed["constant_cost"] = istype(ability_raw, /datum/action/innate/zombie/default) ? "Constant Cost: [initial(default_ability_raw.constant_cost)]" : ""

		abilities += list(ability_processed)
	data["abilities"] += abilities

	for(var/datum/zombie_mutation/mutation_raw as anything in subtypesof(/datum/zombie_mutation)) //exclude this, get the subtypes
		if(initial(mutation_raw.sector) != SECTOR_COMMON)
			switch(class_chosen)
				if(null)
					continue
				if(SMOKER)
					if(!(initial(mutation_raw.owner_class) & SMOKER_BITFLAG))
						continue
				if(RUNNER)
					if(!(initial(mutation_raw.owner_class) & RUNNER_BITFLAG))
						continue
				if(SPITTER)
					if(!(initial(mutation_raw.owner_class) & SPITTER_BITFLAG))
						continue
				if(JUGGERNAUT)
					if(!(initial(mutation_raw.owner_class) & JUGGERNAUT_BITFLAG))
						continue
				if(BRAINY)	
					if(!(initial(mutation_raw.owner_class) & BRAINY_BITFLAG))
						continue
		var/list/mutation_processed = list()
		mutation_processed["name"] = initial(mutation_raw.name)
		mutation_processed["id"] = initial(mutation_raw.id)
		mutation_processed["desc"] = initial(mutation_raw.desc)
		mutation_processed["sector"] = initial(mutation_raw.sector)
		mutation_processed["mutation_cost"] = initial(mutation_raw.mutation_cost)
		mutation_processed["owned"] = zombie_mutations[initial(mutation_raw.id)]
		mutation_processed["can_purchase"] = !mutation_processed["owned"] && mutation_points >= initial(mutation_raw.mutation_cost)

		mutations += list(mutation_processed)

	data["mutations"] += mutations

	/////////////////////////////////////////
	/////       Write Your Lore/        /////
	/////       Info Here Section       /////
	/////////////////////////////////////////

	data["info_gameplay"] = "As a frail piece of a [LAZYLEN(team.members) > 1 ? "fractured" : "former"] eldritch horror,\n\
				you cannot fully control your targets without damaging their brains nor suck their souls.\n\
				As a means to fully rebuild yourself you have decided to extract DNA from the cognizant beings resided on the station,\n\
				using your adaptative form to produce spores to help you on your harvest.\n\
				* Your objective as a zombie is to infect as many people as possible, using Alt-click to slowly infect an alive person, and rapidly infect a crit/sleep or dead one.\n\
				* In the top right you are able to use your communicate ability to talk with your fellow monsters to coordinate hatching spots and possible class combinations.\n\
				* After zombifying, you'll be equipped with the evolution button, which lets you choose beetween 5 classes, all focused on one type of playstyle.\n\
				* These classes grant you different passives, unlocks new abilities to mutate and perks to your claws that can be explained further by examining them."
	data["info_abilities"] = ""
	return data

/datum/antagonist/zombie/ui_act(action, params)
	if(..())
		return
	if(action == "upgrade")
		add_mutation(params["id"])

/datum/antagonist/zombie/proc/start_timer()
	addtimer(CALLBACK(src, .proc/add_button_timed), 10 MINUTES)

/datum/antagonist/zombie/proc/add_button_timed()
	if(zombified)
		return	
	zombify.Grant(owner.current)
	to_chat(owner.current, span_userdanger("<b>You can now turn into a zombie! The ability INSTANTLY kills you, and starts the process of turning into a zombie. IN 5 MINUTES YOU WILL FORCIBLY BE ZOMBIFIED IF YOU HAVEN'T.<b>"))
	addtimer(CALLBACK(src, .proc/force_zombify), 5 MINUTES)

/datum/antagonist/zombie/proc/force_zombify()
	if(!zombified)
		zombify.Activate()

/datum/antagonist/zombie/admin_add(datum/mind/new_owner, mob/admin)
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has zombied'ed [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has zombied'ed [key_name(new_owner)].")
	start_timer()


/datum/antagonist/zombie/get_admin_commands()
	. = ..()
	.["Give Transform Button"] = CALLBACK(src, .proc/admin_give_button)
	.["Remove Transform Button"] = CALLBACK(src, .proc/remove_button)
	.["Give Mutation Points"] = CALLBACK(src, .proc/manage_mutation, -1)
	.["Advance Mutation Progress"] = CALLBACK(src, .proc/advance_progress)

/datum/antagonist/zombie/proc/admin_give_button(mob/admin)
	zombify.Grant(owner.current)

/datum/antagonist/zombie/proc/remove_button(mob/admin)
	zombify.Remove(owner.current)

/datum/antagonist/zombie/get_preview_icon()
	var/mob/living/carbon/human/dummy/consistent/zombiedummy = new

	zombiedummy.set_species(/datum/species/zombie)

	var/icon/zombie_icon = render_preview_outfit(null, zombiedummy)

	qdel(zombiedummy)

	return finish_preview_icon(zombie_icon)

/datum/team/zombie
	name = "Zombies"

/datum/team/zombie/proc/setup_objectives()

	var/datum/objective/custom/obj = new()
	obj.name = "Escape on the shuttle, while gathering as many infected as possible!"
	obj.explanation_text = "Escape on the shuttle, while gathering as many infected as possible!"
	obj.completed = TRUE
	objectives += obj


/datum/team/zombie/proc/zombies_on_shuttle()
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(IS_INFECTED(H) && (H.onCentCom() || H.onSyndieBase()))
			return TRUE
	return FALSE

/datum/team/zombie/roundend_report()
	var/list/parts = list()
	if(zombies_on_shuttle())
		parts += "<span class='greentext big'>BRAINS! The zombies have made it to CentCom!</span>"
	else
		parts += "<span class='redtext big'>Target destroyed. The crew has stopped the zombies!</span>"


	if(members.len)
		parts += span_header("The zombies were:")
		parts += printplayerlist(members)

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

#undef MUTATION_TIER_0
#undef MUTATION_TIER_1
#undef MUTATION_TIER_2
#undef MUTATION_TIER_3
