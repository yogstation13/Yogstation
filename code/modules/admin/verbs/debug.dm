/client/proc/Debug2()
	set category = "Misc.Server Debug"
	set name = "Debug-Game"
	if(!check_rights(R_DEBUG))
		return

	if(GLOB.Debug2)
		GLOB.Debug2 = 0
		message_admins("[key_name(src)] toggled debugging off.")
		log_admin("[key_name(src)] toggled debugging off.")
	else
		GLOB.Debug2 = 1
		message_admins("[key_name(src)] toggled debugging on.")
		log_admin("[key_name(src)] toggled debugging on.")

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Debug Two") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!



/* 21st Sept 2010
Updated by Skie -- Still not perfect but better!
Stuff you can't do:
Call proc /mob/proc/adjust_dizzy() for some player
Because if you select a player mob as owner it tries to do the proc for
/mob/living/carbon/human/ instead. And that gives a run-time error.
But you can call procs that are of type /mob/living/carbon/human/proc/ for that player.
*/

/client/proc/callproc()
	set category = "Misc.Server Debug"
	set name = "Advanced ProcCall"
	set waitfor = FALSE

	if(!check_rights(R_DEBUG))
		return

	var/datum/target = null
	var/targetselected = FALSE
	var/returnval = null

	if(alert("Proc owned by something?",,"Yes","No") == "Yes")
		targetselected = TRUE
		var/list/value = vv_get_value(default_class = VV_ATOM_REFERENCE, classes = list(VV_ATOM_REFERENCE, VV_DATUM_REFERENCE, VV_MOB_REFERENCE, VV_CLIENT))
		if (!value["class"] || !value["value"])
			return
		target = value["value"]

	var/procpath = input("Proc path, eg: /proc/fake_blood","Path:", null) as text|null
	if(!procpath)
		return
	//thanks paradise - https://github.com/ParadiseSS13/Paradise/pull/27327
	if(findtextEx(trim(lowertext(procpath)), "rustg"))
		message_admins("<span class='userdanger'>[key_name_admin(src)] attempted to proc call rust-g procs. Inform council/host <u>at once</u>.</span>")
		log_admin("[key_name(src)] attempted to proc call rust-g procs. Inform council/host at once.")
		return

	//strip away everything but the proc name
	var/list/proclist = splittext(procpath, "/")
	if (!length(proclist))
		return

	var/procname = proclist[proclist.len]
	var/proctype = ("verb" in proclist) ? "verb" :"proc"

	if(targetselected)
		if(!hascall(target, procname))
			to_chat(usr, span_warning("Error: callproc(): type [target.type] has no [proctype] named [procpath]."), confidential=TRUE)
			return
	else
		procpath = "/[proctype]/[procname]"
		if(!text2path(procpath))
			to_chat(usr, span_warning("Error: callproc(): [procpath] does not exist."), confidential=TRUE)
			return

	var/list/lst = get_callproc_args()
	if(!lst)
		return

	if(targetselected)
		if(!target)
			to_chat(usr, span_warning("Error: callproc(): owner of proc no longer exists."), confidential=TRUE)
			return
		var/msg = "[key_name(src)] called [target]'s [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no argument"]."
		log_admin(msg)
		message_admins(msg)
		admin_ticket_log(target, msg)
		returnval = WrapAdminProcCall(target, procname, lst)
	else
		var/msg = "[key_name(src)] called [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no argument"]."
		log_admin(msg)
		message_admins(msg)
		returnval = WrapAdminProcCall(GLOBAL_PROC, procpath, lst) //calling globals needs full qualified name (e.g /proc/foo)
	. = get_callproc_returnval(returnval, procname)
	if(.)
		to_chat(usr, ., confidential=TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Advanced ProcCall") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

GLOBAL_VAR(AdminProcCaller)
GLOBAL_PROTECT(AdminProcCaller)
GLOBAL_VAR_INIT(AdminProcCallCount, 0)
GLOBAL_PROTECT(AdminProcCallCount)
GLOBAL_VAR(LastAdminCalledTargetRef)
GLOBAL_PROTECT(LastAdminCalledTargetRef)
GLOBAL_VAR(LastAdminCalledTarget)
GLOBAL_PROTECT(LastAdminCalledTarget)
GLOBAL_VAR(LastAdminCalledProc)
GLOBAL_PROTECT(LastAdminCalledProc)
GLOBAL_LIST_EMPTY(AdminProcCallSpamPrevention)
GLOBAL_PROTECT(AdminProcCallSpamPrevention)


/// Wrapper for proccalls where the datum is flagged as vareditted
/proc/WrapAdminProcCall(datum/target, procname, list/arguments)
	SIGNAL_HANDLER
	if(target && procname == "Del")
		to_chat(usr, "Calling Del() is not allowed", confidential = TRUE)
		return
	if(target != GLOBAL_PROC && !target.CanProcCall(procname))
		to_chat(usr, "Proccall on [target.type]/proc/[procname] is disallowed!", confidential=TRUE)
		return

	var/current_caller = GLOB.AdminProcCaller
	var/user_identifier = usr ? usr.client?.ckey : GLOB.AdminProcCaller
	if(!user_identifier)
		CRASH("WrapAdminProcCall with no ckey: [target] [procname] [english_list(arguments)]")
	if(current_caller && current_caller != user_identifier)
		to_chat(usr, span_adminnotice("Another set of admin called procs are still running. Try again later."), confidential = TRUE)
		return

	GLOB.LastAdminCalledProc = procname
	if(target != GLOBAL_PROC)
		GLOB.LastAdminCalledTargetRef = REF(target)

	GLOB.AdminProcCaller = user_identifier //if this runtimes, too bad for you
	++GLOB.AdminProcCallCount
	. = world.WrapAdminProcCall(target, procname, arguments)
	GLOB.AdminProcCallCount--
	if(GLOB.AdminProcCallCount == 0)
		GLOB.AdminProcCaller = null

//adv proc call this, ya nerds
/world/proc/WrapAdminProcCall(datum/target, procname, list/arguments)
	if(target == GLOBAL_PROC)
		return call(procname)(arglist(arguments))
	else if(target != world)
		return call(target, procname)(arglist(arguments))
	else
		log_admin_private("[key_name(usr)] attempted to call world/proc/[procname] with arguments: [english_list(arguments)]")

/proc/IsAdminAdvancedProcCall()
#ifdef TESTING
	return FALSE
#else
	return usr && usr.client && GLOB.AdminProcCaller == usr.client.ckey
#endif

/client/proc/callproc_datum(datum/A as null|area|mob|obj|turf)
	set category = "Misc.Server Debug"
	set name = "Atom ProcCall"
	set waitfor = FALSE

	if(!check_rights(R_DEBUG))
		return

	var/procname = input("Proc name, eg: fake_blood","Proc:", null) as text|null
	if(!procname)
		return
	if(!hascall(A,procname))
		to_chat(usr, span_warning("Error: callproc_datum(): type [A.type] has no proc named [procname]."), confidential=TRUE)
		return
	var/list/lst = get_callproc_args()
	if(!lst)
		return

	if(!A || !IsValidSrc(A))
		to_chat(usr, span_warning("Error: callproc_datum(): owner of proc no longer exists."), confidential=TRUE)
		return
	var/msg = "[key_name(src)] called [A]'s [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"]."
	log_admin(msg)
	message_admins(msg)
	admin_ticket_log(A, msg)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Atom ProcCall") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	var/returnval = WrapAdminProcCall(A, procname, lst) // Pass the lst as an argument list to the proc
	. = get_callproc_returnval(returnval,procname)
	if(.)
		to_chat(usr, ., confidential=TRUE)

