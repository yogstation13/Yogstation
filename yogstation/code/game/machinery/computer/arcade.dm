/obj/machinery/computer/arcade/minesweeper
	name = "Minesweeper"
	desc = "An arcade machine that generates grids. It seems that the machine sparks and screeches when a grid is generated, as if it cannot cope with the intensity of generating the grid."
	icon_state = "arcade"
	circuit = /obj/item/circuitboard/computer/arcade/minesweeper
	
	var/datum/minesweeper/board

/obj/machinery/computer/arcade/minesweeper/Initialize()
	. = ..()
	board = new /datum/minesweeper()
	board.emaggable = TRUE
	board.host = src

/obj/machinery/computer/arcade/minesweeper/Destroy(force)
	board.host = null
	QDEL_NULL(board)
	. = ..()

/obj/machinery/computer/arcade/minesweeper/interact(mob/user, special_state)
	. = ..()
	if(!is_operational())
		return
	if(board.game_status == MINESWEEPER_IDLE || board.game_status == MINESWEEPER_DEAD || board.game_status == MINESWEEPER_VICTORY)
		if(obj_flags & EMAGGED)
			playsound(loc, 'yogstation/sound/arcade/minesweeper_emag2.ogg', 50, 0, extrarange = -3, falloff = 10)
		else
			playsound(loc, 'yogstation/sound/arcade/minesweeper_startup.ogg', 50, 0, extrarange = -3, falloff = 10)

	if(obj_flags & EMAGGED)
		do_sparks(5, 1, src)

	add_fingerprint(user)

/obj/machinery/computer/arcade/minesweeper/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!is_operational())
		return
	if(!ui)
		ui = new(user, src, "Minesweeper", name)
		ui.open()

/obj/machinery/computer/arcade/minesweeper/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/minesweeper),
	)

/obj/machinery/computer/arcade/minesweeper/ui_data(mob/user)
	var/list/data = ..()

	data["board_data"] = board.board_data
	data["game_status"] = board.game_status
	data["difficulty"] = board.diff_text(board.difficulty)
	data["current_difficulty"] = board.current_difficulty
	data["emagged"] = obj_flags & EMAGGED
	data["flag_mode"] = board.flag_mode
	data["tickets"] = board.ticket_count
	data["flags"] = board.flags
	data["current_mines"] = board.current_mines
	data["custom_height"] = board.custom_height
	data["custom_width"] = board.custom_width
	data["custom_mines"] = board.custom_mines
	var/display_time = (board.time_frozen ? board.time_frozen : REALTIMEOFDAY - board.starting_time) / 10
	data["time_string"] = board.starting_time ? "[add_leading(num2text(FLOOR(display_time / 60,1)), 2, "0")]:[add_leading(num2text(display_time % 60), 2, "0")]" : "00:00"
	
	return data

/obj/machinery/computer/arcade/minesweeper/ui_act(action, list/params, mob/user)
	if(..())
		return TRUE

	switch(action)
		if("PRG_do_tile")
			var/x = params["x"]
			var/y = params["y"]
			var/flagging = params["flag"]
			if(!x || !y)
				return

			return board.do_tile(x,y,flagging,user)
		
		if("PRG_new_game")
			board.play_snd('yogstation/sound/arcade/minesweeper_boardpress.ogg')
			board.generate_new_board(board.difficulty)
			board.current_difficulty = board.diff_text(board.difficulty)
			board.current_mines = board.mines
			board.flags = 0
			board.starting_time = 0
			return TRUE
		
		if("PRG_difficulty")
			var/diff = params["difficulty"]
			if(!diff)
				return
			board.play_snd('yogstation/sound/arcade/minesweeper_boardpress.ogg')
			board.difficulty = diff
			return TRUE

		if("PRG_height")
			var/cin = params["height"]
			if(!cin)
				return
			cin = text2num(cin)
			if(cin < 5 || cin > 17)
				cin = clamp(cin, 5, 17)
			board.custom_height = cin
			board.custom_mines = min(board.custom_mines, FLOOR(board.custom_width*board.custom_height/2,1))
			board.difficulty = MINESWEEPER_CUSTOM
			return TRUE
		
		if("PRG_width")
			var/cin = params["width"]
			if(!cin)
				return
			cin = text2num(cin)
			if(cin < 5 || cin > 30)
				cin = clamp(cin, 5, 30)
			board.custom_width = cin
			board.custom_mines = min(board.custom_mines, FLOOR(board.custom_width*board.custom_height/2,1))
			board.difficulty = MINESWEEPER_CUSTOM
			return TRUE
		
		if("PRG_mines")
			var/cin = params["mines"]
			if(!cin)
				return
			cin = text2num(cin)
			if(cin < 5 || cin > FLOOR(board.custom_width*board.custom_height/2,1))
				cin = clamp(cin, 5, FLOOR(board.custom_width*board.custom_height/2,1))
			board.custom_mines = cin
			board.difficulty = MINESWEEPER_CUSTOM
			return TRUE

		if("PRG_toggle_flag")
			board.play_snd('yogstation/sound/arcade/minesweeper_boardpress.ogg')
			board.flag_mode = !board.flag_mode
			return TRUE

		if("PRG_tickets")
			board.play_snd('yogstation/sound/arcade/minesweeper_boardpress.ogg')
			if(board.ticket_count >= 1)
				new /obj/item/stack/arcadeticket(loc, 1)
				to_chat(user, span_notice("[src] dispenses a ticket!"))
				board.ticket_count -= 1
			else
				to_chat(user, span_notice("You don't have any stored tickets!"))
			return TRUE

/obj/machinery/computer/arcade/minesweeper/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	desc = "An arcade machine that generates grids. It's clunking and sparking everywhere, almost as if threatening to explode at any moment!"
	do_sparks(5, 1, src)
	obj_flags |= EMAGGED
	if(board.game_status != MINESWEEPER_CONTINUE)
		to_chat(user, span_warning("An ominous tune plays from the arcade's speakers!"))
		playsound(user, 'yogstation/sound/arcade/minesweeper_emag1.ogg', 100, 0, extrarange = 3, falloff = 10)
	else	//Can't let you do that, star fox!
		to_chat(user, span_warning("The machine buzzes and sparks... the game has been reset!"))
		playsound(user, 'sound/machines/buzz-sigh.ogg', 100, 0, extrarange = 3, falloff = 10)	//Loud buzz
		board.game_status = MINESWEEPER_IDLE
