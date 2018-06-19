GLOBAL_DATUM_INIT(DonorBorgHolder, /datum/borg_skin_holder, new)

/mob/living/silicon/robot
	var/special_skin = FALSE //Have we got a donor only skin?

/datum/borg_skin_holder
	var/name = "Donator Borg Skin Datumbase"
	var/datum/borg_skin/skins = list()

/datum/borg_skin_holder/New()
	generate_borg_skins()
	. = ..()

/datum/borg_skin_holder/proc/generate_borg_skins()
	for(var/L in subtypesof(/datum/borg_skin))
		var/datum/borg_skin/Bskin = L
		var/datum/borg_skin/instance = new Bskin
		skins += instance
	for(var/S in subtypesof(/datum/ai_skin))
		var/datum/ai_skin/Bskin = S
		var/datum/ai_skin/instance = new Bskin
		skins += instance

/datum/borg_skin_holder/proc/AddSkin(var/datum/borg_skin/B)
	if(!B in skins)
		skins += B
		log_game("Successfully added the [B.name] donor borg skin to the datumbase!")

/datum/borg_skin/New()
	if(GLOB.DonorBorgHolder)
		if(!src in GLOB.DonorBorgHolder.skins)
			GLOB.DonorBorgHolder.AddSkin(src) //On new, add the skin to the borg skin database

/mob/living/silicon/robot/proc/PickBorgSkin(var/forced = FALSE) //We'll do our own AI version inside its pre existent skin selector methinks
	icon = initial(icon) //Redundancy in case they repick a skin after modulechange
	if(!GLOB.DonorBorgHolder)
		message_admins("[client.ckey] just tried to change their borg skin, but there is no borg skin holder datum! (Has the game not started yet?)")
		to_chat(src, "An error occured, if the game has not started yet, please try again after it has. The admins have been notified about this")
		return FALSE
	if(forced || is_donator(client))//First off, are we even meant to have this verb? or is an admin bruteforcing it onto a non donator for some reason?
		if(module.name == "Default")
			to_chat(src, "Please choose a module first! (Standard works too)")
			return FALSE
		if(module.name == "Syndicate")
			to_chat(src, "You cannot reskin a syndicate cyborg :(")
			return FALSE
		var/datum/borg_skin/skins = list()
		for(var/datum/borg_skin/S in GLOB.DonorBorgHolder.skins)
			if(S.owner == client.ckey || !S.owner) //We own this skin.
				if(!S.module_locked || S.module_locked == module.name)
					skins += S //So add it to the temp list which we'll iterate through
		var/datum/borg_skin/A //Defining A as a borg_skin datum so we can pick out the vars we want and reskin the unit
		A = input(src,"Here's a list of your available silicon skins, pick one! (To reset your choice, get a module reset)", "Donator silicon skin picker 9000", A) as null|anything in skins//Pick any datum from the list we just established up here ^^
		if(!A)
			return FALSE
		if(A.name == "Cancel")
			to_chat(src, "You've chosen to use the standard skinset instead of a custom one")
			special_skin = FALSE
			return FALSE
		icon =  A.icon
		icon_state = A.icon_state
		cut_overlays()
		eye_lights.icon = A.icon
		eye_lights.icon_state = "[icon_state]_e[is_servant_of_ratvar(src) ? "_r" : ""]"
		add_overlay(eye_lights)
		to_chat(src, "You have successfully applied the skin: [A.name]")
		special_skin = TRUE
		return TRUE

//I'm overriding this so that donors will be able to pick their borg skin after choosing a module.
/obj/item/robot_module/do_transform_delay()
	var/mob/living/silicon/robot/R = loc
	var/prev_lockcharge = R.lockcharge
	sleep(1)
	flick("[cyborg_base_icon]_transform", R)
	R.notransform = TRUE
	R.SetLockdown(TRUE)
	R.anchored = TRUE
	sleep(1)
	for(var/i in 1 to 4)
		playsound(R, pick('sound/items/drill_use.ogg', 'sound/items/jaws_cut.ogg', 'sound/items/jaws_pry.ogg', 'sound/items/welder.ogg', 'sound/items/ratchet.ogg'), 80, 1, -1)
		sleep(7)
	if(!prev_lockcharge)
		R.SetLockdown(FALSE)
	R.setDir(SOUTH)
	R.anchored = FALSE
	R.notransform = FALSE
	R.update_headlamp()
	R.notify_ai(NEW_MODULE)
	if(R.hud_used)
		R.hud_used.update_robot_modules_display()
	SSblackbox.record_feedback("tally", "cyborg_modules", 1, R.module)
	R.PickBorgSkin()

/mob/living/silicon/ai/pick_icon() //Who the fuck wrote this shit????? Hello???
	set category = "AI Commands"
	set name = "Set AI Core Display"
	icon_state = "ai"
	if(incapacitated())
		return
	if(PickAiSkin())
		return
	else
		. = ..()

/mob/living/silicon/ai/proc/PickAiSkin(var/forced = FALSE)
	icon = initial(icon)
	if(!GLOB.DonorBorgHolder)
		message_admins("[client.ckey] just tried to change their AI skin, but there is no borg skin holder datum! (Has the game not started yet?)")
		to_chat(src, "An error occured, if the game has not started yet, please try again after it has. The admins have been notified about this")
		return FALSE
	if(is_donator(client) || forced)//First off, are we even meant to have this verb? or is an admin bruteforcing it onto a non donator for some reason?
		var/datum/ai_skin/skins = list()
		for(var/datum/ai_skin/S in GLOB.DonorBorgHolder.skins)
			if(S.owner == client.ckey || !S.owner) //We own this skin.
				skins += S //So add it to the temp list which we'll iterate through
		var/datum/ai_skin/A //Defining A as a borg_skin datum so we can pick out the vars we want and reskin the unit
		A = input(src,"You're a donator! Would you like to use a custom AI skin? (If not, hit cancel and pick a normal one)", "Donator AI skin picker 9000", A) as null|anything in skins//Pick any datum from the list we just established up here ^^
		if(!A)
			return
		if(A.name != "Cancel")
			icon =  A.icon
			icon_state = A.icon_state
			to_chat(src, "You have successfully applied the skin: [A.name]")
			return TRUE
		else
			to_chat(src, "You've chosen to use the normal AI skinset")
			return FALSE


/mob/living/silicon/robot/update_icons() //Need to change this, as it's killing donorborgs
	var/old_icon = icon_state
	. = ..()
	if (special_skin)
		cut_overlays()
		icon_state = old_icon
		eye_lights.icon_state = "[icon_state]_e[is_servant_of_ratvar(src) ? "_r" : ""]"
		add_overlay(eye_lights)

/mob/living/silicon/robot/examine(mob/user)
	. = ..()
	to_chat(user, "It seems to have the [module.name] module loaded")
