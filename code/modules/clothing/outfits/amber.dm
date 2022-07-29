// amber task force clothing
/obj/item/clothing/under/rank/security/grey/amber
	name = "amber task force jumpsuit"

/obj/item/clothing/head/beret/sec/amber_medic
	name = "amber medic beret"
	desc = "A white beret for the mundane life of an amber task force medic."
	icon = 'yogstation/icons/obj/clothing/hats.dmi'
	mob_overlay_icon = 'yogstation/icons/mob/clothing/head/head.dmi'
	icon_state = "beret_ce"


/obj/item/clothing/head/beret/corpsec/amber_commander
	name = "amber commander beret"
	desc = "A special black beret for the mundane life of an amber task force commander."

// amber task force vest loadouts
// To note: each vest has 7 normal slots - Hopek
/obj/item/storage/belt/military/amber/ComponentInitialize() // Amber Soldier
	. = ..()
	new /obj/item/ammo_box/magazine/recharge(src)
	new /obj/item/ammo_box/magazine/recharge(src)
	new /obj/item/reagent_containers/autoinjector/medipen(src)
	new /obj/item/flashlight/flare(src)
	new /obj/item/flashlight/flare(src)
	new /obj/item/restraints/handcuffs/cable/zipties(src)
	new /obj/item/jawsoflife/jimmy(src)


/obj/item/storage/belt/military/amber_commander/ComponentInitialize() // Amber Commander
	. = ..()
	new /obj/item/ammo_box/magazine/recharge(src)
	new /obj/item/ammo_box/magazine/recharge(src)
	new /obj/item/reagent_containers/autoinjector/medipen(src)
	new /obj/item/melee/classic_baton/telescopic(src)
	new /obj/item/megaphone(src)
	new /obj/item/restraints/handcuffs/cable/zipties(src)
	new /obj/item/jawsoflife/jimmy(src)

/obj/item/storage/belt/military/amber_medic/ComponentInitialize() // Amber Medic
	. = ..()
	new /obj/item/ammo_box/magazine/recharge(src)
	new /obj/item/reagent_containers/medspray/synthflesh(src) // for getting people back to defib range
	new /obj/item/reagent_containers/autoinjector/medipen/survival(src)
	new /obj/item/reagent_containers/autoinjector/medipen/survival(src)
	new /obj/item/reagent_containers/autoinjector/medipen/survival(src)
	new /obj/item/reagent_containers/autoinjector/combat(src)
	new /obj/item/jawsoflife/jimmy(src)


/datum/outfit/amber
	name = "Amber Soldier"

	uniform = /obj/item/clothing/under/rank/security/grey/amber
	suit = /obj/item/clothing/suit/armor/bulletproof
	shoes = /obj/item/clothing/shoes/combat/combat_knife
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset/headset_cent/alt
	mask = /obj/item/clothing/mask/breath/tactical
	belt = /obj/item/storage/belt/military/amber
	suit_store = /obj/item/gun/ballistic/automatic/laser
	back = /obj/item/tank/internals/oxygen/tactical
	head = /obj/item/clothing/head/helmet/riot/raised
	l_pocket = /obj/item/flashlight/seclite
	id = /obj/item/card/id/ert/amber
	implants = list(/obj/item/implant/mindshield)
	


/datum/outfit/amber/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	H.facial_hair_style = "None" // Everyone in the Amber task force is bald and has no facial hair
	H.hair_style = "None"
	
	var/obj/item/radio/R = H.ears
	R.set_frequency(FREQ_CENTCOM)
	R.freqlock = TRUE

	var/obj/item/clothing/mask/bandana/durathread/D = new /obj/item/clothing/mask/bandana/durathread(src)
	D.AltClick(H)

	var/obj/item/card/id/W = H.wear_id
	W.icon_state = "centcom"
	W.registered_name = "Unknown"
	W.assignment = "Amber Task Force"
	W.originalassignment = "Amber Task Force"
	W.update_label(W.registered_name, W.assignment)

	H.ignores_capitalism = TRUE // Yogs -- Lets the Amber force buy a damned smoke for christ's sake


/datum/outfit/amber/commander
	name = "Amber Commander"
	head = /obj/item/clothing/head/beret/corpsec/amber_commander
	belt = /obj/item/storage/belt/military/amber_commander
	r_pocket = /obj/item/clothing/mask/breath/tactical
	mask = /obj/item/clothing/mask/cigarette/cigar/cohiba
	glasses = /obj/item/clothing/glasses/hud/security

	
/datum/outfit/amber/medic
	name = "Amber Medic"
	glasses = /obj/item/clothing/glasses/hud/health
	belt = /obj/item/storage/belt/military/amber_medic
	back = /obj/item/defibrillator/loaded
	r_pocket = /obj/item/tank/internals/emergency_oxygen/engi
	head = /obj/item/clothing/head/beret/sec/amber_medic
	
