/obj/machinery/paystand_custom
	name = "unregistered custom price pay stand"
	desc = "See title."
	icon = 'icons/obj/economy.dmi'
	icon_state = "card_scanner"
	density = TRUE
	anchored = TRUE
	var/obj/item/card/id/my_card
	var/obj/item/electronics/airlock/board

/obj/machinery/paystand_custom/Initialize()
	check_access(null)
	if(req_access.len || req_one_access.len)
		board = new(src)
		if(req_access.len)
			board.accesses = req_access
		else
			board.one_access = 1
			board.accesses = req_one_access

/obj/machinery/paystand_custom/attackby(obj/item/W, mob/user, params)
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
			if(!allowed(user))
				to_chat(user, "<span class='danger'>Access Denied</span>")
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
		to_chat(user, "Physical money is not accepted.Please use your ID card")
		return
	if(istype(W, /obj/item/stack/spacecash))
		to_chat(user, "Physical money is not accepted.Please use your ID card")
		return
	if(istype(W, /obj/item/coin))
		to_chat(user, "Physical money is not accepted.Please use your ID card")
		return

	if(W.tool_behaviour == TOOL_SCREWDRIVER)
		if(panel_open || allowed(user))
			default_deconstruction_screwdriver(user, "card_scanner", "card_scanner",W)
			update_icon()
		else
			to_chat(user, "<span class='danger'>Access Denied</span>")

	else if(default_pry_open(W))
		return

	else if(default_unfasten_wrench(user, W))
		return

	else if(default_deconstruction_crowbar(W))
		return
	else if(panel_open)
		if(!board && istype(W, /obj/item/electronics/airlock))
			if(!user.transferItemToLoc(W, src))
				to_chat(user, "<span class='warning'>\The [W] is stuck to you!</span>")
				return
			board = W
			if(board.one_access)
				req_one_access = board.accesses
			else
				req_access = board.accesses
			to_chat(user, "<span class='notice'>You add [W] to the paystand.</span>")
	else
		return ..()

/obj/machinery/paystand_custom/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	add_fingerprint(user)
	if(panel_open)
		if(board)
			if(board)
				board.forceMove(drop_location())
				req_access = list()
				req_one_access = list()
				board = null
			to_chat(user, "<span class='notice'>You remove electronics from the paystand.</span>")

/obj/machinery/paystand_custom/proc/purchase(buyer,paid)
	my_card.registered_account.adjust_money(paid)
	my_card.registered_account.bank_card_talk("Purchase made at your vendor by [buyer] for [paid] credits.")