/client/proc/get_callproc_args()
	var/argnum = input("Number of arguments","Number:",0) as num|null
	if(isnull(argnum))
		return

	. = list()
	var/list/named_args = list()
	while(argnum--)
		var/named_arg = input("Leave blank for positional argument. Positional arguments will be considered as if they were added first.", "Named argument") as text|null
		var/value = vv_get_value(restricted_classes = list(VV_RESTORE_DEFAULT))
		if (!value["class"])
			return
		if(named_arg)
			named_args[named_arg] = value["value"]
		else
			. += value["value"]
	if(LAZYLEN(named_args))
		. += named_args

/client/proc/get_callproc_returnval(returnval,procname)
	. = ""
	if(islist(returnval))
		var/list/returnedlist = returnval
		. = "<span class='notice'>"
		if(returnedlist.len)
			var/assoc_check = returnedlist[1]
			if(istext(assoc_check) && (returnedlist[assoc_check] != null))
				. += "[procname] returned an associative list:"
				for(var/key in returnedlist)
					. += "\n[key] = [returnedlist[key]]"

			else
				. += "[procname] returned a list:"
				for(var/elem in returnedlist)
					. += "\n[elem]"
		else
			. = "[procname] returned an empty list"
		. += "</span>"

	else
		. = span_notice("[procname] returned: [!isnull(returnval) ? returnval : "null"]")


