/// Cooldown duration for using print/post functionality
#define PRINTER_COOLDOWN 6 SECONDS
/// How many pages to send to the UI
#define PAGESIZE 10

/// Saved books from the DB
GLOBAL_LIST_EMPTY(cachedbooks)
/// Books that are currently checked out
GLOBAL_LIST_EMPTY(checkouts)

/* Library Machines
 *
 * Contains:
 *		Borrowbook datum
 *		Cachedbook datum
 *		Library Computer
 *		Library Scanner
 *		Book Binder
 */

/*
 * Library Public Computer
 */
/obj/machinery/computer/libraryconsole
	name = "library visitor console"
	icon_state = "oldcomp"
	icon_screen = "library" 
	icon_keyboard = null
	circuit = /obj/item/circuitboard/computer/libraryconsole
	desc = "Checked out books MUST be returned on time."
	// Search Parameters
	/// Title to search
	var/title
	/// Category to search
	var/category = "Any"
	/// Author to search
	var/author

	/// How long until next print
	var/cooldown = 0
	/// Is it the curators book management console
	var/librarianconsole = FALSE
	/// Saved scanner
	var/obj/machinery/libraryscanner/scanner
	// Whatever this does
	clockwork = TRUE
	/// What page are we on
	var/page = 0
	/// How many pages do we have
	var/totalpages = 0
	/// Categorys in the DB
	var/list/validcategorys = list("Any", "Fiction", "Non-Fiction", "Adult", "Reference", "Religion")
	/// Types of items the corprate materials tab can print
	var/list/corpratecategorys = list("Bible", "Poster")
	/// Types of forbidden items the corporate tab can print
	var/list/forbiddenitems = list("Blood Cult", "Clockwork Cult", "Forbidden Book")

/obj/machinery/computer/libraryconsole/Initialize(mapload)
	. = ..()
	scanner = findscanner(4)
	STOP_PROCESSING(SSmachines, src)
	START_PROCESSING(SSslowprocess, src) // Should be slow/in background and not every other second
	load_library_db_to_cache()


/obj/machinery/computer/libraryconsole/process()
	. = ..()
	load_library_db_to_cache()

/obj/machinery/computer/libraryconsole/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LibraryConsole", name)
		ui.open()

/obj/machinery/computer/libraryconsole/ui_data(mob/user)
	var/list/data = list()
	data["validcategorys"] = validcategorys
	data["category"] = category
	data["title"] = title
	data["author"] = author
	data["librarianconsole"] = librarianconsole
	data["page"] = page
	data["emagged"] = (obj_flags & EMAGGED)
	if(!scanner)
		scanner = findscanner(4)
	if(!scanner || !scanner.cache)
		data["scanner"] = null
	else
		data["scanner"] = list()
		if(scanner.cache)
			data["scanner"]["author"] = scanner.cache.author
			data["scanner"]["title"] = scanner.cache.title
			data["scanner"]["id"] = REF(scanner.cache)

		if(scanner.idcard)
			data["scanner"]["idname"] = scanner.idcard.registered_name
			data["scanner"]["assignment"] = scanner.idcard.assignment

	data["corpmaterials"] = corpratecategorys
	if(obj_flags & EMAGGED)
		data["corpmaterials"] |= "Arcane"

	data["newscast"] = 1 && GLOB.news_network

	return data


