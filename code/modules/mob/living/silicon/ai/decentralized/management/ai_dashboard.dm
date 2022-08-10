/datum/ai_dashboard
	var/mob/living/silicon/ai/owner

	var/available_projects

	//What we're currently using, not what we're being granted by the ai data core
	var/list/cpu_usage
	var/list/ram_usage 
	var/free_ram = 0

	var/completed_projects

	var/running_projects
	///Should we be contributing spare CPU to generate research points?
	var/contribute_spare_cpu = TRUE
	///Are we using 50% of our spare CPU to mine bitcoin?
	var/crypto_mining = FALSE

/datum/ai_dashboard/New(mob/living/silicon/ai/new_owner)
	if(!istype(new_owner))
		qdel(src)
	owner = new_owner
	available_projects = list()
	completed_projects = list()
	running_projects = list()
	cpu_usage = list()
	ram_usage = list()

	for(var/path in subtypesof(/datum/ai_project))
		available_projects += new path(owner, src)


/datum/ai_dashboard/proc/is_interactable(mob/user)
	if(user?.client?.holder)
		return TRUE
	if(user != owner || owner.incapacitated())
		return FALSE
	if(owner.control_disabled)
		to_chat(user, span_warning("Wireless control is disabled."))
		return FALSE
	return TRUE

/datum/ai_dashboard/ui_status(mob/user)
	if(is_interactable(user))
		return ..()
	return UI_CLOSE

/datum/ai_dashboard/ui_state(mob/user)
	return GLOB.always_state

/datum/ai_dashboard/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiDashboard")
		ui.open()

/datum/ai_dashboard/ui_data(mob/user)
	var/list/data = list()

	data["current_cpu"] = owner.ai_network.resources.cpu_assigned[owner] ? owner.ai_network.resources.cpu_assigned[owner] : 0
	data["current_ram"] = owner.ai_network.resources.ram_assigned[owner] ? owner.ai_network.resources.ram_assigned[owner] : 0
	data["current_ram"] += free_ram

	var/total_cpu_used = 0
	for(var/I in cpu_usage)
		total_cpu_used += cpu_usage[I]

	var/total_ram_used = 0
	for(var/I in ram_usage)
		total_ram_used += ram_usage[I]

	data["contribute_spare_cpu"] = contribute_spare_cpu

	data["used_cpu"] = total_cpu_used
	data["used_ram"] = total_ram_used

	data["total_cpu_used"] = owner.ai_network.resources.total_cpu_assigned()
	data["max_cpu"] = owner.ai_network.resources.total_cpu()
	data["max_ram"] = owner.ai_network.resources.total_ram()

	data["categories"] = GLOB.ai_project_categories
	data["available_projects"] = list()

	var/turf/current_turf = get_turf(owner)

	data["integrity"] = owner.health

	data["location_name"] = get_area(current_turf)

	data["location_coords"] = "[current_turf.x], [current_turf.y], [current_turf.z]"
	var/datum/gas_mixture/env = current_turf.return_air()
	data["temperature"] = env.return_temperature()

	for(var/datum/ai_project/AP as anything in available_projects)
		data["available_projects"] += list(list("name" = AP.name, "description" = AP.description, "ram_required" = AP.ram_required, "available" = AP.canResearch(), "research_cost" = AP.research_cost, "research_progress" = AP.research_progress, 
		"assigned_cpu" = cpu_usage[AP.name] ? cpu_usage[AP.name] : 0, "research_requirements" = AP.research_requirements_text, "category" = AP.category))

	var/list/ability_paths = list()
	data["completed_projects"] = list()
	data["chargeable_abilities"] = list()
	for(var/datum/ai_project/P as anything in completed_projects)
		data["completed_projects"] += list(list("name" = P.name, "description" = P.description, "ram_required" = P.ram_required, "running" = P.running, "category" = P.category, "can_be_run" = P.can_be_run))
		if(P.ability_path && !(P.ability_path in ability_paths)) //Check that we've not already added a thing to recharge this type of ability
			if(P.ability_recharge_cost <= 0)
				continue
			ability_paths += P.ability_path
			var/datum/action/innate/ai/the_ability = locate(P.ability_path) in owner.actions
			if(the_ability)
				data["chargeable_abilities"] += list(list("assigned_cpu" = cpu_usage[P.name],"cost" = P.ability_recharge_cost, "progress" = P.ability_recharge_invested, "name" = the_ability.name, 
				"project_name" = P.name, "uses" = the_ability.uses, "max_uses" = the_ability.max_uses))

	return data

