#define MAIN_SCREEN "main"
#define RECORD_MAINT "maint"
#define RECORD_VIEW "record_view"

/obj/machinery/computer/secure_data
	name = "security records console"
	desc = "Used to view and edit personnel's security records."
	icon_screen = "security"
	icon_keyboard = "security_key"
	req_one_access = list(ACCESS_SECURITY, ACCESS_DETECTIVE)
	circuit = /obj/item/circuitboard/computer/secure_data

	var/screen = MAIN_SCREEN

	var/printing = FALSE

	var/maxFine = 1000

	var/logged_in = FALSE
	var/rank = null

	var/datum/data/record/active_general_record = null
	var/datum/data/record/active_security_record = null

	//Radio internal
	var/obj/item/radio/radio
	var/radio_key = /obj/item/encryptionkey/heads/hos
	var/sec_freq = RADIO_CHANNEL_SECURITY
	var/command_freq = RADIO_CHANNEL_COMMAND

	var/special_message

	light_color = LIGHT_COLOR_RED

/obj/machinery/computer/secure_data/Initialize(mapload)
	. = ..()
	radio = new(src)
	radio.keyslot = new radio_key
	radio.subspace_transmission = TRUE
	radio.set_listening(FALSE)
	radio.use_command = TRUE
	radio.independent = TRUE
	radio.recalculateChannels()

/obj/machinery/computer/secure_data/Destroy()
	. = ..()
	QDEL_NULL(radio)

/obj/machinery/computer/secure_data/syndie
	icon_keyboard = "syndie_key"

/obj/machinery/computer/secure_data/laptop
	name = "security laptop"
	desc = "A cheap Nanotrasen security laptop, it functions as a security records console. It's bolted to the table."
	icon_state = "laptop"
	icon_screen = "seclaptop"
	icon_keyboard = "laptop_key"
	clockwork = TRUE //it'd look weird
	pass_flags = PASSTABLE

/obj/machinery/computer/secure_data/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SecurityConsole", name)
		ui.open()

