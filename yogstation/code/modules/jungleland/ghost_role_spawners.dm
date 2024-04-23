
//Ivymen eggs: Spawns in ivymen dens on Jungleland. Ghosts become unique podpeople that wish to expand by sacrificing corpses to their carnivorous birth plant.

/obj/effect/mob_spawn/human/ivymen
	name = "ivymen egg"
	desc = "A man-sized wood colored egg covered in plant matter, spawned from some sort of tree perhaps. A humanoid silhouette lurks within, barely visible through the cracks."
	mob_name = "an ivyman"
	icon = 'yogstation/icons/mob/jungle.dmi'
	icon_state = "ivymen_egg"
	mob_species = /datum/species/pod/ivymen
	outfit = /datum/outfit/ivymen
	roundstart = FALSE
	death = FALSE
	anchored = FALSE
	move_resist = MOVE_FORCE_NORMAL
	density = FALSE
	short_desc = "You are an Ivyman. Your tribe is birthed from The Mother Tree, and worships it."
	flavour_text = "The jungle is a sacred, pure land full of wondrous creatures to hunt and befriend. \
	You have seen lights in the distance... they foreshadow the arrival of outsiders that seek to tear apart the Jungle and your home. Fresh sacrifices for your nest."
	assignedrole = "Ivyman"
	var/datum/team/ivymen/team
	

/obj/effect/mob_spawn/human/ivymen/special(mob/living/new_spawn)
	var/plant_name = pick("Thorn", "Spine", "Pitcher", "Belladonna", "Reed", "Ivy", "Kudzu", "Nettle", "Moss", "Hemlock", "Foxglove", "Root", "Bark", "Amanitin", "Hyacinth", "Leaf", \
	"Venus", "Snakeroot", "Pinyang", "Henbane", "Aconite", "Oak", "Cactus", "Pepper", "Juniper", "Cannabis") //many of the 'soft' names like Sprout have been replaced with poisonous plants. Metal, dude!
	new_spawn.fully_replace_character_name(null,plant_name)
	to_chat(new_spawn, "<b>Drag the corpses of men and beasts to your nest. It will absorb them to create more of your kind. Glory to the Mother Tree!</b>") //yogs - removed a sentence

	new_spawn.mind.add_antag_datum(/datum/antagonist/ivymen, team)

/obj/effect/mob_spawn/human/ivymen/Initialize(mapload, datum/team/ivymen/ivyteam)
	. = ..()
	var/area/A = get_area(src)
	team = ivyteam
	if(A)
		notify_ghosts("An ivyman egg is ready to hatch in \the [A.name].", source = src, action=NOTIFY_ATTACKORBIT, flashwindow = FALSE, ignore_key = POLL_IGNORE_ASHWALKER)

/datum/outfit/ivymen
	name = "Ivyman"
	uniform = /obj/item/clothing/under/ash_robe/hunter/jungle

/datum/outfit/ivymen/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	H.underwear = "Nude"
	H.update_body()

/// Syndicate station spawners

/obj/effect/mob_spawn/human/lavaland_syndicate/jungle
	outfit = /datum/outfit/lavaland_syndicate/jungle

/obj/effect/mob_spawn/human/lavaland_syndicate/jungle/lieutenant
	name = "Syndicate Comms Lieutenant"
	short_desc = "You are a syndicate lieutenant, employed in a top secret research facility that is developing biological weapons."
	flavour_text = "Unfortunately, your hated enemy, Nanotrasen, has begun mining in this sector. Issue commands to the rest of the base, keep tabs on communications, and try to keep a low profile."
	important_info = "The base is rigged with explosives, DO NOT abandon it, let it fall into enemy hands, or share your supplies with non-syndicate personnel."
	outfit = /datum/outfit/lavaland_syndicate/jungle/lieutenant
	assignedrole = "Lavaland Syndicate"

/obj/effect/mob_spawn/human/lavaland_syndicate/jungle/scientist
	outfit = /datum/outfit/lavaland_syndicate/jungle/scientist

