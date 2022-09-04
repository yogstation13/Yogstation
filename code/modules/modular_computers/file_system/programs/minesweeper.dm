#define MINESWEEPER_BEGINNER 1
#define MINESWEEPER_INTERMEDIATE 2
#define MINESWEEPER_EXPERT 3

#define MINESWEEPER_CONTINUE 0
#define MINESWEEPER_DEAD 1
#define MINESWEEPER_VICTORY 2
#define MINESWEEPER_IDLE 3

/datum/computer_file/program/minesweeper
	filename = "minesweeper"
	filedesc = "Nanotrasen Micro Arcade: Minesweeper"
	program_icon_state = "arcade"
	extended_desc = "A port of the classic game 'Minesweeper', redesigned to run on tablets."
	requires_ntnet = FALSE
	network_destination = "arcade network"
	size = 6
	tgui_id = "NtosMinesweeper"
	program_icon = "gamepad"

	var/ticket_count = 0
	var/flag_mode = FALSE
	var/flags = 0
	var/difficulty = MINESWEEPER_BEGINNER

	var/game_status = MINESWEEPER_IDLE

	// board_data[y][x]
	// Y-coord must go first so that it loops by rows
	var/board_data[31][17] 
	var/mine_spots = list()
	var/width = 10
	var/height = 10
	var/mines = 10

	var/tiles_left = 100

/datum/computer_file/program/minesweeper/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/minesweeper),
	)

/datum/computer_file/program/minesweeper/ui_data(mob/user)
	var/list/data = get_header_data()

	data["board_data"] = board_data
	data["game_status"] = game_status
	data["difficulty"] = diff_text(difficulty)
	data["emagged"] = FALSE
	data["flag_mode"] = flag_mode
	data["tickets"] = ticket_count
	
	return data

/datum/computer_file/program/minesweeper/ui_act(action, list/params, mob/user)
	if(..())
		return TRUE
	var/obj/item/computer_hardware/printer/printer
	if(computer)
		printer = computer.all_components[MC_PRINT]

	switch(action)
		if("PRG_do_tile")
			var/x = params["x"]
			var/y = params["y"]
			var/flagging = params["flag"]
			if(!x || !y)
				return
			
			if(game_status)
				return

			if(board_data[y][x] != "minesweeper_hidden.png" && !flag_mode && !flagging)
				return
			
			if(flag_mode || flagging)
				if(board_data[y][x] == "minesweeper_hidden.png")
					board_data[y][x] = "minesweeper_flag.png"
					flags++
					computer.play_computer_sound('yogstation/sound/arcade/minesweeper_boardpress.ogg', 50, 0)
				else if(board_data[y][x] == "minesweeper_flag.png")
					board_data[y][x] = "minesweeper_hidden.png"
					flags--
					computer.play_computer_sound('yogstation/sound/arcade/minesweeper_boardpress.ogg', 50, 0)
				else
					return
				return TRUE

			computer.play_computer_sound('yogstation/sound/arcade/minesweeper_boardpress.ogg', 50, 0)

			while(height * width == tiles_left && !is_blank_tile_start(x,y))
				generate_new_board(difficulty) // The first selected tile will always be a blank one.

			var/result = select_square(x,y)
			game_status = result
			if(result == MINESWEEPER_VICTORY)
				computer.play_computer_sound('yogstation/sound/arcade/minesweeper_win.ogg', 50, 0)
				ticket_count += difficulty

			return TRUE
		
		if("PRG_new_game")
			computer.play_computer_sound('yogstation/sound/arcade/minesweeper_boardpress.ogg', 50, 0)
			generate_new_board(difficulty)
			return TRUE
		
		if("PRG_difficulty")
			var/diff = params["difficulty"]
			if(!diff)
				return
			computer.play_computer_sound('yogstation/sound/arcade/minesweeper_boardpress.ogg', 50, 0)
			difficulty = diff
			return TRUE

		if("PRG_toggle_flag")
			computer.play_computer_sound('yogstation/sound/arcade/minesweeper_boardpress.ogg', 50, 0)
			flag_mode = !flag_mode
			return TRUE

		if("PRG_tickets")
			computer.play_computer_sound('yogstation/sound/arcade/minesweeper_boardpress.ogg', 50, 0)
			if(!printer)
				to_chat(user, span_notice("Hardware error: A printer is required to redeem tickets."))
				return
			if(printer.stored_paper <= 0)
				to_chat(user, span_notice("Hardware error: Printer is out of paper."))
				return
			else
				computer.visible_message(span_notice("\The [computer] prints out paper."))
				if(ticket_count >= 1)
					new /obj/item/stack/arcadeticket((get_turf(computer)), 1)
					to_chat(user, span_notice("[src] dispenses a ticket!"))
					ticket_count -= 1
					printer.stored_paper -= 1
				else
					to_chat(user, span_notice("You don't have any stored tickets!"))
				return TRUE

