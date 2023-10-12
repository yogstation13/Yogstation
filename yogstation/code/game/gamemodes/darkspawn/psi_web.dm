
#define SCOUT (1<<0)
#define FIGHTER (1<<1)
#define WARLOCK (1<<2)

#define STORE_OFFENSE "offense" //things that you use and it fucks someone up
#define STORE_UTILITY "utility" //things that you use and it does something less straightforward
#define STORE_PASSIVE "passives" //things that always happen all the time

//Used to access the Psi Web to buy abilities.
//Accesses the Psi Web, which darkspawn use to purchase abilities using lucidity. Lucidity is drained from people using the Devour Will ability.
/datum/antag_menu/psi_web
	name = "psi web"
	ui_name = "PsiWeb"
	var/list/show_categories = list(STORE_OFFENSE, STORE_UTILITY, STORE_PASSIVE)

/datum/antag_menu/psi_web/ui_data(mob/user)
	var/list/data = list()
	var/datum/antagonist/darkspawn/darkspawn = antag_datum

	if(!istype(darkspawn))
		CRASH("darkspawn menu started with wrong datum.")

	data["lucidity"] = "[darkspawn.lucidity]  |  [darkspawn.lucidity_drained] / [SSticker.mode.required_succs] unique drained total"
	data["specialization"] = darkspawn.specialization //whether or not they've picked their specialization


	for(var/category in show_categories)
		var/list/category_data = list()
		category_data["name"] = category

		var/list/upgrades = list()
		for(var/path in subtypesof(/datum/psi_web))
			var/datum/psi_web/selection = new path

			if(!selection.check_show(user))
				continue

			var/list/AL = list()
			AL["name"] = selection.name
			AL["desc"] = selection.desc
			AL["lucidity_cost"] = selection.lucidity_cost
			AL["can_purchase"] = darkspawn.lucidity >= selection.lucidity_cost
			AL["type_path"] = selection.type
			
			if(category == selection.menu_tab)
				upgrades += list(AL)

			qdel(selection)

		category_data["upgrades"] = upgrades
		data["categories"] += list(category_data)

	return data

/datum/antag_menu/psi_web/ui_act(action, params)
	if(..())
		return
	var/datum/antagonist/darkspawn/darkspawn = antag_datum
	if(!istype(darkspawn))
		return
	switch(action)
		if("purchase")
			var/upgradePath = text2path(params["upgradePath"])
			if(!ispath(upgradePath, /datum/psi_web))
				return FALSE
			var/datum/psi_web/selected = new upgradePath
			selected.on_purchase(darkspawn?.owner?.current)

//ability for using the shadow store
/datum/action/cooldown/spell/psi_web
	name = "Psi Web"
	desc = "Access the Mindlink directly to unlock and upgrade your supernatural powers."
	panel = null
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "psi_web"
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_DARKSPAWN
	var/datum/antag_menu/psi_web/psi_web

/datum/action/cooldown/spell/psi_web/New(our_target)
	. = ..()
	if(istype(our_target, /datum/antag_menu/psi_web))
		psi_web = our_target
	else
		CRASH("psi_web action created with non web.")

/datum/action/cooldown/spell/psi_web/Destroy()
	psi_web = null
	return ..()

/datum/action/cooldown/spell/psi_web/cast(atom/cast_on)
	. = ..()
	to_chat(usr, "<span class='velvet bold'>You retreat inwards and touch the Mindlink...</span>")
	psi_web.ui_interact(usr)


//shadow store datums (upgrades and abilities)
/datum/psi_web
	///Name of the effect
	var/name = "Basic knowledge"
	///Description of the effect
	var/desc = "Basic knowledge of forbidden arts."
	///Icon that gets displayed
	var/icon = ""
	///Cost of to learn this
	var/lucidity_cost = 0
	///What specialization can buy this
	var/shadow_flags = NONE
	///what ability is granted if any
	var/datum/action/learned_ability
	///what is printed when learned
	var/learn_text
	///what tab of the antag menu does it fall under
	var/menu_tab
	///The antag datum of the owner(used for modifying)
	var/datum/antagonist/darkspawn/darkspawn

///Check to see if they should be shown the ability
/datum/psi_web/proc/check_show(mob/user)
	if(!menu_tab && shadow_flags)
		return FALSE
	darkspawn = user.mind?.has_antag_datum(/datum/antagonist/darkspawn)
	if(!darkspawn)
		return FALSE
	if(shadow_flags && !(darkspawn.specialization & shadow_flags))
		return FALSE
	if(locate(type) in darkspawn.upgrades)//if they already have it
		return FALSE
	return TRUE

///When the button to purchase is clicked
/datum/psi_web/proc/on_purchase(mob/user)
	darkspawn = user.mind?.has_antag_datum(/datum/antagonist/darkspawn)
	if(!darkspawn)
		return FALSE
	if(shadow_flags && !(darkspawn.specialization & shadow_flags))//they shouldn't even be shown it in the first place, but just in case
		return FALSE
	if(darkspawn.lucidity < lucidity_cost)
		return FALSE

	if(learn_text)
		to_chat(user, span_velvet(learn_text))
	darkspawn.lucidity -= lucidity_cost
	activate(user)
	return TRUE