/client/proc/Cell()
	set category = "Misc.Server Debug"
	set name = "Air Status in Location"
	if(!mob)
		return
	var/turf/T = get_turf(mob)
	if(!isturf(T))
		return
	atmosanalyzer_scan(usr, T, TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Air Status In Location") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_robotize(mob/M in GLOB.mob_list)
	set category = "Admin.Player Interaction"
	set name = "Make Robot"

	if(!SSticker.HasRoundStarted())
		tgui_alert(usr,"Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(src)] has robotized [M.key].")
		var/mob/living/carbon/human/H = M
		spawn(0)
			H.Robotize()

	else
		tgui_alert(usr,"Invalid mob")

/client/proc/cmd_admin_blobize(mob/M in GLOB.mob_list)
	set category = "Admin.Player Interaction"
	set name = "Make Blob"

	if(!SSticker.HasRoundStarted())
		tgui_alert(usr,"Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(src)] has blobized [M.key].")
		var/mob/living/carbon/human/H = M
		H.become_overmind()
	else
		tgui_alert(usr,"Invalid mob")


/client/proc/cmd_admin_animalize(mob/M in GLOB.mob_list)
	set category = "Admin.Player Interaction"
	set name = "Make Simple Animal"

	if(!SSticker.HasRoundStarted())
		tgui_alert(usr,"Wait until the game starts")
		return

	if(!M)
		tgui_alert(usr,"That mob doesn't seem to exist, close the panel and try again.")
		return

	if(isnewplayer(M))
		tgui_alert(usr,"The mob must not be a new_player.")
		return

	log_admin("[key_name(src)] has animalized [M.key].")
	spawn(0)
		M.Animalize()

/client/proc/cmd_admin_alienize(mob/M in GLOB.mob_list)
	set category = "Admin.Player Interaction"
	set name = "Make Alien"

	if(!SSticker.HasRoundStarted())
		tgui_alert(usr,"Wait until the game starts")
		return
	if(ishuman(M))
		INVOKE_ASYNC(M, /mob/living/carbon/human/proc/Alienize)
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Make Alien") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		log_admin("[key_name(usr)] made [key_name(M)] into an alien at [AREACOORD(M)].")
		message_admins(span_adminnotice("[key_name_admin(usr)] made [ADMIN_LOOKUPFLW(M)] into an alien."))
	else
		tgui_alert(usr,"Invalid mob")

/client/proc/cmd_admin_slimeize(mob/M in GLOB.mob_list)
	set category = "Admin.Player Interaction"
	set name = "Make slime"

	if(!SSticker.HasRoundStarted())
		tgui_alert(usr,"Wait until the game starts")
		return
	if(ishuman(M))
		INVOKE_ASYNC(M, /mob/living/carbon/human/proc/slimeize)
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Make Slime") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		log_admin("[key_name(usr)] made [key_name(M)] into a slime at [AREACOORD(M)].")
		message_admins(span_adminnotice("[key_name_admin(usr)] made [ADMIN_LOOKUPFLW(M)] into a slime."))
	else
		tgui_alert(usr,"Invalid mob")

/client/proc/cmd_admin_pacmanize(mob/M in GLOB.mob_list)
	set category = "Admin.Player Interaction"
	set name = "Make pacman"

	if(!SSticker.HasRoundStarted())
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		INVOKE_ASYNC(M, /mob/living/carbon/human/proc/pacmanize)
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Make Pacman") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		log_admin("[key_name(usr)] made [key_name(M)] into a pacman at [AREACOORD(M)].")
		message_admins(span_adminnotice("[key_name_admin(usr)] made [ADMIN_LOOKUPFLW(M)] into a pacman."))
	else
		alert("Invalid mob")

/proc/make_types_fancy(list/types)
	if (ispath(types))
		types = list(types)
	. = list()
	for(var/type in types)
		var/typename = "[type]"
		var/static/list/TYPES_SHORTCUTS = list(
			/obj/effect/decal/cleanable = "CLEANABLE",
			/obj/item/radio/headset = "HEADSET",
			/obj/item/clothing/head/helmet/space = "SPESSHELMET",
			/obj/item/book/manual = "MANUAL",
			/obj/item/reagent_containers/food/drinks = "DRINK", //longest paths comes first
			/obj/item/reagent_containers/food = "FOOD",
			/obj/item/reagent_containers = "REAGENT_CONTAINERS",
			/obj/machinery/atmospherics = "ATMOS_MECH",
			/obj/machinery/portable_atmospherics = "PORT_ATMOS",
			/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack = "MECHA_MISSILE_RACK",
			/obj/item/mecha_parts/mecha_equipment = "MECHA_EQUIP",
			/obj/item/organ = "ORGAN",
			/obj/item = "ITEM",
			/obj/machinery = "MACHINERY",
			/obj/effect = "EFFECT",
			/obj = "O",
			/datum = "D",
			/turf/open = "OPEN",
			/turf/closed = "CLOSED",
			/turf = "T",
			/mob/living/carbon = "CARBON",
			/mob/living/simple_animal = "SIMPLE",
			/mob/living = "LIVING",
			/mob = "M"
		)
		for (var/tn in TYPES_SHORTCUTS)
			if (copytext(typename,1, length("[tn]/")+1)=="[tn]/" /*findtextEx(typename,"[tn]/",1,2)*/ )
				typename = TYPES_SHORTCUTS[tn]+copytext(typename,length("[tn]/"))
				break
		.[typename] = type

/proc/get_fancy_list_of_atom_types()
	var/static/list/pre_generated_list
	if (!pre_generated_list) //init
		pre_generated_list = make_types_fancy(typesof(/atom))
	return pre_generated_list


/proc/get_fancy_list_of_datum_types()
	var/static/list/pre_generated_list
	if (!pre_generated_list) //init
		pre_generated_list = make_types_fancy(sortList(typesof(/datum) - typesof(/atom)))
	return pre_generated_list


/proc/filter_fancy_list(list/L, filter as text)
	var/list/matches = new
	for(var/key in L)
		var/value = L[key]
		if(findtext("[key]", filter) || findtext("[value]", filter))
			matches[key] = value
	return matches

//TODO: merge the vievars version into this or something maybe mayhaps
/client/proc/cmd_debug_del_all(object as text)
	set category = "Misc.Server Debug"
	set name = "Del-All"

	var/list/matches = get_fancy_list_of_atom_types()
	if (!isnull(object) && object!="")
		matches = filter_fancy_list(matches, object)

	if(matches.len==0)
		return
	var/hsbitem = input(usr, "Choose an object to delete.", "Delete:") as null|anything in matches
	if(hsbitem)
		hsbitem = matches[hsbitem]
		var/counter = 0
		for(var/atom/O in world)
			if(istype(O, hsbitem))
				counter++
				qdel(O)
			CHECK_TICK
		log_admin("[key_name(src)] has deleted all ([counter]) instances of [hsbitem].")
		message_admins("[key_name_admin(src)] has deleted all ([counter]) instances of [hsbitem].")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Delete All") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/cmd_debug_make_powernets()
	set category = "Misc.Server Debug"
	set name = "Make Powernets"
	SSmachines.makepowernets()
	log_admin("[key_name(src)] has remade the powernet. makepowernets() called.")
	message_admins("[key_name_admin(src)] has remade the powernets. makepowernets() called.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Make Powernets") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_grantfullaccess(mob/M in GLOB.mob_list)
	set category = "Misc.Server Debug"
	set name = "Grant Full Access"

	if(!SSticker.HasRoundStarted())
		tgui_alert(usr,"Wait until the game starts")
		return
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/worn = H.wear_id
		var/obj/item/card/id/id = null
		if(worn)
			id = worn.GetID()
		if(id)
			id.icon_state = "id_gold"
			id.access = get_debug_access()
		else
			id = new /obj/item/card/id/gold(H.loc)
			id.access = get_debug_access()
			id.registered_name = H.real_name
			id.assignment = "Captain"
			id.originalassignment = "Captain"
			id.update_label()

			if(worn)
				if(istype(worn, /obj/item/modular_computer))
					var/obj/item/modular_computer/worn_computer = worn
					worn_computer.InsertID(id)
				else if(istype(worn, /obj/item/storage/wallet))
					var/obj/item/storage/wallet/W = worn
					W.front_id = id
					id.forceMove(W)
					W.update_appearance(UPDATE_ICON)
			else
				H.equip_to_slot(id,ITEM_SLOT_ID)
	else if(isanimal(M))
		var/mob/living/simple_animal/SA = M
		SA.access_card = new /obj/item/card/id/ert/debug
	else
		tgui_alert(usr,"Invalid mob")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Grant Full Access") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(src)] has granted [M.key] full access.")
	message_admins(span_adminnotice("[key_name_admin(usr)] has granted [M.key] full access."))

