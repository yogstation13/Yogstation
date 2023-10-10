
#define SCOUT (1<<0)
#define FIGHTER (1<<1)
#define WARLOCK (1<<2)

#define STORE_OFFENSE "offense" //things that you use and it fucks someone up
#define STORE_UTILITY "utility" //things that you use and it does something less straightforward
#define STORE_PASSIVE "passives" //things that always happen all the time

//Used to access the Psi Web to buy abilities.
//Accesses the Psi Web, which darkspawn use to purchase abilities using lucidity. Lucidity is drained from people using the Devour Will ability.
/datum/antag_menu/shadow_store
	name = "psi web"
	ui_name = "PsiWeb"
	var/list/show_categories = list(STORE_OFFENSE, STORE_UTILITY, STORE_PASSIVE)

/datum/antag_menu/shadow_store/ui_data(mob/user)
	var/list/data = list()
	var/datum/antagonist/darkspawn/darkspawn = antag_datum

	if(!istype(darkspawn))
		CRASH("darkspawn menu started with wrong datum.")

	data["lucidity"] = "[darkspawn.lucidity]  |  [darkspawn.lucidity_drained] / [darkspawn.lucidity_needed] unique drained total"
	data["specialization"] = darkspawn.specialization
	for(var/category in show_categories)
		var/list/category_data = list()
		category_data["name"] = category

		var/list/upgrades = list()
		for(var/path in subtypesof(/datum/shadow_store))
			var/datum/shadow_store/selection = new path

			if(!selection.check_show(user))
				continue

			var/list/AL = list()
			AL["name"] = selection.name
			AL["desc"] = selection.desc
			AL["psi_cost"] = selection.psi_cost
			AL["lucidity_cost"] = selection.lucidity_cost
			AL["can_purchase"] = darkspawn.lucidity >= selection.lucidity_cost
			AL["type_path"] = selection.type
			
			if(category == selection.menutab)
				upgrades += list(AL)

			qdel(selection)

		category_data["upgrades"] = upgrades
		data["categories"] += list(category_data)

	return data

/datum/antag_menu/shadow_store/ui_act(action, params)
	if(..())
		return
	var/datum/antagonist/darkspawn/darkspawn = antag_datum
	if(!istype(darkspawn))
		return
	switch(action)
		if("purchase")
			var/upgradePath = text2path(params["upgradePath"])
			if(!ispath(upgradePath, /datum/shadow_store))
				return FALSE
			var/datum/shadow_store/selected = new upgradePath
			selected.on_purchase(darkspawn?.owner?.current)

//ability for using the shadow store
/datum/action/innate/darkspawn/shadow_store
	name = "Psi Web"
	id = "psi_web"
	desc = "Access the Mindlink directly to unlock and upgrade your supernatural powers."
	button_icon_state = "psi_web"
	check_flags = AB_CHECK_CONSCIOUS
	psi_cost = 0
	var/datum/antag_menu/shadow_store/shadow_store

/datum/action/innate/darkspawn/shadow_store/New(our_target)
	. = ..()
	if(istype(our_target, /datum/antag_menu/shadow_store))
		shadow_store = our_target
	else
		CRASH("psi_web action created with non web.")

/datum/action/innate/darkspawn/shadow_store/Destroy()
	shadow_store = null
	return ..()

/datum/action/innate/darkspawn/shadow_store/Activate()
	if(!darkspawn)
		return
	to_chat(usr, "<span class='velvet bold'>You retreat inwards and touch the Mindlink...</span>")
	shadow_store.ui_interact(usr)
	return TRUE


//shadow store datums (upgrades and abilities)
/datum/shadow_store
	///Name of the effect
	var/name = "Basic knowledge"
	///Description of the effect
	var/desc = "Basic knowledge of forbidden arts."
	///Icon that gets displayed
	var/icon = ""
	///Cost of to learn this
	var/lucidity_cost = 0
	///Cost of to cast this
	var/psi_cost = 0
	///What specialization can buy this
	var/shadow_flags = NONE
	///what ability is granted if any
	var/learned_ability
	///what is printed when learned
	var/learn_text
	///what tab of the antag menu does it fall under
	var/menutab
	///The antag datum of the owner(used for modifying)
	var/datum/antagonist/darkspawn/owner

///Check to see if they should be shown the ability
/datum/shadow_store/proc/check_show(mob/user)
	if(!menutab)
		return FALSE
	owner = user.mind?.has_antag_datum(/datum/antagonist/darkspawn)
	if(!owner)
		return FALSE
	if(shadow_flags && !(owner.specialization & shadow_flags))
		return FALSE
	if(locate(type) in owner.upgrades)//if they already have it
		return FALSE
	return TRUE

///When the button to purchase is clicked
/datum/shadow_store/proc/on_purchase(mob/user)
	owner = user.mind?.has_antag_datum(/datum/antagonist/darkspawn)
	if(!owner)
		return FALSE
	if(shadow_flags && !(owner.specialization & shadow_flags))//they shouldn't even be shown it in the first place, but just in case
		return FALSE
	if(owner.lucidity < lucidity_cost)
		return FALSE

	if(learn_text)
		to_chat(user, span_velvet(learn_text))
	owner.lucidity -= lucidity_cost
	activate(user)
	return TRUE

///If the purchase goes through, this gets called
/datum/shadow_store/proc/activate(mob/user)
	if(!owner)//no clue how it got here, but alright
		return
	owner.upgrades |= src //add it to the list
	if(learn_text)
		to_chat(user, learn_text)
	if(learned_ability)
		var/datum/action/innate/darkspawn/action = new learned_ability
		action.Grant(user)

/*
	Purchases to select spec
*/
/datum/shadow_store/scout
	name = "shadow step"
	desc = "shadow step"

/datum/shadow_store/scout/activate(mob/user)
	user.LoadComponent(/datum/component/walk/shadow)
	user.AddComponent(/datum/component/shadow_step)
	owner.specialization = SCOUT

/datum/shadow_store/fighter
	name = "fighter"
	desc = "fighter"

/datum/shadow_store/fighter/activate(mob/user)
	owner.specialization = FIGHTER

/datum/shadow_store/warlock
	name = "warlock"
	desc = "warlock"

/datum/shadow_store/warlock/activate(mob/user)
	owner.specialization = WARLOCK
