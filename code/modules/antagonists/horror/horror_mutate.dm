// Horror mutation menu
// Totally not a copypaste of darkspawn menu, not a copypaste of cellular emporium, i swear. Edit: now looks like guardianbuilder too

/mob/living/simple_animal/horror/proc/has_ability(typepath)
	for(var/datum/action/innate/horror/ability in horrorabilities)
		if(istype(ability, typepath))
			return ability
	return

/mob/living/simple_animal/horror/proc/add_ability(typepath)
	if(has_ability(typepath))
		return
	var/datum/action/innate/horror/action = new typepath
	action.B = src
	horrorabilities += action
	RefreshAbilities()
	to_chat(src, span_velvet("You have mutated the <b>[action.name]</b>."))
	available_points = max(0, available_points - action.soul_price)
	return TRUE

/mob/living/simple_animal/horror/proc/has_upgrade(id)
	return horrorupgrades[id]

/mob/living/simple_animal/horror/proc/add_upgrade(id)
	if(has_upgrade(id))
		return
	for(var/V in subtypesof(/datum/horror_upgrade))
		var/datum/horror_upgrade/_U = V
		if(initial(_U.id) == id)
			var/datum/horror_upgrade/U = new _U(src)
			horrorupgrades[id] = TRUE
			to_chat(src, "<span class='velvet bold'>You have adapted the \"[U.name]\" upgrade.</span>")
			available_points = max(0, available_points - U.soul_price)
			U.unlock()

//mutation menu, 100% ripoff of psiweb, pls don't sue

/mob/living/simple_animal/horror/ui_state(mob/user)
	return GLOB.always_state

/mob/living/simple_animal/horror/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HorrorMutate", "Horror Mutation")
		ui.open()

/mob/living/simple_animal/horror/ui_data(mob/user)
	var/list/data = list()

	data["available_points"] = "[available_points]  |  [consumed_souls] consumed souls total"

	var/list/abilities = list()
	var/list/upgrades = list()

	for(var/path in subtypesof(/datum/action/innate/horror))
		var/datum/action/innate/horror/ability = path

		if(initial(ability.blacklisted))
			continue

		var/list/AL = list()
		AL["name"] = initial(ability.name)
		AL["typepath"] = path
		AL["desc"] = initial(ability.desc)
		AL["soul_cost"] = initial(ability.soul_price)
		AL["owned"] = has_ability(path)
		AL["can_purchase"] = !AL["owned"] && available_points >= initial(ability.soul_price)

		abilities += list(AL)

	data["abilities"] = abilities

	for(var/path in subtypesof(/datum/horror_upgrade))
		var/datum/horror_upgrade/upgrade = path

		var/list/DE = list()
		DE["name"] = initial(upgrade.name)
		DE["id"] = initial(upgrade.id)
		DE["desc"] = initial(upgrade.desc)
		DE["soul_cost"] = initial(upgrade.soul_price)
		DE["owned"] = has_upgrade(initial(upgrade.id))
		DE["can_purchase"] = !DE["owned"] && available_points >= initial(upgrade.soul_price)

		upgrades += list(DE)

	data["upgrades"] = upgrades

	return data

/mob/living/simple_animal/horror/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("unlock")
			add_ability(params["typepath"])
		if("upgrade")
			add_upgrade(params["id"])