// Imperial ERT outfits and Clothing

/obj/item/clothing/neck/imperial
	name = "golden aquilla"
	desc = "A symbol of the Imperium. Left eye closed, and right eye open, it symbolises how the Imperium never looks back."
	icon_state = "guard_neckpiece"
	item_state = "guard_neckpiece"

/obj/item/clothing/head/helmet/imperial
	name = "flak helmet"
	desc = "Standard-issue flak helmet for members of the Imperial Guard"
	icon_state = "guard_helmet"
	item_state = "guard_helmet"
	armor = list(MELEE = 50, BULLET = 35, LASER = 35,ENERGY = 10, BOMB = 50, BIO = 0, RAD = 20, FIRE = 30, ACID = 50, WOUND = 5)

/obj/item/clothing/under/imperial
	name = "guardsman fatigues"
	desc = "A set of khaki fatigues. Standard issue for Imperial Guardsmen"
	icon_state = "guard_uniform"
	item_state = "guard_uniform"
	can_adjust = 0

/obj/item/clothing/shoes/combat/imperial
	name = "flak boots"
	desc = "A pair of heavy duty armored shoes, providing protection up to the knees. Standard issue in the Imperial Guard"
	icon_state = "guard_shoes"
	item_state = "guard_shoes"
	cold_protection = LEGS|FEET
	heat_protection = LEGS|FEET
	body_parts_covered = LEGS|FEET

/obj/item/clothing/suit/armor/imperial
	name = "flak vest"
	desc = "A set of standard issue flak armor for Imperial Guardsmen. Protects you fairly well from most threats."
	icon_state = "guard_armor"
	item_state = "guard_armor"
	blood_overlay_type = "armor"
	cold_protection = CHEST|GROIN|ARMS
	heat_protection = CHEST|GROIN|ARMS
	body_parts_covered = CHEST|GROIN|ARMS
	armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 10, BOMB = 50, BIO = 0, RAD = 0, FIRE = 60, ACID = 90, WOUND = 10)
/obj/item/storage/belt/military/imperial
	name = "Imperial Belt"
	desc = "A well worn belt, standard issue among Imperial Guard forces."
	icon_state = "guard_belt"
	item_state = "guard_belt"

/obj/item/card/id/ert/imperial
	name = "\improper Imperial Guard ID"
	desc = "An Imperial Guard ID card."
	assignment = "Imperial Guard"
	originalassignment = "Imperial Guard"

/obj/item/card/id/ert/imperial/commissar
	name = "\improper Imperial Commissar ID"
	desc = "An Imperial Commissar ID card."
	assignment = "Imperial Commissar"
	originalassignment = "Imperial Commissar"

/obj/item/clothing/suit/armor/imperial/commissar
	name = "armored commisar coat"
	desc = "A black and red coat. Armored and padded, it instils fear into all that see it, friend and foe alike."
	icon = 'icons/obj/clothing/suits/suits.dmi'
	icon_state = "commissar"
	item_state = "commissar"


/obj/item/clothing/head/helmet/imperial/commissar
	name = "commissar cap"
	desc = "An armored cap, protecting your head from stray rounds and your eyes from splashes of blood."
	icon = 'icons/obj/clothing/hats/hats.dmi'
	icon_state = "commissar"
	item_state = "commissar"

/obj/item/clothing/under/imperial/commissar
	name = "commissarial fatigues"
	desc = "A set of black and red fatigues. Makes your allies more afraid than your enemies."
	icon = 'icons/obj/clothing/uniforms.dmi'
	icon_state = "commissar"
	item_state = "commissar"

/obj/item/clothing/shoes/combat/imperial/commissar
	name = "imperial boots"
	desc = "A pair of heavy duty armored shoes. Black and gold to show the person beneath your status."
	icon = 'icons/obj/clothing/shoes.dmi'
	icon_state = "commissar"
	item_state = "commissar"

/obj/item/chainsaw_sword
	name = "imperial chainsword"
	desc = "Cuts through flesh, bone, and most types of metal as if it wasn't there."
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_BELT
	attack_verb = list("sawed", "torn", "cut", "chopped", "diced")
	hitsound = 'sound/weapons/chainsawhit.ogg'
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	icon = 'icons/obj/weapons/swords.dmi'
	icon_state = "imp_chainswordon"
	item_state = "imp_chainswordon"
	sharpness = SHARP_EDGED
	max_integrity = 200
	force = 30
	throwforce = 10
	w_class = WEIGHT_CLASS_HUGE
	flags_1 = CONDUCT_1


// Belts
/obj/item/storage/belt/military/imperial/guardsman/Initialize(mapload) // Imperial Guardsman
	. = ..()
	new /obj/item/ammo_box/magazine/recharge/lasgun(src)
	new /obj/item/ammo_box/magazine/recharge/lasgun(src)
	new /obj/item/ammo_box/magazine/recharge/lasgun(src)
	new /obj/item/reagent_containers/autoinjector/medipen(src)
	new /obj/item/flashlight/flare(src)
	new /obj/item/restraints/handcuffs/cable/zipties(src)
	new /obj/item/jawsoflife/jimmy(src)

/obj/item/storage/belt/military/imperial/plasma/Initialize(mapload) // Plasma gunner
	. = ..()
	new /obj/item/ammo_box/magazine/recharge/lasgun/pistol(src)
	new /obj/item/ammo_box/magazine/recharge/lasgun/pistol(src)
	new /obj/item/reagent_containers/autoinjector/medipen(src)
	new /obj/item/flashlight/flare(src)
	new /obj/item/restraints/handcuffs/cable/zipties(src)
	new /obj/item/jawsoflife/jimmy(src)
	new /obj/item/stack/medical/mesh(src) // for when his gun inevitably explodes

