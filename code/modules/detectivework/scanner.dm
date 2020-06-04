//CONTAINS: Detective's Scanner

// TODO: Split everything into easy to manage procs.

/obj/item/detective_scanner
	name = "forensic scanner"
	desc = "Used to remotely scan objects and biomass for DNA and fingerprints. Can print a report of the findings."
	icon = 'icons/obj/device.dmi'
	icon_state = "forensicnew"
	w_class = WEIGHT_CLASS_SMALL
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	actions_types = list(/datum/action/item_action/displayDetectiveScanResults)
	var/scanning = 0
	var/list/log = list()
	var/range = 8
	var/view_check = TRUE
	var/forensicPrintCount = 0
	var/icon_state_neutral // stores the neutral icon state
	var/scan_icon = TRUE // does the forensic scanner have a scanning icon state?
	var/icon_state_scanning =  "forensicnew_scan" // icon state for scanning
	var/scan_speed = 4 // the speed between scans. The delay is this value x2 . Total scan time  = scan_speed * 10 for minimum , scan_speed * 18 if results for each catagory are found
	var/admin = FALSE // does this scanner pull up hiddenprints? Also removes scan time and feedback giving instant results
	var/advanced = FALSE // does this scanner pull up more details on results?

	// sounds must be in sound/items by default. Modify sound_directory for a different directory.
	var/can_sound = TRUE // can this scanner play sound at all?
	var/sound_on = TRUE // is the sound currently turned on?
	var/sound_directory = "sound/items" // just in-case you decide to place your sounds outside of sound\items
	var/sound_positive = "scanner_positive" // plays as a result is found during the scan
	var/sound_scan = "scanner_scan" // plays as each new scan is starting
	var/sound_match = "scanner_match" // plays at the end when there is a match found
	var/sound_nomatch = "scanner_nomatch" // plays at the end when no matches were found

/obj/item/detective_scanner/proc/feedback(file)
	if(!file || admin)
		return
	var/sound_to_play = "[sound_directory]/[file].ogg"
	sleep(scan_speed)
	if(sound_on)
		playsound(src, sound_to_play, 50, 0)
	sleep(scan_speed)

/obj/item/detective_scanner/Initialize()
	. = ..()
	icon_state_neutral = icon_state
	sound_on = (can_sound ? sound_on : FALSE)

/datum/action/item_action/displayDetectiveScanResults
	name = "Display Forensic Scanner Results"

/datum/action/item_action/displayDetectiveScanResults/Trigger()
	var/obj/item/detective_scanner/scanner = target
	if(istype(scanner))
		scanner.displayDetectiveScanResults(usr)

/obj/item/detective_scanner/attack_self(mob/user)
	// placeholders ; Redoing this part and splitting into different procs - Hopek
	radial_generate()
	radial_show(user)
	
	
	//option_print(user)
	//option_clearlogs(user)
	
/obj/item/detective_scanner/proc/option_print(mob/user)
	if(log.len && !scanning)
		scanning = 1
		scan_animation()
		to_chat(user, "<span class='notice'>Printing report, please wait...</span>")
		if(admin)
			PrintReport() // admin scanner bypasses print wait
		else
			addtimer(CALLBACK(src, .proc/PrintReport), 100)
	else
		to_chat(user, "<span class='notice'>The scanner has no logs or is in use.</span>")

/obj/item/detective_scanner/proc/option_clearlogs(mob/user)
	// Best way for checking if a player can use while not incapacitated, etc
	if(!user.canUseTopic(src, be_close=TRUE))
		return
	if(!LAZYLEN(log))
		to_chat(user, "<span class='notice'>Cannot clear logs, the scanner has no logs.</span>")
		return
	if(scanning)
		to_chat(user, "<span class='notice'>Cannot clear logs, the scanner is in use.</span>")
		return
	to_chat(user, "<span class='notice'>The scanner logs are cleared.</span>")
	log = list()

/obj/item/detective_scanner/attack(mob/living/M, mob/user)
	return

/obj/item/detective_scanner/proc/scan_animation()
	if(scan_icon)
		icon_state = (scanning ? icon_state_scanning : icon_state_neutral)

/obj/item/detective_scanner/proc/radial_generate() // generate option menu in order to show context sensitive menu
	// placeholder

/obj/item/detective_scanner/proc/radial_show(mob/user) // shows radial to user and performs actions based on it.
	// placeholder

/obj/item/detective_scanner/proc/PrintReport()
	// Create our paper
	var/obj/item/paper/P = new(get_turf(src))

	//This could be a global count like sec and med record printouts. See GLOB.data_core.medicalPrintCount AKA datacore.dm
	var frNum = ++forensicPrintCount

	P.name = text("FR-[] 'Forensic Record'", frNum)
	P.info = text("<center><B>Forensic Record - (FR-[])</B></center><HR><BR>", frNum)
	P.info += jointext(log, "<BR>")
	P.info += "<HR><B>Notes:</B><BR>"
	P.update_icon()

	if(ismob(loc))
		var/mob/M = loc
		M.put_in_hands(P)
		to_chat(M, "<span class='notice'>Report printed. Log cleared.</span>")

	// Clear the logs
	log = list()
	scanning = 0
	scan_animation()

/obj/item/detective_scanner/afterattack(atom/A, mob/user, params)
	. = ..()
	scan(A, user)
	return FALSE

