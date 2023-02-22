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
	var/obj/item/card/id/id = user.get_idcard()
	if(id && id.registered_account && !id.registered_account.bounties)
		id.registered_account.generate_bounties()
	printer_ready = world.time + PRINTER_TIMEOUT
	cargocash = SSeconomy.get_dep_account(ACCOUNT_CAR)
	. = ..()

/datum/computer_file/program/cargobounty/ui_data(mob/user)
	var/list/data = get_header_data()
	var/list/bountyinfo = list()
	var/obj/item/card/id/id = user.get_idcard()
	for(var/datum/bounty/B in id?.registered_account?.bounties)
		bountyinfo += list(list("name" = B.name, "description" = B.description, "reward_string" = B.reward_string(), "completion_string" = B.completion_string() , "claimed" = B.claimed, "can_claim" = B.can_claim(), "priority" = B.high_priority, "bounty_ref" = REF(B)))
	data["stored_cash"] = cargocash.account_balance
	data["bountydata"] = bountyinfo
	return data

/datum/computer_file/program/cargobounty/ui_act(action, params)
	if(..())
		return