/datum/computer_file/program/minesweeper/proc/generate_new_board(diff)
	board_data = new /list(31,17) // Fresh board
	mine_spots = list()

	switch(diff)
		if(MINESWEEPER_BEGINNER) // 10x10, 10 mines
			height = 10
			width = 10
			mines = 10
		if(MINESWEEPER_INTERMEDIATE) // 17x17, 40 mines
			height = 17
			width = 17
			mines = 40
		if(MINESWEEPER_EXPERT) // 30x16, 99 mines
			height = 30
			width = 16
			mines = 99
	
	tiles_left = height * width

	mines = min(tiles_left-1, mines) // Crash protection
	
	for(var/i=1, i<mines+1, i++) // Set up mines
		var/mine_spot = list(rand(0,width-1),rand(0,height-1))
		while(find_in_mines(mine_spot)) // There's already a mine here! Choose another spot
			mine_spot = list(rand(0,width-1),rand(0,height-1))
		mine_spots += list(mine_spot)
	
	for(var/y=1, y<height+1, y++) // Set all squares to be hidden
		for(var/x=1, x<width+1, x++)
			board_data[y][x] = "minesweeper_hidden.png"

	game_status = MINESWEEPER_CONTINUE

/datum/computer_file/program/minesweeper/proc/select_square(x,y)
	if(find_in_mines(list(x-1,y-1)))
		board_data[y][x] = "minesweeper_minehit.png"
		for(var/list/mine in mine_spots)
			if(mine[1] == x-1 && mine[2] == y-1)
				continue
			board_data[mine[2]+1][mine[1]+1] = "minesweeper_mine.png"
		switch(rand(1,3))
			if(1)
				computer.play_computer_sound('yogstation/sound/arcade/minesweeper_explosion1.ogg', 50, 0)
			if(2)
				computer.play_computer_sound('yogstation/sound/arcade/minesweeper_explosion2.ogg', 50, 0)
			if(3)
				computer.play_computer_sound('yogstation/sound/arcade/minesweeper_explosion3.ogg', 50, 0)
		return MINESWEEPER_DEAD
	
	tiles_left--

	var/mine_count = 0
	for(var/scanx=-1, scanx<2, scanx++) // -1, 0, 1
		for(var/scany=-1, scany<2, scany++)
			if(scanx+x < 1 || scany+y < 1)
				continue
			if(scanx == 0 && scany == 0) // We know we aren't a mine
				continue
			if(board_data[scany+y][scanx+x] != "minesweeper_hidden.png")
				continue
			if(find_in_mines(list(scanx+x-1,scany+y-1)))
				mine_count++
	
	if(mine_count == 0) // There are no mines around me! Select every square adjacent!
		board_data[y][x] = "minesweeper_empty.png"
		for(var/scanx=-1, scanx<2, scanx++) // -1, 0, 1
			for(var/scany=-1, scany<2, scany++)
				if(scanx+x < 1 || scany+y < 1)
					continue
				if(scanx == 0 && scany == 0)
					continue
				if(board_data[scany+y][scanx+x] != "minesweeper_hidden.png")
					continue
				select_square(scanx+x,scany+y)
	else
		board_data[y][x] = "minesweeper_[mine_count].png"

	return tiles_left <= mines ? MINESWEEPER_VICTORY : MINESWEEPER_CONTINUE

/datum/computer_file/program/minesweeper/proc/diff_text(diff)
	return list("Beginner", "Intermediate", "Expert")[diff]

/datum/computer_file/program/minesweeper/proc/find_in_mines(list/coord)
	for(var/list/L in mine_spots)
		if(coord[1] == L[1] && coord[2] == L[2])
			return TRUE
	return FALSE

/datum/computer_file/program/minesweeper/proc/is_blank_tile_start(x,y)
	for(var/scanx=-1, scanx<2, scanx++) // -1, 0, 1
		for(var/scany=-1, scany<2, scany++)
			if(scanx+x < 1 || scany+y < 1)
				continue
			if(find_in_mines(list(scanx+x-1,scany+y-1)))
				return FALSE
	return TRUE

#undef MINESWEEPER_BEGINNER
#undef MINESWEEPER_INTERMEDIATE
#undef MINESWEEPER_EXPERT
#undef MINESWEEPER_CONTINUE
#undef MINESWEEPER_DEAD
#undef MINESWEEPER_VICTORY
#undef MINESWEEPER_IDLE
