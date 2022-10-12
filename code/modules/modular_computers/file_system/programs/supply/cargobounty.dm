/datum/computer_file/program/cargobounty
	filename = "bounty"
	filedesc = "Nanotrasen Bounty Hunter"
	category = PROGRAM_CATEGORY_SUPL
	program_icon_state = "bountyboard"
	extended_desc = "A basic interface for supply personnel to check and claim bounties."
	requires_ntnet = TRUE
	transfer_access = ACCESS_CARGO
	network_destination = "cargo claims interface"
	size = 10
	tgui_id = "NtosBountyConsole"
	program_icon = "file-invoice-dollar"
	///cooldown var for printing paper sheets.
	var/printer_ready = 0
	///The cargo account for grabbing the cargo account's credits.
	var/static/datum/bank_account/cargocash

/datum/computer_file/program/cargobounty/ui_interact(mob/user, ui_key, datum/tgui/ui, force_open, datum/tgui/master_ui, datum/ui_state/state)
	if(!GLOB.bounties_list.len)
		setup_bounties()
	printer_ready = world.time + PRINTER_TIMEOUT
	cargocash = SSeconomy.get_dep_account(ACCOUNT_CAR)
	. = ..()

/datum/computer_file/program/cargobounty/ui_data(mob/user)
	var/list/data = get_header_data()
	var/list/bountyinfo = list()
	for(var/datum/bounty/B in GLOB.bounties_list)
		bountyinfo += list(list("name" = B.name, "description" = B.description, "reward_string" = B.reward_string(), "completion_string" = B.completion_string() , "claimed" = B.claimed, "can_claim" = B.can_claim(), "priority" = B.high_priority, "bounty_ref" = REF(B)))
	data["stored_cash"] = cargocash.account_balance
	data["bountydata"] = bountyinfo
	return data

/datum/computer_file/program/cargobounty/ui_act(action, params)
	if(..())
		return

	var/obj/item/computer_hardware/printer/printer
	if(computer)
		printer = computer.all_components[MC_PRINT]

	switch(action)
		if("ClaimBounty")
			var/datum/bounty/cashmoney = locate(params["bounty"]) in GLOB.bounties_list
			if(cashmoney)
				cashmoney.claim()
			return TRUE
		if("Print")
			if(!printer)
				to_chat(usr, span_notice("Hardware error: No printer detected."))
				return
			if(!printer.print_type(/obj/item/paper/bounty_printout))
				to_chat(usr, span_notice("Hardware error: Printer was unable to print the file. It may be out of paper."))
				return
