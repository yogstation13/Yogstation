#define MINESWEEPER_GAME_MAIN_MENU	0
#define MINESWEEPER_GAME_PLAYING	1
#define MINESWEEPER_GAME_LOST		2
#define MINESWEEPER_GAME_WON		3

/obj/machinery/computer/arcade/minesweeper
	name = "Minesweeper"
	desc = "An arcade machine that generates grids. It seems that the machine sparks and screeches when a grid is generated, as if it cannot cope with the intensity of generating the grid."
	icon_state = "arcade"
	circuit = /obj/item/circuitboard/computer/arcade/minesweeper
	var/area
	var/difficulty = ""	//To show what difficulty you are playing
	var/flag_text = ""
	var/flagging = FALSE
	var/game_status = MINESWEEPER_GAME_MAIN_MENU
	var/mine_limit = 0
	var/mine_placed = 0
	var/mine_sound = TRUE	//So it doesn't get repeated when multiple mines are exposed
	var/randomcolour = 1
	var/randomnumber = 1	//Random emagged game iteration number to be displayed, put here so it is persistent across one individual arcade machine
	var/safe_squares_revealed
	var/saved_web = ""	//To display the web if you click on the arcade
	var/win_condition
	var/rows = 1
	var/columns = 1
	var/table[31][51]	//Make the board boys, 30x50 board
	var/squareflag
	var/squaremine
	var/squarehidden
	var/squareempty
	var/squareminehit
	var/square1
	var/square2
	var/square3
	var/square4
	var/square5
	var/square6
	var/square7
	var/square8
	var/sameboard = FALSE

/obj/machinery/computer/arcade/minesweeper/Initialize()
	squareflag = "[icon2html('yogstation/icons/arcade/minesweeper_tiles.dmi', world, "minesweeper_flag")]"
	squaremine = "[icon2html('yogstation/icons/arcade/minesweeper_tiles.dmi', world, "minesweeper_mine")]"
	squarehidden = "[icon2html('yogstation/icons/arcade/minesweeper_tiles.dmi', world, "minesweeper_hidden")]"
	squareempty = "[icon2html('yogstation/icons/arcade/minesweeper_tiles.dmi', world, "minesweeper_empty")]"
	squareminehit = "[icon2html('yogstation/icons/arcade/minesweeper_tiles.dmi', world, "minesweeper_minehit")]"
	square1 = "[icon2html('yogstation/icons/arcade/minesweeper_tiles.dmi', world, "minesweeper_1")]"
	square2 = "[icon2html('yogstation/icons/arcade/minesweeper_tiles.dmi', world, "minesweeper_2")]"
	square3 = "[icon2html('yogstation/icons/arcade/minesweeper_tiles.dmi', world, "minesweeper_3")]"
	square4 = "[icon2html('yogstation/icons/arcade/minesweeper_tiles.dmi', world, "minesweeper_4")]"
	square5 = "[icon2html('yogstation/icons/arcade/minesweeper_tiles.dmi', world, "minesweeper_5")]"
	square6 = "[icon2html('yogstation/icons/arcade/minesweeper_tiles.dmi', world, "minesweeper_6")]"
	square7 = "[icon2html('yogstation/icons/arcade/minesweeper_tiles.dmi', world, "minesweeper_7")]"
	square8 = "[icon2html('yogstation/icons/arcade/minesweeper_tiles.dmi', world, "minesweeper_8")]"
	..()