/obj/machinery/computer/secure_data/ui_data(mob/living/carbon/human/user)
	var/list/data = list()
	data["records"] = list()

	data["z"] = loc.z

	data["logged_in"] = logged_in

	data += tgui_login_data(user, src)

	if(!logged_in)
		return data

	data["screen"] = screen
	data["special_message"]= special_message

	if(!isnull(GLOB.data_core.general) && screen == MAIN_SCREEN)
		for(var/RP in sortRecord(GLOB.data_core.general, "name"))
			var/list/record = list()
			var/datum/data/record/R = RP

			//What is their criminal status?
			var/crime_status = ""

			if(!istype(R))
				continue
			for(var/EP in GLOB.data_core.security)
				var/datum/data/record/E = EP
				if(!istype(E))
					continue
				if((E.fields["name"] == R.fields["name"]) && (E.fields["id"] == R.fields["id"]))
					crime_status = E.fields["criminal"]

			switch(crime_status)
				if(WANTED_ARREST)
					record["recordColor"] = "#990000"
					record["recordIcon"] = "fingerprint"
				if(WANTED_SEARCH)
					record["recordColor"] = "#5C4949"
					record["recordIcon"] = "search"
				if(WANTED_PRISONER)
					record["recordColor"] = "#181818"
					record["recordIcon"] = "dungeon"
				if(WANTED_SUSPECT)
					record["recordColor"] = "#CD6500"
					record["recordIcon"] = "exclamation"
				if(WANTED_PAROLE)
					record["recordColor"] = "#046713"
					record["recordIcon"] = "unlink"
				if(WANTED_DISCHARGED)
					record["recordColor"] = "#006699"
					record["recordIcon"] = "dove"
				if(WANTED_NONE)
					record["recordColor"] = "#740349"
				if("")
					crime_status = "No Record."

			record["name"] = R.fields["name"]
			record["id"] = R.fields["id"]
			record["rank"] = R.fields["rank"]
			record["fingerprint"] = R.fields["fingerprint"]
			record["crime_status"] = crime_status
			record["reference"] = REF(R)

			data["records"] += list(record)

	if(screen == RECORD_VIEW)
		var/list/record = list()

		if(!istype(active_general_record, /datum/data/record) || !GLOB.data_core.general.Find(active_general_record))
			screen = MAIN_SCREEN
			return
		var/list/assets = list()
		data["active_general_record"] = TRUE

		if(istype(active_general_record.fields["photo_front"], /obj/item/photo))
			var/obj/item/photo/P2 = active_general_record.fields["photo_front"]
			var/icon/picture = icon(P2.picture.picture_image)
			var/md5 = md5(fcopy_rsc(picture))

			if(!SSassets.cache["photo_[md5]_cropped.png"])
				SSassets.transport.register_asset("photo_[md5]_cropped.png", picture)
			SSassets.transport.send_assets(user, list("photo_[md5]_cropped.png" = picture))

			record["front_image"] = SSassets.transport.get_asset_url("photo_[md5]_cropped.png")

		if(istype(active_general_record.fields["photo_side"], /obj/item/photo))
			var/obj/item/photo/P3 = active_general_record.fields["photo_side"]
			var/icon/picture = icon(P3.picture.picture_image)
			var/md5 = md5(fcopy_rsc(picture))

			if(!SSassets.cache["photo_[md5]_cropped.png"])
				SSassets.transport.register_asset("photo_[md5]_cropped.png", picture)
			SSassets.transport.send_assets(user, list("photo_[md5]_cropped.png" = picture))

			record["side_image"] = SSassets.transport.get_asset_url("photo_[md5]_cropped.png")

		SSassets.transport.send_assets(user, assets)

		record["name"] = active_general_record.fields["name"]
		record["id"] = active_general_record.fields["id"]
		record["gender"] = active_general_record.fields["gender"]
		record["age"] = active_general_record.fields["age"]



		record["species"] = active_general_record.fields["species"]
		record["rank"] = active_general_record.fields["rank"]
		record["fingerprint"] = active_general_record.fields["fingerprint"]
		record["p_stat"] = active_general_record.fields["p_stat"]
		record["m_stat"] = active_general_record.fields["m_stat"]

		if(istype(active_security_record, /datum/data/record) && GLOB.data_core.security.Find(active_security_record))

			record["criminal_status"] = active_security_record.fields["criminal"]

			switch(active_security_record.fields["criminal"])
				if(WANTED_ARREST)
					record["recordColor"] = "#990000"
				if(WANTED_SEARCH)
					record["recordColor"] = "#5C4949"
				if(WANTED_PRISONER)
					record["recordColor"] = "#181818"
				if(WANTED_SUSPECT)
					record["recordColor"] = "#CD6500"
				if(WANTED_PAROLE)
					record["recordColor"] = "#046713"
				if(WANTED_DISCHARGED)
					record["recordColor"] = "#006699"
				if(WANTED_NONE)
					record["recordColor"] = "#740349"

			record["citations"] = list()

			for(var/datum/data/crime/C in active_security_record.fields["citation"])
				var/list/citation = list()
				var/owed = C.fine - C.paid
				citation["name"] = C.crimeName
				citation["fine"] = C.fine
				citation["time"] = C.time
				citation["author"] = C.author
				if(owed > 0)
					citation["status"] = "Unpaid"
				else
					citation["status"] = "Paid Off"
				citation["id"] = C.dataId

				record["citations"] += list(citation)

			record["crimes"] = list()

			for(var/datum/data/crime/C in active_security_record.fields["crimes"])
				var/list/crime = list()
				crime["name"] = C.crimeName
				crime["details"] = C.crimeDetails
				crime["author"] = C.author
				crime["time"] = C.time
				crime["id"] = C.dataId

				record["crimes"] += list(crime)

			record["comments"] = list()

			for(var/datum/data/comment/C in active_security_record.fields["comments"])
				var/list/comment = list()
				comment["content"] = C.commentText
				comment["author"] = C.author
				comment["time"] = C.time
				comment["id"] = C.dataId

				record["comments"] += list(comment)

			record["notes"] = active_security_record.fields["notes"]

		data["active_record"] = record

	return data

/obj/machinery/computer/secure_data/ui_static_data(mob/user)
	var/list/data = list()

	data["min_age"] = AGE_MIN
	data["max_age"] = AGE_MAX

	return data

