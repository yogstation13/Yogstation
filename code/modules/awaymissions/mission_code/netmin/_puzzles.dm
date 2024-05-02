GLOBAL_VAR_INIT(decrypted_puzzle_disks, 0)
GLOBAL_LIST_EMPTY(button_puzzles)
GLOBAL_LIST_EMPTY(rock_paper_scissors_puzzle_answers)

/proc/rock_paper_scissors_puzzle()
	var/player_list = GLOB.player_list.Copy()

	for(var/mob/unsorted_players in player_list)
		if(unsorted_players.job == "Network Admin")
			player_list -= unsorted_players
		if(!unsorted_players.client)
			player_list -= unsorted_players
		else	
			if(unsorted_players.client.address in list("127.0.0.1", "::1"))
				player_list -= unsorted_players

	var/players_to_ask = 3
	if(length(player_list) < players_to_ask)
		players_to_ask = length(player_list)

	while(players_to_ask > 0)
		var/mob/player = pick_n_take(player_list)
		var/answer = tgui_input_list(player, "You've been selected for a quick game of rock-paper-scissors. Unfortunately we cannot tell you if you win.", "Rock Paper Scissors", list("Rock", "Paper", "Scissors"))
		if(!answer)
			GLOB.rock_paper_scissors_puzzle_answers += pick("Rock", "Paper", "Scissors")
		else
			GLOB.rock_paper_scissors_puzzle_answers += answer
		players_to_ask--

/obj/item/disk/puzzle
	name = "encrypted floppy drive"
	desc = "Likely contains the access key to a locked door."
	icon = 'icons/obj/card.dmi'
	icon_state = "data_3"
	item_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	var/decrypted = FALSE
	var/id
	var/decryption_progress = 0
	var/detail_color = COLOR_ASSEMBLY_BLUE

/obj/item/disk/puzzle/examine(mob/user)
	. = ..()
	. += "The disk seems to be [decrypted ? "decrypted" : "encrypted"]."

/obj/item/disk/puzzle/Initialize(mapload)
	.=..()
	update_icon()

/obj/item/disk/puzzle/update_overlays()
	. = ..()
	if(detail_color == COLOR_FLOORTILE_GRAY)
		return
	var/mutable_appearance/detail_overlay = mutable_appearance('icons/obj/card.dmi', "[icon_state]-color")
	detail_overlay.color = detail_color
	add_overlay(detail_overlay)


/datum/button_puzzle_holder
	var/id
	var/list/buttons = list()
	var/list/doors = list()
	var/list/papers = list()
	var/index = 1


/datum/button_puzzle_holder/New()
	addtimer(CALLBACK(src, PROC_REF(generate_order)), 5 SECONDS)

/datum/button_puzzle_holder/proc/generate_order()
	shuffle_inplace(buttons)

	var/number = 1
	for(var/obj/item/paper/fluff/awaymissions/button_puzzle/paper in papers)
		var/obj/machinery/button_puzzle/button = buttons[number]
		paper.generate(number, button.name)
		number++
	
/datum/button_puzzle_holder/proc/reset()
	index = 1

/datum/button_puzzle_holder/proc/button_pressed(obj/machinery/button_puzzle/button)
	if(index > buttons.len)
		open_doors()
		return

	if(buttons[index] == button)
		index++
	else
		reset()

	if(index > buttons.len)
		open_doors()
		return

/datum/button_puzzle_holder/proc/open_doors()
	for(var/obj/machinery/door/password/button_puzzle/door in doors)
		door.open()

/obj/item/paper/fluff/awaymissions/button_puzzle
	name = "MEMORY DUMP"
	info = "<b>MEMORY DUMPED. CONTENTS:</b> <br>49EA+<b></b>g4cF"
	var/id

/obj/item/paper/fluff/awaymissions/button_puzzle/proc/generate(number, order)
	info = "<b>MEMORY DUMPED. CONTENTS:</b> <br>49EA+<b>[number] - [order]</b>g4cF"

/obj/item/paper/fluff/awaymissions/button_puzzle/Initialize(mapload)
	. = ..()
	var/found_datum = FALSE
	for(var/datum/button_puzzle_holder/holder in GLOB.button_puzzles)
		if(holder.id == id)
			holder.papers += src
			found_datum = TRUE
			break
	if(!found_datum)
		var/datum/button_puzzle_holder/H = new()
		H.id = id
		H.papers += src
		GLOB.button_puzzles += H


/obj/machinery/button_puzzle
	name = "button"
	desc = "A remote control switch."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl"
	var/skin = "doorctrl"
	var/id = null
	var/order

	var/datum/button_puzzle_holder/manager

	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/machinery/button_puzzle/Initialize(mapload)
	. = ..()

	name = "[initial(name)] - [random_nukecode(4)]"
	if(id)
		var/found_datum = FALSE
		for(var/datum/button_puzzle_holder/holder in GLOB.button_puzzles)
			if(holder.id == id)
				holder.buttons += src
				manager = holder
				found_datum = TRUE
				break

		if(!found_datum)
			var/datum/button_puzzle_holder/H = new()
			H.id = id
			H.buttons += src
			manager = H
			GLOB.button_puzzles += H
	

/obj/machinery/button_puzzle/update_icon_state()
	. = ..()
	if(panel_open)
		icon_state = "button-open"
	else
		if(stat & (NOPOWER|BROKEN))
			icon_state = "[skin]-p"
		else
			icon_state = skin


/obj/machinery/button_puzzle/attackby(obj/item/W, mob/user, params)
	if(user.a_intent != INTENT_HARM && !(W.item_flags & NOBLUDGEON))
		return attack_hand(user)
	else
		return ..()


/obj/machinery/button_puzzle/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	add_fingerprint(user)
	play_click_sound("button")


	use_power(5)
	icon_state = "[skin]1"

	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom/, update_icon)), 15)
	manager.button_pressed(src)