/obj/machinery/computer/libraryconsole/ui_static_data(mob/user)
	. = ..()
	var/list/data = list()
	var/list/checkedout = list()
	for(var/borrower in GLOB.checkouts)
		checkedout[REF(borrower)] = list("books" = list())
		for(var/datum/cachedbook/borrowbook/b in GLOB.checkouts[borrower])
			var/timetaken = world.time - b.getdate
			timetaken = round(timetaken/600)
			var/timedue = (b.duedate - world.time)/600
			checkedout[REF(borrower)]["books"][REF(b.instance)] = list()
			var/list/borrowedbook = checkedout[REF(borrower)]["books"][REF(b.instance)]

			if(timedue <= 0)
				borrowedbook["overdue"] = TRUE
			else
				borrowedbook["overdue"] = FALSE

			borrowedbook["borrower"] = b.mobname
			borrowedbook["due"] = round(timedue)
			borrowedbook["ref"] = REF(b)
			borrowedbook["title"] = b.title
			borrowedbook["category"] = b.category
			borrowedbook["author"] = b.author

	var/list/books = list()
	for(var/id in GLOB.cachedbooks)
		var/book = GLOB.cachedbooks[id]
		if(author && !(findtext(book["author"], author)))
			continue

		if(title && !(findtext(book["title"], title)))
			continue

		if((category == "Any") || (book["category"] == category))
			books[id] = book
			

	if(books)
		var/totalpages = CEILING(books.len/PAGESIZE, 1)
		data["totalpages"] = totalpages
		if(page > totalpages) // Sanity Check
			page = 0
		data["result"] = books.Copy(page*PAGESIZE, clamp(page*PAGESIZE+PAGESIZE, 0, books.len))
	data["checkouts"] = checkedout
	return data