/client/proc/cmd_assume_direct_control(mob/M in GLOB.mob_list)
	set category = "Misc.Unused"
	set name = "Assume direct control"
	set desc = "Direct intervention"

	if(M.ckey)
		if(tgui_alert(usr,"This mob is being controlled by [M.key]. Are you sure you wish to assume control of it? [M.key] will be made a ghost.",,list("Yes","No")) != "Yes")
			return
		else
			var/mob/dead/observer/ghost = new/mob/dead/observer(M,1)
			ghost.ckey = M.ckey
	message_admins(span_adminnotice("[key_name_admin(usr)] assumed direct control of [M]."))
	log_admin("[key_name(usr)] assumed direct control of [M].")
	var/mob/adminmob = src.mob
	M.ckey = src.ckey
	if( isobserver(adminmob) )
		qdel(adminmob)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Assume Direct Control") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_give_direct_control(mob/M in GLOB.mob_list)
	set category = "Admin.Game"
	set name = "Give direct control"

	if(!M)
		return
	if(M.ckey)
		if(tgui_alert(usr,"This mob is being controlled by [M.key]. Are you sure you wish to give someone else control of it? [M.key] will be made a ghost.",,list("Yes","No")) != "Yes")
			return
	var/client/newkey = input(src, "Pick the player to put in control.", "New player") as null|anything in sortList(GLOB.clients)
	var/mob/oldmob = newkey.mob
	var/delmob = FALSE
	if((isobserver(oldmob) || tgui_alert(usr,"Do you want to delete [newkey]'s old mob?","Delete?",list("Yes","No")) != "No"))
		delmob = TRUE
	if(!M || QDELETED(M))
		to_chat(usr, "<span class='warning'>The target mob no longer exists, aborting.</span>")
		return
	if(M.ckey)
		M.ghostize(FALSE)
	M.ckey = newkey.key
	M.client?.init_verbs()
	if(delmob)
		qdel(oldmob)
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] gave away direct control of [M] to [newkey].</span>")
	log_admin("[key_name(usr)] gave away direct control of [M] to [newkey].")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Give Direct Control") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_test_atmos_controllers()
	set category = "Misc.Server Debug"
	set name = "Test Atmos Monitoring Consoles"

	var/list/dat = list()

	if(SSticker.current_state == GAME_STATE_STARTUP)
		to_chat(usr, "Game still loading, please hold!", confidential=TRUE)
		return

	message_admins(span_adminnotice("[key_name_admin(usr)] used the Test Atmos Monitor debug command."))
	log_admin("[key_name(usr)] used the Test Atmos Monitor debug command.")

	var/bad_shit = 0
	for(var/obj/machinery/computer/atmos_control/tank/console in GLOB.atmos_air_controllers)
		dat += "<h1>[console] at [AREACOORD(console)]:</h1><br>"
		if(console.input_tag == console.output_tag)
			dat += "Error: input_tag is the same as the output_tag, \"[console.input_tag]\"!<br>"
			bad_shit++
		if(!LAZYLEN(console.input_info))
			dat += "Failed to find a valid outlet injector as an input with the tag [console.input_tag].<br>"
			bad_shit++
		if(!LAZYLEN(console.output_info))
			dat += "Failed to find a valid siphon pump as an outlet with the tag [console.output_tag].<br>"
			bad_shit++
		if(!bad_shit)
			dat += "<B>STATUS:</B> NORMAL"
		else
			bad_shit = 0
		dat += "<br>"
		CHECK_TICK

	var/datum/browser/popup = new(usr, "testatmoscontroller", "Test Atmos Monitoring Consoles", 500, 750)
	popup.set_content(dat.Join())
	popup.open()

