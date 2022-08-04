/obj/machinery/computer/bank_machine
	name = "bank machine"
	desc = "A machine used to deposit and withdraw station funds."
	icon = 'goon/icons/obj/goon_terminals.dmi'
	idle_power_usage = 100

	var/siphoning = FALSE

	var/siphon_percent = 0
	var/siphon_request = 0
	var/ui_siphon_request = 0

	var/next_warning = 0
	var/obj/item/radio/radio
	var/radio_channel_cargo = RADIO_CHANNEL_SUPPLY
	var/radio_channel_sec = RADIO_CHANNEL_SECURITY
	var/minimum_time_between_warnings = 15 SECONDS

/obj/machinery/computer/bank_machine/Initialize()
	. = ..()
	radio = new(src)
	radio.subspace_transmission = TRUE
	radio.canhear_range = 0
	radio.channels += radio_channel_cargo
	radio.channels += radio_channel_sec
	radio.recalculateChannels()

/obj/machinery/computer/bank_machine/Destroy()
	QDEL_NULL(radio)
	. = ..()

/obj/machinery/computer/bank_machine/attackby(obj/item/I, mob/user)
	var/value = 0
	if(istype(I, /obj/item/stack/spacecash))
		var/obj/item/stack/spacecash/C = I
		value = C.value * C.amount
	else if(istype(I, /obj/item/holochip))
		var/obj/item/holochip/H = I
		value = H.credits
	if(value)
		var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
		if(D)
			D.adjust_money(value)
			to_chat(user, span_notice("You deposit [I]. The Cargo Budget is now $[D.account_balance]."))
		qdel(I)
		return
	return ..()

/obj/machinery/computer/bank_machine/process()
	..()
	if(siphoning)
		if(!siphon_request)
			var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
			if(D && D.account_balance >= 1)
				siphon_request = FLOOR(clamp(ui_siphon_request, 1, D.account_balance/100), 1)
			else
				end_syphon()
				return
			
		if (stat & (BROKEN|NOPOWER))
			say("Insufficient power. Halting siphon.")
			end_syphon()
			return
		
		playsound(src, 'sound/items/poster_being_created.ogg', 100, 1)

		siphon_percent = min(siphon_percent + rand(3,15), 100)
		
		if(next_warning < world.time && prob(20))
			var/area/A = get_area(loc)
			var/message = "Credit withdrawal underway in [A.map_name]!!"
			say("Credit withdrawal completion: [siphon_percent]%")
			radio.talk_into(src, message, radio_channel_cargo)
			radio.talk_into(src, message, radio_channel_sec)
			next_warning = world.time + minimum_time_between_warnings

/obj/machinery/computer/bank_machine/proc/end_syphon()
	siphoning = FALSE
	if(siphon_percent >= 100)
		say("Withdrawl of [siphon_request] credits complete.")
		var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
		if(D) // Purposefully don't check if they still have the money, so they go in debt if anyone tries to scum it
			D.adjust_money(-siphon_request*100) // Withdrawing money this way loses 99% of cargo points
		new /obj/item/holochip(drop_location(), siphon_request) //get the loot
	else
		say("Withdrawal ended prematurely! [siphon_request] credits could not be withdrawn.")
	siphon_request = 0
	siphon_percent = 0


/obj/machinery/computer/bank_machine/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BankMachine", name)
		ui.open()

/obj/machinery/computer/bank_machine/ui_data(mob/user)
	var/list/data = list()
	var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)

	if(D)
		data["current_balance"] = D.account_balance
	else
		data["current_balance"] = 0
	data["siphoning"] = siphoning
	data["ui_siphon_request"] = ui_siphon_request // Layer of security
	data["siphon_percent"] = siphon_percent // Completion
	data["station_name"] = station_name()

	return data

/obj/machinery/computer/bank_machine/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("siphon")
			say("Withdrawal of station credits has begun!")
			siphoning = TRUE
			. = TRUE
		if("halt")
			say("Station credit withdrawal halted.")
			end_syphon()
			. = TRUE
		if("siphon_amt")
			if(!siphoning)
				if(params["amount"] && isnum(params["amount"]))
					ui_siphon_request = params["amount"]
				. = TRUE
