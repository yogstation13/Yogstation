/obj/machinery/paystand_custom
	name = "unregistered custom price pay stand"
	desc = "See title."
	icon = 'icons/obj/economy.dmi'
	icon_state = "card_scanner"
	density = TRUE
	anchored = TRUE
	var/obj/item/card/id/my_card

/obj/machinery/paystand/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/card/id))
		if(!my_card)
			var/obj/item/card/id/owner_card = W
			if(owner_card.registered_account)
				var/msg = stripped_input(user, "Name of pay stand:", "Paystand Naming", "[user]'s Awesome Paystand")
				if(!msg)
					return
				name = "[msg] (Custom Price)"
				desc = "Owned by [owner_card.registered_account.account_holder]. Pays directly into [user.p_their()] account when swiped with an ID card."
				my_card = owner_card
				to_chat(user, "You link the stand to your account.")
				return
		var/obj/item/card/id/payer_card = W
		if(payer_card.registered_account)
            var/stuff = input(user, "Enter price.", "Paystand Paying", 25) as num
			if(!stuff || stuff < 0)
					return
			if(payer_card.registered_account.adjust_money(-stuff))
				purchase(payer_card.registered_account.account_holder,stuff)
				to_chat(user, "Thanks for purchasing! The vendor has been informed.")
				return
			else
				to_chat(user, "Unsufficent funds.")
				return
		else
			to_chat(user, "Bank account not found.Please link an account to your ID and try again.")
			return
	if(istype(W, /obj/item/holochip))
		var/obj/item/holochip/H = W
		if(H.spend(price, FALSE))
			purchase(user)
			to_chat(user, "Thanks for purchasing! The vendor has been informed.")
			return
		else
			to_chat(user, "You trying to punk me, kid? Come back when you have the cash.")
			return
	if(istype(W, /obj/item/stack/spacecash))
		to_chat(user, "Physical money is not accepted.Please use your ID card")
		return
	if(istype(W, /obj/item/coin))
		to_chat(user, "Physical money is not accepted.Please use your ID card")
		return

	if(default_deconstruction_screwdriver(user, "card_scanner", "card_scanner", W))
		return

	else if(default_pry_open(W))
		return

	else if(default_unfasten_wrench(user, W))
		return

	else if(default_deconstruction_crowbar(W))
		return
	else
		return ..()
		
/obj/machinery/paystand/proc/purchase(buyer,paid)
	my_card.registered_account.adjust_money(paid)
	my_card.registered_account.bank_card_talk("Purchase made at your vendor by [buyer] for [paid] credits.")