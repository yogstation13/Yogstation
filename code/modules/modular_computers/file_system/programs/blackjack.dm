#define BLACKJACK_CONTINUE 0
#define BLACKJACK_LOSS 1
#define BLACKJACK_WIN 2
#define BLACKJACK_TIE 3
#define BLACKJACK_IDLE 4
#define BLACKJACK_DEALER_TURN 5

#define JACK_CARD "J"
#define QUEEN_CARD "Q"
#define KING_CARD "K"
#define ACE_CARD "A"

/datum/computer_file/program/blackjack
	filename = "blackjack"
	filedesc = "Nanotrasen Micro Arcade: Blackjack"
	program_icon_state = "arcade"
	extended_desc = "Nanotrasen does not permit anyone under the age of 21 to partake in gambling. Requires an NTNet connection."
	requires_ntnet = TRUE
	network_destination = "arcade network"
	size = 4
	tgui_id = "NtosBlackjack"
	program_icon = "gamepad"

	var/game_state = BLACKJACK_IDLE
	/// Card format is value and suit i.e. "2H" = 2 of Hearts, "KC" = King of Clubs
	var/list/active_player_cards = list()
	var/list/active_dealer_cards = list()
	var/list/current_deck = list()
	var/credits_stored = 0
	var/active_wager = 0
	var/set_wager = 5

	var/game_end_reason = ""

	var/game_id = 0

	var/datum/bank_account/temp_account // Call refresh_id_account() or get_credit_amount() before using this

/datum/computer_file/program/blackjack/proc/refresh_id_account()
	temp_account = null
	if(holder && istype(holder.holder, /obj/item/modular_computer))
		var/obj/item/modular_computer/computer = holder.holder
		var/obj/item/card/id/stored_card = computer.GetID()
		if(istype(stored_card) && istype(stored_card.registered_account))
			temp_account = stored_card.registered_account
			return stored_card.registered_account

/datum/computer_file/program/blackjack/proc/get_credit_amount()
	refresh_id_account()
	return temp_account?.account_balance || credits_stored

/datum/computer_file/program/blackjack/proc/adjust_credits(amt)
	if(refresh_id_account())
		temp_account.adjust_money(amt)
	else
		credits_stored += amt

/datum/computer_file/program/blackjack/proc/new_game()
	if(set_wager <= 0 || get_credit_amount() < set_wager)
		return

	game_id++

	adjust_credits(-set_wager)
	active_wager = set_wager

	game_state = BLACKJACK_CONTINUE
	game_end_reason = ""
	active_player_cards = list()
	active_dealer_cards = list()
	current_deck = list(
		"2S","3S","4S","5S","6S","7S","8S","9S","10S","JS","QS","KS","AS",
		"2H","3H","4H","5H","6H","7H","8H","9H","10H","JH","QH","KH","AH",
		"2C","3C","4C","5C","6C","7C","8C","9C","10C","JC","QC","KC","AC",
		"2D","3D","4D","5D","6D","7D","8D","9D","10D","JD","QD","KD","AD"
	)
	shuffle_inplace(current_deck)

	// smooth
	play_snd('sound/machines/switch3.ogg')
	active_player_cards += pop(current_deck)
	active_dealer_cards += pop(current_deck)
	active_player_cards += pop(current_deck)

/datum/computer_file/program/blackjack/proc/calculate_hand_worth(list/hand)
	var/worth = 0
	var/aces = 0
	var/list/hand_copy = LAZYCOPY(hand)
	for(var/card in hand_copy)
		card = copytext(card, 1, -1) // Remove the suit, we do not care about it
		if(text2num(card))
			worth += text2num(card)
		else
			switch(card)
				if(JACK_CARD, QUEEN_CARD, KING_CARD) // "Picture" cards are worth 10
					worth += 10
				if(ACE_CARD) // Aces are calculated last
					aces += 1

	for(var/i in 1 to aces) // Ace is worth either 1 or 11, whichever is more beneficial
		if(worth < 12 - aces) // This algorithm will never surpass 21 unless you have too many aces (somehow)
			worth += 11
		else
			worth += 1

	return worth

/datum/computer_file/program/blackjack/ui_data(mob/user)
	var/list/data = get_header_data()

	data["game_state"] = game_state
	data["active_dealer_cards"] = active_dealer_cards
	data["active_player_cards"] = active_player_cards
	data["credits_stored"] = get_credit_amount()
	data["local_credits"] = credits_stored
	data["has_id"] = !!temp_account
	data["active_wager"] = active_wager
	data["set_wager"] = set_wager
	data["game_end_reason"] = game_end_reason

	return data

/datum/computer_file/program/blackjack/try_insert(obj/item/inserted_item, mob/living/user)
	if(!holder || !istype(holder?.holder, /obj/item/modular_computer))
		return FALSE

	if(!inserted_item.get_item_credit_value())
		return FALSE

	credits_stored += inserted_item.get_item_credit_value()
	QDEL_NULL(inserted_item)
	play_snd('sound/machines/ping.ogg')
	SStgui.try_update_ui(user, src)
	return TRUE

