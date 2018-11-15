/obj/machinery/paystand/advanced
	name = "unregistered advanced paystand"
	desc = "A FANCY advanced paystand."
	var/dumbtext = "Thanks for purchasing! The vendor has been informed."

/obj/machinery/paystand/advanced/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/card/id))
		if(!my_card)
			var/obj/item/card/id/assistant_mains_need_to_die = W
			if(assistant_mains_need_to_die.registered_account)
				var/msg = stripped_input(user, "Name of paystand:", "Paystand Naming", "[user]'s Awesome Paystand")
				if(!msg)
					return
				name = "[msg] (Advanced Stand)"
				desc = "Owned by [assistant_mains_need_to_die.registered_account.account_holder]. Pays directly into [user.p_their()] account after swiping an ID and typing in the amount you wish to pay."
				my_card = assistant_mains_need_to_die
				to_chat(user, "You link the stand to your account.")
				return
		var/obj/item/card/id/vbucks = W
		if(vbucks.registered_account)
			var/price2 = input(user, "Enter the amount you wish to pay.", "Paystand Paying", 100) as num
			if(!price2 || price2 < 0 || price2 > vbucks.registered_account.account_balance)
				to_chat(user, "<span class='warning'>ERROR : Transaction Failure.</span>")
				return
			price = price2
			vbucks.registered_account.adjust_money(-price)
			purchase(vbucks.registered_account.account_holder)
			to_chat(user, "[dumbtext]")
			return
		else
			to_chat(user, "You're going to need an actual bank account for that one, buddy.")
			return
	if(istype(W, /obj/item/holochip))
		return

	..()



/obj/machinery/paystand/advanced/security
	name = "security fine payer"
	desc = "A paystand designed for paying security fines at gun-point. Swipe your ID into it and type in the amount to do so."
	my_card = /obj/item/card/id/departmental_budget/sec // this doesnt even work on its own but it needs an id anyways so who cares
	dumbtext = "Thank you for giving your hard-earned money to Security for your hard-ass crimes!"

/obj/machinery/paystand/advanced/security/purchase(buyer)
	var/datum/bank_account/security_account = SSeconomy.get_dep_account(ACCOUNT_SEC)
	security_account.adjust_money(price)