/datum/ai_dashboard/ui_act(action, params)
	if(..())
		return
	if(!is_interactable(usr))
		return

	switch(action)
		if("run_project")
			var/datum/ai_project/project = get_project_by_name(params["project_name"])
			if(!project || !run_project(project))
				to_chat(owner, span_warning("Unable to run the program '[params["project_name"]].'"))
			else
				to_chat(owner, span_notice("Spinning up instance of [params["project_name"]]..."))
				. = TRUE
		if("stop_project")
			var/datum/ai_project/project = get_project_by_name(params["project_name"])
			if(project)
				stop_project(project) 
				to_chat(owner, span_notice("Instance of [params["project_name"]] succesfully ended."))
				. = TRUE
		if("allocate_cpu")
			var/datum/ai_project/project = get_project_by_name(params["project_name"], TRUE)
			if(!project || !set_project_cpu(project, text2num(params["amount"])))
				to_chat(owner, span_warning("Unable to add CPU to [params["project_name"]]. Either not enough free CPU or project is unavailable."))
			. = TRUE
		if("allocate_recharge_cpu")
			var/datum/ai_project/project = get_project_by_name(params["project_name"])
			if(!has_completed_project(project.type))
				return
			var/datum/action/innate/ai/the_ability = locate(project.ability_path) in owner.actions
			if(!the_ability)
				return
			if(the_ability.uses >= the_ability.max_uses)
				to_chat(owner, span_warning("This action already has the maximum amount of charges!"))
				return
			if(!project || !set_project_cpu(project, text2num(params["amount"])))
				to_chat(owner, span_warning("Unable to add CPU to [params["project_name"]]. Either not enough free CPU or ability recharge is unavailable."))
			. = TRUE
		if("max_cpu")
			var/datum/ai_project/project = get_project_by_name(params["project_name"], TRUE)
			if(!project)
				to_chat(owner, span_warning("Unable to add CPU to [params["project_name"]]. Either not enough free CPU or project is unavailable."))
				return

			var/total_cpu_used = 0
			for(var/I in cpu_usage)
				if(I == project.name)
					continue
				total_cpu_used += cpu_usage[I]

			var/amount_to_add = 1 - total_cpu_used
			if(!set_project_cpu(project, amount_to_add))
				to_chat(owner, span_warning("Unable to add CPU to [params["project_name"]]. Either not enough free CPU or project is unavailable."))
			. = TRUE
		if("toggle_contribute_cpu")
			contribute_spare_cpu = !contribute_spare_cpu
			to_chat(owner, span_notice("You now[contribute_spare_cpu ? "" : " DO NOT"] contribute spare CPU to generating research points."))

		if("clear_ai_resources")
			owner.ai_network.resources.clear_ai_resources(src)
			. = TRUE

		if("set_cpu")
			var/amount = params["amount_cpu"]

			if(amount > 1 || amount < 0)
				return

			owner.ai_network.resources.set_cpu(owner, amount)
			. = TRUE
		if("max_cpu_assign")
			var/amount = (1 - owner.ai_network.resources.total_cpu_assigned()) + owner.ai_network.resources.cpu_assigned[owner]

			owner.ai_network.resources.set_cpu(owner, amount)
			. = TRUE
		if("add_ram")
			if(owner.ai_network.resources.total_ram_assigned() >= owner.ai_network.resources.total_ram())
				return
			owner.ai_network.resources.add_ram(owner, 1)
			. = TRUE

		if("remove_ram")
			var/current_ram = owner.ai_network.resources.ram_assigned[owner]

			if(current_ram <= 0)
				return
			owner.ai_network.resources.remove_ram(owner, 1)
			. = TRUE
			
/datum/ai_dashboard/proc/get_project_by_name(project_name, only_available = FALSE)
	for(var/datum/ai_project/AP as anything in available_projects)
		if(AP.name == project_name)
			return AP
	if(!only_available)
		for(var/datum/ai_project/AP as anything in completed_projects)
			if(AP.name == project_name)
				return AP

	return FALSE

/datum/ai_dashboard/proc/set_project_cpu(datum/ai_project/project, amount)
	if(!project.canResearch())
		return FALSE
	
	if(amount < 0)
		return FALSE
  
	if(has_completed_project(project.type))
		if(!project.ability_recharge_cost)
			return
		var/datum/action/innate/ai/the_ability = locate(project.ability_path) in owner.actions
		if(!the_ability)
			return
		if(the_ability.uses >= the_ability.max_uses)
			return
	
	
	var/total_cpu_used = 0
	for(var/I in cpu_usage)
		if(I == project.name)
			continue
		total_cpu_used += cpu_usage[I]


	if((1 - total_cpu_used) >= amount)
		cpu_usage[project.name] = amount
		return TRUE
	return FALSE


