// Imperial ERT outfits and Clothing

/obj/item/clothing/under/rank/security/grey/amber
	name = "Imperial Guard Jumpsuit"





// Belts

/obj/item/storage/belt/military/imperial/ComponentInitialize() // Imperial Guardsman
	. = ..()
	new /obj/item/ammo_box/magazine/recharge/lasgun(src)
	new /obj/item/ammo_box/magazine/recharge/lasgun(src)
    new /obj/item/ammo_box/magazine/recharge/lasgun(src)
	new /obj/item/reagent_containers/autoinjector/medipen(src)
	new /obj/item/flashlight/flare(src)
	new /obj/item/restraints/handcuffs/cable/zipties(src)
	new /obj/item/jawsoflife/jimmy(src)

/obj/item/storage/belt/military/imperial_plasma/ComponentInitialize() // Plasma gunner
	. = ..()
    new /obj/item/ammo_box/magazine/recharge/lasgun/pistol(src)
    new /obj/item/ammo_box/magazine/recharge/lasgun/pistol(src)
	new /obj/item/reagent_containers/autoinjector/medipen(src)
	new /obj/item/flashlight/flare(src)
	new /obj/item/restraints/handcuffs/cable/zipties(src)
	new /obj/item/jawsoflife/jimmy(src)
    new /obj/item/stack/medical/mesh(src) // for when his gun inevitably explodes

/obj/item/storage/belt/military/imperial_hotshot/ComponentInitialize() // Veteran
	. = ..()
	new /obj/item/ammo_box/magazine/recharge/lasgun/hotshot(src)
	new /obj/item/ammo_box/magazine/recharge/lasgun/hotshot(src)
    new /obj/item/ammo_box/magazine/recharge/lasgun/pistol(src)
	new /obj/item/reagent_containers/autoinjector/medipen(src)
	new /obj/item/flashlight/flare(src)
	new /obj/item/restraints/handcuffs/cable/zipties(src)
	new /obj/item/jawsoflife/jimmy(src)

/obj/item/storage/belt/military/imperial_sniper/ComponentInitialize() // Marksman
	. = ..()
	new /obj/item/ammo_box/magazine/recharge/lasgun/sniper(src)
	new /obj/item/ammo_box/magazine/recharge/lasgun/sniper(src)
    new /obj/item/ammo_box/magazine/recharge/lasgun/pistol(src)
	new /obj/item/reagent_containers/autoinjector/medipen(src)
	new /obj/item/restraints/handcuffs/cable/zipties(src)
	new /obj/item/jawsoflife/jimmy(src)
    new /obj/item/twohanded/binoculars(src)


/obj/item/storage/belt/military/imperial_sergeant/ComponentInitialize() // Sergeant
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

	uniform = 
	suit = 
	shoes = 
	gloves = /obj/item/clothing/gloves/combat
	ears = 
	mask = /obj/item/clothing/mask/breath/tactical
	belt = 
	suit_store = /obj/item/gun/ballistic/automatic/laser/lasgun
	back = 
	head = 
    neck = 
	l_pocket = 
    r_pocket = /obj/item/tank/internals/emergency_oxygen/engi
	id = 
	implants = list(/obj/item/implant/mindshield)
	
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
	name = "Sergeant"
	head = 
	belt = /obj/item/storage/belt/military/imperial_sergeant
	glasses = /obj/item/clothing/glasses/hud/security
	
/datum/outfit/imperial/marksman
	name = "Marksman"
	belt = /obj/item/storage/belt/military/imperial_sniper

/datum/outfit/imperial/plasma
	name = "Plasma Gunner"
	belt = /obj/item/storage/belt/military/imperial_plasma

/datum/outfit/imperial/veteran
	name = "Veteran"
	belt = /obj/item/storage/belt/military/imperial_hotshot