/obj/machinery/computer/libraryconsole/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("setpage")
			page = clamp(params["page"], 0, totalpages)
			update_static_data(usr)

		if("settitle")
			title = pretty_filter(params["name"])
			update_static_data(usr)

		if("setauthor")
			author = pretty_filter(params["name"])
			update_static_data(usr)

		if("setcategory")
			if(category in validcategorys)
				category = params["category"]
			else
				category = "Any"
			update_static_data(usr)

		if("newsupload")
			if(!GLOB.news_network)
				say("No news network found... Aborting.")
				return

			if(cooldown > world.time)
				say("Request blocked... Please allow time for the network to cooldown.")
				return

			var/channelexists = 0
			for(var/datum/newscaster/feed_channel/FC in GLOB.news_network.network_channels)
				if(FC.channel_name == "Nanotrasen Book Club")
					channelexists = 1
					break
			if(!channelexists)
				GLOB.news_network.CreateFeedChannel("Nanotrasen Book Club", "Library", null)
			GLOB.news_network.SubmitArticle(scanner.cache.dat, "[scanner.cache.name]", "Nanotrasen Book Club", null)
			say("Upload complete. Your uploaded title is now available on station newscasters.")

		if("checkoutbook")
			if (!(scanner.cache) || !(scanner.idcard))
				say("Missing an ID or Book")
				return
			var/datum/cachedbook/borrowbook/b = new /datum/cachedbook/borrowbook
			if(!GLOB.checkouts[scanner.idcard.name])
				GLOB.checkouts[scanner.idcard.name] = list()
			var/list/bookthing = GLOB.checkouts[scanner.idcard.name]
			for(var/datum/cachedbook/borrowbook/book in bookthing)
				if(params["id"] == book.instance)
					say("Book is already checked out to this user")
					return
			b.instance = params["id"]
			b.title = params["title"]
			b.author = params["author"]
			b.mobname = scanner.idcard.name
			b.getdate = world.time
			b.duedate = world.time + params["time"] MINUTES
			GLOB.checkouts[scanner.idcard.name] |= b 
			update_static_data(usr)

		if("uploadbook")
			var/msg = "[key_name(usr)] has uploaded the book titled [scanner.cache.name], [length(scanner.cache.dat)] signs"
			var/datum/DBQuery/query_library_upload = SSdbcore.NewQuery({"
				INSERT INTO [format_table_name("library")] (author, title, content, category, ckey, datetime, round_id_created)
				VALUES (:author, :title, :content, :category, :ckey, Now(), :round_id)
			"}, list("title" = scanner.cache.name, "author" = scanner.cache.author, "content" = scanner.cache.dat, "category" = params["category"], "ckey" = usr.ckey, "round_id" = GLOB.round_id))

			if(!query_library_upload.Execute())
				qdel(query_library_upload)
				say("ERR: Connection to archive severed")
				return
			else
				log_game(msg)
				qdel(query_library_upload)
				say("Upload Complete. Uploaded title will be unavailable for printing for a short period")

		if("vendbook")
			var/id = params["book"]
			if(cooldown > world.time)
				say("Printer unavailable. Please allow a short time before attempting to print.")
			else
				cooldown = world.time + PRINTER_COOLDOWN
				var/datum/DBQuery/query_library_print = SSdbcore.NewQuery(
					"SELECT * FROM [format_table_name("library")] WHERE id=:id AND deleted IS NULL",
					list("id" = id)
				)
				if(!query_library_print.Execute())
					qdel(query_library_print.item)
					say("PRINTER ERROR! Failed to print document (0x0000000F)")
					return
				while(query_library_print.NextRow())
					var/bookauthor = query_library_print.item[2]
					var/booktitle = query_library_print.item[3]
					var/bookcontent = query_library_print.item[4]
					if(!QDELETED(src))
						var/obj/item/book/B = new(get_turf(src))
						B.name = "Book: [booktitle]"
						B.title = booktitle
						B.author = bookauthor
						B.dat = bookcontent
						B.icon_state = "book[rand(1,8)]"
						visible_message("[src]'s printer hums as it produces a completely bound book. How did it do that?")
					break
				qdel(query_library_print)

		if("printtype")
			if(cooldown > world.time)
				say("Printer currently unavailable, please wait a moment.")
				return

			switch(params["type"])
				if("Bible")
					var/obj/item/storage/book/bible/B = new /obj/item/storage/book/bible(src.loc)
					if(GLOB.bible_icon_state && GLOB.bible_item_state)
						B.icon_state = GLOB.bible_icon_state
						B.item_state = GLOB.bible_item_state
						B.name = GLOB.bible_name
						B.deity_name = GLOB.deity

				if("Poster")
					new /obj/item/poster/random_official(src.loc)

				if("Arcane")
					var/toprint = pick(forbiddenitems)
					switch(toprint) // are you crying yet; I am
						if("Blood Cult")
							new /obj/item/melee/cultblade/dagger(get_turf(src))
							to_chat(usr, span_warning("Your sanity barely endures the seconds spent in the vault's browsing window. The only thing to remind you of this when you stop browsing is a sinister dagger sitting on the desk. You don't even remember where it came from..."))
						
						if("Clockwork Cult")
							new /obj/item/clockwork/slab(get_turf(src))
							to_chat(usr, span_warning("Your sanity barely endures the seconds spent in the vault's browsing window. The only thing to remind you of this when you stop browsing is a strange metal tablet sitting on the desk. You don't even remember where it came from..."))
						
						if("Forbidden Book")
							new /obj/item/forbidden_book(get_turf(src))
							to_chat(usr, span_warning("You lose your train of thought, the longer you stare into the vault's browsing window, the deeper you reach into timeless eons. You tear away from the screen, and a book fashioned in a strange leather, bound in chains, appears before you..."))
							usr.visible_message("[usr] stares at the blank screen for a few moments, [usr.p_their()] expression frozen in fear. When [usr.p_they()] finally awaken[usr.p_s()] from it, [usr.p_they()] look[usr.p_s()] a lot older.", 2)
				
			cooldown = world.time + PRINTER_COOLDOWN

/obj/machinery/computer/libraryconsole/emag_act(mob/user)
	obj_flags ^= EMAGGED
	if(obj_flags & EMAGGED)
		to_chat(user, "<font color='red'>You short out the safeties on [src]!</font>")
	else
		to_chat(user, "<font color='red'>You reset the safeties on [src]!</font>")

/*
 * Cachedbook datum
 */
/datum/cachedbook // Datum used to cache the SQL DB books locally in order to achieve a performance gain.
	var/id
	var/title
	var/author
	var/category

/*
 * Borrowbook datum
 */
/datum/cachedbook/borrowbook // Datum used to keep track of who has borrowed what when and for how long.
	var/bookname
	var/mobname
	var/getdate
	var/duedate
	var/instance

/obj/machinery/computer/libraryconsole/proc/load_library_db_to_cache()
	set waitfor = 0
	if(!SSdbcore.Connect())
		return
	var/datum/DBQuery/query_library_cache = SSdbcore.NewQuery("SELECT id, author, title, category FROM [format_table_name("library")] WHERE deleted IS NULL")
	if(!query_library_cache.Execute())
		qdel(query_library_cache)
		return
	while(query_library_cache.NextRow())
		GLOB.cachedbooks[num2text(query_library_cache.item[1])] = list(
			"author" = query_library_cache.item[2],
			"title" = query_library_cache.item[3],
			"category" = query_library_cache.item[4]
		)
	qdel(query_library_cache)
	totalpages = CEILING(GLOB.cachedbooks.len/PAGESIZE, 1)
	GLOB.cachedbooks = sortList(GLOB.cachedbooks)


/obj/machinery/computer/libraryconsole/proc/findscanner(viewrange)
	for(var/obj/machinery/libraryscanner/S in range(viewrange, get_turf(src)))
		return S
	return null

/*
 * Library Computer
 * After 860 days, it's finally a buildable computer.
 */
// TODO: Make this an actual /obj/machinery/computer that can be crafted from circuit boards and such
// It is August 22nd, 2012... This TODO has already been here for months.. I wonder how long it'll last before someone does something about it.
// It's December 25th, 2014, and this is STILL here, and it's STILL relevant. Kill me
/obj/machinery/computer/libraryconsole/bookmanagement
	name = "book inventory management console"
	desc = "Librarian's command station."
	verb_say = "beeps"
	verb_ask = "beeps"
	verb_exclaim = "beeps"
	pass_flags = PASSTABLE
	librarianconsole = TRUE

/obj/machinery/computer/libraryconsole/bookmanagement/Initialize()
	. = ..()
	if(circuit)
		circuit.name = "Book Inventory Management Console (Machine Board)"
		circuit.build_path = /obj/machinery/computer/libraryconsole/bookmanagement

/*
 * Library Scanner
 */
/obj/machinery/libraryscanner
	name = "scanner control interface"
	icon = 'icons/obj/library.dmi'
	icon_state = "bigscanner"
	desc = "It servers the purpose of scanning stuff."
	density = TRUE
	var/obj/item/book/cache		// Last scanned book
	var/obj/item/card/id/idcard

/obj/machinery/libraryscanner/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LibraryScanner", name)
		ui.open()

/obj/machinery/libraryscanner/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	data["cache"] = list()
	data["id"] = list()
	if(cache)
		data["cache"]["author"] = cache.author
		data["cache"]["name"] = cache.title
	if(idcard)
		data["id"]["name"] = idcard.registered_name
		data["id"]["assignment"] = idcard.assignment
	return data

/obj/machinery/libraryscanner/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("ejectbook")
			cache.forceMove(drop_location())
			cache = null
		if("clearid")
			idcard = null

/obj/machinery/libraryscanner/attackby(obj/O, mob/user, params)
	if(istype(O, /obj/item/book))
		if(!user.transferItemToLoc(O, src))
			return
		cache = O

	else if(istype(O, /obj/item/card/id))
		idcard = O
	else
		return ..()


/*
 * Book binder
 */
/obj/machinery/bookbinder
	name = "book binder"
	icon = 'icons/obj/library.dmi'
	icon_state = "binder"
	desc = "Only intended for binding paper products."
	density = TRUE
	var/busy = FALSE

/obj/machinery/bookbinder/attackby(obj/O, mob/user, params)
	if(istype(O, /obj/item/paper))
		bind_book(user, O)
	else if(default_unfasten_wrench(user, O))
		return 1
	else
		return ..()

/obj/machinery/bookbinder/proc/bind_book(mob/user, obj/item/paper/P)
	if(stat)
		return
	if(busy)
		to_chat(user, span_warning("The book binder is busy. Please wait for completion of previous operation."))
		return
	if(!user.transferItemToLoc(P, src))
		return
	user.visible_message("[user] loads some paper into [src].", "You load some paper into [src].")
	audible_message("[src] begins to hum as it warms up its printing drums.")
	busy = TRUE
	busy = FALSE
	if(P)
		if(!stat)
			visible_message("[src] whirs as it prints and binds a new book.")
			var/obj/item/book/B = new(src.loc)
			for(var/datum/langtext/L in P.written)
				B.dat += L.text
			var/title = "Print Job #" + "[rand(100, 999)]"
			B.name = title
			B.title = title
			B.icon_state = "book[rand(1,7)]"
			B.author = user
			qdel(P)
		else
			P.forceMove(drop_location())
