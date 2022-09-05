#define MINESWEEPER_BEGINNER 1
#define MINESWEEPER_INTERMEDIATE 2
#define MINESWEEPER_EXPERT 3
#define MINESWEEPER_CUSTOM 4

#define MINESWEEPER_CONTINUE 0
#define MINESWEEPER_DEAD 1
#define MINESWEEPER_VICTORY 2
#define MINESWEEPER_IDLE 3

/obj/machinery/computer/arcade/minesweeper
	name = "Minesweeper"
	desc = "An arcade machine that generates grids. It seems that the machine sparks and screeches when a grid is generated, as if it cannot cope with the intensity of generating the grid."
	icon_state = "arcade"
	circuit = /obj/item/circuitboard/computer/arcade/minesweeper
	
	var/ticket_count = 0
	var/flag_mode = FALSE
	var/flags = 0
	var/current_mines = 10
	var/difficulty = MINESWEEPER_BEGINNER
	var/value = MINESWEEPER_BEGINNER
	var/current_difficulty = "Beginner"

	var/custom_height = 10
	var/custom_width = 10
	var/custom_mines = 10

	var/game_status = MINESWEEPER_IDLE

	var/board_data[31][18] 
	var/mine_spots = list()
	var/height = 10
	var/width = 10
	var/mines = 10

	var/tiles_left = 100

/obj/machinery/computer/arcade/minesweeper/interact(mob/user, special_state)
	. = ..()
	if(!is_operational())
		return
	if(game_status == MINESWEEPER_IDLE || game_status == MINESWEEPER_DEAD || game_status == MINESWEEPER_VICTORY)
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

	data["board_data"] = board_data
	data["game_status"] = game_status
	data["difficulty"] = diff_text(difficulty)
	data["current_difficulty"] = current_difficulty
	data["emagged"] = obj_flags & EMAGGED
	data["flag_mode"] = flag_mode
	data["tickets"] = ticket_count
	data["flags"] = flags
	data["current_mines"] = current_mines
	data["custom_height"] = custom_height
	data["custom_width"] = custom_width
	data["custom_mines"] = custom_mines
	
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
			
			if(game_status)
				return

			if(board_data[x][y] != "minesweeper_hidden.png" && !flag_mode && !flagging)
				return
			
			if(flag_mode || flagging)
				if(board_data[x][y] == "minesweeper_hidden.png")
					board_data[x][y] = "minesweeper_flag.png"
					flags++
					playsound(loc, 'yogstation/sound/arcade/minesweeper_boardpress.ogg', 50, 0, extrarange = -3, falloff = 10)
				else if(board_data[x][y] == "minesweeper_flag.png")
					board_data[x][y] = "minesweeper_hidden.png"
					flags--
					playsound(loc, 'yogstation/sound/arcade/minesweeper_boardpress.ogg', 50, 0, extrarange = -3, falloff = 10)
				else
					return
				return TRUE

			playsound(loc, 'yogstation/sound/arcade/minesweeper_boardpress.ogg', 50, 0, extrarange = -3, falloff = 10)

			if(current_difficulty != diff_text(difficulty))
				generate_new_board(difficulty)

			if(width * height == tiles_left && !is_blank_tile_start(x,y))
				move_bombs(x,y) // The first selected tile will always be a blank one.
			
			current_mines = mines
			
			if(difficulty == MINESWEEPER_CUSTOM)
				switch(mines/(height*width))
					if(0.1 to 0.14999)
						value = 1
					if(0.14999 to 0.19999)
						if(height >= 10 && width >= 10)
							value = 2
						else
							value = 1
					if(0.19999 to 0.29999)
						if(height >= 10 && width >= 10)
							value = 3
						else
							value = 1
					if(0.29999 to 1)
						if(height >= 10 && width >= 10)
							value = 4
						else
							value = 1
					else
						value = 0
			else
				value = difficulty

			current_difficulty = diff_text(difficulty)

			var/result = select_square(x,y)
			game_status = result
			if(result == MINESWEEPER_VICTORY)
				playsound(loc, 'yogstation/sound/arcade/minesweeper_win.ogg', 50, 0, extrarange = -3, falloff = 10)
				say("You cleared the board of all mines! Congratulations!")
				if(obj_flags & EMAGGED && value >= 1)
					var/itemname
					switch(rand(1,3))
						if(1)
							itemname = "a syndicate bomb beacon"
							new /obj/item/sbeacondrop/bomb(loc)
						if(2)
							itemname = "a rocket launcher"
							new /obj/item/gun/ballistic/rocketlauncher/unrestricted(loc)
							new /obj/item/ammo_casing/caseless/rocket/hedp(loc)
							new /obj/item/ammo_casing/caseless/rocket/hedp(loc)
							new /obj/item/ammo_casing/caseless/rocket/hedp(loc)
						if(3)
							itemname = "two bags of c4"
							new /obj/item/storage/backpack/duffelbag/syndie/c4(loc)
							new /obj/item/storage/backpack/duffelbag/syndie/x4(loc)
					message_admins("[key_name_admin(user)] won emagged Minesweeper and got [itemname]!")
					visible_message(span_notice("[src] dispenses [itemname]!"), span_notice("You hear a chime and a clunk."))
				else
					ticket_count += value

			if(result == MINESWEEPER_DEAD && (obj_flags & EMAGGED))
				// One crossed wire, one wayward pinch of potassium chlorate, ONE ERRANT TWITCH
				// AND
				KABLOOEY()

			return TRUE
		
		if("PRG_new_game")
			playsound(loc, 'yogstation/sound/arcade/minesweeper_boardpress.ogg', 50, 0, extrarange = -3, falloff = 10)
			generate_new_board(difficulty)
			current_difficulty = diff_text(difficulty)
			return TRUE
		
		if("PRG_difficulty")
			var/diff = params["difficulty"]
			if(!diff)
				return
			playsound(loc, 'yogstation/sound/arcade/minesweeper_boardpress.ogg', 50, 0, extrarange = -3, falloff = 10)
			difficulty = diff
			return TRUE

		if("PRG_height")
			var/cin = params["height"]
			if(!cin)
				return
			cin = text2num(cin)
			if(cin < 5 || cin > 17)
				cin = clamp(cin, 5, 17)
			custom_height = cin
			custom_mines = min(custom_mines, FLOOR(custom_width*custom_height/2,1))
			difficulty = MINESWEEPER_CUSTOM
			return TRUE
		
		if("PRG_width")
			var/cin = params["width"]
			if(!cin)
				return
			cin = text2num(cin)
			if(cin < 5 || cin > 30)
				cin = clamp(cin, 5, 30)
			custom_width = cin
			custom_mines = min(custom_mines, FLOOR(custom_width*custom_height/2,1))
			difficulty = MINESWEEPER_CUSTOM
			return TRUE
		
		if("PRG_mines")
			var/cin = params["mines"]
			if(!cin)
				return
			cin = text2num(cin)
			if(cin < 5 || cin > FLOOR(custom_width*custom_height/2,1))
				cin = clamp(cin, 5, FLOOR(custom_width*custom_height/2,1))
			custom_mines = cin
			difficulty = MINESWEEPER_CUSTOM
			return TRUE

		if("PRG_toggle_flag")
			playsound(loc, 'yogstation/sound/arcade/minesweeper_boardpress.ogg', 50, 0, extrarange = -3, falloff = 10)
			flag_mode = !flag_mode
			return TRUE

		if("PRG_tickets")
			playsound(loc, 'yogstation/sound/arcade/minesweeper_boardpress.ogg', 50, 0, extrarange = -3, falloff = 10)
			if(ticket_count >= 1)
				new /obj/item/stack/arcadeticket(loc, 1)
				to_chat(user, span_notice("[src] dispenses a ticket!"))
				ticket_count -= 1
			else
				to_chat(user, span_notice("You don't have any stored tickets!"))
			return TRUE

