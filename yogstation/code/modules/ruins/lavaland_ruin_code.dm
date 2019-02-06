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
	flavour_text = "You are a travelling Bard! Your only purpose in life is to travel the galaxy, playing songs and telling epic tales of adventure, you have seen many things and you only wish to share your knowledge with all those who you pass. You are a very passive person and dislike the idea of killing another sentient person, if you cannot stop conflict through peace then you would rather remain neutral. Despite your peaceful demeanor, you are not immune to brainwashing or conversion techniques, if converted or brainwashed you are to follow the will of your masters."
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
	flavour_text = "<font size=3><b>Y</b></font><b>ou were working on a medical outpost on Orion when a bluespace translocation was reported in the vicinity, it seems to have moved the outpost to some strange ashen wasteland, regardless of the situation the medical supplies are low and medical scanners report you aren't the first here, time to put your expertise to use and see if there's anyone out there who needs help</b>"
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
	belt = /obj/item/gun/energy/e_gun/advtaser
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	head = /obj/item/clothing/head/helmet/swat
	mask = /obj/item/clothing/mask/gas
	flavour_text = "You are an Orion Spaceport officer, the outpost you were assigned to was moved due to a bluespace anomaly, you are to ensure that no harm comes to the outpost or its staff. You do not follow Space Law. You are the Law."
	id_job = "Security Officer"
	id_access = "Security Officer"
	r_pocket = /obj/item/tank/internals/emergency_oxygen/double
	l_pocket = /obj/item/flashlight/seclite
	id = /obj/item/card/id
	roundstart = FALSE
	death = FALSE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"