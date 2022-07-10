//miscellaneous spacesuits
/*
Contains:
 - SWAT suit
 - Officer's beret/spacesuit
 - NASA Voidsuit
 - Father Christmas' magical clothes
 - Pirate's spacesuit
 - Paramedic spacesuit
 - Command spacesuit
 - Cosmonaut spacesuit
 - Freedom's spacesuit (freedom from vacuum's oppression)
 - Emergency spacesuit
*/

	//NEW SWAT suit
/obj/item/clothing/suit/space/swat
	name = "MK.I SWAT Suit"
	desc = "A tactical space suit first developed in a joint effort by the defunct IS-ERI and Nanotrasen in 20XX for military space operations. A tried and true workhorse, it is very difficult to move in but offers robust protection against all threats!"
	icon_state = "heavy"
	item_state = "swat_suit"
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals, /obj/item/kitchen/knife/combat)
	armor = list(MELEE = 40, BULLET = 40, LASER = 30,ENERGY = 30, BOMB = 50, BIO = 90, RAD = 20, FIRE = 100, ACID = 100, WOUND = 15)
	strip_delay = 120
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/head/helmet/space/beret
	name = "officer's beret"
	desc = "An armored beret commonly used by special operations officers. Uses advanced force field technology to protect the head from space."
	icon_state = "beret_badge"
	dynamic_hair_suffix = "+generic"
	dynamic_fhair_suffix = "+generic"
	flags_inv = 0
	armor = list(MELEE = 80, BULLET = 80, LASER = 50, ENERGY = 50, BOMB = 100, BIO = 100, RAD = 100, FIRE = 100, ACID = 100, WOUND = 15)
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/suit/space/officer
	name = "officer's jacket"
	desc = "An armored, space-proof jacket used in special operations."
	icon_state = "detective"
	item_state = "det_suit"
	blood_overlay_type = "coat"
	slowdown = 0
	flags_inv = 0
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	armor = list(MELEE = 80, BULLET = 80, LASER = 50, ENERGY = 50, BOMB = 100, BIO = 100, RAD = 100, FIRE = 100, ACID = 100, WOUND = 15)
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF

	//NASA Voidsuit
/obj/item/clothing/head/helmet/space/nasavoid
	name = "NASA Void Helmet"
	desc = "An old, NASA CentCom branch designed, dark red space suit helmet."
	icon_state = "void"
	item_state = "void"

/obj/item/clothing/suit/space/nasavoid
	name = "NASA Voidsuit"
	icon_state = "void"
	item_state = "void"
	desc = "An old, NASA CentCom branch designed, dark red space suit."
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/multitool)

/obj/item/clothing/head/helmet/space/nasavoid/old
	name = "Engineering Void Helmet"
	desc = "A CentCom engineering dark red space suit helmet. While old and dusty, it still gets the job done."
	icon_state = "void"
	item_state = "void"

/obj/item/clothing/suit/space/nasavoid/old
	name = "Engineering Voidsuit"
	icon_state = "void"
	item_state = "void"
	desc = "A CentCom engineering dark red space suit. Age has degraded the suit making it difficult to move around in."
	slowdown = 4
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/multitool)

	//Space santa outfit suit
/obj/item/clothing/head/helmet/space/santahat
	name = "Santa's hat"
	desc = "Ho ho ho. Merrry X-mas!"
	icon_state = "santahat"
	flags_cover = HEADCOVERSEYES

	dog_fashion = /datum/dog_fashion/head/santa

/obj/item/clothing/suit/space/santa
	name = "Santa's suit"
	desc = "Festive!"
	icon_state = "santa"
	item_state = "santa"
	slowdown = 0
	allowed = list(/obj/item) //for stuffing exta special presents

/obj/item/clothing/suit/santa //version with no space protection
	name = "Santa's suit"
	desc = "Festive!"
	icon_state = "santa"
	item_state = "santa"
	slowdown = 0
	allowed = list(/obj/item) //for stuffing exta special presents


	//Space pirate outfit
/obj/item/clothing/head/helmet/space/pirate
	name = "syndicate pirate hat"
	desc = "Ahoy! A reinforced hat worn by space privateers who thrill in stealing fine booty."
	icon_state = "pirate"
	item_state = "pirate"
	armor = list(MELEE = 30, BULLET = 50, LASER = 30, ENERGY = 25, BOMB = 30, BIO = 30, RAD = 30, FIRE = 60, ACID = 75)
	flags_inv = HIDEHAIR
	strip_delay = 40
	equip_delay_other = 20
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/head/helmet/space/pirate/bandana
	name = "syndicate pirate bandana"
	desc = "Ahoy! Worn by typical maties who sail out to terrorize ships and stations alike. The bandana is reinforced."
	icon_state = "bandana"
	item_state = "bandana"

/obj/item/clothing/head/helmet/space/pirate/captain
	name = "syndicate pirate captain hat"
	desc = "Ahoy! The pinnacle of terror of hardened Syndicate captains who lead violent crews to plunder and glory. Reinforced to keep your skull on your skeleton."
	armor = list(MELEE = 40, BULLET = 60, LASER = 40, ENERGY = 25, BOMB = 50, BIO = 30, RAD = 30, FIRE = 100, ACID = 100, WOUND = 10)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	icon_state = "hgpiratecap"
	item_state = "hgpiratecap"

