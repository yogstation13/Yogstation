///Travelling Bard

/obj/effect/mob_spawn/human/travelling_bard
	name = "Travelling Bard"
	uniform = /obj/item/clothing/under/jester
	shoes = /obj/item/clothing/shoes/sneakers/green
	gloves = /obj/item/clothing/gloves/color/green
	back = /obj/item/storage/backpack/clown
	belt = /obj/item/pickaxe/drill/diamonddrill
	glasses = /obj/item/clothing/glasses/meson/night
	head = /obj/item/clothing/head/jester
	mask = /obj/item/clothing/mask/bandana/green
	r_pocket = /obj/item/tank/internals/emergency_oxygen/double
	r_hand = /obj/item/instrument/guitar
	flavour_text = "You are a travelling Bard! Your only purpose in life is to travel the galaxy, playing songs and telling epic tales of adventure, you have seen many things and you only wish to share your knowledge with all those who you pass. You are a very passive person and dislike the idea of killing another sentient person, if you cannot stop conflict through peace then you would rather remain neutral."
	important_info = "Despite your peaceful demeanor, you are not immune to brainwashing or conversion techniques, if converted or brainwashed you are to follow the will of your masters."
	short_desc = "You are a travelling Bard!"
	id_job = "Travelling Bard"
	id = /obj/item/card/id
	roundstart = FALSE
	death = FALSE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"

///Orion Medical Outpost Staff

/obj/effect/mob_spawn/human/orion_doctor
	name = "Orion Outpost Doctor"
	uniform = /obj/item/clothing/under/rank/medical
	shoes = /obj/item/clothing/shoes/sneakers/white
	gloves = /obj/item/clothing/gloves/color/white
	back = /obj/item/storage/backpack/medic
	belt = /obj/item/storage/belt/medical
	glasses = /obj/item/clothing/glasses/hud/health
	short_desc = "You are an Orion medical doctor."
	flavour_text = "You were working on a medical outpost on Orion when a bluespace translocation was reported in the vicinity, it seems to have moved the outpost to some strange ashen wasteland, regardless of the situation the medical supplies are low and medical scanners report you aren't the first here."
	important_info = "Time to put your expertise to use and see if there's anyone out there who needs help."
	id_job = "Medical Doctor"
	id = /obj/item/card/id
	roundstart = FALSE
	death = FALSE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"

/obj/effect/mob_spawn/human/orion_security
	name = "Orion Outpost Security Officer"
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/combat
	suit = /obj/item/clothing/suit/armor/vest
	gloves = /obj/item/clothing/gloves/combat
	back = /obj/item/gun/ballistic/shotgun/lethal
	belt = /obj/item/gun/energy/disabler
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	head = /obj/item/clothing/head/helmet/swat
	mask = /obj/item/clothing/mask/gas
	flavour_text = "You are an Orion Spaceport officer, the outpost you were assigned to was moved due to a bluespace anomaly, you are to ensure that no harm comes to the outpost or its staff. You do not follow Space Law. You are the Law."
	short_desc = "You are an Orion security officer."
	id_job = "Security Officer"
	id_access = "Security Officer"
	r_pocket = /obj/item/tank/internals/emergency_oxygen/double
	l_pocket = /obj/item/flashlight/seclite
	id = /obj/item/card/id
	roundstart = FALSE
	death = FALSE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"

///Gas Station Clerk
/obj/effect/mob_spawn/human/gasstation_clerk
	name = "Gas Station Clerk"
	short_desc = "You are a gas station clerk."
	flavour_text = "The gas station you worked most of your life in was moved to some hellhole in the middle of nowhere for some reason, you are to try to make the best of the situation and make as much money as possible from any locals or passerbys you may encounter. Feel free to explore around the planet and find things to sell to potential customers but do not leave the planet unless the gas station is somehow completely destroyed, If someone is trying to break in or is trying to steal your products you have the right to use any means necessary to stop them including murder."
	roundstart = FALSE
	death = FALSE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	id_job = "Clerk"
	outfit = /datum/outfit/lavaland_gasclerk

/datum/outfit/lavaland_gasclerk
	name = "Gas Station Clerk"
	uniform = /obj/item/clothing/under/pants/youngfolksjeans
	shoes = /obj/item/clothing/shoes/sneakers/black
	suit = /obj/item/clothing/suit/nerdshirt
	back = /obj/item/storage/backpack/holding
	head = /obj/item/clothing/head/beanie/red
	ears = /obj/item/clothing/ears/headphones
	implants = list(/obj/item/implant/teleporter/gasclerk)
	r_pocket = /obj/item/paper/gasstation_lore
	l_pocket = /obj/item/flashlight/seclite
	id = /obj/item/card/id/gasclerk

///Loot Spawner For UFO
/obj/effect/spawner/lootdrop/lavaland_surface_ufo_crash
	name = "alien tile"
	lootdoubles = 0
	lootcount = 1
	loot = list(/obj/item/organ/heart/gland/heals = 8,
				/obj/item/organ/heart/gland/slime = 8,
				/obj/item/organ/heart/gland/mindshock = 8,
				/obj/item/organ/heart/gland/pop = 8,
				/obj/item/organ/heart/gland/ventcrawling = 8,
				/obj/item/organ/heart/gland/viral = 8,
				/obj/item/organ/heart/gland/trauma = 8,
				/obj/item/organ/heart/gland/spiderman = 8,
				/obj/item/organ/heart/gland/egg = 8,
				/obj/item/organ/heart/gland/electric = 8,
				/obj/item/organ/heart/gland/chem = 8,
				/obj/item/organ/heart/gland/plasma = 8)

/obj/effect/mob_spawn/human/lavaland_syndicate/comms/space // Weird typo fix override
	flavour_text = "Monitor enemy activity as best you can, and try to keep a low profile. Use the communication equipment to provide support to any field agents, and sow disinformation to throw Nanotrasen off your trail. Do not let the base fall into enemy hands!"