/client/proc/cmd_admin_areatest(on_station)
	set category = "Misc.Server Debug"
	set name = "Test Areas"

	var/list/dat = list()
	var/list/areas_all = list()
	var/list/areas_with_APC = list()
	var/list/areas_with_multiple_APCs = list()
	var/list/areas_with_air_alarm = list()
	var/list/areas_with_RC = list()
	var/list/areas_with_light = list()
	var/list/areas_with_LS = list()
	var/list/areas_with_intercom = list()
	var/list/areas_with_camera = list()
	var/list/station_areas_blacklist = typecacheof(list(/area/holodeck/rec_center, /area/shuttle, /area/engine/supermatter, /area/science/test_area, /area/space, /area/solar, /area/mine, /area/ruin, /area/asteroid))

	if(SSticker.current_state == GAME_STATE_STARTUP)
		to_chat(usr, "Game still loading, please hold!", confidential=TRUE)
		return

	var/log_message
	if(on_station)
		dat += "<b>Only checking areas on station z-levels.</b><br><br>"
		log_message = "station z-levels"
	else
		log_message = "all z-levels"

	message_admins(span_adminnotice("[key_name_admin(usr)] used the Test Areas debug command checking [log_message]."))
	log_admin("[key_name(usr)] used the Test Areas debug command checking [log_message].")

	for(var/area/A as anything in GLOB.areas)
		if(on_station)
			var/turf/picked = pick(get_area_turfs(A.type))
			if(picked && is_station_level(picked.z))
				if(!(A.type in areas_all) && !is_type_in_typecache(A, station_areas_blacklist))
					areas_all.Add(A.type)
		else if(!(A.type in areas_all))
			areas_all.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/power/apc/APC in GLOB.apcs_list)
		var/area/A = APC.area
		if(!A)
			dat += "Skipped over [APC] in invalid location, [APC.loc]."
			continue
		if(!(A.type in areas_with_APC))
			areas_with_APC.Add(A.type)
		else if(A.type in areas_all)
			areas_with_multiple_APCs.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/airalarm/AA in GLOB.machines)
		var/area/A = get_area(AA)
		if(!A) //Make sure the target isn't inside an object, which results in runtimes.
			dat += "Skipped over [AA] in invalid location, [AA.loc].<br>"
			continue
		if(!(A.type in areas_with_air_alarm))
			areas_with_air_alarm.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/requests_console/RC in GLOB.machines)
		var/area/A = get_area(RC)
		if(!A)
			dat += "Skipped over [RC] in invalid location, [RC.loc].<br>"
			continue
		if(!(A.type in areas_with_RC))
			areas_with_RC.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/light/L in GLOB.machines)
		var/area/A = get_area(L)
		if(!A)
			dat += "Skipped over [L] in invalid location, [L.loc].<br>"
			continue
		if(!(A.type in areas_with_light))
			areas_with_light.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/light_switch/LS in GLOB.machines)
		var/area/A = get_area(LS)
		if(!A)
			dat += "Skipped over [LS] in invalid location, [LS.loc].<br>"
			continue
		if(!(A.type in areas_with_LS))
			areas_with_LS.Add(A.type)
		CHECK_TICK

	for(var/obj/item/radio/intercom/I in GLOB.machines)
		var/area/A = get_area(I)
		if(!A)
			dat += "Skipped over [I] in invalid location, [I.loc].<br>"
			continue
		if(!(A.type in areas_with_intercom))
			areas_with_intercom.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/camera/C in GLOB.machines)
		var/area/A = get_area(C)
		if(!A)
			dat += "Skipped over [C] in invalid location, [C.loc].<br>"
			continue
		if(!(A.type in areas_with_camera))
			areas_with_camera.Add(A.type)
		CHECK_TICK

	var/list/areas_without_APC = areas_all - areas_with_APC
	var/list/areas_without_air_alarm = areas_all - areas_with_air_alarm
	var/list/areas_without_RC = areas_all - areas_with_RC
	var/list/areas_without_light = areas_all - areas_with_light
	var/list/areas_without_LS = areas_all - areas_with_LS
	var/list/areas_without_intercom = areas_all - areas_with_intercom
	var/list/areas_without_camera = areas_all - areas_with_camera

	if(areas_without_APC.len)
		dat += "<h1>AREAS WITHOUT AN APC:</h1>"
		for(var/areatype in areas_without_APC)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_with_multiple_APCs.len)
		dat += "<h1>AREAS WITH MULTIPLE APCS:</h1>"
		for(var/areatype in areas_with_multiple_APCs)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_air_alarm.len)
		dat += "<h1>AREAS WITHOUT AN AIR ALARM:</h1>"
		for(var/areatype in areas_without_air_alarm)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_RC.len)
		dat += "<h1>AREAS WITHOUT A REQUEST CONSOLE:</h1>"
		for(var/areatype in areas_without_RC)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_light.len)
		dat += "<h1>AREAS WITHOUT ANY LIGHTS:</h1>"
		for(var/areatype in areas_without_light)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_LS.len)
		dat += "<h1>AREAS WITHOUT A LIGHT SWITCH:</h1>"
		for(var/areatype in areas_without_LS)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_intercom.len)
		dat += "<h1>AREAS WITHOUT ANY INTERCOMS:</h1>"
		for(var/areatype in areas_without_intercom)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_camera.len)
		dat += "<h1>AREAS WITHOUT ANY CAMERAS:</h1>"
		for(var/areatype in areas_without_camera)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(!(areas_with_APC.len || areas_with_multiple_APCs.len || areas_with_air_alarm.len || areas_with_RC.len || areas_with_light.len || areas_with_LS.len || areas_with_intercom.len || areas_with_camera.len))
		dat += "<b>No problem areas!</b>"

	var/datum/browser/popup = new(usr, "testareas", "Test Areas", 500, 750)
	popup.set_content(dat.Join())
	popup.open()


/client/proc/cmd_admin_areatest_station()
	set category = "Misc.Server Debug"
	set name = "Test Areas (STATION Z)"
	cmd_admin_areatest(TRUE)

/client/proc/cmd_admin_areatest_all()
	set category = "Misc.Server Debug"
	set name = "Test Areas (ALL)"
	cmd_admin_areatest(FALSE)