/obj/machinery/computer/arcade/minesweeper/interact(mob/user)
	var/web_difficulty_menu = "<font size='2'> Reveal all the squares without hitting a mine!<br>What difficulty do you want to play?<br><br><br><br><b><a href='byond://?src=[REF(src)];Easy=1'><font color='#cc66ff'>Easy (9x9 board, 10 mines)</font></a><br><a href='byond://?src=[REF(src)];Intermediate=1'><font color='#cc66ff'>Intermediate (16x16 board, 40 mines)</font></a><br><a href='byond://?src=[REF(src)];Hard=1'><font color='#cc66ff'>Hard (16x30 board, 99 mines)</font></a><br><a href='byond://?src=[REF(src)];Custom=1'><font color='#cc66ff'>Custom</font>"
	var/static_web = "<head><meta charset='UTF-8'><title>Minesweeper</title></head><div align='center'><b>Minesweeper</b><br>"	//When we need to revert to the main menu we set web as this
	var/static_emagged_web = "<head><meta charset='UTF-8'><title>Minesweeper</title></head><div align='center'><b>Minesweeper <font color='red'>EXTREME EDITION</font>: Iteration <font color='[randomcolour]'>#[randomnumber]</font></b><br>"	//Different colour mix for every random number made
	var/emagged_web_difficulty_menu = "<font size='2'>Explode in the game, explode in real life!<br>What difficulty do you want to play?<br><br><br><br><b><a href='byond://?src=[REF(src)];Easy=1'><font color='#cc66ff'>Easy (9x9 board, 10 mines)</font></a><br><a href='byond://?src=[REF(src)];Intermediate=1'><font color='#cc66ff'>Intermediate (16x16 board, 40 mines)</font></a><br><a href='byond://?src=[REF(src)];Hard=1'><font color='#cc66ff'>Hard (16x30 board, 99 mines)</font></a><br><a href='byond://?src=[REF(src)];Custom=1'><font color='#cc66ff'>Custom</font>"
	user = usr

	if(game_status == MINESWEEPER_GAME_MAIN_MENU)
		if(obj_flags & EMAGGED)
			playsound(loc, 'yogstation/sound/arcade/minesweeper_emag2.ogg', 50, 0, extrarange = -3, falloff = 10)
			user << browse(static_emagged_web+emagged_web_difficulty_menu,"window=minesweeper,size=400x500")
		else
			playsound(loc, 'yogstation/sound/arcade/minesweeper_startup.ogg', 50, 0, extrarange = -3, falloff = 10)
			user << browse(static_web+web_difficulty_menu,"window=minesweeper,size=400x500")
	else
		playsound(loc, 'yogstation/sound/arcade/minesweeper_boardpress.ogg', 50, 0, extrarange = -3, falloff = 10)
		user << browse(saved_web,"window=minesweeper,size=400x500")
	if(obj_flags & EMAGGED)
		do_sparks(5, 1, src)
	add_fingerprint(user)

	..()