///If the purchase goes through, this gets called
/datum/psi_web/proc/activate(mob/user)
	if(!darkspawn)//no clue how it got here, but alright
		return
	darkspawn.upgrades |= src //add it to the list
	if(learn_text)
		to_chat(user, learn_text)
	if(learned_ability)
		var/datum/action/action = new learned_ability
		action.Grant(user)

/*
	Purchases to select spec
*/
/datum/psi_web/scout
	name = "shadow step"
	desc = "GO FAST, TOUCH GRASS"

/datum/psi_web/scout/activate(mob/user)
	user.LoadComponent(/datum/component/walk/shadow)
	darkspawn.specialization = SCOUT

/datum/psi_web/fighter
	name = "fighter"
	desc = "me no think so good"
	learned_ability = /datum/action/cooldown/spell/toggle/pass

/datum/psi_web/fighter/activate(mob/user)
	darkspawn.specialization = FIGHTER
	var/datum/action/cooldown/spell/toggle/light_eater/spell = locate() in darkspawn.upgrades
	if(spell)
		spell.Remove(user)

/datum/psi_web/warlock
	name = "warlock"
	desc = "apartment \"complex\"... really? I find it quite simple"

/datum/psi_web/warlock/activate(mob/user)
	darkspawn.specialization = WARLOCK



/datum/psi_web/castertest
	name = "warlock ability"
	desc = "apartment \"complex\"... really? I find it quite simple"
	shadow_flags = WARLOCK

/datum/psi_web/fightertest
	name = "fighter ability"
	desc = "me no think so good"
	shadow_flags = FIGHTER

/datum/psi_web/scouttest
	name = "scout ability (dark speed)"
	desc = "GO FAST, TOUCH GRASS"
	shadow_flags = SCOUT

/datum/psi_web/scouttest/activate(mob/user)
	user.AddComponent(/datum/component/shadow_step)

/datum/psi_web/everyone
	name = "universal ability"
	desc = "everyone should see this"
	shadow_flags = SCOUT | WARLOCK | FIGHTER


////////////////////////////////////////////////////////////////////////////////////
//--------------------------------Passive Upgrades--------------------------------//
////////////////////////////////////////////////////////////////////////////////////
//Increases max Psi by 25.
/datum/psi_web/psi_cap
	name = "\'Psi\' Sigils"
	desc = "The Atlwjz sigils, representing Psi, are etched onto the forehead. Unlocking these sigils increases your maximum Psi by 25."
	lucidity_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = WARLOCK

/datum/psi_web/psi_cap/activate(mob/user)
	darkspawn.psi_cap += 25

//Decreases the Psi regeneration delay by 3 ticks and increases Psi regeneration threshold to 25.
/datum/psi_web/psi_regen
	name = "\'Recovery\' Sigil"
	desc = "The Mqeygjao sigil, representing swiftness, is etched onto the forehead. Unlocking this sigil causes your Psi to regenerate 3 ticks sooner, and you will regenerate up to 25 Psi instead of 20."
	lucidity_cost = 1
	menu_tab = STORE_PASSIVE
	shadow_flags = WARLOCK

/datum/psi_web/psi_regen/activate(mob/user)
	darkspawn.psi_regen += 5
	darkspawn.psi_regen_delay -= 3

//Increases healing in darkness by 25%.
/datum/psi_web/dark_healing
	name = "\'Mending\' Sigil"
	desc = "The Naykranu sigil, representing perseverence, is etched onto the back. Unlocking this sigil increases your healing in darkness by 25%."
	lucidity_cost = 1
	menu_tab = STORE_PASSIVE
	shadow_flags = FIGHTER | SCOUT

/datum/psi_web/dark_healing/activate(mob/user)
	darkspawn.dark_healing *= 1.25

//Halves lightburn damage and gives resistance to dim light.
/datum/psi_web/light_resistance
	name = "\'Lightward\' Sigil"
	desc = "The Lnkpayp sigil, representing imperviousness, is etched onto the abdomen. Unlocking this sigil halves light damage taken and protects from dim light."
	lucidity_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = FIGHTER

/datum/psi_web/light_resistance/activate(mob/user)
	darkspawn.light_burning /= 2
	ADD_TRAIT(user, TRAIT_DARKSPAWN_LIGHTRES, "lightward sigils")

//Provides immunity to starlight.
/datum/psi_web/spacewalking
	name = "\'Starlight\' Sigils"
	desc = "The Jaxqhw sigils, representing the void, are etched multiple times across the body. Unlocking these sigils provides the ability to walk freely in space without fear of starlight."
	lucidity_cost = 3
	menu_tab = STORE_PASSIVE
	shadow_flags = FIGHTER | SCOUT

/datum/psi_web/spacewalking/activate(mob/user)
	ADD_TRAIT(user, TRAIT_DARKSPAWN_SPACEWALK, "starlight sigils")

//Using Pass will now form two tendrils if possible.
//Attacking with one set of tendrils will attack with the other.
//This also speeds up most actions they have.
//Check pass.dm and for the effect.
/datum/psi_web/twin_tendrils
	name = "\'Duality\' Sigils"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes Pass to form tendrils in both hands if possible, which empowers both."
	lucidity_cost = 1
	shadow_flags = FIGHTER
	menu_tab = STORE_PASSIVE

/datum/psi_web/twin_tendrils/activate(mob/user)
	var/datum/action/cooldown/spell/toggle/pass/spell = locate() in darkspawn.upgrades
	if(spell)
		spell.twin = TRUE