/client/proc/cmd_admin_dress(mob/M in GLOB.mob_list)
	set category = "Admin.Player Interaction"
	set name = "Select equipment"

	if(!check_rights(R_SPAWN))
		return

	if(!(ishuman(M) || isobserver(M)))
		alert("Invalid mob")
		return

	var/dresscode = robust_dress_shop()

	if(!dresscode)
		return

	var/delete_pocket
	var/mob/living/carbon/human/H
	if(isobserver(M))
		H = M.change_mob_type(/mob/living/carbon/human, null, null, TRUE)
	else
		H = M
		if(H.l_store || H.r_store || H.s_store) //saves a lot of time for admins and coders alike
			if(alert("Drop Items in Pockets? No will delete them.", "Robust quick dress shop", "Yes", "No") == "No")
				delete_pocket = TRUE

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Select Equipment") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	for (var/obj/item/I in H.get_equipped_items(delete_pocket))
		qdel(I)
	if(dresscode != "Naked")
		H.equipOutfit(dresscode)

	H.regenerate_icons()

	log_admin("[key_name(usr)] changed the equipment of [key_name(H)] to [dresscode].")
	message_admins(span_adminnotice("[key_name_admin(usr)] changed the equipment of [ADMIN_LOOKUPFLW(H)] to [dresscode]."))

/client/proc/robust_dress_shop()
	var/list/outfits = list() //Yogs -- a hashtable. key is a result from user input, value is an outfit path
	var/list/options = list("Naked","Custom","As Job...","As CentCom Rank...")//Yogs
	var/list/choices = list()//Yogs -- The actual list of options available to the user
	var/list/paths = subtypesof(/datum/outfit) - typesof(/datum/outfit/job, /datum/outfit/centcom)
	for(var/path in paths)
		var/datum/outfit/O = path //not much to initalize here but whatever
		if(initial(O.can_be_admin_equipped))
			outfits[initial(O.name)] = path
			choices += initial(O.name)
	choices = options + sortList(choices, /proc/cmp_text_asc) // Yogs -- Alphabetizes this list here

	var/dresscode = input("Select outfit", "Robust quick dress shop") as null|anything in choices
	if (isnull(dresscode))
		return

	if (outfits[dresscode])
		dresscode = outfits[dresscode]

	if (dresscode == "As Job...")
		var/list/job_paths = subtypesof(/datum/outfit/job)
		var/list/job_outfits = list()
		var/list/job_choices = list()
		for(var/path in job_paths)
			var/datum/outfit/O = path
			if(initial(O.can_be_admin_equipped))
				job_outfits[initial(O.name)] = path
				job_choices += initial(O.name)
		job_choices = sortList(job_choices,/proc/cmp_text_asc)
		dresscode = input("Select job equipment", "Robust quick dress shop") as null|anything in job_choices
		dresscode = job_outfits[dresscode]
		if(isnull(dresscode))
			return

	if (dresscode == "Custom")
		var/list/custom_names = list()
		for(var/datum/outfit/D in GLOB.custom_outfits)
			custom_names[D.name] = D
		var/selected_name = input("Select outfit", "Robust quick dress shop") as null|anything in custom_names
		dresscode = custom_names[selected_name]
		if(isnull(dresscode))
			return

	if (dresscode == "As CentCom Rank...")
		var/list/job_paths = subtypesof(/datum/outfit/centcom)
		var/list/job_outfits = list()
		var/list/job_choices = list()
		for(var/path in job_paths)
			var/datum/outfit/O = path
			if(initial(O.can_be_admin_equipped))
				job_outfits[initial(O.name)] = path
				job_choices += initial(O.name)
		job_choices = sortList(job_choices,/proc/cmp_text_asc)
		dresscode = input("Select job equipment", "Robust quick dress shop") as null|anything in job_choices
		dresscode = job_outfits[dresscode]
		if(isnull(dresscode))
			return

	return dresscode

/client/proc/startSinglo()

	set category = "Misc.Server Debug"
	set name = "Start Singularity"
	set desc = "Sets up the singularity and all machines to get power flowing through the station"

	if(alert("Are you sure? This will start up the engine. Should only be used during debug!",,"Yes","No") != "Yes")
		return

	for(var/obj/machinery/power/emitter/E in GLOB.machines)
		if(E.anchored)
			E.active = 1

	for(var/obj/machinery/field/generator/F in GLOB.machines)
		if(F.active == 0)
			F.active = 1
			F.state = 2
			F.power = 250
			F.anchored = TRUE
			F.warming_up = 3
			F.start_fields()
			F.update_appearance(UPDATE_ICON)

	spawn(30)
		for(var/obj/machinery/the_singularitygen/G in GLOB.machines)
			if(G.anchored)
				var/obj/singularity/S = new /obj/singularity(get_turf(G), 50)
//				qdel(G)
				S.energy = 1750
				S.current_size = 7
				S.icon = 'icons/effects/224x224.dmi'
				S.icon_state = "singularity_s7"
				S.pixel_x = -96
				S.pixel_y = -96
				S.grav_pull = 0
				//S.consume_range = 3
				S.dissipate = 0
				//S.dissipate_delay = 10
				//S.dissipate_track = 0
				//S.dissipate_strength = 10

	for(var/obj/machinery/power/rad_collector/Rad in GLOB.machines)
		if(Rad.anchored)
			if(!Rad.loaded_tank)
				var/obj/item/tank/internals/plasma/Plasma = new/obj/item/tank/internals/plasma(Rad)
				Plasma.air_contents.set_moles(GAS_PLASMA, 70)
				Rad.drainratio = 0
				Rad.loaded_tank = Plasma
				Plasma.forceMove(Rad)

			if(!Rad.active)
				Rad.toggle_power()

	for(var/obj/machinery/power/smes/SMES in GLOB.machines)
		if(SMES.anchored)
			SMES.input_attempt = 1