/obj/effect/mob_spawn/human/lavaland_syndicate/jungle/technician
	name = "Syndicate Technician"
	short_desc = "You are a syndicate technician, employed in a top secret research facility that is developing biological weapons."
	flavour_text = "Unfortunately, your hated enemy, Nanotrasen, has begun mining in this sector. Keep the base functional and manned, and try to keep a low profile."
	outfit = /datum/outfit/lavaland_syndicate/jungle/technician

/obj/effect/mob_spawn/human/lavaland_syndicate/special(mob/living/new_spawn)
	new_spawn.grant_language(/datum/language/codespeak, TRUE, TRUE, LANGUAGE_MIND)

/datum/outfit/lavaland_syndicate/jungle
	name = "Jungle Syndicate Agent"

/datum/outfit/lavaland_syndicate/jungle/lieutenant
	name = "Jungle Syndicate Lieutenant"
	r_hand = /obj/item/melee/transforming/energy/sword/saber
	suit = /obj/item/clothing/suit/armor/vest
	gloves = /obj/item/clothing/gloves/sec_maga/syndicate
	mask = /obj/item/clothing/mask/chameleon/gps

/datum/outfit/lavaland_syndicate/jungle/scientist
	name = "Jungle Syndicate Scientist"
	r_hand = null

/datum/outfit/lavaland_syndicate/jungle/technician
	name = "Jungle Syndicate Technician"
	r_hand = null
	suit = /obj/item/clothing/suit/armor/vest

/obj/item/clothing/gloves/sec_maga/syndicate //syndicate jungle ghostrole version, only works on base
	name = "combat gloves plus"
	desc = "These tactical gloves are fireproof and shock resistant, and using nanochip technology it teaches you the powers of krav maga. Anti-theft measures prevent these gloves from being used outside the base."
	icon_state = "black"
	item_state = "blackglovesplus"
	strip_delay = 80
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 60, RAD = 0, FIRE = 80, ACID = 50, ELECTRIC = 100)
	enabled_areas = list(/area/ruin/powered/syndicate_lava_base)

/obj/effect/mob_spawn/human/greedydemon
	name = "Red Sleeper"
	desc = "An ancient sleeper that could possibly not even be man made, housing a raging hell fire."
	roundstart = FALSE
	death = FALSE
	random = TRUE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	short_desc = "You are a hellish demon of greed, posted on a house of sin and gambling."
	flavour_text = "Attract patrons to your terrible home, make cash, and prepare any facilities that are needed. Make sure your guests feel welcome, it is the best way to tempt them. In addition, do not give things away for free, everything has a price after all."
	important_info = "Do not leave your establishment if possible, and do not leave the planet at all."
	outfit = /datum/outfit/greedydemon
	assignedrole = "Greedy Demon"
	id_access_list = list(ACCESS_BAR,ACCESS_KITCHEN,ACCESS_HYDROPONICS)

/obj/effect/mob_spawn/human/greedydemon/special(mob/living/new_spawn)
	var/datum/antagonist/sinfuldemon/demon = new
	demon.demonsin = "greed"
	new_spawn.mind.add_antag_datum(demon)
	demon.greet()
	message_admins("[ADMIN_LOOKUPFLW(new_spawn)] has been made into a Sinful Demon by a ghost spawner.")
	log_game("[key_name(new_spawn)] was spawned as a Sinful Demon by a ghost spawner.")

/datum/outfit/greedydemon
	name = "Greedy Demon"
	uniform = /obj/item/clothing/under/suit_jacket/really_black
	head = /obj/item/clothing/head/that
	back = /obj/item/storage/backpack
	suit = /obj/item/clothing/suit/armor/vest
	mask = /obj/item/clothing/mask/cigarette/pipe
	shoes = /obj/item/clothing/shoes/laceup
	glasses = /obj/item/clothing/glasses/sunglasses/reagent
	gloves = /obj/item/clothing/gloves/color/white
	ears = /obj/item/radio/headset
	id = /obj/item/card/id
	implants = list(/obj/item/implant/teleporter/demon) //stay at your den of sin