/obj/item/detective_scanner/proc/scan(atom/A, mob/user)
	set waitfor = 0
	if(!scanning)
		// Can remotely scan objects and mobs.
		if((get_dist(A, user) > range) || (!(A in view(range, user)) && view_check) || (loc != user))
			return

		scanning = 1
		scan_animation()

		user.visible_message("\The [user] points the [src.name] at \the [A] and performs a forensic scan.")
		to_chat(user, "<span class='notice'>You scan \the [A]. The scanner is now analysing the results...</span>")


		// GATHER INFORMATION

		//Make our lists
		var/list/fingerprints = list()
		var/list/blood = A.return_blood_DNA()
		var/list/fibers = A.return_fibers()
		var/list/reagents = list()

		var/target_name = A.name

		// Start gathering

		if(ishuman(A))

			var/mob/living/carbon/human/H = A
			if(!H.gloves)
				fingerprints += md5(H.dna.uni_identity)

		else if(!ismob(A))

			fingerprints = ( admin ? A.return_hiddenprints() : A.return_fingerprints() )

			// Only get reagents from non-mobs.
			if(A.reagents && A.reagents.reagent_list.len)

				for(var/datum/reagent/R in A.reagents.reagent_list)
					reagents[R.name] = R.volume

					// Get blood data from the blood reagent.
					if(istype(R, /datum/reagent/blood))

						if(R.data["blood_DNA"] && R.data["blood_type"])
							var/blood_DNA = R.data["blood_DNA"]
							var/blood_type = R.data["blood_type"]
							LAZYINITLIST(blood)
							blood[blood_DNA] = blood_type

		// We gathered everything. Create a fork and slowly display the results to the holder of the scanner.
		var/found_something = 0
		add_log("<B>[station_time_timestamp()][get_timestamp()] - [target_name]</B>", 0)
		if(advanced)
			var/area/scan_location = (get_area(src))
			add_log("<B>Location of scan:</B> [scan_location.map_name].")

		// Fingerprints
		feedback(sound_scan)
		if(length(fingerprints))
			add_log("<span class='info'><B>Prints:</B></span>")
			for(var/finger in fingerprints)
				add_log("[finger]")
			found_something = 1
			feedback(sound_positive)

		// Blood
		feedback(sound_scan)
		if (length(blood))
			feedback(sound_positive)
			add_log("<span class='info'><B>Blood:</B></span>")
			for(var/B in blood)
				add_log("Type: <font color='red'>[blood[B]]</font> DNA: <font color='red'>[B]</font>")
				found_something = 1

		//Fibers
		feedback(sound_scan)
		if(length(fibers))
			feedback(sound_positive)
			add_log("<span class='info'><B>Fibers:</B></span>")
			for(var/fiber in fibers)
				add_log("[fiber]")
			found_something = 1

		//Reagents
		feedback(sound_scan)
		if(length(reagents))
			add_log("<span class='info'><B>Reagents:</B></span>")
			for(var/R in reagents)
				add_log("Reagent: <font color='red'>[R]</font> Volume: <font color='red'>[reagents[R]]</font>")
			found_something = 1
			feedback(sound_positive)

		// Get a new user
		var/mob/holder = null
		if(ismob(src.loc))
			holder = src.loc

		if(!found_something)
			feedback(sound_nomatch)
			add_log("<I># No forensic traces found #</I>", 0) // Don't display this to the holder user
			if(holder)
				to_chat(holder, "<span class='warning'>Unable to locate any fingerprints, materials, fibers, or blood on \the [target_name]!</span>")
		else
			feedback(sound_match)
			if(holder)
				to_chat(holder, "<span class='notice'>You finish scanning \the [target_name].</span>")

		add_log("---------------------------------------------------------", 0)
		scanning = 0
		scan_animation()
		return

/obj/item/detective_scanner/proc/add_log(msg, broadcast = 1)
	if(scanning)
		if(broadcast && ismob(loc))
			var/mob/M = loc
			to_chat(M, msg)
		log += "&nbsp;&nbsp;[msg]"
	else
		CRASH("[src] [REF(src)] is adding a log when it was never put in scanning mode!")

/proc/get_timestamp()
	return time2text(world.time + 432000, ":ss")

/obj/item/detective_scanner/AltClick(mob/living/user)
	return

/obj/item/detective_scanner/examine(mob/user)
	. = ..()
	if(LAZYLEN(log) && !scanning)
		. += "<span class='notice'>Alt-click to clear scanner logs.</span>"

/obj/item/detective_scanner/proc/displayDetectiveScanResults(mob/living/user)
	// No need for can-use checks since the action button should do proper checks
	if(!LAZYLEN(log))
		to_chat(user, "<span class='notice'>Cannot display logs, the scanner has no logs.</span>")
		return
	if(scanning)
		to_chat(user, "<span class='notice'>Cannot display logs, the scanner is in use.</span>")
		return
	to_chat(user, "<span class='notice'><B>Scanner Report</B></span>")
	for(var/iterLog in log)
		to_chat(user, iterLog)


/obj/item/detective_scanner/admin // An admin tool. returns hidden fingerprints and the duration is instant.
	name = "badmin forensic scanner"
	desc = "An unbelievable scanner capable of returning results seemingly out of nowhere."
	admin = TRUE
	advanced = TRUE
	color = "#00FFFF" // aqua

/obj/item/detective_scanner/advanced
	name = "advanced forensic scanner"
	desc = "Processes data much quicker at the cost of not being able to scan remotely. Gives more detailed reports."
	icon_state = "forensic2"
	var/icon_state_scanning =  "forensic2_scan" // icon state for scanning
	var/range = 1 // this scanner does not have range
	var/scan_speed = 4
	var/advanced = TRUE
