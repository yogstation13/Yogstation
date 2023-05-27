//Used to access the Psi Web to buy abilities.
//Accesses the Psi Web, which darkspawn use to purchase abilities using lucidity. Lucidity is drained from people using the Devour Will ability.
/datum/antag_menu/psi_web
	name = "psi web"
	ui_name = "PsiWeb"

/datum/antag_menu/psi_web/ui_data(mob/user)
	var/list/data = list()
	var/datum/antagonist/darkspawn/darkspawn = antag_datum

	if(!istype(darkspawn))
		CRASH("darkspawn menu started with wrong datum.")

	data["lucidity"] = "[darkspawn.lucidity]  |  [darkspawn.lucidity_drained] / 20 unique drained total"

	var/list/abilities = list()
	var/list/upgrades = list()

	for(var/path in subtypesof(/datum/action/innate/darkspawn))
		var/datum/action/innate/darkspawn/ability = path

		if(initial(ability.blacklisted))
			continue

		var/list/AL = list() //This is mostly copy-pasted from the cellular emporium, but it should be fine regardless
		AL["name"] = initial(ability.name)
		AL["id"] = initial(ability.id)
		AL["desc"] = initial(ability.desc)
		AL["psi_cost"] = "[initial(ability.psi_cost)][initial(ability.psi_addendum)]"
		AL["lucidity_cost"] = initial(ability.lucidity_price)
		AL["owned"] = darkspawn.has_ability(initial(ability.id))
		AL["can_purchase"] = !AL["owned"] && darkspawn.lucidity >= initial(ability.lucidity_price)

		abilities += list(AL)

	data["abilities"] = abilities

	for(var/path in subtypesof(/datum/darkspawn_upgrade))
		var/datum/darkspawn_upgrade/upgrade = path

		var/list/DE = list()
		DE["name"] = initial(upgrade.name)
		DE["id"] = initial(upgrade.id)
		DE["desc"] = initial(upgrade.desc)
		DE["lucidity_cost"] = initial(upgrade.lucidity_price)
		DE["owned"] = darkspawn.has_upgrade(initial(upgrade.id))
		DE["can_purchase"] = !DE["owned"] && darkspawn.lucidity >= initial(upgrade.lucidity_price)

		upgrades += list(DE)

	data["upgrades"] = upgrades

	return data

/datum/antag_menu/psi_web/ui_act(action, params)
	if(..())
		return
	var/datum/antagonist/darkspawn/darkspawn = antag_datum
	switch(action)
		if("unlock")
			darkspawn.add_ability(params["id"])
		if("upgrade")
			darkspawn.add_upgrade(params["id"])

/datum/action/innate/darkspawn/psi_web
	name = "Psi Web"
	id = "psi_web"
	desc = "Access the Mindlink directly to unlock and upgrade your supernatural powers."
	button_icon_state = "psi_web"
	check_flags = AB_CHECK_CONSCIOUS
	blacklisted = TRUE
	psi_cost = 0
	var/datum/antag_menu/psi_web/psi_web

/datum/action/innate/darkspawn/psi_web/New(our_target)
	. = ..()
	if(istype(our_target, /datum/antag_menu/psi_web))
		psi_web = our_target
	else
		CRASH("psi_web action created with non web.")

/datum/action/innate/darkspawn/psi_web/Destroy()
	psi_web = null
	return ..()

/datum/action/innate/darkspawn/psi_web/Activate()
	if(!darkspawn)
		return
	to_chat(usr, "<span class='velvet bold'>You retreat inwards and touch the Mindlink...</span>")
	psi_web.ui_interact(usr)
	return TRUE
