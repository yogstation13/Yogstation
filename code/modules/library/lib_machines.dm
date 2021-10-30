#define PRINTER_COOLDOWN 60
#define PAGESIZE 10

GLOBAL_LIST_EMPTY(cachedbooks) // List of our cached book datums
GLOBAL_LIST_EMPTY(checkouts)

/* Library Machines
 *
 * Contains:
 *		Borrowbook datum
 *		Library Public Computer
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
	var/title
	var/category = "Any"
	var/author
	var/SQLquery = ""
	var/list/results = list()
	var/errorstate = FALSE
	var/cooldown = 0
	var/list/inventory = list()
	var/buffer_book
	/// Is it the curators book management console
	var/librarianconsole = FALSE
	/// Saved scanner
	var/obj/machinery/libraryscanner/scanner
	clockwork = TRUE //it'd look weird
	var/page = 0
	var/totalpages = 0

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
	/**
	dat += "<h3>Check Out a Book</h3><BR>"
	dat += "Book: [src.buffer_book] "
	dat += "<A href='?src=[REF(src)];editbook=1'>\[Edit\]</A><BR>"
	dat += "Recipient: [src.buffer_mob] "
	dat += "<A href='?src=[REF(src)];editmob=1'>\[Edit\]</A><BR>"
	dat += "Checkout Date : [world.time/600]<BR>"
	dat += "Due Date: [(world.time + checkoutperiod)/600]<BR>"
	dat += "(Checkout Period: [checkoutperiod] minutes) (<A href='?src=[REF(src)];increasetime=1'>+</A>/<A href='?src=[REF(src)];decreasetime=1'>-</A>)"
	dat += "<A href='?src=[REF(src)];checkout=1'>(Commit Entry)</A><BR>"
	dat += "<A href='?src=[REF(src)];switchscreen=0'>(Return to main menu)</A><BR>"
	*/
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
			//checkedout[REF(borrower)]["books"][REF(b.instance)] = borrowedbook
	data["checkouts"] = checkedout
	data["validcategorys"] = list("Any", "Fiction", "Non-Fiction", "Adult", "Reference", "Religion")
	data["category"] = category
	data["title"] = title
	data["author"] = author
	data["error"] = errorstate
	data["librarianconsole"] = librarianconsole
	data["page"] = page
	data["totalpages"] = CEILING(GLOB.cachedbooks.len/PAGESIZE, 1)
	data["emagged"] = (obj_flags & EMAGGED)
	var/list/books = list()
	for(var/id in GLOB.cachedbooks)
		var/book = GLOB.cachedbooks[id]
		// Certified byond moment interpreting a var as a string
		if(category == "Any")
			books += list("[id]"=book)
		else if(book["category"] == category)
			books += list("[id]"=book)
	data["result"] = books.Copy(page*PAGESIZE, clamp(page*PAGESIZE+PAGESIZE, 0, books.len))
	if(!scanner)
		scanner = findscanner(4)
	if(!scanner || !scanner.cache)
		data["scanner"] = null
	else
		data["scanner"] = list("author" = scanner.cache.author, "title" = scanner.cache.title, "id" = REF(scanner.cache))
	return data

