/datum/reforge_menu
	var/mob/owner
	var/obj/machinery/anvil/parent_anvil
	var/obj/item/reforge_target
	var/use_super_credits = FALSE
	COOLDOWN_DECLARE(reroll_cooldown)

/datum/reforge_menu/New(mob/new_owner, obj/machinery/anvil/parent_anvil)
	if(!istype(new_owner))
		qdel(src)
	src.owner = new_owner
	src.parent_anvil = parent_anvil
	
	RegisterSignal(parent_anvil, COMSIG_QDELETING, PROC_REF(on_anvil_destroyed))

/datum/reforge_menu/ui_state(mob/user)
	return GLOB.physical_state

/datum/reforge_menu/Destroy()
	owner = null
	parent_anvil = null
	reforge_target = null
	return ..()

/datum/reforge_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "ReforgerMenu")
		ui.open()

/datum/reforge_menu/ui_host()
	return parent_anvil

/datum/reforge_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if ("reroll")
			if(!COOLDOWN_FINISHED(src, reroll_cooldown))
				to_chat(owner, span_danger("The cooldown for rerolling hasn't finished yet."))
				return
			parent_anvil.reroll(reforge_target, owner, src)
			. = TRUE
		if ("toggle_super_credits")
			use_super_credits = !use_super_credits
			. = TRUE

/datum/reforge_menu/ui_data(mob/user)
	var/list/data = list()
	data["reforge_cooldown"] = reroll_cooldown - world.time
	data["super_credits_available"] = user.mind.super_credits
	data["use_super_credits"] = use_super_credits
	data["reforge_target"] = null
	if(reforge_target)
		var/list/details = list()
		details["name"] = reforge_target.name
		details["description"] = reforge_target.desc
		var/datum/component/fantasy/fantasy_affix = reforge_target.GetComponent(/datum/component/fantasy)
		details["rarity"] = list("name" = fantasy_affix.rarity, "color" = GLOB.rarity_to_color[fantasy_affix.rarity], "chances" = GLOB.rarity_weights[fantasy_affix.rarity])
		details["item_pic"] = icon2base64(getFlatIcon(reforge_target))
		data["reforge_target"] = details
	return data

/datum/reforge_menu/ui_static_data(mob/user)
	var/list/data = list()
	data["rarities"] = list()
	var/rarity_total_weight = 0
	for(var/rarity in GLOB.rarity_weights)
		var/list/rarity_data = list()
		rarity_data["name"] = rarity
		rarity_data["color"] = GLOB.rarity_to_color[rarity]
		rarity_data["weight"] = GLOB.rarity_weights[rarity]
		
		data["rarities"] += list(rarity_data)
		rarity_total_weight += GLOB.rarity_weights[rarity]
	
	data["rarity_total_weight"] = rarity_total_weight
	return data

/datum/reforge_menu/proc/set_target_item(obj/item/new_reforge_target)
	src.reforge_target = new_reforge_target

/datum/reforge_menu/proc/on_anvil_destroyed()
	qdel(src)