/obj/machinery/computer/arcade/minesweeper/Topic(href, href_list)
	if(..())
		return

	var/exploding_hell = FALSE	//For emagged failures
	var/reset_board = FALSE
	var/prizevended = TRUE
	var/mob/living/user = usr	//To identify who the hell is using this window, this should also make things like aliens and monkeys able to use the machine!!
	var/web_difficulty_menu = "<font size='2'> Reveal all the squares without hitting a mine!<br>What difficulty do you want to play?<br><br><br><br><b><a href='byond://?src=[REF(src)];Easy=1'><font color='#cc66ff'>Easy (9x9 board, 10 mines)</font></a><br><a href='byond://?src=[REF(src)];Intermediate=1'><font color='#cc66ff'>Intermediate (16x16 board, 40 mines)</font></a><br><a href='byond://?src=[REF(src)];Hard=1'><font color='#cc66ff'>Hard (16x30 board, 99 mines)</font></a><br><a href='byond://?src=[REF(src)];Custom=1'><font color='#cc66ff'>Custom</font>"
	var/web = "<head><meta charset='UTF-8'><title>Minesweeper</title></head><div align='center'><b>Minesweeper</b><br>"
	var/static_web = "<head><meta charset='UTF-8'><title>Minesweeper</title></head><div align='center'><b>Minesweeper</b><br>"	//When we need to revert to the main menu we set web as this
	web = static_web

	if(obj_flags & EMAGGED)
		web = "<head><meta charset='UTF-8'><title>Minesweeper</title></head><body><div align='center'><b>Minesweeper <font color='red'>EXTREME EDITION</font>: Iteration <font color='[randomcolour]'>#[randomnumber]</font></b><br>"	//Different colour mix for every random number made
		do_sparks(5, 1, src)

	if(href_list["Main_Menu"])
		game_status = MINESWEEPER_GAME_MAIN_MENU
		mine_limit = 0
		rows = 0
		columns = 0
		mine_placed = 0
	if(href_list["Easy"])
		playsound(loc, 'yogstation/sound/arcade/minesweeper_menuselect.ogg', 50, 0, extrarange = -3, falloff = 10)
		flag_text = "OFF"
		game_status = MINESWEEPER_GAME_PLAYING
		reset_board = TRUE
		difficulty = "Easy"
		rows = 10	//9x9 board
		columns = 10
		mine_limit = 10
	if(href_list["Intermediate"])
		playsound(loc, 'yogstation/sound/arcade/minesweeper_menuselect.ogg', 50, 0, extrarange = -3, falloff = 10)
		flag_text = "OFF"
		game_status = MINESWEEPER_GAME_PLAYING
		reset_board = TRUE
		difficulty = "Intermediate"
		rows = 17	//16x16 board
		columns = 17
		mine_limit = 40
	if(href_list["Hard"])
		playsound(loc, 'yogstation/sound/arcade/minesweeper_menuselect.ogg', 50, 0, extrarange = -3, falloff = 10)
		flag_text = "OFF"
		game_status = MINESWEEPER_GAME_PLAYING
		reset_board = TRUE
		difficulty = "Hard"
		rows = 17	//16x30 board
		columns = 31
		mine_limit = 99
	if(href_list["Custom"])
		playsound(loc, 'yogstation/sound/arcade/minesweeper_menuselect.ogg', 50, 0, extrarange = -3, falloff = 10)
		flag_text = "OFF"
		game_status = MINESWEEPER_GAME_PLAYING
		reset_board = TRUE
		difficulty = "Custom"
		rows = text2num(input(usr, "How many rows do you want? (Maximum of 30 allowed)", "Minesweeper Rows"))+1	//+1 as dm arrays start at 1
		columns = text2num(input(usr, "How many columns do you want? (Maximum of 50 allowed)", "Minesweeper Squares"))+1	//+1 as dm arrays start at 1
		var/grid_area = (rows-1)*(columns-1)
		mine_limit = text2num(input(usr, "How many mines do you want? (Maximum of [round(grid_area*0.85)] allowed)", "Minesweeper Mines"))
		custom_generation()
	if(href_list["Flag"])
		playsound(loc, 'yogstation/sound/arcade/minesweeper_boardpress.ogg', 50, 0, extrarange = -3, falloff = 10)
		if(!flagging)
			flagging = TRUE
			flag_text = "ON"
		else
			flagging = FALSE
			flag_text = "OFF"

	if(game_status == MINESWEEPER_GAME_MAIN_MENU)
		if(obj_flags & EMAGGED)
			playsound(loc, 'yogstation/sound/arcade/minesweeper_emag2.ogg', 50, 0, extrarange = -3, falloff = 10)
			web += "<font size='2'>Explode in the game, explode in real life!<br>What difficulty do you want to play?<br><br><br><br><b><a href='byond://?src=[REF(src)];Easy=1'><font color='#cc66ff'>Easy (9x9 board, 10 mines)</font></a><br><a href='byond://?src=[REF(src)];Intermediate=1'><font color='#cc66ff'>Intermediate (16x16 board, 40 mines)</font></a><br><a href='byond://?src=[REF(src)];Hard=1'><font color='#cc66ff'>Hard (16x30 board, 99 mines)</font></a><br><a href='byond://?src=[REF(src)];Custom=1'><font color='#cc66ff'>Custom</font>"
		else
			playsound(loc, 'yogstation/sound/arcade/minesweeper_startup.ogg', 50, 0, extrarange = -3, falloff = 10)
			web += web_difficulty_menu

	if(game_status == MINESWEEPER_GAME_PLAYING)
		prizevended = FALSE
		mine_sound = TRUE

	area = (rows-1)*(columns-1)

	if(reset_board)
		mine_placed = 0
		var/reset_everything = TRUE
		make_mines(reset_everything)

	safe_squares_revealed = 0
	win_condition = area-mine_placed

	if(game_status != MINESWEEPER_GAME_MAIN_MENU)
		for(var/y1=1;y1<rows;y1++)
			for(var/x1=1;x1<columns;x1++)
				var/coordinates
				coordinates = (y1*100)+x1
				if(href_list["[coordinates]"])
					if(game_status == MINESWEEPER_GAME_PLAYING)	//Don't do anything if we won or something
						if(!flagging)
							if(table[y1][x1] < 10 && table[y1][x1] >= 0)	//Check that it's not already revealed, and stop flag removal if we're out of flag mode
								table[y1][x1] += 10
								if(table[y1][x1] != 10)
									playsound(loc, 'yogstation/sound/arcade/minesweeper_boardpress.ogg', 50, 0, extrarange = -3, falloff = 10)
								else
									if(game_status != MINESWEEPER_GAME_LOST && game_status != MINESWEEPER_GAME_WON)
										game_status = MINESWEEPER_GAME_LOST
										if(obj_flags & EMAGGED && !exploding_hell)
											exploding_hell  = TRUE
											explode_EVERYTHING()
										if(mine_sound)
											switch(rand(1,3))	//Play every time a mine is hit
												if(1)
													playsound(loc, 'yogstation/sound/arcade/minesweeper_explosion1.ogg', 50, 0, extrarange = -3, falloff = 10)
												if(2)
													playsound(loc, 'yogstation/sound/arcade/minesweeper_explosion2.ogg', 50, 0, extrarange = -3, falloff = 10)
												if(3)
													playsound(loc, 'yogstation/sound/arcade/minesweeper_explosion3.ogg', 50, 0, extrarange = -3, falloff = 10)
											mine_sound = FALSE
						else
							playsound(loc, 'yogstation/sound/arcade/minesweeper_boardpress.ogg', 50, 0, extrarange = -3, falloff = 10)
							if(table[y1][x1] >= 0)	//Check that it's not already flagged
								table[y1][x1] -= 10
							else if(table[y1][x1] < 0)	//If flagged, remove the flag
								table[y1][x1] += 10
				if(href_list["same_board"])	//Reset the board... kinda
					sameboard = TRUE
					if(game_status != MINESWEEPER_GAME_PLAYING)
						game_status = MINESWEEPER_GAME_PLAYING
					if(table[y1][x1] >= 10)	//If revealed, become unrevealed!
						playsound(loc, 'yogstation/sound/arcade/minesweeper_menuselect.ogg', 50, 0, extrarange = -3, falloff = 10)
						table[y1][x1] -= 10
				if(table[y1][x1] > 10 && !reset_board)
					safe_squares_revealed += 1
				var/y2 = y1
				var/x2 = x1
				work_squares(y2, x2)	//Work squares while in this loop so there's less load
				reset_board = FALSE

		web += "<table>"	//Start setting up the html table
		web += "<tbody>"
		for(var/y1=1;y1<rows;y1++)
			web += "<tr>"
			for(var/x1=1;x1<columns;x1++)
				var/coordinates
				coordinates = (y1*100)+x1
				switch(table[y1][x1])
					if(-10 to -1)
						if(game_status != MINESWEEPER_GAME_PLAYING)
							web += "<td>[squareflag]</td>"
						else
							web += "<td><a href='byond://?src=[REF(src)];[coordinates]=1'><img style='border:0' [squareflag]</a></td>"
					if(0)
						if(game_status != MINESWEEPER_GAME_PLAYING)
							web += "<td>[squaremine]</td>"
						else
							web += "<td><a href='byond://?src=[REF(src)];[coordinates]=1'><img style='border:0' [squarehidden]</a></td>"	//Make unique hrefs for every square
					if(1 to 9)
						if(game_status != MINESWEEPER_GAME_PLAYING)
							web += "<td>[squarehidden]</td>"
						else
							web += "<td><a href='byond://?src=[REF(src)];[coordinates]=1'><img style='border:0' [squarehidden]</a></td>"	//Make unique hrefs for every square
					if(10)
						web += "<td>[squareminehit]</td>"
					if(11)
						web += "<td>[squareempty]</td>"
					if(12)
						web += "<td>[square1]</td>"
					if(13)
						web += "<td>[square2]</td>"
					if(14)
						web += "<td>[square3]</td>"
					if(15)
						web += "<td>[square4]</td>"
					if(16)
						web += "<td>[square5]</td>"
					if(17)
						web += "<td>[square6]</td>"
					if(18)
						web += "<td>[square7]</td>"
					if(19)
						web += "<td>[square8]</td>"
			web += "</tr>"
		web += "</table>"
		web += "</tbody>"
	web += "<br>"

	if(safe_squares_revealed >= win_condition && game_status == MINESWEEPER_GAME_PLAYING)
		game_status = MINESWEEPER_GAME_WON

	if(game_status == MINESWEEPER_GAME_WON)
		if(sameboard) //sucks to be you, you fucking cheater!
			playsound(loc, 'yogstation/sound/arcade/minesweeper_winfail.ogg', 50, 0, extrarange = -3, falloff = 10)
			say("You cleared the board of all mines, but you played the same board twice! Try again with a new board!")
			prizevended = TRUE
			web += "<font size='4'>You won, but you played the same board twice! Try again with a new board!<br><font size='3'>Want to play again?<br><b><a href='byond://?src=[REF(src)];Easy=1'><font color='#cc66ff'>Easy (9x9 board, 10 mines)</font></a><br><a href='byond://?src=[REF(src)];Intermediate=1'><font color='#cc66ff'>Intermediate (16x16 board, 40 mines)</font></a><br><a href='byond://?src=[REF(src)];Hard=1'><font color='#cc66ff'>Hard (16x30 board, 99 mines)</font></a><br><a href='byond://?src=[REF(src)];Custom=1'><font color='#cc66ff'>Custom</font></a></b><br><a href='byond://?src=[REF(src)];same_board=1'><font color='#cc66ff'>Play on the same board</font></a><br><a href='byond://?src=[REF(src)];Main_Menu=1'><font color='#cc66ff'>Return to Main Menu</font></a></b><br>"
		if(rows < 10 || columns < 10)	//If less than easy difficulty
			if(!prizevended)
				playsound(loc, 'yogstation/sound/arcade/minesweeper_winfail.ogg', 50, 0, extrarange = -3, falloff = 10)
				say("You cleared the board of all mines, but you picked too small of a board! Try again with at least a 9x9 board!")
				prizevended = TRUE
			web += "<font size='4'>You won, but your board was too small! Pick a bigger board next time!<br><font size='3'>Want to play again?<br><b><a href='byond://?src=[REF(src)];Easy=1'><font color='#cc66ff'>Easy (9x9 board, 10 mines)</font></a><br><a href='byond://?src=[REF(src)];Intermediate=1'><font color='#cc66ff'>Intermediate (16x16 board, 40 mines)</font></a><br><a href='byond://?src=[REF(src)];Hard=1'><font color='#cc66ff'>Hard (16x30 board, 99 mines)</font></a><br><a href='byond://?src=[REF(src)];Custom=1'><font color='#cc66ff'>Custom</font></a></b><br><a href='byond://?src=[REF(src)];same_board=1'><font color='#cc66ff'>Play on the same board</font></a><br><a href='byond://?src=[REF(src)];Main_Menu=1'><font color='#cc66ff'>Return to Main Menu</font></a></b><br>"
		else
			if(!prizevended)
				playsound(loc, 'yogstation/sound/arcade/minesweeper_win.ogg', 50, 0, extrarange = -3, falloff = 10)
				say("You cleared the board of all mines! Congratulations!")
				if(obj_flags & EMAGGED)
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
					visible_message("<span class='notice'>[src] dispenses [itemname]!</span>", "<span class='notice'>You hear a chime and a clunk.</span>")
				else
					prizevend(user)
				prizevended = TRUE
			web += "<font size='6'>Congratulations, you have won!<br><font size='3'>Want to play again?<br><b><a href='byond://?src=[REF(src)];Easy=1'><font color='#cc66ff'>Easy (9x9 board, 10 mines)</font></a><br><a href='byond://?src=[REF(src)];Intermediate=1'><font color='#cc66ff'>Intermediate (16x16 board, 40 mines)</font></a><br><a href='byond://?src=[REF(src)];Hard=1'><font color='#cc66ff'>Hard (16x30 board, 99 mines)</font></a><br><a href='byond://?src=[REF(src)];Custom=1'><font color='#cc66ff'>Custom</font></a></b><br><a href='byond://?src=[REF(src)];same_board=1'><font color='#cc66ff'>Play on the same board</font></a><br><a href='byond://?src=[REF(src)];Main_Menu=1'><font color='#cc66ff'>Return to Main Menu</font></a></b><br>"

	if(game_status == MINESWEEPER_GAME_LOST)
		web += "<font size='6'>You have lost!<br><font size='3'>Try again?<br><b><a href='byond://?src=[REF(src)];Easy=1'><font color='#cc66ff'>Easy (9x9 board, 10 mines)</font></a><br><a href='byond://?src=[REF(src)];Intermediate=1'><font color='#cc66ff'>Intermediate (16x16 board, 40 mines)</font></a><br><a href='byond://?src=[REF(src)];Hard=1'><font color='#cc66ff'>Hard (16x30 board, 99 mines)</font></a><br><a href='byond://?src=[REF(src)];Custom=1'><font color='#cc66ff'>Custom</font></a></b><br><a href='byond://?src=[REF(src)];same_board=1'><font color='#cc66ff'>Play on the same board</font></a><br><a href='byond://?src=[REF(src)];Main_Menu=1'><font color='#cc66ff'>Return to Main Menu</font></a></b><br>"

	if(game_status == MINESWEEPER_GAME_PLAYING)
		web += "<a href='byond://?src=[REF(src)];Main_Menu=1'><font color='#cc66ff'>Return to Main Menu</font></a><br>"
		web += "<div align='right'>Difficulty: [difficulty]<br>Mines: [mine_placed]<br>Rows: [rows-1]<br>Columns: [columns-1]<br><a href='byond://?src=[REF(src)];Flag=1'><font color='#cc66ff'>Flagging mode: [flag_text]</font></a></div>"

	web += "</div>"
	saved_web = web
	user << browse(web,"window=minesweeper,size=400x500")
	return