/obj/machinery/computer/arcade/minesweeper/proc/generate_new_board(diff)
	board_data = new /list(31,18) // Fresh board
	mine_spots = list()

	switch(diff)
		if(MINESWEEPER_BEGINNER) // 10x10, 10 mines
			width = 10
			height = 10
			mines = 10
		if(MINESWEEPER_INTERMEDIATE) // 17x17, 40 mines
			width = 17
			height = 17
			mines = 40
		if(MINESWEEPER_EXPERT) // 30x16, 99 mines
			width = 30
			height = 16
			mines = 99
		if(MINESWEEPER_CUSTOM)
			width = custom_width
			height = custom_height
			mines = custom_mines
	
	tiles_left = width * height

	mines = min(FLOOR(tiles_left/2,1), mines) // Crash protection
	
	for(var/i=1, i<mines+1, i++) // Set up mines
		var/mine_spot = list(rand(0,width-1),rand(0,height-1))
		while(find_in_mines(mine_spot)) // There's already a mine here! Choose another spot
			mine_spot = list(rand(0,width-1),rand(0,height-1))
		mine_spots += list(mine_spot)
	
	for(var/y=1, y<height+1, y++) // Set all squares to be hidden
		for(var/x=1, x<width+1, x++)
			board_data[x][y] = "minesweeper_hidden.png"

	game_status = MINESWEEPER_CONTINUE

