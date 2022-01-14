/obj/machinery/computer/bounty
	name = "\improper Nanotrasen bounty console"
	desc = "Used to check and claim bounties offered by Nanotrasen"
	icon_screen = "bounty"
	circuit = /obj/item/circuitboard/computer/bounty
	light_color = "#E2853D"//orange
	var/obj/machinery/bounty_packager/linked_packager
	var/obj/item/card/id/ID

/obj/machinery/computer/bounty/Initialize(mapload)
	. = ..()
	if(mapload)
		addtimer(CALLBACK(src, .proc/linkPackager))

/obj/machinery/computer/bounty/proc/linkPackager()
	if(GLOB.bounty_packager && !GLOB.bounty_packager.linked_console)
		linked_packager = GLOB.bounty_packager
		linked_packager.linked_console = src


/obj/machinery/computer/bounty/ui_interact(mob/user, datum/tgui/ui)
	if(ID && ID.registered_account && !ID.registered_account.bounties)
		ID.registered_account.generate_bounties()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CargoBountyConsole", name)
		ui.open()

/obj/machinery/computer/bounty/ui_data(mob/user)
	var/list/data = list()
	var/list/bountyinfo = list()
	for(var/datum/bounty/B in ID?.registered_account?.bounties)
		bountyinfo += list(list("name" = B.name, "description" = B.description, "reward_string" = B.reward_string(), "completion_string" = B.completion_string() , "claimed" = B.claimed, "selected" = (B == linked_packager?.selected_bounty), "priority" = B.high_priority, "bounty_ref" = REF(B)))
	data["bountydata"] = bountyinfo
	data["is_packager"] = !!linked_packager
	data["has_id"] = !!ID
	data["orig_job"] = ID?.originalassignment
	data["job"] = ID?.assignment
	data["name"] = ID?.registered_name
	return data

/obj/machinery/computer/bounty/ui_act(action,params)
	if(..())
		return
	switch(action)
		if("SelectBounty")
			if(!linked_packager || !ID || !ID.registered_account || !ID.registered_account.bounties)
				return FALSE
			linked_packager.selected_bounty = locate(params["bounty"]) in ID.registered_account.bounties
			return TRUE
		if("Eject")
			if(!ID)
				return FALSE
			var/mob/user = usr
			if(user)
				user.put_in_hands(ID)
			else
				ID.forceMove(drop_location())
			ID = null
			if(linked_packager) linked_packager.selected_bounty = null
			return TRUE
		if("ReloadBounties")
			if(!ID?.registered_account)
				return FALSE
			var/result = ID.registered_account.generate_bounties()
			if(result != TRUE)
				say(result)
				return FALSE
			return TRUE


/obj/machinery/computer/bounty/attackby(obj/item/I, mob/living/user, params)
	if(!isidcard(I))
		return ..()
	
	I.forceMove(src)
	ID = I
	if(ID && ID.registered_account && !ID.registered_account.bounties)
		ID.registered_account.generate_bounties()
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
	return TRUE

/obj/machinery/computer/bounty/multitool_act(mob/living/user, obj/item/I)
	var/obj/item/multitool/multitool = I
	if(!istype(multitool)) return FALSE
	if(!istype(multitool.buffer, /obj/machinery/bounty_packager))
		multitool.buffer = src
		to_chat(user, span_notice("[src] stored in [I]"))
		return TRUE

	linked_packager = multitool.buffer
	linked_packager.linked_console = src
	to_chat(user, span_notice("[src] has been linked to [linked_packager]"))
	return TRUE
