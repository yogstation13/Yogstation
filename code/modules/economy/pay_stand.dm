/obj/machinery/paystand
	name = "unregistered pay stand"
	desc = "See title."
	icon = 'icons/obj/economy.dmi'
	icon_state = "card_scanner"
	density = TRUE
	anchored = TRUE
	circuit = /obj/item/circuitboard/machine/paystand
	var/locked = FALSE
	var/obj/item/card/id/my_card
	var/obj/item/assembly/signaler/signaler //attached signaler, let people attach signalers that get activated if the user's transaction limit is achieved.
	var/signaler_threshold = 0 //signaler threshold amount
	var/amount_deposited = 0 //keep track of the amount deposited over time so you can pay multiple times to reach the signaler threshold
	var/invoice = "" //keep track of items in the paystand
	var/paynum = 0 //keep track of receipt number
	var/price = 0 //keep track of invoice price

/obj/machinery/paystand/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/card/id))
		if(!my_card)
			var/obj/item/card/id/assistant_mains_need_to_die = W
			if(assistant_mains_need_to_die.registered_account)
				var/msg = stripped_input(user, "Name of pay stand:", "Paystand Naming", "[user]'s Awesome Paystand")
				if(!msg)
					return
				name = msg
				message_admins("The paystand at X:[src.x] Y:[src.y] Z:[src.z][ADMIN_COORDJMP(src)] was named [msg] by [ADMIN_LOOKUPFLW(user)]")
				desc = "Owned by [assistant_mains_need_to_die.registered_account.account_holder], pays directly into [user.p_their()] account."
				my_card = assistant_mains_need_to_die
				to_chat(user, "You link the stand to your account.")
				return
		if(W == my_card)
			var/whichact = input(user, "Choose an action", src.name) as null|anything in list("Toggle Bolts","Add item to invoice","Clear invoice","View invoice","View stats","Cancel")
			switch(whichact)
				if("Toggle Bolts")
					locked = !locked
					to_chat(user, span_notice("You [src.locked ? "lock" : "unlock"] the bolts on the paystand."))
					return
				if("Add item to invoice")
					var/addAnotherItem = TRUE
					var/askAdd = ""
					while(addAnotherItem)
						var/msg = stripped_input(user, "Item?","Paystand - Add Item","Banana")
						var/cost = FLOOR(input(user, "[msg] cost?", "Paystand - Add Item", 5) as num, 1)
						if (cost < 1)
							if (cost < 0)
								to_chat(user, span_notice("Invalid cost! Item discarded."))
								addAnotherItem = FALSE
							invoice = invoice + "<br>[msg]\tFREE!"
							to_chat(user,span_notice("Added [msg] for free to the invoice! Invoice Total: [price] credits!"))
							playsound(src, 'sound/machines/beep.ogg', 100)
							visible_message("[icon2html(src,world)][src] displays, " + span_notice("\"[msg] - <i>FREE</i>\""))
							askAdd = input(user, "Add another item?", src.name) as null|anything in list("Yes","No")
							if(!askAdd || askAdd == "No")
								addAnotherItem = FALSE
						else
							price = price + cost
							invoice = invoice + "<br>[msg]\t[cost] credits"
							to_chat(user,span_notice("Added [msg] for [cost] credits to the invoice! Invoice Total: [price] credits!"))
							playsound(src, 'sound/machines/beep.ogg', 100)
							visible_message("[icon2html(src,world)][src] displays, " + span_notice("\"[msg] - <i>[cost] credits</i>\""))
							askAdd = input(user, "Add another item?", src.name) as null|anything in list("Yes","No")
							if(!askAdd || askAdd == "No")
								addAnotherItem = FALSE
					return //this return shouldn't be needed, but as a failsafe
				if("Clear invoice")
					invoice = ""
					price = 0
					to_chat(user,span_warning("Invoice cleared!"))
					playsound(src, 'sound/machines/buzz-sigh.ogg', 100)
					visible_message("[icon2html(src,world)][src] displays, " + span_warning("Invoice cleared."))
					return
				if("View invoice")
					to_chat(user,span_notice("Current invoice:[invoice]<br>Total Cost: [price] credits."))
					return
				if("View stats")
					to_chat(user,span_notice("Transactions Processed: [paynum]<br>Total earned: [amount_deposited]"))
					return
				if("Cancel")
					return
		var/obj/item/card/id/vbucks = W
		if(vbucks.registered_account)
			if(!my_card)
				to_chat(user, span_warning("ERROR: No bank account assigned to pay stand."))
				return
			if(invoice == "")
				var/momsdebitcard = input(user, "How much would you like to deposit?", "Money Deposit") as null|num
				if(momsdebitcard < 1)
					to_chat(user, span_warning("ERROR: Invalid amount designated."))
					return
				if(vbucks.registered_account.adjust_money(-momsdebitcard))
					purchase(vbucks.registered_account.account_holder, momsdebitcard)
					playsound(src, "sound/items/scanner_match.ogg", 100)
					to_chat(user, "Thanks for purchasing! The vendor has been informed.")
					return
				else
					to_chat(user, span_warning("ERROR: Account has insufficient funds to make transaction."))
					return
			else
				var/continue_transaction = input(user, "The paystand displays [price] credits as the total owed. Continue transaction?", "Transaction") as null|anything in list("Pay","Cancel")
				if(!continue_transaction || continue_transaction == "Cancel")
					to_chat(user,span_notice("You decide not to pay [my_card.registered_account.account_holder] the displayed amount."))
					return
				else
					if(vbucks.registered_account.adjust_money(-price))
						purchase(vbucks.registered_account.account_holder, price)
						to_chat(user, "Thanks for your purchase of [price] credits. The vendor has been notified. Please take your receipt.")
						handle_receipt(TRUE)
						invoice = ""
						price = 0
						return
					else
						to_chat(user, span_warning("ERROR: Account has insufficient funds to make transaction."))
						return

		else
			to_chat(user, span_warning("ERROR: No bank account assigned to identification card."))
			return
	if(istype(W, /obj/item/holochip))
		var/obj/item/holochip/H = W
		if(invoice == "")
			var/cashmoney = input(user, "How much would you like to deposit?", "Money Deposit") as null|num
			if(H.spend(cashmoney, FALSE))
				purchase(user, cashmoney)
				to_chat(user, "Thanks for purchasing! The vendor has been informed.")
				return
			else
				to_chat(user, span_warning("ERROR: Insufficient funds to make transaction."))
				return
		else
			var/continue_transaction = input(user, "The paystand displays [price] credits as the total owed. Continue transaction?", "Transaction") as null|anything in list("Pay","Cancel")
			if(!continue_transaction || continue_transaction == "Cancel")
				to_chat(user,span_notice("You decide not to pay [my_card.registered_account.account_holder] the displayed amount."))
				return
			if(H.spend(price, FALSE))
				purchase(user, price)
				to_chat(user, "Thanks for your purchase of [price] credits. The vendor has been notified. Please take your receipt.")
				handle_receipt(FALSE)
				invoice = ""
				price = 0
				return
			else
				to_chat(user, span_warning("ERROR: Insufficient funds to make transaction."))
				return
	if(istype(W, /obj/item/stack/spacecash))
		to_chat(user, "What is this, the 2000s? We only take card here.")
		return
	if(istype(W, /obj/item/coin))
		to_chat(user, "What is this, the 1800s? We only take card here.")
		return
	if(istype(W, /obj/item/assembly/signaler))
		var/obj/item/assembly/signaler/S = W
		if(S.secured)
			to_chat(user, span_warning("The signaler needs to be in attachable mode to add it to the paystand!"))
			return
		if(!my_card)
			to_chat(user, span_warning("ERROR: No identification card has been assigned to this paystand yet!"))
			return
		if(!signaler)
			var/cash_limit = input(user, "Enter the minimum amount of cash needed to deposit before the signaler is activated.", "Signaler Activation Threshold") as null|num
			if(cash_limit < 1)
				to_chat(user, span_warning("ERROR: Invalid amount designated."))
				return
			if(cash_limit)
				S.forceMove(src)
				signaler = S
				signaler_threshold = cash_limit
				to_chat(user, "You attach the signaler to the paystand.")
				desc += " A signaler appears to be attached to the scanner."
		else
			to_chat(user, span_warning("A signaler is already attached to this unit!"))

	if(default_deconstruction_screwdriver(user, icon_state, icon_state, W))
		return

	else if(default_pry_open(W))
		return

	else if(default_unfasten_wrench(user, W))
		return

	else if(default_deconstruction_crowbar(W))
		return
	else
		return ..()