/obj/machinery/computer/arcade/minesweeper/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	desc = "An arcade machine that generates grids. It's clunking and sparking everywhere, almost as if threatening to explode at any moment!"
	do_sparks(5, 1, src)
	randomnumber = rand(1,255)
	randomcolour = rgb(randomnumber,randomnumber/2,randomnumber/3)
	obj_flags |= EMAGGED
	if(game_status == MINESWEEPER_GAME_MAIN_MENU)
		to_chat(user, "<span class='warning'>An ominous tune plays from the arcade's speakers!</span>")
		playsound(user, 'yogstation/sound/arcade/minesweeper_emag1.ogg', 100, 0, extrarange = 3, falloff = 10)
	else	//Can't let you do that, star fox!
		to_chat(user, "<span class='warning'>The machine buzzes and sparks... the game has been reset!</span>")
		playsound(user, 'sound/machines/buzz-sigh.ogg', 100, 0, extrarange = 3, falloff = 10)	//Loud buzz
		game_status = MINESWEEPER_GAME_MAIN_MENU

/obj/machinery/computer/arcade/minesweeper/proc/custom_generation()
	playsound(loc, 'yogstation/sound/arcade/minesweeper_menuselect.ogg', 50, 0, extrarange = -3, falloff = 10)	//Entered into the menu so ping sound
	if(rows < 4)
		rows = text2num(input(usr, "You must put at least 4 rows! Pick a higher amount of rows", "Minesweeper Rows"))+1	//+1 as dm arrays start at 1
		playsound(loc, 'yogstation/sound/arcade/minesweeper_menuselect.ogg', 50, 0, extrarange = -3, falloff = 10)
		custom_generation()
	if(columns < 4)
		columns = text2num(input(usr, "You must put at least 4 columns! Pick a higher amount of columns", "Minesweeper Columns"))+1	//+1 as dm arrays start at 1
		playsound(loc, 'yogstation/sound/arcade/minesweeper_menuselect.ogg', 50, 0, extrarange = -3, falloff = 10)
		custom_generation()
	if(rows > 31)
		rows = text2num(input(usr, "A maximum of 30 rows are allowed! Pick a lower amount of rows", "Minesweeper Rows"))+1	//+1 as dm arrays start at 1
		playsound(loc, 'yogstation/sound/arcade/minesweeper_menuselect.ogg', 50, 0, extrarange = -3, falloff = 10)
		custom_generation()
	if(columns > 51)
		columns = text2num(input(usr, "A maximum of 50 columns are allowed! Pick a lower amount of columns", "Minesweeper Columns"))+1//+1 as dm arrays start at 1
		playsound(loc, 'yogstation/sound/arcade/minesweeper_menuselect.ogg', 50, 0, extrarange = -3, falloff = 10)
		custom_generation()
	var/grid_area = (rows-1)*(columns-1)	//Need a live update of this, won't update if we use the area var in topic
	if(mine_limit > round(grid_area*0.85))
		mine_limit = text2num(input(usr, "You can only put in [round(grid_area*0.85)] mines on this board! Pick a lower amount of mines to insert", "Minesweeper Mines"))
		playsound(loc, 'yogstation/sound/arcade/minesweeper_menuselect.ogg', 50, 0, extrarange = -3, falloff = 10)
		custom_generation()
	if(mine_limit < round(grid_area/6.4))	//Same mine density as intermediate difficulty
		mine_limit = text2num(input(usr, "You must at least put [round(grid_area/6.4)] mines on this board! Pick a higher amount of mines to insert", "Minesweeper Mines"))
		playsound(loc, 'yogstation/sound/arcade/minesweeper_menuselect.ogg', 50, 0, extrarange = -3, falloff = 10)
		custom_generation()