/obj/item/storage/belt/military/imperial/hotshot/Initialize(mapload) // Veteran
	. = ..()
	new /obj/item/ammo_box/magazine/recharge/lasgun/hotshot(src)
	new /obj/item/ammo_box/magazine/recharge/lasgun/hotshot(src)
	new /obj/item/ammo_box/magazine/recharge/lasgun/pistol(src)
	new /obj/item/reagent_containers/autoinjector/medipen(src)
	new /obj/item/flashlight/flare(src)
	new /obj/item/restraints/handcuffs/cable/zipties(src)
	new /obj/item/jawsoflife/jimmy(src)

/obj/item/storage/belt/military/imperial/sniper/Initialize(mapload) // Marksman
	. = ..()
	new /obj/item/ammo_box/magazine/recharge/lasgun/sniper(src)
	new /obj/item/ammo_box/magazine/recharge/lasgun/sniper(src)
	new /obj/item/stack/medical/mesh(src) // for when his pistol inevitably explodes
	new /obj/item/reagent_containers/autoinjector/medipen(src)
	new /obj/item/restraints/handcuffs/cable/zipties(src)
	new /obj/item/jawsoflife/jimmy(src)
	new /obj/item/binoculars(src)


/obj/item/storage/belt/military/imperial/sergeant/Initialize(mapload) // Sergeant
	. = ..()
	new /obj/item/ammo_box/magazine/boltpistol(src)
	new /obj/item/ammo_box/magazine/boltpistol(src)
	new /obj/item/reagent_containers/autoinjector/medipen(src)
	new /obj/item/melee/classic_baton/telescopic(src)
	new /obj/item/megaphone(src)
	new /obj/item/restraints/handcuffs/cable/zipties(src)
	new /obj/item/jawsoflife/jimmy(src)

/datum/outfit/imperial
	name = "Imperial Guardsman"

	uniform = /obj/item/clothing/under/imperial
	suit = /obj/item/clothing/suit/armor/imperial
	shoes = /obj/item/clothing/shoes/combat/imperial
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset/headset_cent/alt
	mask = /obj/item/clothing/mask/breath/tactical
	belt = /obj/item/storage/belt/military/imperial/guardsman
	suit_store = /obj/item/gun/ballistic/automatic/laser/lasgun
	head = /obj/item/clothing/head/helmet/imperial
	neck = /obj/item/clothing/neck/imperial
	r_pocket = /obj/item/tank/internals/emergency_oxygen/engi
	id = /obj/item/card/id/ert/imperial
	implants = list(/obj/item/implant/mindshield, /obj/item/implant/biosig_ert)
	
/datum/outfit/imperial/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	H.facial_hair_style = "None" // No crazy hairstyles or nonsense like that.
	H.hair_style = "None"
	
	var/obj/item/radio/R = H.ears
	R.set_frequency(FREQ_CENTCOM)
	R.freqlock = TRUE

	var/obj/item/clothing/mask/bandana/durathread/D = new /obj/item/clothing/mask/bandana/durathread(src)
	D.AltClick(H)

	var/obj/item/card/id/W = H.wear_id
	W.icon_state = "centcom"
	W.registered_name = "Unknown"
	W.assignment = "Imperial Guard Task Force"
	W.originalassignment = "Imperial Guard Task Force"
	W.update_label(W.registered_name, W.assignment)

/datum/outfit/imperial/commander
	name = "Imperial Sergeant"
	belt = /obj/item/storage/belt/military/imperial/sergeant
	glasses = /obj/item/clothing/glasses/hud/security
	suit_store =/obj/item/gun/ballistic/automatic/pistol/boltpistol 
	back = /obj/item/chainsaw_sword
	
/datum/outfit/imperial/marksman
	name = "Imperial Marksman"
	belt = /obj/item/storage/belt/military/imperial/sniper
	suit_store = /obj/item/gun/ballistic/automatic/laser/longlas
	l_pocket = /obj/item/gun/energy/grimdark/pistol

/datum/outfit/imperial/plasma
	name = "Imperial Plasma Gunner"
	belt = /obj/item/storage/belt/military/imperial/plasma
	suit_store = /obj/item/gun/energy/grimdark/rifle
	l_pocket = /obj/item/gun/ballistic/automatic/laser/laspistol

/datum/outfit/imperial/veteran
	name = "Imperial Veteran"
	belt = /obj/item/storage/belt/military/imperial/hotshot
	suit_store = /obj/item/gun/ballistic/automatic/laser/hotshot
	l_pocket = /obj/item/gun/ballistic/automatic/laser/laspistol

/datum/outfit/imperial/commissar
	name = "Imperial Commissar"
	uniform = /obj/item/clothing/under/imperial/commissar
	suit = /obj/item/clothing/suit/armor/imperial/commissar
	shoes = /obj/item/clothing/shoes/combat/imperial/commissar
	gloves = /obj/item/clothing/gloves/combat
	head = /obj/item/clothing/head/helmet/imperial/commissar
	belt = /obj/item/storage/belt/military/imperial/sergeant
	glasses = /obj/item/clothing/glasses/hud/security
	suit_store =/obj/item/gun/ballistic/automatic/pistol/boltpistol 
	back = /obj/item/chainsaw_sword