/obj/machinery/computer/arcade/minesweeper/proc/select_square(x,y)
	if(find_in_mines(list(x-1,y-1)))
		board_data[x][y] = "minesweeper_minehit.png"
		for(var/list/mine in mine_spots)
			if(mine[1] == x-1 && mine[2] == y-1)
				continue
			board_data[mine[1]+1][mine[2]+1] = "minesweeper_mine.png"
		switch(rand(1,3))
			if(1)
				playsound(loc, 'yogstation/sound/arcade/minesweeper_explosion1.ogg', 50, 0, extrarange = -3, falloff = 10)
			if(2)
				playsound(loc, 'yogstation/sound/arcade/minesweeper_explosion2.ogg', 50, 0, extrarange = -3, falloff = 10)
			if(3)
				playsound(loc, 'yogstation/sound/arcade/minesweeper_explosion3.ogg', 50, 0, extrarange = -3, falloff = 10)
		return MINESWEEPER_DEAD
	
	tiles_left--

	var/mine_count = 0
	for(var/scanx=-1, scanx<2, scanx++) // -1, 0, 1
		for(var/scany=-1, scany<2, scany++)
			if(scanx+x < 1 || scany+y < 1)
				continue
			if(scanx == 0 && scany == 0) // We know we aren't a mine
				continue
			if(board_data[scanx+x][scany+y] != "minesweeper_hidden.png" && board_data[scanx+x][scany+y] != "minesweeper_flag.png")
				continue
			if(find_in_mines(list(scanx+x-1,scany+y-1)))
				mine_count++
	
	if(mine_count == 0) // There are no mines around me! Select every square adjacent!
		board_data[x][y] = "minesweeper_empty.png"
		for(var/scanx=-1, scanx<2, scanx++) // -1, 0, 1
			for(var/scany=-1, scany<2, scany++)
				if(scanx+x < 1 || scany+y < 1)
					continue
				if(scanx == 0 && scany == 0)
					continue
				if(board_data[scanx+x][scany+y] != "minesweeper_hidden.png")
					continue
				select_square(scanx+x,scany+y)
	else
		board_data[x][y] = "minesweeper_[mine_count].png"

	return tiles_left <= mines ? MINESWEEPER_VICTORY : MINESWEEPER_CONTINUE

/obj/machinery/computer/arcade/minesweeper/proc/diff_text(diff)
	return list("Beginner", "Intermediate", "Expert", "Custom")[diff]

/obj/machinery/computer/arcade/minesweeper/proc/find_in_mines(list/coord)
	var/order = 0
	for(var/list/L in mine_spots)
		order++
		if(coord[1] == L[1] && coord[2] == L[2])
			return order
	return FALSE

/obj/machinery/computer/arcade/minesweeper/proc/is_blank_tile_start(x,y)
	for(var/scanx=-1, scanx<2, scanx++) // -1, 0, 1
		for(var/scany=-1, scany<2, scany++)
			if(scanx+x < 1 || scany+y < 1)
				continue
			if(find_in_mines(list(scanx+x-1,scany+y-1)))
				return FALSE
	return TRUE

/obj/machinery/computer/arcade/minesweeper/proc/move_bombs(x,y)
	for(var/scanx=-1, scanx<2, scanx++) // -1, 0, 1
		for(var/scany=-1, scany<2, scany++)
			if(scanx+x < 1 || scany+y < 1)
				continue
			var/mine_index = find_in_mines(list(scanx+x-1,scany+y-1))
			if(mine_index)
				var/mine_spot = list(rand(0,width-1),rand(0,height-1))
				while(find_in_mines(mine_spot) || is_surrounding(x,y,mine_spot)) // There's already a mine here/surrounding! Choose another spot
					mine_spot = list(rand(0,width-1),rand(0,height-1))
				mine_spots[mine_index] = mine_spot

/obj/machinery/computer/arcade/minesweeper/proc/is_surrounding(x,y,list/coord)
	for(var/scanx=-1, scanx<2, scanx++) // -1, 0, 1
		for(var/scany=-1, scany<2, scany++)
			if(scanx+x < 1 || scany+y < 1)
				continue
			var/list/C = list(scanx+x-1,scany+y-1)
			if(coord[1] == C[1] && coord[2] == C[2])
				return TRUE
	return FALSE

/obj/machinery/computer/arcade/minesweeper/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	desc = "An arcade machine that generates grids. It's clunking and sparking everywhere, almost as if threatening to explode at any moment!"
	do_sparks(5, 1, src)
	obj_flags |= EMAGGED
	if(game_status == MINESWEEPER_CONTINUE)
		to_chat(user, span_warning("An ominous tune plays from the arcade's speakers!"))
		playsound(user, 'yogstation/sound/arcade/minesweeper_emag1.ogg', 100, 0, extrarange = 3, falloff = 10)
	else	//Can't let you do that, star fox!
		to_chat(user, span_warning("The machine buzzes and sparks... the game has been reset!"))
		playsound(user, 'sound/machines/buzz-sigh.ogg', 100, 0, extrarange = 3, falloff = 10)	//Loud buzz
		game_status = MINESWEEPER_IDLE
	update_static_data(user)

/obj/machinery/computer/arcade/minesweeper/proc/KABLOOEY()
	explosion(loc,1,3,rand(1,5),rand(1,10))

#undef MINESWEEPER_BEGINNER
#undef MINESWEEPER_INTERMEDIATE
#undef MINESWEEPER_EXPERT
#undef MINESWEEPER_CUSTOM
#undef MINESWEEPER_CONTINUE
#undef MINESWEEPER_DEAD
#undef MINESWEEPER_VICTORY
#undef MINESWEEPER_IDLE
