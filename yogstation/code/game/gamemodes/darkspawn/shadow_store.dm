
#define SCOUT (1<<0)
#define FIGHTER (1<<1)
#define WARLOCK (1<<2)

//Used to access the Psi Web to buy abilities.
//Accesses the Psi Web, which darkspawn use to purchase abilities using lucidity. Lucidity is drained from people using the Devour Will ability.
/datum/antag_menu/shadow_store
	name = "psi web"
	ui_name = "PsiWeb"

/datum/antag_menu/shadow_store/ui_data(mob/user)
	var/list/data = list()
	var/datum/antagonist/darkspawn/darkspawn = antag_datum

	if(!istype(darkspawn))
		CRASH("darkspawn menu started with wrong datum.")

	data["lucidity"] = "[darkspawn.lucidity]  |  [darkspawn.lucidity_drained] / [darkspawn.lucidity_needed] unique drained total"

	var/list/upgrades = list()

	for(var/path in subtypesof(/datum/shadow_store))
		var/datum/shadow_store/selection = path

		if(!selection.check_show(user))
			continue

		var/list/AL = list()
		AL["name"] = initial(selection.name)
		AL["desc"] = initial(selection.desc)
		AL["psi_cost"] = initial(selection.psi_cost)
		AL["lucidity_cost"] = initial(ability.lucidity_price)
		AL["can_purchase"] = darkspawn.lucidity >= initial(ability.lucidity_price)

		upgrades += list(AL)

	data["upgrades"] = upgrades

	return data

/datum/antag_menu/shadow_store/ui_act(action, params)
	if(..())
		return
	var/datum/antagonist/darkspawn/darkspawn = antag_datum
	switch(action)
		if("purchase")
			if(istype(params["id"], /datum/shadow_store))
				var/datum/shadow_store/selected = params["id"]
				selected.on_purchase(darkspawn?.owner?.current)

//ability for using the shadow store
/datum/action/innate/darkspawn/shadow_store
	name = "Psi Web"
	id = "psi_web"
	desc = "Access the Mindlink directly to unlock and upgrade your supernatural powers."
	button_icon_state = "psi_web"
	check_flags = AB_CHECK_CONSCIOUS
	psi_cost = 0
	var/datum/antag_menu/psi_web/psi_web

/datum/action/innate/darkspawn/shadow_store/New(our_target)
	. = ..()
	if(istype(our_target, /datum/antag_menu/psi_web))
		psi_web = our_target
	else
		CRASH("psi_web action created with non web.")

/datum/action/innate/darkspawn/shadow_store/Destroy()
	psi_web = null
	return ..()

/datum/action/innate/darkspawn/shadow_store/Activate()
	if(!darkspawn)
		return
	to_chat(usr, "<span class='velvet bold'>You retreat inwards and touch the Mindlink...</span>")
	psi_web.ui_interact(usr)
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

///Check to see if they should be shown the ability
/datum/shadow_store/proc/check_show(mob/user)
	SHOULD_CALL_PARENT(TRUE) //for now
	var/datum/antagonist/darkspawn/edgy= user.mind?.has_antag_datum(/datum/antagonist/darkspawn)
	if(!edgy)
		return FALSE
	if(!(edgy.specialization & shadow_flags))
		return FALSE
	if(edgy.has_upgrade(name))//if they already have it
		return FALSE
	return TRUE

///When the button to purchase is clicked
/datum/shadow_store/proc/on_purchase(mob/user)
	var/datum/antagonist/darkspawn/edgy= user.mind?.has_antag_datum(/datum/antagonist/darkspawn)
	if(!edgy)
		return FALSE
	if(!(edgy.specialization & shadow_flags))//they shouldn't even be shown it in the first place, but just in case
		return FALSE
	if(edgy.lucidity < cost)
		return FALSE

	if(learn_text)
		to_chat(user, span_velvet(learn_text))
	edgy.add_upgrade(name)
	edgy.lucidity -= cost
	activate(user)
	return TRUE

///If the purchase goes through, this gets called
/datum/shadow_store/proc/activate(mob/user)
	var/datum/antagonist/darkspawn/edgy= user.mind?.has_antag_datum(/datum/antagonist/darkspawn)
	if(!edgy)
		return
	if(learned_ability)
		var/datum/action/innate/darkspawn/action = new learned_ability
		action.Grant(user)

///if for whatever reason the ability needs to be removed
/datum/shadow_store/proc/remove(mob/user)
	var/datum/antagonist/darkspawn/edgy= user.mind?.has_antag_datum(/datum/antagonist/darkspawn)
	if(!edgy)
		return
	edgy.remove_upgrade(name)
	if(learned_ability)
		var/datum/action/innate/darkspawn/action = new learned_ability
		action.Remove(user)

/*
	Purchases to select spec
*/
/datum/shadow_store/scout
	name = "shadow step"
	desc = "shadow step"

/datum/shadow_store/scout/activate(mob/user)
	user.LoadComponent(/datum/component/walk/shadow)
	user.AddComponent(/datum/component/shadow_step)
	var/datum/antagonist/darkspawn/edgy = user.mind?.has_antag_datum(/datum/antagonist/darkspawn)
	if(edgy)//there's NO way they get here without it
		edgy.specialization = SCOUT


/datum/shadow_store/fighter
	name = "shadow step"
	desc = "shadow step"

/datum/shadow_store/fighter/activate(mob/user)
	var/datum/antagonist/darkspawn/edgy = user.mind?.has_antag_datum(/datum/antagonist/darkspawn)
	if(edgy)//there's NO way they get here without it
		edgy.specialization = FIGHTER

/datum/shadow_store/warlock
	name = "shadow step"
	desc = "shadow step"

/datum/shadow_store/warlock/activate(mob/user)
	var/datum/antagonist/darkspawn/edgy = user.mind?.has_antag_datum(/datum/antagonist/darkspawn)
	if(edgy)//there's NO way they get here without it ... right?
		edgy.specialization = WARLOCK