/obj/machinery/computer/arcade/minesweeper/proc/make_mines(var/reset_everything)
	if(reset_everything)
		sameboard = FALSE
		
	if(mine_placed < mine_limit)
		for(var/y1=1;y1<rows;y1++)	//Board resetting and mine building
			for(var/x1=1;x1<columns;x1++)
				if(prob(area/mine_limit) && mine_placed < mine_limit && table[y1][x1] != 0)	//Unlikely for this to happen but this has eaten mines before
					table[y1][x1] = 0
					mine_placed += 1
				else if(reset_everything)
					table[y1][x1] = 1
		reset_everything = FALSE
		make_mines()	//In case the first pass doesn't generate enough mines

/obj/machinery/computer/arcade/minesweeper/proc/work_squares(var/y2, var/x2, var/y3, var/x3)
	if(y3 > 0 && x3 > 0)
		y2 = y3
		x2 = x3
	if(table[y2][x2] == 1)
		for(y3=y2-1;y3<y2+2;y3++)
			if(y3 >= rows || y3 < 1)
				continue
			for(x3=x2-1;x3<x2+2;x3++)
				if(x3 >= columns || x3 < 1)
					continue
				if(table[y3][x3] == 0)
					table[y2][x2] += 1
	if(table[y2][x2] == 11)
		for(y3=y2-1;y3<y2+2;y3++)
			if(y3 >= rows || y3 < 1)
				continue
			for(x3=x2-1;x3<x2+2;x3++)
				if(x3 >= columns || x3 < 1)
					continue
				if(table[y3][x3] > 0 && table[y3][x3] < 10)
					table[y3][x3] += 10
					work_squares(y3, x3)	//Refresh so we check everything we might be missing