/obj/item/clothing/suit/space/pirate
	name = "syndicate pirate coat"
	desc = "Arrrgh! The standard armor of freelance forces contracted by the Syndicate to terrorize and disrupt commercial operations."
	icon_state = "pirate"
	item_state = "pirate"
	w_class = WEIGHT_CLASS_NORMAL
	flags_inv = 0
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals, /obj/item/melee/transforming/energy/sword/pirate, /obj/item/melee/cutlass, /obj/item/reagent_containers/food/drinks/bottle/rum)
	slowdown = 0
	armor = list(MELEE = 30, BULLET = 50, LASER = 30, ENERGY = 15, BOMB = 30, BIO = 30, RAD = 30, FIRE = 60, ACID = 75)
	strip_delay = 40
	equip_delay_other = 20

/obj/item/clothing/suit/space/pirate/captain
	name = "syndicate pirate captain coat"
	desc = "Arrrgh! Adorned with immeasurable protection, this coat serves the most fearsome Syndicate pirates in their neverending quest of loot."
	armor = list(MELEE = 40, BULLET = 60, LASER = 40, ENERGY = 25, BOMB = 50, BIO = 30, RAD = 30, FIRE = 100, ACID = 100, WOUND = 10)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	icon_state = "hgpirate"
	item_state = "hgpirate"

/obj/item/clothing/suit/space/paramedic
	name = "medical space suit"
	desc = "A suit that protects against low pressure environments. Has a big cross on the back."
	icon_state = "paramedic"
	item_state = "paramedic"

/obj/item/clothing/head/helmet/space/heads
	name = "command space helmet"
	icon_state = "command"
	item_state = "command"
	desc = "A special helmet with solar UV shielding to protect your eyes from harmful rays."
	armor = list(MELEE = 10, BULLET = 10, LASER = 10,ENERGY = 0, BOMB = 0, BIO = 100, RAD = 50, FIRE = 40, ACID = 65)

/obj/item/clothing/suit/space/heads
	name = "command space suit"
	icon_state = "command"
	item_state = "command"
	desc = "A suit that protects against low pressure environments. Has a big N on the back. This variation has reinforced seams."
	armor = list(MELEE = 10, BULLET = 10, LASER = 10,ENERGY = 0, BOMB = 0, BIO = 100, RAD = 50, FIRE = 40, ACID = 65)

/obj/item/clothing/head/helmet/space/freedom
	name = "eagle helmet"
	desc = "An advanced, space-proof helmet. It appears to be modeled after an old-world eagle."
	icon_state = "griffinhat"
	item_state = "griffinhat"
	armor = list(MELEE = 20, BULLET = 40, LASER = 30, ENERGY = 25, BOMB = 50, BIO = 100, RAD = 100, FIRE = 80, ACID = 80) //yogs reason below
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = ACID_PROOF | FIRE_PROOF

/obj/item/clothing/suit/space/freedom
	name = "eagle suit"
	desc = "An advanced, light suit, fabricated from a mixture of synthetic feathers and space-resistant material. A gun holster appears to be integrated into the suit and the wings appear to be stuck in 'freedom' mode."
	icon_state = "freedom"
	item_state = "freedom"
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	armor = list(MELEE = 20, BULLET = 40, LASER = 30,ENERGY = 25, BOMB = 25, BIO = 100, RAD = 100, FIRE = 80, ACID = 80, WOUND = 15) //yogs nerfed bomb resistance as its now obtainable
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = ACID_PROOF | FIRE_PROOF
	slowdown = 0

/obj/item/clothing/head/helmet/space/cosmonaut
	name = "cosmonaut space helmet"
	icon_state = "cosmonaut"
	item_state = "cosmonaut"
	desc = "A special helmet with solar UV shielding to protect your eyes from harmful rays."
	armor = list(MELEE = 15, BULLET = 20, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 100, RAD = 50, FIRE = 40, ACID = 65)

/obj/item/clothing/suit/space/cosmonaut
	name = "cosmonaut space suit"
	icon_state = "cosmonaut"
	item_state = "cosmonaut"
	desc = "A suit that protects against low pressure environments. Has a big red star on the back."
	armor = list(MELEE = 15, BULLET = 20, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 100, RAD = 50, FIRE = 40, ACID = 65)

/obj/item/clothing/head/helmet/space/fragile
	name = "emergency space helmet"
	desc = "A bulky, air-tight helmet meant to protect the user during emergency situations. It doesn't look very durable."
	icon_state = "emergency"
	item_state = "emergency"
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 10, FIRE = 0, ACID = 0)
	strip_delay = 65

/obj/item/clothing/suit/space/fragile
	name = "emergency space suit"
	desc = "A bulky, air-tight suit meant to protect the user during emergency situations. It doesn't look very durable."
	var/torn = FALSE
	icon_state = "emergency"
	item_state = "emergency"
	slowdown = 2
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 10, FIRE = 0, ACID = 0)
	strip_delay = 65

/obj/item/clothing/suit/space/fragile/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!torn && prob(50))
		to_chat(owner, span_warning("[src] tears from the damage, breaking the air-tight seal!"))
		clothing_flags &= ~STOPSPRESSUREDAMAGE
		name = "torn [src]."
		desc = "A bulky suit meant to protect the user during emergency situations, at least until someone tore a hole in the suit."
		torn = TRUE
		playsound(loc, 'sound/weapons/slashmiss.ogg', 50, 1)
		playsound(loc, 'sound/effects/refill.ogg', 50, 1)