/datum/computer_file/program/blackjack/proc/play_snd(sound_path)
	if(holder && istype(holder.holder, /obj/item/modular_computer))
		var/obj/item/modular_computer/computer = holder.holder
		computer.play_computer_sound(sound_path, 40, 1)

/datum/computer_file/program/blackjack/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(..())
		return .

	if(ishuman(usr))
		var/mob/living/carbon/human/user = usr
		if(user.age < 21) // We do not condone underage gambling
			play_snd('sound/machines/buzz-sigh.ogg')
			return FALSE

	switch(action)
		if("PRG_new_game")
			new_game()
			return TRUE

		if("PRG_eject_credits")
			if(credits_stored < 1)
				return FALSE
			var/obj/item/holochip/holochip = new (usr.drop_location(), credits_stored)
			usr.put_in_hands(holochip)
			to_chat(usr, span_notice("You withdraw [credits_stored] credits into a holochip."))
			credits_stored = 0
			play_snd('sound/machines/click.ogg')
			return TRUE

		if("PRG_set_wager")
			if(!isnum(text2num(params["wager"])))
				return FALSE
			var/new_wager = text2num(params["wager"])
			if(round(new_wager) < 1)
				return FALSE
			set_wager = round(new_wager)
			play_snd('sound/machines/click.ogg')
			return TRUE

		if("PRG_hit")
			if(game_state != BLACKJACK_CONTINUE)
				return FALSE
			play_snd('sound/machines/switch3.ogg')
			active_player_cards += pop(current_deck)
			check_player_hand(usr)
			return TRUE

		if("PRG_stand")
			if(game_state != BLACKJACK_CONTINUE)
				return FALSE
			game_state = BLACKJACK_DEALER_TURN
			addtimer(CALLBACK(src, PROC_REF(dealer_turn), game_id, usr), 1 SECONDS)
			play_snd('sound/machines/click.ogg')
			return TRUE

		if("PRG_double_down")
			if(game_state != BLACKJACK_CONTINUE)
				return FALSE
			if(get_credit_amount() < active_wager)
				return
			adjust_credits(-active_wager)
			active_wager *= 2
			play_snd('sound/machines/switch3.ogg')
			active_player_cards += pop(current_deck)
			if(!check_player_hand(usr))
				game_state = BLACKJACK_DEALER_TURN
				addtimer(CALLBACK(src, PROC_REF(dealer_turn), game_id, usr), 1 SECONDS)
			return TRUE

/datum/computer_file/program/blackjack/proc/check_player_hand(mob/user)
	var/worth = calculate_hand_worth(active_player_cards)
	if(worth == 21)
		game_state = BLACKJACK_DEALER_TURN
		addtimer(CALLBACK(src, PROC_REF(dealer_turn), game_id, user), 1 SECONDS)
		return TRUE

	if(worth > 21)
		game_state = BLACKJACK_LOSS
		game_end_reason = "You busted!"
		active_wager = 0
		play_snd('sound/machines/buzz-two.ogg')
		return TRUE

	return FALSE

/datum/computer_file/program/blackjack/proc/dealer_turn(g_id, mob/user)
	if(game_state != BLACKJACK_DEALER_TURN || game_id != g_id)
		return

	play_snd('sound/machines/switch1.ogg')
	active_dealer_cards += pop(current_deck)
	SStgui.try_update_ui(user, src)

	var/dealer_worth = calculate_hand_worth(active_dealer_cards)
	if(dealer_worth < 17) // Dealer draws until it has 17 or higher
		addtimer(CALLBACK(src, PROC_REF(dealer_turn), game_id, user), 1 SECONDS)
		return

	var/player_worth = calculate_hand_worth(active_player_cards)
	// check_player_hand() already checked for player bust
	if(dealer_worth == player_worth)
		game_state = BLACKJACK_TIE
		adjust_credits(active_wager)
		active_wager = 0
		SStgui.try_update_ui(user, src)
		play_snd('sound/machines/button1.ogg')
		return

	if(dealer_worth > 21 || player_worth > dealer_worth)
		if(dealer_worth > 21)
			game_end_reason = "Dealer busted!"
		else
			game_end_reason = "You won!"
		game_state = BLACKJACK_WIN
		adjust_credits(active_wager * 2)
		active_wager = 0
		SStgui.try_update_ui(user, src)
		play_snd('sound/machines/chime.ogg')
		return

	if(player_worth < dealer_worth) // this is redundant, but it helps understand what is happening
		game_state = BLACKJACK_LOSS // | || || |_
		game_end_reason = "You lost!"
		active_wager = 0
		SStgui.try_update_ui(user, src)
		play_snd('sound/machines/buzz-two.ogg')
		return

#undef BLACKJACK_CONTINUE
#undef BLACKJACK_LOSS
#undef BLACKJACK_WIN
#undef BLACKJACK_TIE
#undef BLACKJACK_IDLE
#undef BLACKJACK_DEALER_TURN

#undef JACK_CARD
#undef QUEEN_CARD
#undef KING_CARD
#undef ACE_CARD