/obj/machinery/computer/arcade/minesweeper/proc/explode_EVERYTHING()
	var/mob/living/user = usr
	to_chat(user, "<span class='warning'><font size='2'><b>You feel a great sense of dread wash over you. You feel as if you just unleashed armageddon upon yourself!</b></span>")
	var/row_limit = rows-1
	var/column_limit = columns-1
	var/mine_limit_v2 = mine_limit
	if(rows > 11)
		row_limit = 10
	if(columns > 11)
		column_limit = 10
	if(mine_limit > (rows*columns)/3.4)
		mine_limit_v2 = 33
	message_admins("[key_name_admin(user)] failed Minesweeper and has unleashed an explosion armageddon of size [row_limit],[column_limit] around [user.loc]!")
	if(mine_limit_v2 < 10)
		explosion(src.loc,3,6,12,24, adminlog = TRUE)	//Thought you could survive by putting as few mines as possible, huh??
	else
		explosion(src.loc,1,3,rand(1,5),rand(1,10), adminlog = FALSE)
	for(var/y69=y-row_limit;y69<y+row_limit;y69++)	//Create a shitton of explosions in irl turfs if we lose, it will probably kill us
		for(var/x69=x-column_limit;x69<x+column_limit;x69++)
			if(prob(mine_limit_v2))	//Probability of explosion happening, according to how many mines were on the board... up to a limit
				var/explosionloc
				explosionloc = locate(y69,x69,z)
				explosion(explosionloc, ,rand(1,2),rand(1,5),rand(3,10), adminlog = FALSE)