/obj/machinery/computer/libraryconsole/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("setpage")
			page = clamp(params["page"], 0, totalpages)
		if("settitle")
			title = pretty_filter(params["name"])
		if("setauthor")
			author = pretty_filter(params["name"])
		if("setcategory")
			category = params["category"]
		if("checkoutbook")
			var/datum/cachedbook/borrowbook/b = new /datum/cachedbook/borrowbook
			var/found = FALSE
			for(var/person in GLOB.checkouts)
				if(person != usr)
					continue
				else
					found = TRUE
			if(!found)
				GLOB.checkouts[usr] = list()
			var/list/bookthing = GLOB.checkouts[usr]
			for(var/datum/cachedbook/borrowbook/book in bookthing)
				if(params["id"] == book.instance)
					say("Book is already checked out to this user")
					return
			b.instance = params["id"]
			b.title = params["title"]
			b.author = params["author"]
			b.mobname = usr
			b.getdate = world.time
			b.duedate = world.time + params["time"] MINUTES
			GLOB.checkouts[usr] |= b 
		if("uploadbook")
			var/msg = "[key_name(usr)] has uploaded the book titled [scanner.cache.name], [length(scanner.cache.dat)] signs"
			var/datum/DBQuery/query_library_upload = SSdbcore.NewQuery({"
				INSERT INTO [format_table_name("library")] (author, title, content, category, ckey, datetime, round_id_created)
				VALUES (:author, :title, :content, :category, :ckey, Now(), :round_id)
			"}, list("title" = scanner.cache.name, "author" = scanner.cache.author, "content" = scanner.cache.dat, "category" = params["category"], "ckey" = usr.ckey, "round_id" = GLOB.round_id))

			if(!query_library_upload.Execute())
				qdel(query_library_upload)
				alert("Database error encountered uploading to Archive")
				return
			else
				log_game(msg)
				qdel(query_library_upload)
				alert("Upload Complete. Uploaded title will be unavailable for printing for a short period")
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
					qdel(query_library_print)
					say("PRINTER ERROR! Failed to print document (0x0000000F)")
					return
				while(query_library_print.NextRow())
					var/bookauthor = query_library_print.item[2]
					var/booktitle = query_library_print.item[3]
					var/bookcontent = query_library_print.item[4]
					if(!QDELETED(src))
						var/obj/item/book/B = new(get_turf(src))
						B.name = "Book: [title]"
						B.title = booktitle
						B.author = bookauthor
						B.dat = bookcontent
						B.icon_state = "book[rand(1,8)]"
						visible_message("[src]'s printer hums as it produces a completely bound book. How did it do that?")
					break
				qdel(query_library_print)

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
	//screenstate = 0 // 0 - Main Menu, 1 - Inventory, 2 - Checked Out, 3 - Check Out a Book
	verb_say = "beeps"
	verb_ask = "beeps"
	verb_exclaim = "beeps"
	pass_flags = PASSTABLE
	var/arcanecheckout = 0
	var/upload_category = "Fiction"
	var/checkoutperiod = 5 // In minutes
	var/list/libcomp_menu
	librarianconsole = TRUE

/obj/machinery/computer/libraryconsole/bookmanagement/proc/build_library_menu()
	if(libcomp_menu)
		return
	load_library_db_to_cache()
	if(!GLOB.cachedbooks)
		return
	libcomp_menu = list("")

	for(var/i in 1 to GLOB.cachedbooks.len)
		var/datum/cachedbook/C = GLOB.cachedbooks[i]
		var/page = round(i/250)+1
		if (libcomp_menu.len < page)
			libcomp_menu.len = page
			libcomp_menu[page] = ""
		libcomp_menu[page] += "<tr><td>[C.author]</td><td>[C.title]</td><td>[C.category]</td><td><A href='?src=[REF(src)];targetid=[C.id]'>\[Order\]</A></td></tr>\n"

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

/obj/machinery/libraryscanner/attackby(obj/O, mob/user, params)
	if(istype(O, /obj/item/book))
		if(!user.transferItemToLoc(O, src))
			return
	else
		return ..()

/obj/machinery/libraryscanner/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	usr.set_machine(src)
	var/dat = "" // <META HTTP-EQUIV='Refresh' CONTENT='10'>
	if(cache)
		dat += "<FONT color=#005500>Data stored in memory.</FONT><BR>"
	else
		dat += "No data stored in memory.<BR>"
	dat += "<A href='?src=[REF(src)];scan=1'>\[Scan\]</A>"
	if(cache)
		dat += "       <A href='?src=[REF(src)];clear=1'>\[Clear Memory\]</A><BR><BR><A href='?src=[REF(src)];eject=1'>\[Remove Book\]</A>"
	else
		dat += "<BR>"
	var/datum/browser/popup = new(user, "scanner", name, 600, 400)
	popup.set_content(dat)
	popup.open()

/obj/machinery/libraryscanner/Topic(href, href_list)
	if(..())
		usr << browse(null, "window=scanner")
		onclose(usr, "scanner")
		return

	if(href_list["scan"])
		for(var/obj/item/book/B in contents)
			cache = B
			break
	if(href_list["clear"])
		cache = null
	if(href_list["eject"])
		for(var/obj/item/book/B in contents)
			B.forceMove(drop_location())
	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return


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
	sleep(rand(200,400))
	busy = FALSE
	if(P)
		if(!stat)
			visible_message("[src] whirs as it prints and binds a new book.")
			var/obj/item/book/B = new(src.loc)
			for(var/datum/langtext/L in P.written)
				B.dat = L.text
			B.name = "Print Job #" + "[rand(100, 999)]"
			B.icon_state = "book[rand(1,7)]"
			B.author = user
			qdel(P)
		else
			P.forceMove(drop_location())
