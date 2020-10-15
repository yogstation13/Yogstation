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
	if(!(B in skins))
		skins += B
		log_game("Successfully added the [B.name] donor borg skin to the datumbase!")

/datum/borg_skin/New()
	if(GLOB.DonorBorgHolder)
		if(!(src in GLOB.DonorBorgHolder.skins))
			GLOB.DonorBorgHolder.AddSkin(src) //On new, add the skin to the borg skin database