/obj/machinery/computer/secure_data/ui_act(action, list/params)
	if(..())
		return



	switch(action)
		if("back")
			if(!logged_in)
				return
			screen = MAIN_SCREEN
			active_general_record = null
			active_security_record = null
			special_message = null
		if("log_in")
			active_general_record = null
			active_security_record = null
			screen = MAIN_SCREEN

			logged_in = tgui_login_act(usr, src)
			if(!logged_in)
				return

			if(issilicon(usr))
				var/mob/living/silicon/borg = usr
				logged_in = borg.name
				rank = "Silicon"
				return

			if(IsAdminGhost(usr))
				logged_in = usr.client.holder.admin_signature
				rank = "Central Command Officer"
				return

			var/mob/living/carbon/human/H = usr
			if(istype(H))
				logged_in = H.get_authentification_name("Unknown")
				rank = H.get_assignment("Unknown", "Unknown")
				return

		if("log_out")
			if(!logged_in)
				return
			logged_in = FALSE
			rank = null
			screen = MAIN_SCREEN
			active_general_record = null
			active_security_record = null

		if("record_maint")
			if(!logged_in)
				return
			screen = RECORD_MAINT
			active_general_record = null
			active_security_record = null

		if("browse_record")
			if(!logged_in)
				return
			var/datum/data/record/R = locate(params["record"]) in GLOB.data_core.general
			if(!R)
				special_message = "Record Not Found!";
			else
				active_general_record = R
				for(var/datum/data/record/E in GLOB.data_core.security)
					if((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
						active_security_record = E
				screen = RECORD_VIEW

		if("print_record")
			if(!logged_in)
				return

			if(!printing)
				printing = TRUE
				GLOB.data_core.securityPrintCount++
				playsound(loc, 'sound/items/poster_being_created.ogg', 100, 1)
				sleep(2 SECONDS)
				var/obj/item/paper/P = new /obj/item/paper(loc)
				P.info = "<CENTER><B>Security Record - (SR-[GLOB.data_core.securityPrintCount])</B></CENTER><BR>"
				if((istype(active_general_record, /datum/data/record) && GLOB.data_core.general.Find(active_general_record)))
					P.info += text("Name: [] ID: []<BR>\nGender: []<BR>\nAge: []<BR>", active_general_record.fields["name"], active_general_record.fields["id"], active_general_record.fields["gender"], active_general_record.fields["age"])
					P.info += "\nSpecies: [active_general_record.fields["species"]]<BR>"
					P.info += text("\nFingerprint: []<BR>\nPhysical Status: []<BR>\nMental Status: []<BR>", active_general_record.fields["fingerprint"], active_general_record.fields["p_stat"], active_general_record.fields["m_stat"])
				else
					P.info += "<B>General Record Lost!</B><BR>"
				if((istype(active_security_record, /datum/data/record) && GLOB.data_core.security.Find(active_security_record)))
					P.info += text("<BR>\n<CENTER><B>Security Data</B></CENTER><BR>\nCriminal Status: []", active_security_record.fields["criminal"])

					P.info += "<BR>\n<BR>\nCrimes:<BR>\n"
					P.info +={"<table style="text-align:center;" border="1" cellspacing="0" width="100%">
					<tr>
						<th>Crime</th>
						<th>Details</th>
						<th>Author</th>
						<th>Time Added</th>
					</tr>"}

					for(var/datum/data/crime/C in active_security_record.fields["crimes"])
						P.info += "<tr><td>[C.crimeName]</td>"
						P.info += "<td>[C.crimeDetails]</td>"
						P.info += "<td>[C.author]</td>"
						P.info += "<td>[C.time]</td>"
						P.info += "</tr>"
					P.info += "</table>"

					P.info += "<BR>\nComments: <BR>\n"
					P.info +={"<table style="text-align:center;" border="1" cellspacing="0" width="100%">
					<tr>
						<th>Comment</th>
						<th>Author</th>
						<th>Time Added</th>
					</tr>"}

					for(var/datum/data/comment/C in active_security_record.fields["comments"])
						P.info += "<tr><td>[C.commentText]</td>"
						P.info += "<td>[C.author]</td>"
						P.info += "<td>[C.time]</td>"
						P.info += "</tr>"
					P.info += "</table>"


					P.info += text("<BR>\nImportant Notes:<BR>\n\t[]<BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>", active_security_record.fields["notes"])

					P.name = text("SR-[] '[]'", GLOB.data_core.securityPrintCount, active_general_record.fields["name"])
				else
					P.info += "<B>Security Record Lost!</B><BR>"
					P.name = text("SR-[] '[]'", GLOB.data_core.securityPrintCount, "Record Lost")
				P.info += "</TT>"
				P.update_appearance(UPDATE_ICON)
				printing = FALSE

		if("print_poster")
			if(!logged_in)
				return
			if(!active_security_record)
				return
			if(!printing)
				var/wanted_name = stripped_input(usr, "Please enter an alias for the criminal:", "Print Wanted Poster", active_general_record.fields["name"])
				if(wanted_name)
					var/default_description = "A poster declaring [wanted_name] to be a dangerous individual, wanted by Nanotrasen. Report any sightings to security immediately."
					var/list/crimes = active_security_record.fields["crimes"]
					if(crimes.len)
						default_description += "\n[wanted_name] is wanted for the following crimes:\n"
					if(crimes.len)
						for(var/datum/data/crime/C in active_security_record.fields["crimes"])
							default_description += "\n[C.crimeName]\n"
							default_description += "[C.crimeDetails]\n"

					var/headerText = stripped_input(usr, "Please enter Poster Heading (Max 7 Chars):", "Print Wanted Poster", "WANTED", 8)

					var/info = stripped_multiline_input(usr, "Please input a description for the poster:", "Print Wanted Poster", default_description, null)
					if(info)
						playsound(loc, 'sound/items/poster_being_created.ogg', 100, 1)
						printing = TRUE
						sleep(2 SECONDS)
						if((istype(active_general_record, /datum/data/record) && GLOB.data_core.general.Find(active_general_record)))//make sure the record still exists.
							var/obj/item/photo/photo = active_general_record.fields["photo_front"]
							new /obj/item/poster/wanted(loc, photo.picture.picture_image, wanted_name, info, headerText)
						printing = FALSE

		if("print_missing")
			if(!logged_in)
				return
			if(!active_general_record)
				return
			if(!printing)
				var/missing_name = stripped_input(usr, "Please enter an alias for the missing person:", "Print Missing Persons Poster", active_general_record.fields["name"])
				if(missing_name)
					var/default_description = "A poster declaring [missing_name] to be a missing individual, missed by Nanotrasen. Report any sightings to security immediately."

					var/headerText = stripped_input(usr, "Please enter Poster Heading (Max 7 Chars):", "Print Missing Persons Poster", "MISSING", 8)

					var/info = stripped_multiline_input(usr, "Please input a description for the poster:", "Print Missing Persons Poster", default_description, null)
					if(info)
						playsound(loc, 'sound/items/poster_being_created.ogg', 100, 1)
						printing = TRUE
						sleep(2 SECONDS)
						if((istype(active_general_record, /datum/data/record) && GLOB.data_core.general.Find(active_general_record)))//make sure the record still exists.
							var/obj/item/photo/photo = active_general_record.fields["photo_front"]
							new /obj/item/poster/wanted/missing(loc, photo.picture.picture_image, missing_name, info, headerText)
						printing = FALSE
		if("delete_records")
			if(!logged_in)
				return
			if(tgui_alert(usr, "Are you sure you want to delete all security records?",, list("Yes", "No")) != "Yes")
				return
			investigate_log("[key_name(usr)] has purged all the security records.", INVESTIGATE_RECORDS)
			for(var/datum/data/record/R in GLOB.data_core.security)
				qdel(R)
			GLOB.data_core.security.Cut()
			special_message = "All Security Records Deleted."
			screen = MAIN_SCREEN

		if("new_record")
			if(!logged_in)
				return
			if(istype(active_general_record, /datum/data/record) && !istype(active_security_record, /datum/data/record))
				var/datum/data/record/R = new /datum/data/record()
				R.fields["name"] = active_general_record.fields["name"]
				R.fields["id"] = active_general_record.fields["id"]
				R.name = text("Security Record #[]", R.fields["id"])
				R.fields["criminal"] = WANTED_NONE
				R.fields["crimes"] = list()
				R.fields["comments"] = list()
				R.fields["notes"] = "No notes."
				GLOB.data_core.security += R
				active_security_record = R
				screen = RECORD_VIEW
		if("new_record_general")
			if(!logged_in)
				return
			//General Record
			var/datum/data/record/G = new /datum/data/record()
			G.fields["name"] = "New Record"
			G.fields["id"] = "[num2hex(rand(1, 1.6777215E7), 6)]"
			G.fields["rank"] = "Unassigned"
			G.fields["gender"] = "Male"
			G.fields["age"] = "Unknown"
			G.fields["species"] = "Human"
			G.fields["photo_front"] = new /icon()
			G.fields["photo_side"] = new /icon()
			G.fields["fingerprint"] = "?????"
			G.fields["p_stat"] = "Active"
			G.fields["m_stat"] = "Stable"
			GLOB.data_core.general += G
			active_general_record = G

			//Security Record
			var/datum/data/record/R = new /datum/data/record()
			R.fields["name"] = active_general_record.fields["name"]
			R.fields["id"] = active_general_record.fields["id"]
			R.name = text("Security Record #[]", R.fields["id"])
			R.fields["criminal"] = WANTED_NONE
			R.fields["crimes"] = list()
			R.fields["comments"] = list()
			R.fields["notes"] = "No notes."
			GLOB.data_core.security += R
			active_security_record = R

			//Medical Record
			var/datum/data/record/M = new /datum/data/record()
			M.fields["id"]			= active_general_record.fields["id"]
			M.fields["name"]		= active_general_record.fields["name"]
			M.fields["blood_type"]	= "?"
			M.fields["b_dna"]		= "?????"
			M.fields["mi_dis"]		= "None"
			M.fields["mi_dis_d"]	= "No minor disabilities have been declared."
			M.fields["ma_dis"]		= "None"
			M.fields["ma_dis_d"]	= "No major disabilities have been diagnosed."
			M.fields["alg"]			= "None"
			M.fields["alg_d"]		= "No allergies have been detected in this patient."
			M.fields["cdi"]			= "None"
			M.fields["cdi_d"]		= "No diseases have been diagnosed at the moment."
			M.fields["notes"]		= "No notes."
			GLOB.data_core.medical += M

		if("delete_general_record_and_security")
			if(!logged_in)
				return
			if(tgui_alert(usr, "Are you sure you want to delete these records?",, list("Yes", "No")) != "Yes")
				return
			if(active_general_record)
				investigate_log("[key_name(usr)] has deleted all records for [active_general_record.fields["name"]].", INVESTIGATE_RECORDS)
				for(var/datum/data/record/R in GLOB.data_core.medical)
					if((R.fields["name"] == active_general_record.fields["name"] || R.fields["id"] == active_general_record.fields["id"]))
						qdel(R)
						break
				qdel(active_general_record)
				active_general_record = null

				if(active_security_record)
					qdel(active_security_record)
					active_security_record = null
				screen = MAIN_SCREEN
				ui_interact(usr)


		if("delete_security_record")
			if(!logged_in)
				return
			if(tgui_alert(usr, "Are you sure you want to delete this record?",, list("Yes", "No")) != "Yes")
				return
			investigate_log("[key_name(usr)] has deleted the security records for [active_general_record.fields["name"]].", INVESTIGATE_RECORDS)
			if(active_security_record)
				screen = MAIN_SCREEN
				qdel(active_security_record)
				active_general_record = null
				active_security_record = null
				special_message = "Record Deleted"
				ui_interact(usr)



		if("edit_field")
			if(!logged_in)
				return
			var/general_record = active_general_record
			var/security_record = active_security_record

			switch(params["field"])
				if("name")
					if(istype(general_record, /datum/data/record) || istype(security_record, /datum/data/record))
						var/name = stripped_input(usr, "Please input name:", "Security Records", active_general_record.fields["name"], MAX_MESSAGE_LEN)
						if(!valid_record_change(usr, name, general_record))
							return
						if(istype(active_general_record, /datum/data/record))
							active_general_record.fields["name"] = name
						if(istype(active_security_record, /datum/data/record))
							active_security_record.fields["name"] = name

				if("id")
					if(istype(active_security_record, /datum/data/record) || istype(active_general_record, /datum/data/record))
						var/id = stripped_input(usr, "Please input ID:", "Security Records", active_general_record.fields["id"])
						if(!valid_record_change(usr, id, general_record))
							return
						if(istype(active_general_record, /datum/data/record))
							active_general_record.fields["id"] = id
						if(istype(active_security_record, /datum/data/record))
							active_security_record.fields["id"] = id

				if("fingerprint")
					if(istype(active_general_record, /datum/data/record))
						var/fingerprint = stripped_input(usr, "Please input fingerprint hash:", "Security Records", active_general_record.fields["fingerprint"])
						if(!valid_record_change(usr, fingerprint, general_record))
							return
						active_general_record.fields["fingerprint"] = fingerprint

				if("gender")
					if(istype(active_general_record, /datum/data/record))
						if(active_general_record.fields["gender"] == "Male")
							active_general_record.fields["gender"] = "Female"
						else if(active_general_record.fields["gender"] == "Female")
							active_general_record.fields["gender"] = "Other"
						else
							active_general_record.fields["gender"] = "Male"

				if("age")
					if(istype(active_general_record, /datum/data/record))
						var/age = text2num(params["field_value"])
						if(!valid_record_change(usr, "age", general_record))
							return
						active_general_record.fields["age"] = age

				if("species")
					if(istype(active_general_record, /datum/data/record))
						var/species = input("Select a species", "Species Selection") as null|anything in GLOB.roundstart_races
						if(!valid_record_change(usr, species, general_record))
							return
						active_general_record.fields["species"] = species

				if("upd_photo_front")
					var/obj/item/photo/photo = get_photo(usr)
					if(photo)
						qdel(active_general_record.fields["photo_front"])
						//Lets center it to a 32x32.
						var/icon/I = photo.picture.picture_image
						var/w = I.Width()
						var/h = I.Height()
						var/dw = w - 32
						var/dh = w - 32
						I.Crop(dw/2, dh/2, w - dw/2, h - dh/2)
						active_general_record.fields["photo_front"] = photo

				if("print_photo_front")
					if(active_general_record.fields["photo_front"])
						if(istype(active_general_record.fields["photo_front"], /obj/item/photo))
							var/obj/item/photo/P = active_general_record.fields["photo_front"]
							print_photo(P.picture.picture_image, active_general_record.fields["name"])

				if("upd_photo_side")
					var/obj/item/photo/photo = get_photo(usr)
					if(photo)
						qdel(active_general_record.fields["photo_side"])
						//Lets center it to a 32x32.
						var/icon/I = photo.picture.picture_image
						var/w = I.Width()
						var/h = I.Height()
						var/dw = w - 32
						var/dh = w - 32
						I.Crop(dw/2, dh/2, w - dw/2, h - dh/2)
						active_general_record.fields["photo_side"] = photo

				if("print_photo_side")
					if(active_general_record.fields["photo_side"])
						if(istype(active_general_record.fields["photo_side"], /obj/item/photo))
							var/obj/item/photo/P = active_general_record.fields["photo_side"]
							print_photo(P.picture.picture_image, active_general_record.fields["name"])

				if("crime_delete")
					if(istype(active_general_record, /datum/data/record))
						if(params["id"])
							if(!valid_record_change(usr, "delete", null, active_security_record))
								return
							GLOB.data_core.removeCrime(active_general_record.fields["id"], params["id"])

				if("crime_add")
					if(istype(active_general_record, /datum/data/record))
						var/name = stripped_input(usr, "Please input crime name:", "Security Records", "")
						var/details = stripped_input(usr, "Please input crime details:", "Security Records", "")
						if(!valid_record_change(usr, name, null, active_security_record))
							return
						var/crime = GLOB.data_core.createCrimeEntry(name, details, logged_in, station_time_timestamp())
						GLOB.data_core.addCrime(active_general_record.fields["id"], crime)
						investigate_log("New Crime: <strong>[name]</strong>: [details] | Added to [active_general_record.fields["name"]] by [key_name(usr)]", INVESTIGATE_RECORDS)

				if("comment_delete")
					if(istype(active_general_record, /datum/data/record))
						if(params["id"])
							if(!valid_record_change(usr, "delete", null, active_security_record))
								return
							GLOB.data_core.removeComment(active_general_record.fields["id"], params["id"])

				if("comment_add")
					if(istype(active_general_record, /datum/data/record))
						var/t1 = stripped_multiline_input(usr, "Add Comment:", "Security records")
						if(!valid_record_change(usr, name, null, active_security_record))
							return
						var/comment = GLOB.data_core.createCommentEntry(t1, logged_in)
						GLOB.data_core.addComment(active_general_record.fields["id"], comment)
						investigate_log("New Comment: [t1] | Added to [active_general_record.fields["name"]] by [key_name(usr)]", INVESTIGATE_RECORDS)


				if("citation_add")
					if(istype(active_general_record, /datum/data/record))
						var/name = stripped_input(usr, "Please input citation crime:", "Security Records", "")
						var/fine = FLOOR(input(usr, "Please input citation fine:", "Security Records", 50) as num, 1)
						if(!fine || fine < 0)
							to_chat(usr, span_warning("You're pretty sure that's not how money works."))
							return
						fine = min(fine, maxFine)
						if(!valid_record_change(usr, name, null, active_security_record))
							return
						var/crime = GLOB.data_core.createCrimeEntry(name, "", logged_in, station_time_timestamp(), fine)
						GLOB.data_core.addCitation(active_general_record.fields["id"], crime)
						investigate_log("New Citation: <strong>[name]</strong> Fine: [fine] | Added to [active_general_record.fields["name"]] by [key_name(usr)]", INVESTIGATE_RECORDS)
				if("citation_delete")
					if(istype(active_general_record, /datum/data/record))
						if(params["id"])
							if(!valid_record_change(usr, "delete", null, active_security_record))
								return
							GLOB.data_core.removeCitation(active_general_record.fields["id"], params["id"])

				if("edit_note")
					if(istype(active_security_record, /datum/data/record))
						var/name = stripped_input(usr, "Please summarize notes:", "Security Records", active_security_record.fields["notes"])
						if(!valid_record_change(usr, name, null, active_security_record))
							return
						active_security_record.fields["notes"] = name

				if("criminal_status")
					if(active_security_record)
						var/crime = tgui_input_list(usr, "Select a status", "Criminal Status Selection", list("None", "Arrest", "Search", "Incarcerated", "Suspected", "Paroled", "Discharged"))
						if(!crime)
							crime = "none"
						var/old_field = active_security_record.fields["criminal"]
						switch(crime)
							if("None")
								active_security_record.fields["criminal"] = WANTED_NONE
							if("Arrest")
								active_security_record.fields["criminal"] = WANTED_ARREST
							if("Search")
								active_security_record.fields["criminal"] = WANTED_SEARCH
							if("Incarcerated")
								active_security_record.fields["criminal"] = WANTED_PRISONER
							if("Suspected")
								active_security_record.fields["criminal"] = WANTED_SUSPECT
							if("Paroled")
								active_security_record.fields["criminal"] = WANTED_PAROLE
							if("Discharged")
								active_security_record.fields["criminal"] = WANTED_DISCHARGED
						investigate_log("[active_general_record.fields["name"]] has been set from [old_field] to [active_security_record.fields["criminal"]] by [key_name(usr)].", INVESTIGATE_RECORDS)
						active_security_record.fields["comments"] |= GLOB.data_core.createCommentEntry("Criminal status set to [active_security_record.fields["criminal"]].", logged_in)
						for(var/mob/living/carbon/human/H in GLOB.carbon_list)
							H.sec_hud_set_security_status()

				if("rank")
					var/changed_rank = null
					var/mob/living/carbon/human/user = usr
					if(!issilicon(usr))
						if(user.wear_id)
							var/list/access = user.wear_id.GetAccess()
							if((ACCESS_KEYCARD_AUTH || ACCESS_CAPTAIN || ACCESS_CHANGE_IDS || ACCESS_HOP || ACCESS_HOS) in access)
								changed_rank = input("Select a rank", "Rank Selection") as null|anything in get_all_jobs()
							else
								say("You do not have the required access to do this!")
								return
						else
							say("Cannot detect ID in your ID slot!")
							return
					else
						changed_rank = input("Select a rank", "Rank Selection") as null|anything in get_all_jobs()

					if(active_general_record && changed_rank)
						active_general_record.fields["rank"] = strip_html(changed_rank)
						if(changed_rank in get_all_jobs())
							active_general_record.fields["real_rank"] = changed_rank


/obj/machinery/computer/secure_data/proc/valid_record_change(mob/user, message1 = 0, record1, record2)
	if(user)
		if(logged_in)
			if(!trim(message1))
				return FALSE
			if(!record1 || record1 == active_general_record)
				if(!record2 || record2 == active_security_record)
					return TRUE
	return FALSE

/obj/machinery/computer/secure_data/proc/get_photo(mob/user)
	var/obj/item/photo/P = null
	if(issilicon(user))
		var/mob/living/silicon/tempAI = user
		var/datum/picture/selection = tempAI.aicamera?.selectpicture(user)
		P = new(null, selection)
	else if(istype(user.get_active_held_item(), /obj/item/photo))
		P = user.get_active_held_item()
	return P

/obj/machinery/computer/secure_data/proc/print_photo(icon/temp, person_name)
	if (printing)
		return
	printing = TRUE
	playsound(loc, 'sound/items/poster_being_created.ogg', 100, 1)
	sleep(2 SECONDS)
	var/obj/item/photo/P = new/obj/item/photo(drop_location())
	var/datum/picture/toEmbed = new(name = person_name, desc = "The photo on file for [person_name].", image = temp)
	P.set_picture(toEmbed, TRUE, TRUE)
	P.pixel_x = rand(-10, 10)
	P.pixel_y = rand(-10, 10)
	printing = FALSE

/obj/machinery/computer/secure_data/proc/trigger_alarm() //Copy pasted from /area/proc/burglaralert(obj/trigger) because why not
	var/area/alarmed = get_area(src)
	if(alarmed.always_unpowered) //no burglar alarms in space/asteroid
		return

	//Trigger alarm effect
	alarmed.set_fire_alarm_effect()
	//Lockdown airlocks
	for(var/obj/machinery/door/DOOR in alarmed)
		alarmed.close_and_lock_door(DOOR)

	for (var/i in GLOB.silicon_mobs)
		var/mob/living/silicon/SILICON = i
		if(SILICON.triggerAlarm("Burglar", alarmed, alarmed.cameras, src))
			//Cancel silicon alert after 1 minute
			addtimer(CALLBACK(SILICON, TYPE_PROC_REF(/mob/living/silicon, cancelAlarm),"Burglar",src,alarmed), 600)

/obj/machinery/computer/secure_data/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(logged_in) // What was the point then?
		return FALSE
	var/name
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		if(human_user.get_idcard(TRUE))
			var/obj/item/card/id/ID = human_user.get_idcard(TRUE)
			name = "[ID.registered_name]"
		else
			name = "Unknown"
	if(issilicon(user))
		name = "[user.name]"
	logged_in = TRUE
	to_chat(user, span_warning("You override [src]'s ID lock."))
	trigger_alarm()
	playsound(src, 'sound/effects/alert.ogg', 50, TRUE)
	var/area/A = get_area(loc)
	radio.talk_into(src, "Alert: security breach alarm triggered in [A.map_name]!! Unauthorized access by [name] of [src]!!", sec_freq)
	radio.talk_into(src, "Alert: security breach alarm triggered in [A.map_name]!! Unauthorized access by [name] of [src]!!", command_freq)
	return TRUE

/obj/machinery/computer/secure_data/emp_act(severity)
	. = ..()

	if(stat & (BROKEN|NOPOWER) || . & EMP_PROTECT_SELF)
		return

	for(var/datum/data/record/R in GLOB.data_core.security)
		if(prob(severity))
			switch(rand(1,8))
				if(1)
					if(prob(10))
						R.fields["name"] = "[pick(lizard_name(MALE),lizard_name(FEMALE))]"
					else
						R.fields["name"] = "[pick(pick(GLOB.first_names_male), pick(GLOB.first_names_female))] [pick(GLOB.last_names)]"
				if(2)
					R.fields["gender"] = pick("Male", "Female", "Other")
				if(3)
					R.fields["age"] = rand(5, 85)
				if(4)
					R.fields["criminal"] = pick(WANTED_NONE, WANTED_ARREST, WANTED_SEARCH, WANTED_PRISONER, WANTED_SUSPECT, WANTED_PAROLE, WANTED_DISCHARGED)
				if(5)
					R.fields["p_stat"] = pick("*Unconscious*", "Active", "Physically Unfit")
				if(6)
					R.fields["m_stat"] = pick("*Insane*", "*Unstable*", "*Watch*", "Stable")
				if(7)
					R.fields["species"] = pick(GLOB.roundstart_races)
				if(8)
					var/datum/data/record/G = pick(GLOB.data_core.general)
					R.fields["photo_front"] = G.fields["photo_front"]
					R.fields["upd_photo_front"] = G.fields["upd_photo_front"]
					R.fields["photo_side"] = G.fields["photo_side"]
					R.fields["upd_photo_side"] = G.fields["upd_photo_side"]
			continue

		else if(prob(1))
			qdel(R)
			continue

#undef MAIN_SCREEN
#undef RECORD_MAINT
#undef RECORD_VIEW
