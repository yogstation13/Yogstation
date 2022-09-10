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
	flavour_text = "You are a travelling bard! Your only purpose in life is to travel the galaxy, playing songs and telling epic tales of adventure. You have seen many things and you only wish to share your knowledge with all those who you pass. You are a very passive person and dislike the idea of killing another sentient person. If you cannot stop conflict through peace then you would rather remain neutral."
	important_info = "Despite your peaceful demeanor, you are not immune to brainwashing or conversion techniques. If converted or brainwashed, you are to follow the will of your masters."
	short_desc = "You are a travelling bard!"
	id_job = "Travelling Bard"
	id = /obj/item/card/id
	roundstart = FALSE
	death = FALSE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"

///Orion Medical Outpost Staff

/obj/effect/mob_spawn/human/orion_doctor
	name = "SIC Outpost Doctor"
	uniform = /obj/item/clothing/under/rank/medical
	shoes = /obj/item/clothing/shoes/sneakers/white
	gloves = /obj/item/clothing/gloves/color/white
	back = /obj/item/storage/backpack/medic
	belt = /obj/item/storage/belt/medical
	glasses = /obj/item/clothing/glasses/hud/health
	short_desc = "You are a SIC medical doctor."
	flavour_text = "You were working on a Sol Interplantery Coalition medical outpost when a bluespace translocation was reported. After a bout of nausea from reality shifting, a glance outside told you that it seems to have moved the station to some strange ashen wasteland. Regardless of the situation, supplies are low and scanners report a variety of unknown lifeforms outside."
	important_info = "Time to put your expertise to use and see if there's anyone out there who needs help."
	id_job = "Medical Doctor"
	id = /obj/item/card/id
	roundstart = FALSE
	death = FALSE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"

/obj/effect/mob_spawn/human/orion_security
	name = "SIC Outpost Security Officer"
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/combat
	suit = /obj/item/clothing/suit/armor/vest
	gloves = /obj/item/clothing/gloves/combat
	back = /obj/item/gun/ballistic/shotgun/lethal
	belt = /obj/item/gun/energy/disabler
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	head = /obj/item/clothing/head/helmet/swat
	mask = /obj/item/clothing/mask/gas
	flavour_text = "You are a Sol Interplanetary Coalition officer. The medical outpost you were assigned to experienced a bluespace anomaly. After the nausea passed from the translocation, the doctors told you there were unknown lifeforms out in the ashen wasteland you now find yourself in. Regardless of the situation, you are to ensure that no harm comes to the outpost or its staff. You do not follow Space Law. You are the Law."
	short_desc = "You are a SIC security officer."
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
	flavour_text = "While working a standard shift on some backwater colony, you felt a sudden splurge of nausea as the alarm for a bluespace translocation cut off abruptly. Calling corporate, they instruct you to continue business with any locals or passerbys. While they permit you to explore the planet, you are not to leave the planet unless the gas station is destroyed. If a hostile individual attempts to destroy the store or steal its goods, you have been given clearance to stop them by any means necessary."
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
	flavour_text = "Monitor enemy activity as best you can. Try to keep a low profile. Use the communication equipment to provide support to any field agents. Sow disinformation to throw Nanotrasen off your trail. Do not let the base fall into enemy hands."
