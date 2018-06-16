//GLOBAL_VAR_INIT(DonorBorgHolder, /datum/borg_skin_holder) Tried doing it this way, didn't work. :(
SUBSYSTEM_DEF(YogFeatures)
	name = "Yog Features" //Kmc's feature dump subsystem
	flags = SS_BACKGROUND
	priority = 10
	var/datum/borg_skin_holder/DonorBorgHolder //Holder datum for borg skins

/datum/controller/subsystem/YogFeatures/fire(resumed = 0) //Runtime avoidance / Anti-Deleting donors
	if(!DonorBorgHolder)
		DonorBorgHolder = new /datum/borg_skin_holder
		return

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

/datum/borg_skin_holder/proc/AddSkin(var/datum/borg_skin/B)
	if(!B in skins)
		skins += B
		log_game("Successfully added the [B.name] donor borg skin to the datumbase!")

/datum/borg_skin/New()
	if(SSYogFeatures.DonorBorgHolder)
		if(!src in SSYogFeatures.DonorBorgHolder.skins)
			SSYogFeatures.DonorBorgHolder.AddSkin(src) //On new, add the skin to the borg skin database

/mob/living/silicon/robot/proc/PickBorgSkin() //We'll do our own AI version inside its pre existent skin selector methinks
	if(!SSYogFeatures.DonorBorgHolder)
		message_admins("[client.ckey] just tried to change their borg skin, but there is no borg skin holder datum! (Has the game not started yet?)")
		to_chat(src, "An error occured, if the game has not started yet, please try again after it has. The admins have been notified about this")
		return 0
	if(is_donator(client)) //First off, are we even meant to have this verb?
		if(module.name == "Default")
			to_chat(src, "Please choose a module first! (Standard works too)")
			return 0
		var/datum/borg_skin/skins = list()
		for(var/datum/borg_skin/S in SSYogFeatures.DonorBorgHolder.skins)
			if(S.owner == client.ckey || !S.owner) //We own this skin.
				if(!S.module_locked || S.module_locked == module.name)
					skins += S //So add it to the temp list which we'll iterate through
		var/datum/borg_skin/A //Defining A as a borg_skin datum so we can pick out the vars we want and reskin the unit
		A = input(src,"Here's a list of your available silicon skins, pick one! (To reset your choice, get a module reset)", "Donator silicon skin picker 9000", A) as null|anything in skins//Pick any datum from the list we just established up here ^^
		if(!A)
			return 0
		if(A.name == "Cancel")
			to_chat(src, "You've chosen to use the standard skinset instead of a custom one")
			return 0
		icon =  A.icon
		icon_state = A.icon_state
		to_chat(src, "You have successfully applied the skin: [A.name]")
		return 1
	else
		to_chat(src, "This is a premium feature! it's not included in the base game, if you want to be able to pick a skin for your borg / AI characters, please donate using the link above!")
		return 0 // :^(


////////////////////////////////////////////////////////////////////////////////////////////////
//  IMPORTANT! IF YOU'RE ADDING A DONATOR SKIN FOR SOMEONE, PLEASE FOLLOW THE FORMAT BELOW!   //
////////////////////////////////////////////////////////////////////////////////////////////////
//============================================================================================\\
//>------------------------------------Template below-----------------------------------------<\\

/*

/datum/borg_skin/MadVenturerIsBadAtSiege
	name = "HeUsesAcog"
	icon = 'yogstation/icons/mob/DonorRobots.dmi'
	icon_state = "saltborg"
	owner = "asv9"
	module_locked = "Security"

*/

/* And finally, if you want to lock your skin to any specific module, just put module_locked as the name of any of these modules: https://github.com/yogstation13/Yogstation-TG/blob/c3a439daa6b6f8496f47ce55235d30b513334749/code/modules/mob/living/silicon/robot/robot_modules.dm"*/

/datum/borg_skin //Give it a unique type
	var/name = "A borg skin" //Give it a name! This will be visible when it's being picked
	var/icon = 'yogstation/icons/mob/DonorRobots.dmi'
	var/icon_state = null//Change this icon_state to the NAME OF THE BORG SKIN IN THE DMI ABOVE
	var/owner = null//The owner of this borg skin, this should be their ckey in lower case!
	var/module_locked = null //Is this skin for a specific module? don't want a janiborg looking like a secborg, as hilarious as that sounds

/datum/borg_skin/droideka
	name = "Droideka secborg"
	icon_state = "droideka"
	owner = "kmc2000"
	module_locked = "Security"

/datum/borg_skin/snail
	name = "Snailborg"
	icon_state = "snail"
	owner = "drderp3635"

/datum/borg_skin/fallout
	name = "Fallout Borg"
	icon_state = "falloutsecborg"
	owner = "lilhagan"
	module_locked = "Security"

/datum/borg_skin/prawnborg
	name = "Distrct 9 Borg"
	icon_state = "prawnborg"
	owner = "smudgels"

/datum/borg_skin/tronsec
	name = "Neon blue secborg"
	icon_state = "tronsecborg"
	owner = null
	module_locked = "Security"

/datum/borg_skin/tronjani
	name = "Neon blue janiborg"
	icon_state = "tronjaniborg"
	owner = null
	module_locked = "Janitor"

/datum/borg_skin/tronservice
	name = "Neon blue service borg"
	icon_state = "tronservice"
	owner = null
	module_locked = "Service"

/datum/borg_skin/tronengiborg
	name = "Neon blue engineering borg"
	icon_state = "tronengiborg"
	owner = null
	module_locked = "Engineering"

/datum/borg_skin/tronmedicalborg
	name = "Neon blue medical borg"
	icon_state = "tronmedicalborg"
	owner = null
	module_locked = "Medical"

/datum/borg_skin/glados //Originally made for mayhemsailor but uh...yeaaah
	name = "Bipedal GlaDos"
	icon_state = "glados"
	owner = null

/datum/borg_skin/cancel //Grimy, I know. But until I can think of a better solution, here it is :)
	name = "Cancel"
	icon_state = null
	owner = null