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

/datum/borg_skin
	var/name = "A borg skin"
	var/icon = 'yogstation/icons/mob/DonorRobots.dmi'
	var/icon_state = null
	var/owner = null

/datum/borg_skin/New()
	if(SSYogFeatures.DonorBorgHolder)
		if(!src in SSYogFeatures.DonorBorgHolder.skins)
			SSYogFeatures.DonorBorgHolder.AddSkin(src) //On new, add the skin to the borg skin database

/mob/living/silicon/proc/PickBorgSkin()
	if(is_donator(client)) //First off, are we even meant to have this verb?
		var/datum/borg_skin/skins = list()
		for(var/datum/borg_skin/S in SSYogFeatures.DonorBorgHolder.skins)
			if(S.owner == client.ckey) //We own this skin.
				skins += S //So add it to the temp list which we'll iterate through
				to_chat(world,S.name)
			else
				return //Nope, not one of ours!
		var/datum/borg_skin/A //Defining A as a borg_skin datum so we can pick out the vars we want and reskin the unit
		A = input(src,"Here's a list of your available silicon skins, pick one! (You can only do this once per round)", "Donator silicon skin picker 9000", A) as null|anything in skins//Pick any datum from the list we just established up here ^^
		if(!A)
			return
		icon = A.icon
		icon_state = "[A.icon_state]"
		to_chat(src, "You have successfully applied the skin: [A.name]")
		return
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

*/

/datum/borg_skin/droideka //Give it a unique type
	name = "Droideka secborg" //Give it a name! This will be visible when it's being picked
	icon = 'yogstation/icons/mob/DonorRobots.dmi' //No need to change this, unless you're adminbussing!
	icon_state = "droideka" //Change this icon_state to the NAME OF THE BORG SKIN IN THE DMI ABOVE
	owner = "kmc2000" //The owner of this borg skin, this should be their ckey in lower case!

/datum/borg_skin/snail
	name = "Snailborg"
	icon_state = "snail"
	owner = "kmc20001"