/datum/ai_dashboard/proc/run_project(datum/ai_project/project)
	var/current_ram = owner.ai_network.resources.ram_assigned[owner] ? owner.ai_network.resources.ram_assigned[owner] : 0
	current_ram += free_ram

	var/total_ram_used = 0
	for(var/I in ram_usage)
		total_ram_used += ram_usage[I]

	if(current_ram - total_ram_used >= project.ram_required && project.canRun())
		project.run_project()
		ram_usage[project.name] += project.ram_required
		return TRUE
	return FALSE

/datum/ai_dashboard/proc/stop_project(datum/ai_project/project)
	project.stop()
	if(ram_usage[project.name])
		ram_usage[project.name] -= project.ram_required
		return project.ram_required

	return FALSE

/datum/ai_dashboard/proc/has_completed_project(project_type)
	for(var/datum/ai_project/P as anything in completed_projects)
		if(P.type == project_type)
			return TRUE
	return FALSE

/datum/ai_dashboard/proc/finish_project(datum/ai_project/project, notify_user = TRUE)
	available_projects -= project
	completed_projects += project
	cpu_usage[project.name] = 0
	project.finish()
	if(notify_user)
		to_chat(owner, span_notice("[project] has been completed. User input required."))
	
/datum/ai_dashboard/proc/recharge_ability(datum/ai_project/project, notify_user = TRUE)
	
	if(!project.ability_path)
		return
	var/datum/action/innate/ai/ability = locate(project.ability_path) in owner.actions
	if(!ability)
		return
	ability.uses++
	project.ability_recharge_invested = 0
	if(ability.uses >= ability.max_uses)
		cpu_usage[project.name] = 0

	if(notify_user)
		to_chat(owner, span_notice("'[ability.name]' has been recharged."))

/datum/ai_dashboard/proc/is_project_running(datum/ai_project/project)
	var/datum/ai_project/found_project = locate(project) in running_projects
	if(found_project)
		return found_project.running


//Stuff is handled in here per tick :)
/datum/ai_dashboard/proc/tick(seconds)
	var/current_cpu = owner.ai_network.resources.cpu_assigned[owner] ? owner.ai_network.total_cpu() * owner.ai_network.resources.cpu_assigned[owner] : 0
	var/current_ram = owner.ai_network.resources.ram_assigned[owner] ? owner.ai_network.resources.ram_assigned[owner] : 0
	current_ram += free_ram


	var/total_ram_used = 0
	for(var/I in ram_usage)
		total_ram_used += ram_usage[I]

	var/reduction_of_resources = FALSE


	if(total_ram_used > current_ram)
		for(var/I in ram_usage)
			var/datum/ai_project/project = get_project_by_name(I)
			total_ram_used -= stop_project(project)
			reduction_of_resources = TRUE
			if(total_ram_used <= current_ram)
				break


	if(reduction_of_resources)
		to_chat(owner, span_warning("Lack of computational capacity. Some programs may have been stopped."))


	var/remaining_cpu = 1
	for(var/I in cpu_usage)
		remaining_cpu -= cpu_usage[I]

	if(remaining_cpu > 0 && contribute_spare_cpu)
		var/points = max(round(AI_RESEARCH_PER_CPU * (remaining_cpu * current_cpu) * owner.research_point_booster), 0)

		if(crypto_mining)
			points *= 0.5
			var/bitcoin_mined = points * (1-0.05*sqrt(points))	
			bitcoin_mined = clamp(bitcoin_mined, 0, MAX_AI_BITCOIN_MINED_PER_TICK)
			var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
			if(D)
				D.adjust_money(bitcoin_mined * AI_BITCOIN_PRICE)

		SSresearch.science_tech.add_point_list(list(TECHWEB_POINT_TYPE_AI = points))
		


	for(var/project_being_researched in cpu_usage)
		if(!cpu_usage[project_being_researched])
			continue
		
		var/used_cpu = round(cpu_usage[project_being_researched] * seconds * current_cpu, 1)
		var/datum/ai_project/project = get_project_by_name(project_being_researched)
		if(!project)
			cpu_usage[project_being_researched] = 0
			continue
		if(has_completed_project(project.type)) //This means we're an ability recharging
			if(!project.ability_recharge_cost) //No ability, just waste the CPU
				continue
			project.ability_recharge_invested += used_cpu
			if(project.ability_recharge_invested > project.ability_recharge_cost)
				owner.playsound_local(owner, 'sound/machines/ping.ogg', 50, 0)
				recharge_ability(project)
			continue

		project.research_progress += used_cpu
		if(project.research_progress > project.research_cost)
			owner.playsound_local(owner, 'sound/machines/ping.ogg', 50, 0)
			finish_project(project)
