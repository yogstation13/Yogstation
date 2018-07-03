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
// And finally, if you want to lock your skin to any specific module, just put module_locked as the name of any of these modules: https://github.com/yogstation13/Yogstation-TG/blob/c3a439daa6b6f8496f47ce55235d30b513334749/code/modules/mob/living/silicon/robot/robot_modules.dm"

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

/*							PENDING SPRITE!
/datum/borg_skin/snail
	name = "Snailborg"
	icon_state = "snail"
	owner = "drderp3635"
*/

/datum/borg_skin/fallout
	name = "Fallout Borg"
	icon_state = "falloutsecborg"
	owner = "lilhagan"
	module_locked = "Security"

/datum/borg_skin/prawnborg
	name = "District 9 Borg"
	icon_state = "prawnborg"
	owner = "smudgels"

/datum/borg_skin/tronsec
	name = "Neon blue secborg"
	icon_state = "tronsecborg"
	module_locked = "Security"

/datum/borg_skin/tronjani
	name = "Neon blue janiborg"
	icon_state = "tronjaniborg"
	module_locked = "Janitor"

/datum/borg_skin/tronservice
	name = "Neon blue service borg"
	icon_state = "tronservice"
	module_locked = "Service"

/datum/borg_skin/tronengiborg
	name = "Neon blue engineering borg"
	icon_state = "tronengiborg"
	module_locked = "Engineering"

/datum/borg_skin/tronmedicalborg
	name = "Neon blue medical borg"
	icon_state = "tronmedicalborg"
	module_locked = "Medical"

/datum/borg_skin/glados //Originally made for mayhemsailor but uh...yeaaah
	name = "Bipedal GlaDos"
	icon_state = "glados"

/datum/borg_skin/dio
	name = "DIO L.I.T.E"
	icon_state = "diosecborg"
	owner = "atrealdonaldtrump"
	module_locked = "Security"

/datum/borg_skin/brainjar
	name = "Cryojar"
	icon_state = "brainjar"
	owner = "qe"
	module_locked = null

/datum/borg_skin/angel
	name = "Angel"
	icon_state = "angel"
	owner = "lilhagan"
	module_locked = null

/datum/borg_skin/paladin
	name = "Silver Paladin"
	icon_state = "paladin"
	module_locked = "Security"

//Begin AI skins://
/* These follow the same format as borg skins*/

/datum/ai_skin
	var/name = "A cool ai skin"
	var/icon = 'yogstation/icons/mob/DonorRobots.dmi'
	var/icon_state = "ai_dead"
	var/owner = null

/datum/ai_skin/ducc
	name = "Angel"
	icon_state = "ducc"
	owner = "lilhagan"

/datum/ai_skin/sneaker
	name = "Sneaker database"
	icon_state = "sneaker_database"
	owner = "kmc2000"

/datum/ai_skin/dio
	name = "D.I.O"
	icon_state = "dioAI"
	owner = "atrealdonaldtrump"

/datum/ai_skin/dio
	name = "Nick Crompton"
	icon_state = "nickcrompton"
	owner = "drderp3635"

/datum/ai_skin/nich
	name = "You spin me right round right round nich like a record baby round round"
	icon_state = "oneofourcouncilmembers"
	owner = "nichlas0010"
	
/datum/ai_skin/ling
	name = "You spin me right round right round nich like a record baby round round"
	icon_state = "oneofourcouncilmembers"
	owner = "thatling"

/datum/ai_skin/tokamak
	name = "Tokamak fusion generator mk.1"
	icon_state = "tokamak"

/datum/ai_skin/cancel //Grimy, I know. But until I can think of a better solution, here it is :)
	name = "Cancel"
	icon_state = null

/datum/borg_skin/cancel //Grimy, I know. But until I can think of a better solution, here it is :)
	name = "Cancel"
	icon_state = null