/obj/machinery/paystand/proc/handle_receipt(card_pay)
	playsound(src, "sound/items/scanner_match.ogg", 100)
	paynum += 1
	var/obj/item/paper/P = new /obj/item/paper(src)
	var/obj/item/paper/M = new /obj/item/paper(src)
	P.written += new/datum/langtext("<center><h3>Receipt from [src.name]</h3></center><hr><b>Vendor: [my_card.registered_account.account_holder]<br>Receipt #[paynum]<br>",/datum/language/common)
	if(card_pay)
		P.written += new/datum/langtext("Payment Method: CARD<hr></b>",/datum/language/common)
	else
		P.written += new/datum/langtext("Payment Method: HOLOCHIP<hr></b>",/datum/language/common)
	P.written += new/datum/langtext("<b>Items Purchased:</b>[invoice]<hr><b>Total: [price] credits.</b><br>Thanks for your patronage!<br>Customer Copy",/datum/language/common)
	P.name = "Receipt #[paynum] from [src.name] - Customer Copy"
	P.desc = "A receipt generated by a paystand. This one lists a total of [price] credits."
	M.written += new/datum/langtext("<center><h3>Receipt from [src.name]</h3></center><hr><b>Vendor: [my_card.registered_account.account_holder]<br>Receipt #[paynum]<hr></b>",/datum/language/common)
	M.written += new/datum/langtext("<b>Items Purchased:</b>[invoice]<hr><b>Total: [price] credits.</b><br>Thanks for your patronage!<br>Merchant Copy",/datum/language/common)
	M.name = "Receipt #[paynum] from [src.name] - Merchant Copy"
	M.desc = "A receipt generated by a paystand. This one lists a total of [price] credits."
	P.update_icon()
	M.update_icon()
	P.forceMove(src.loc)
	M.forceMove(src.loc)

/obj/machinery/paystand/proc/purchase(buyer, price)
	if(!my_card)
		return
	my_card.registered_account.adjust_money(price)
	my_card.registered_account.bank_card_talk("Purchase made at your vendor by [buyer] for [price] credits.")
	amount_deposited = amount_deposited + price
	if(signaler && amount_deposited >= signaler_threshold)
		signaler.activate()
		amount_deposited = 0

/obj/machinery/paystand/default_unfasten_wrench(mob/user, obj/item/I, time = 20)
	if(locked)
		to_chat(user, span_warning("The anchored bolts on this paystand are currently locked!"))
		return
	. = ..()