/client/proc/cmd_debug_mob_lists()
	set category = "Misc.Server Debug"
	set name = "Debug Mob Lists"
	set desc = "For when you just gotta know"

	switch(input(usr, "Which list?",, list("Players","Admins","Mobs","Living Mobs","Dead Mobs","Clients","Joined Clients")))
		if("Players")
			to_chat(usr, jointext(GLOB.player_list,","), confidential=TRUE)
		if("Admins")
			to_chat(usr, jointext(GLOB.permissions.admins,","), confidential=TRUE)
		if("Mobs")
			to_chat(usr, jointext(GLOB.mob_list,","), confidential=TRUE)
		if("Living Mobs")
			to_chat(usr, jointext(GLOB.alive_mob_list,","), confidential=TRUE)
		if("Dead Mobs")
			to_chat(usr, jointext(GLOB.dead_mob_list,","), confidential=TRUE)
		if("Clients")
			to_chat(usr, jointext(GLOB.clients,","), confidential=TRUE)
		if("Joined Clients")
			to_chat(usr, jointext(GLOB.joined_player_list,","), confidential=TRUE)

/client/proc/cmd_display_del_log()
	set category = "Misc.Server Debug"
	set name = "Display del() Log"
	set desc = "Display del's log of everything that's passed through it."

	var/list/dellog = list("<HTML><HEAD><meta charset='UTF-8'></HEAD><BODY><B>List of things that have gone through qdel this round</B><BR><BR><ol>")
	sortTim(SSgarbage.items, cmp=/proc/cmp_qdel_item_time, associative = TRUE)
	for(var/path in SSgarbage.items)
		var/datum/qdel_item/I = SSgarbage.items[path]
		dellog += "<li><u>[path]</u><ul>"
		if (I.failures)
			dellog += "<li>Failures: [I.failures]</li>"
		dellog += "<li>qdel() Count: [I.qdels]</li>"
		dellog += "<li>Destroy() Cost: [I.destroy_time]ms</li>"
		if (I.hard_deletes)
			dellog += "<li>Total Hard Deletes [I.hard_deletes]</li>"
			dellog += "<li>Time Spent Hard Deleting: [I.hard_delete_time]ms</li>"
		if (I.slept_destroy)
			dellog += "<li>Sleeps: [I.slept_destroy]</li>"
		if (I.no_respect_force)
			dellog += "<li>Ignored force: [I.no_respect_force]</li>"
		if (I.no_hint)
			dellog += "<li>No hint: [I.no_hint]</li>"
		dellog += "</ul></li>"

	dellog += "</ol></BODY></HTML>"

	usr << browse(dellog.Join(), "window=dellog")

/client/proc/cmd_display_overlay_log()
	set category = "Misc.Server Debug"
	set name = "Display overlay Log"
	set desc = "Display SSoverlays log of everything that's passed through it."

	render_stats(SSoverlays.stats, src)

/client/proc/cmd_display_init_log()
	set category = "Misc.Server Debug"
	set name = "Display Initialize(mapload) Log"
	set desc = "Displays a list of things that didn't handle Initialize(mapload) properly"

	var/datum/browser/browser = new(usr, "initlog", "Initialize Log", 500, 500)
	browser.set_content(replacetext(SSatoms.InitLog(), "\n", "<br>"))
	browser.open()

/client/proc/debug_plane_masters()
	set category = "Misc.Server Debug"
	set name = "Edit/Debug Planes"
	set desc = "Edit and visualize plane masters and their connections (relays)"

	edit_plane_masters()

/client/proc/edit_plane_masters(mob/debug_on)
	if(!holder)
		return
	if(debug_on)
		holder.plane_debug.set_mirroring(TRUE)
		holder.plane_debug.set_target(debug_on)
	else
		holder.plane_debug.set_mirroring(FALSE)
	holder.plane_debug.ui_interact(mob)

/client/proc/debug_huds(i as num)
	set category = "Misc.Server Debug"
	set name = "Debug HUDs"
	set desc = "Debug the data or antag HUDs"

	if(!holder)
		return
	debug_variables(GLOB.huds[i])

/client/proc/jump_to_ruin()
	set category = "Misc.Server Debug"
	set name = "Jump to Ruin"
	set desc = "Displays a list of all placed ruins to teleport to."
	if(!holder)
		return
	var/list/names = list()
	for(var/i in GLOB.ruin_landmarks)
		var/obj/effect/landmark/ruin/ruin_landmark = i
		var/datum/map_template/ruin/template = ruin_landmark.ruin_template

		var/count = 1
		var/name = template.name
		var/original_name = name

		while(name in names)
			count++
			name = "[original_name] ([count])"

		names[name] = ruin_landmark

	var/ruinname = input("Select ruin", "Jump to Ruin") as null|anything in names


	var/obj/effect/landmark/ruin/landmark = names[ruinname]

	if(istype(landmark))
		var/datum/map_template/ruin/template = landmark.ruin_template
		usr.forceMove(get_turf(landmark))
		to_chat(usr, span_name("[template.name]"), confidential=TRUE)
		to_chat(usr, span_italics("[template.description]"), confidential=TRUE)

