#define MAIN_SCREEN "main"
#define RECORD_MAINT "maint"
#define RECORD_VIEW "record_view"

/obj/machinery/computer/secure_data
	name = "security records console"
	desc = "Used to view and edit personnel's security records."
	icon_screen = "security"
	icon_keyboard = "security_key"
	req_one_access = list(ACCESS_SECURITY, ACCESS_FORENSICS_LOCKERS)
	circuit = /obj/item/circuitboard/computer/secure_data

	var/screen = MAIN_SCREEN

	var/printing = FALSE

	var/maxFine = 1000

	var/logged_in = FALSE
	var/rank = null

	var/datum/data/record/active_general_record = null
	var/datum/data/record/active_security_record = null

	var/special_message

	light_color = LIGHT_COLOR_RED

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

	if(issilicon(user))
		var/mob/living/silicon/borg = user
		data["username"] = borg.name
		data["has_access"] = TRUE

	if(IsAdminGhost(user))
		data["username"] = user.client.holder.admin_signature
		data["has_access"] = TRUE

	if(ishuman(user))
		var/username = user.get_authentification_name("Unknown")
		data["username"] = user.get_authentification_name("Unknown")
		if(username != "Unknown")
			var/datum/data/record/record
			for(var/RP in GLOB.data_core.general)
				var/datum/data/record/R = RP

				if(!istype(R))
					continue
				if(R.fields["name"] == username)
					record = R
					break
			if(record)
				if(istype(record.fields["photo_front"], /obj/item/photo))
					var/obj/item/photo/P1 = record.fields["photo_front"]
					var/icon/picture = icon(P1.picture.picture_image)
					picture.Crop(10, 32, 22, 22)
					var/md5 = md5(fcopy_rsc(picture))

					if(!SSassets.cache["photo_[md5]_cropped.png"])
						SSassets.transport.register_asset("photo_[md5]_cropped.png", picture)
					SSassets.transport.send_assets(user, list("photo_[md5]_cropped.png" = picture))

					data["user_image"] = SSassets.transport.get_asset_url("photo_[md5]_cropped.png")
		data["has_access"] = check_access(user.get_idcard())



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
				if("*Arrest*")
					record["recordColor"] = "#990000"
					record["recordIcon"] = "fingerprint"
				if("Search")
					record["recordColor"] = "#5C4949"
					record["recordIcon"] = "search"
				if("Incarcerated")
					record["recordColor"] = "#CD6500"
					record["recordIcon"] = "dungeon"
				if("Paroled")
					record["recordColor"] = "#CD6500;"
					record["recordIcon"] = "unlink"
				if("Discharged")
					record["recordColor"] = "#006699"
					record["recordIcon"] = "dove"
				if("None")
					record["recordColor"] = "#4F7529"
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
			var/obj/item/photo/P1 = active_general_record.fields["photo_front"]
			if(!SSassets.cache["photo_front_[active_general_record.fields["id"]].png"])
				SSassets.transport.register_asset("photo_front_[active_general_record.fields["id"]].png", P1.picture.picture_image)
			assets["photo_front_[active_general_record.fields["id"]].png"] = P1.picture.picture_image

		if(istype(active_general_record.fields["photo_side"], /obj/item/photo))
			var/obj/item/photo/P2 = active_general_record.fields["photo_side"]
			if(!SSassets.cache["photo_side_[active_general_record.fields["id"]].png"])
				SSassets.transport.register_asset("photo_side_[active_general_record.fields["id"]].png", P2.picture.picture_image)
			assets["photo_side_[active_general_record.fields["id"]].png"] = P2.picture.picture_image

		SSassets.transport.send_assets(user, assets)
		
		record["front_image"] = SSassets.transport.get_asset_url("photo_front_[active_general_record.fields["id"]].png")
		record["side_image"] = SSassets.transport.get_asset_url("photo_side_[active_general_record.fields["id"]].png")


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
				if("*Arrest*")
					record["recordColor"] = "#990000"
				if("Search")
					record["recordColor"] = "#5C4949"
				if("Incarcerated")
					record["recordColor"] = "#CD6500"
				if("Paroled")
					record["recordColor"] = "#CD6500;"
				if("Discharged")
					record["recordColor"] = "#006699"
				if("None")
					record["recordColor"] = "#4F7529"

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

			record["minor_crimes"] = list()

			for(var/datum/data/crime/C in active_security_record.fields["mi_crim"])
				var/list/minor_crime = list()
				minor_crime["name"] = C.crimeName
				minor_crime["details"] = C.crimeDetails
				minor_crime["author"] = C.author
				minor_crime["time"] = C.time
				minor_crime["id"] = C.dataId

				record["minor_crimes"] += list(minor_crime)

			record["major_crimes"] = list()

			for(var/datum/data/crime/C in active_security_record.fields["ma_crim"])
				var/list/major_crime = list()
				major_crime["name"] = C.crimeName
				major_crime["details"] = C.crimeDetails
				major_crime["author"] = C.author
				major_crime["time"] = C.time
				major_crime["id"] = C.dataId

				record["major_crimes"] += list(major_crime)

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

			if(issilicon(usr))
				var/mob/living/silicon/borg = usr
				logged_in = borg.name
				rank = "Silicon"
				return

			if(IsAdminGhost(usr))
				logged_in = usr.client.holder.admin_signature
				rank = "Central Command Officer"




			var/mob/living/carbon/human/H = usr
			if(!istype(H))
				return

			if(check_access(H.get_idcard()))
				logged_in = H.get_authentification_name("Unknown")
				rank = H.get_assignment("Unknown", "Unknown")
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

					P.info += "<BR>\n<BR>\nMinor Crimes:<BR>\n"
					P.info +={"<table style="text-align:center;" border="1" cellspacing="0" width="100%">
					<tr>
						<th>Crime</th>
						<th>Details</th>
						<th>Author</th>
						<th>Time Added</th>
					</tr>"}

					for(var/datum/data/crime/C in active_security_record.fields["mi_crim"])
						P.info += "<tr><td>[C.crimeName]</td>"
						P.info += "<td>[C.crimeDetails]</td>"
						P.info += "<td>[C.author]</td>"
						P.info += "<td>[C.time]</td>"
						P.info += "</tr>"
					P.info += "</table>"

					P.info += "<BR>\nMajor Crimes: <BR>\n"
					P.info +={"<table style="text-align:center;" border="1" cellspacing="0" width="100%">
					<tr>
						<th>Crime</th>
						<th>Details</th>
						<th>Author</th>
						<th>Time Added</th>
					</tr>"}

					for(var/datum/data/crime/C in active_security_record.fields["ma_crim"])
						P.info += "<tr><td>[C.crimeName]</td>"
						P.info += "<td>[C.crimeDetails]</td>"
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
				P.update_icon()
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
					var/list/major_crimes = active_security_record.fields["ma_crim"]
					var/list/minor_crimes = active_security_record.fields["mi_crim"]
					if(major_crimes.len + minor_crimes.len)
						default_description += "\n[wanted_name] is wanted for the following crimes:\n"
					if(minor_crimes.len)
						default_description += "\nMinor Crimes:"
						for(var/datum/data/crime/C in active_security_record.fields["mi_crim"])
							default_description += "\n[C.crimeName]\n"
							default_description += "[C.crimeDetails]\n"
					if(major_crimes.len)
						default_description += "\nMajor Crimes:"
						for(var/datum/data/crime/C in active_security_record.fields["ma_crim"])
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
			if(alert("Are you sure you want to delete all security records?",, "Yes", "No") != "Yes")
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
				R.fields["criminal"] = "None"
				R.fields["mi_crim"] = list()
				R.fields["ma_crim"] = list()
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
			R.fields["criminal"] = "None"
			R.fields["mi_crim"] = list()
			R.fields["ma_crim"] = list()
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
			if(alert("Are you sure you want to delete these records?",, "Yes", "No") != "Yes")
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
			if(alert("Are you sure you want to delete this record?",, "Yes", "No") != "Yes")
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
						var/id = stripped_input(usr, "Please input ID:", "Security Records", active_general_record.fields["id"], null)
						if(!valid_record_change(usr, id, general_record))
							return
						if(istype(active_general_record, /datum/data/record))
							active_general_record.fields["id"] = id
						if(istype(active_security_record, /datum/data/record))
							active_security_record.fields["id"] = id

				if("fingerprint")
					if(istype(active_general_record, /datum/data/record))
						var/fingerprint = stripped_input(usr, "Please input fingerprint hash:", "Security Records", active_general_record.fields["fingerprint"], null)
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


				if("print_photo_front")
					if(active_general_record.fields["photo_front"])
						if(istype(active_general_record.fields["photo_front"], /obj/item/photo))
							var/obj/item/photo/P = active_general_record.fields["photo_front"]
							print_photo(P.picture.picture_image, active_general_record.fields["name"])


				if("print_photo_side")
					if(active_general_record.fields["photo_side"])
						if(istype(active_general_record.fields["photo_side"], /obj/item/photo))
							var/obj/item/photo/P = active_general_record.fields["photo_side"]
							print_photo(P.picture.picture_image, active_general_record.fields["name"])

				if("minor_crime_add")
					if(istype(active_general_record, /datum/data/record))
						var/name = stripped_input(usr, "Please input minor crime names:", "Security Records", "", null)
						var/details = stripped_input(usr, "Please input minor crime details:", "Security Records", "", null)
						if(!valid_record_change(usr, name, null, active_security_record))
							return
						var/crime = GLOB.data_core.createCrimeEntry(name, details, logged_in, station_time_timestamp())
						GLOB.data_core.addMinorCrime(active_general_record.fields["id"], crime)
						investigate_log("New Minor Crime: <strong>[name]</strong>: [details] | Added to [active_general_record.fields["name"]] by [key_name(usr)]", INVESTIGATE_RECORDS)

				if("minor_crime_delete")
					if(istype(active_general_record, /datum/data/record))
						if(params["id"])
							if(!valid_record_change(usr, "delete", null, active_security_record))
								return
							GLOB.data_core.removeMinorCrime(active_general_record.fields["id"], params["id"])

				if("major_crime_add")
					if(istype(active_general_record, /datum/data/record))
						var/name = stripped_input(usr, "Please input major crime names:", "Security Records", "", null)
						var/details = stripped_input(usr, "Please input major crime details:", "Security Records", "", null)
						if(!valid_record_change(usr, name, null, active_security_record))
							return
						var/crime = GLOB.data_core.createCrimeEntry(name, details, logged_in, station_time_timestamp())
						GLOB.data_core.addMajorCrime(active_general_record.fields["id"], crime)
						investigate_log("New Major Crime: <strong>[name]</strong>: [details] | Added to [active_general_record.fields["name"]] by [key_name(usr)]", INVESTIGATE_RECORDS)

				if("major_crime_delete")
					if(istype(active_general_record, /datum/data/record))
						if(params["id"])
							if(!valid_record_change(usr, "delete", null, active_security_record))
								return
							GLOB.data_core.removeMajorCrime(active_general_record.fields["id"], params["id"])

				if("citation_add")
					if(istype(active_general_record, /datum/data/record))
						var/name = stripped_input(usr, "Please input citation crime:", "Security Records", "", null)
						var/fine = FLOOR(input(usr, "Please input citation fine:", "Security Records", 50) as num, 1)
						if(!fine || fine < 0)
							to_chat(usr, "<span class='warning'>You're pretty sure that's not how money works.</span>")
							return
						fine = min(fine, maxFine)
						if(!valid_record_change(usr, name, null, active_security_record))
							return
						var/crime = GLOB.data_core.createCrimeEntry(name, "", logged_in, station_time_timestamp(), fine)
						for (var/obj/item/pda/P in GLOB.PDAs)
							if(P.owner == active_general_record.fields["name"])
								var/message = "You have been fined [fine] credits for '[name]'. Fines may be paid at security."
								var/datum/signal/subspace/messaging/pda/signal = new(src, list(
									"name" = "Security Citation",
									"job" = "Citation Server",
									"message" = message,
									"targets" = list("[P.owner] ([P.ownjob])"),
									"automated" = 1
								))
								signal.send_to_receivers()
								usr.log_message("(PDA: Citation Server) sent \"[message]\" to [signal.format_target()]", LOG_PDA)
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
						var/name = stripped_input(usr, "Please summarize notes:", "Security Records", active_security_record.fields["notes"], null)
						if(!valid_record_change(usr, name, null, active_security_record))
							return
						active_security_record.fields["notes"] = name

				if("criminal_status")
					if(active_security_record)
						var/crime = input("Select a status", "Criminal Status Selection") as null|anything in list("None", "Arrest", "Search", "Incarcerated", "Paroled", "Discharged")
						if(!crime)
							crime = "none"
						var/old_field = active_security_record.fields["criminal"]
						switch(crime)
							if("None")
								active_security_record.fields["criminal"] = "None"
							if("Arrest")
								active_security_record.fields["criminal"] = "*Arrest*"
							if("Search")
								active_security_record.fields["criminal"] = "Search"
							if("Incarcerated")
								active_security_record.fields["criminal"] = "Incarcerated"
							if("Paroled")
								active_security_record.fields["criminal"] = "Paroled"
							if("Discharged")
								active_security_record.fields["criminal"] = "Discharged"
						investigate_log("[active_general_record.fields["name"]] has been set from [old_field] to [active_security_record.fields["criminal"]] by [key_name(usr)].", INVESTIGATE_RECORDS)
						for(var/mob/living/carbon/human/H in GLOB.carbon_list)
							H.sec_hud_set_security_status()

				if("rank")
					var/list/allowed_ranks = list("Head of Personnel", "Captain", "AI", "Central Command")
					var/changed_rank = null
					if((istype(active_general_record, /datum/data/record) && allowed_ranks.Find(rank)))
						changed_rank = input("Select a rank", "Rank Selection") as null|anything in get_all_jobs()
					else
						alert(usr, "You do not have the required rank to do this!")
						return

					if(active_general_record)
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
		var/datum/picture/selection = tempAI.GetPhoto(user)
		if(selection)
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

/obj/machinery/computer/secure_data/emp_act(severity)
	. = ..()

	if(stat & (BROKEN|NOPOWER) || . & EMP_PROTECT_SELF)
		return

	for(var/datum/data/record/R in GLOB.data_core.security)
		if(prob(10/severity))
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
					R.fields["criminal"] = pick("None", "*Arrest*", "Search", "Incarcerated", "Paroled", "Discharged")
				if(5)
					R.fields["p_stat"] = pick("*Unconscious*", "Active", "Physically Unfit")
				if(6)
					R.fields["m_stat"] = pick("*Insane*", "*Unstable*", "*Watch*", "Stable")
				if(7)
					R.fields["species"] = pick(GLOB.roundstart_races)
				if(8)
					var/datum/data/record/G = pick(GLOB.data_core.general)
					R.fields["photo_front"] = G.fields["photo_front"]
					R.fields["photo_side"] = G.fields["photo_side"]
			continue

		else if(prob(1))
			qdel(R)
			continue

#undef MAIN_SCREEN
#undef RECORD_MAINT
#undef RECORD_VIEW
