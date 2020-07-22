////////////////////////////////////////////////////////////////////////////////////////////////
//  IMPORTANT! IF YOU'RE ADDING A DONATOR SKIN FOR SOMEONE, PLEASE FOLLOW THE FORMAT BELOW!   //
////////////////////////////////////////////////////////////////////////////////////////////////
//============================================================================================//
//>-------------------------------------Template below---------------------------------------<//

/*
/datum/borg_skin/MadVenturerIsBadAtSiege
	name = "HeUsesAcog"
	icon = 'yogstation/icons/mob/DonorRobots.dmi'
	icon_state = "saltborg"
	owner = "asv9"
	module_locked = "Security"
*/
// And finally, if you want to lock your skin to any specific module, just put module_locked as the name of any of these modules: https://github.com/yogstation13/Yogstation/blob/c3a439daa6b6f8496f47ce55235d30b513334749/code/modules/mob/living/silicon/robot/robot_modules.dm"

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

/*						PENDING SPRITE!
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

/datum/borg_skin/oldbrainjar
	name = "Old Cryojar"
	icon_state = "oldbrainjar"
	owner = "fluffe9911"
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

/datum/borg_skin/rainbowpeace
	name = "Rainbow Peacekeeper"
	icon_state = "rainbow_peace"
	owner = null
	module_locked = "Peacekeeper"

/datum/borg_skin/mrsparako
	name = "Mr. Sparako"
	icon_state = "mrsparako"
	owner = "nickvr628"

/datum/borg_skin/paladin_engi
	name = "Paladin (engineering)"
	icon_state = "paladin_engi"
	owner = null
	module_locked = "Engineering"

/datum/borg_skin/abductor_engi
	name = "Abductor (engineering)"
	icon_state = "abductor_engi"
	owner = null
	module_locked = "Engineering"

/datum/borg_skin/abductor_med
	name = "Abductor (medical)"
	icon_state = "abductor_med"
	owner = null
	module_locked = "Medical"

/datum/borg_skin/drill
	name = "Drillbot"
	icon_state = "drillbot"
	owner = null
	module_locked = "Miner"

/datum/borg_skin/snailborg
	name = "Snailborg"
	icon_state = "snailborg"
	owner = null
	module_locked = "Janitor"

/datum/borg_skin/tau_engi
	name = "Tau (engineering)"
	icon_state = "tau_engi"
	owner = null
	module_locked = "Engineering"

/datum/borg_skin/testdummy_engi
	name = "Crash test dummy (engineering)"
	icon_state = "testdummy_engi"
	owner = null
	module_locked = "Engineering"

/datum/borg_skin/zamboni_janitor
	name = "Zamboni (ice sweeper)"
	icon_state = "zamboni_janitor"
	owner = null
	module_locked = "Janitor"

/datum/borg_skin/abductor_peacekeeper
	name = "Alien E.G.G"
	icon_state = "abductor_peacekeeper"
	owner = null
	module_locked = "Peacekeeper"

/datum/borg_skin/abductor_miner
	name = "Alien M.I.N.E.R"
	icon_state = "abductor_miner"
	owner = null
	module_locked = "Miner"

/datum/borg_skin/cyberpunk_sec
	name = "Nt-tech industries secborg (cyberpunk)"
	icon_state = "cyberpunk_sec"
	module_locked = "Security"

/datum/borg_skin/tau_sec
	name = "Tau (security)"
	icon_state = "tau_sec"
	module_locked = "Security"

/datum/borg_skin/qualified_doctor
	name = "Qualified Doctor"
	icon_state = "qualified_doctor"
	module_locked = "Medical"
	owner = null

//Oldyogs stuff, I didn't sprite this ~Kmc//

/datum/borg_skin/hover_sec
	name = "Hoverborg (security)"
	icon_state = "hover_sec"
	module_locked = "Security"
	owner = null

/datum/borg_skin/hover_med
	name = "Hoverborg (medical)"
	icon_state = "hover_med"
	owner = null
	module_locked = "Medical"

/datum/borg_skin/hover_engi
	name = "Hoverborg (engineering)"
	icon_state = "hover_engi"
	owner = null
	module_locked = "Engineering"

/datum/borg_skin/gutsy
	name = "Mr Gutsy (standard)"
	icon_state = "gutsy_standard"
	owner = null
	module_locked = "Standard"

/datum/borg_skin/gutsy_med
	name = "Mr Gutsy (medical)"
	icon_state = "gutsy_med"
	owner = null
	module_locked = "Medical"

/datum/borg_skin/gutsy_sec
	name = "Mr Gutsy (security)"
	icon_state = "gutsy_sec"
	owner = null
	module_locked = "Security"

/datum/borg_skin/cola
	name = "Sec Cola"
	icon_state = "colaborg"
	owner = "boodaliboo"
	module_locked = "Security"

/datum/borg_skin/polis
	name = "Police Borg"
	icon_state = "policeborg"
	owner = null
	module_locked = "Security"

/datum/borg_skin/klein
	name = "Dr Klein"
	icon_state = "dr_klein"
	owner = null
	module_locked = "Standard"

/datum/borg_skin/atlas
	name = "Atlas"
	icon_state = "brainlas"
	owner = "jierda"
	module_locked = "Engineering"

/datum/borg_skin/icarus
	name = "Icarus"
	icon_state = "icarus"
	owner = "reddsnotdead"
	module_locked = "Engineering"

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

/datum/ai_skin/englandismycity
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

/datum/ai_skin/realisticface
	name = "Hyper Realistic Face"
	icon_state = "realisticface"

/datum/ai_skin/spacewhale
	name = "Space Whale"
	icon_state = "spacewhale"

/datum/ai_skin/extranet
	name = "Extranet"
	icon_state = "extranet"

/datum/ai_skin/wardoge
	name = "War Doge"
	icon_state = "wardoge"
	owner = "fluffe9911"

datum/ai_skin/carrion
	name = "Carrion"
	icon_state = "carrion"
	owner = "xoxeyos"