/client/proc/place_ruin()
	set category = "Misc.Server Debug"
	set name = "Spawn Ruin"
	set desc = "Attempt to randomly place a specific ruin."
	if (!holder)
		return

	var/list/exists = list()
	for(var/landmark in GLOB.ruin_landmarks)
		var/obj/effect/landmark/ruin/L = landmark
		exists[L.ruin_template] = landmark

	var/list/names = list()
	names += "---- Space Ruins ----"
	for(var/name in SSmapping.space_ruins_templates)
		names[name] = list(SSmapping.space_ruins_templates[name], ZTRAIT_SPACE_RUINS, list(/area/space))
	names += "---- Lava Ruins ----"
	for(var/name in SSmapping.lava_ruins_templates)
		names[name] = list(SSmapping.lava_ruins_templates[name], ZTRAIT_LAVA_RUINS, list(/area/lavaland/surface/outdoors/unexplored))
	names += "---- Ice Ruins ----"
	for(var/name in SSmapping.ice_ruins_templates)
		names[name] = list(SSmapping.ice_ruins_templates[name], ZTRAIT_ICE_RUINS, list(/area/icemoon/surface/outdoors/unexplored, /area/icemoon/underground/unexplored))
	names += "---- Ice Underground Ruins ----"
	for(var/name in SSmapping.ice_ruins_underground_templates)
		names[name] = list(SSmapping.ice_ruins_underground_templates[name], ZTRAIT_ICE_RUINS_UNDERGROUND, list(/area/icemoon/underground/unexplored))

	var/ruinname = input("Select ruin", "Spawn Ruin") as null|anything in names
	var/data = names[ruinname]
	if (!data)
		return
	var/datum/map_template/ruin/template = data[1]
	if (exists[template])
		var/response = tgui_alert(usr,"There is already a [template] in existence.", "Spawn Ruin", list("Jump", "Place Another", "Cancel"))
		if (response == "Jump")
			usr.forceMove(get_turf(exists[template]))
			return
		else if (response == "Cancel")
			return

	var/len = GLOB.ruin_landmarks.len
	seedRuins(SSmapping.levels_by_trait(data[2]), max(1, template.cost), data[3], list(ruinname = template))
	if (GLOB.ruin_landmarks.len > len)
		var/obj/effect/landmark/ruin/landmark = GLOB.ruin_landmarks[GLOB.ruin_landmarks.len]
		log_admin("[key_name(src)] randomly spawned ruin [ruinname] at [COORD(landmark)].")
		usr.forceMove(get_turf(landmark))
		to_chat(src, span_name("[template.name]"), confidential=TRUE)
		to_chat(src, span_italics("[template.description]"), confidential=TRUE)
	else
		to_chat(src, span_warning("Failed to place [template.name]."), confidential=TRUE)

/client/proc/clear_dynamic_transit()
	set category = "Misc.Server Debug"
	set name = "Clear Dynamic Turf Reservations"
	set desc = "Deallocates all reserved space, restoring it to round start conditions."
	if(!holder)
		return
	var/answer = tgui_alert(usr,"WARNING: THIS WILL WIPE ALL RESERVED SPACE TO A CLEAN SLATE! ANY MOVING SHUTTLES, ELEVATORS, OR IN-PROGRESS PHOTOGRAPHY WILL BE DELETED!", "Really wipe dynamic turfs?", list("YES", "NO"))
	if(answer != "YES")
		return
	message_admins(span_adminnotice("[key_name_admin(src)] cleared dynamic transit space."))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Clear Dynamic Transit") // If...
	log_admin("[key_name(src)] cleared dynamic transit space.")
	SSmapping.wipe_reservations()				//this goes after it's logged, incase something horrible happens.

/client/proc/view_runtimes()
	set category = "Misc.Server Debug"
	set name = "View Runtimes"
	set desc = "Open the runtime Viewer"

	if(!holder)
		return

	GLOB.error_cache.show_to(src)

/client/proc/start_line_profiling()
	set category = "Profile"
	set name = "Start Line Profiling"
	set desc = "Starts tracking line by line profiling for code lines that support it"

	LINE_PROFILE_START

	message_admins(span_adminnotice("[key_name_admin(src)] started line by line profiling."))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Start Line Profiling")
	log_admin("[key_name(src)] started line by line profiling.")

/client/proc/stop_line_profiling()
	set category = "Profile"
	set name = "Stops Line Profiling"
	set desc = "Stops tracking line by line profiling for code lines that support it"

	LINE_PROFILE_STOP

	message_admins(span_adminnotice("[key_name_admin(src)] stopped line by line profiling."))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Stop Line Profiling")
	log_admin("[key_name(src)] stopped line by line profiling.")

/client/proc/show_line_profiling()
	set category = "Profile"
	set name = "Show Line Profiling"
	set desc = "Shows tracked profiling info from code lines that support it"

	var/sortlist = list(
		"Avg time"		=	/proc/cmp_profile_avg_time_dsc,
		"Total Time"	=	/proc/cmp_profile_time_dsc,
		"Call Count"	=	/proc/cmp_profile_count_dsc
	)
	var/sort = input(src, "Sort type?", "Sort Type", "Avg time") as null|anything in sortlist
	if (!sort)
		return
	sort = sortlist[sort]
	profile_show(src, sort)

/client/proc/reload_configuration()
	set category = "Misc.Server Debug"
	set name = "Reload Configuration"
	set desc = "Force config reload to world default"
	if(!check_rights(R_DEBUG))
		return
	if(tgui_alert(usr, "Are you absolutely sure you want to reload the configuration from the default path on the disk, wiping any in-round modificatoins?", "Really reset?", list("No", "Yes")) == "Yes")
		config.admin_reload()

/client/proc/debug_ai_networks()
	set category = "Misc.Server Debug"
	set name = "Debug AI Networks"
	set desc = "Displays a list of all AI networks to ALL admins"
	if(!check_rights(R_DEBUG))
		return
	_debug_ai_networks()
