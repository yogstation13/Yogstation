/mob/living/silicon/ai
  multicam_allowed = TRUE

/mob/camera/aiEye/pic_in_pic
	telegraph_cameras = FALSE

/mob/living/silicon/ai/pick_icon() //Who the fuck wrote this shit????? Hello???
	set category = "AI Commands"
	set name = "Set AI Core Display"
	icon_state = "ai"
	if(incapacitated())
		return
	if(is_donator(client))
		PickAiSkin()
	else
		return ..()

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