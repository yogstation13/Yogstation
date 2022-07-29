/obj/item/clothing/suit/armor
	allowed = null
	body_parts_covered = CHEST
	cold_protection = CHEST|GROIN
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	strip_delay = 60
	equip_delay_other = 40
	max_integrity = 250
	resistance_flags = NONE
	armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 10, BOMB = 25, BIO = 0, RAD = 0, FIRE = 50, ACID = 50, WOUND = 15)
	cryo_preserve = TRUE

/obj/item/clothing/suit/armor/Initialize()
	. = ..()
	if(!allowed)
		allowed = GLOB.security_vest_allowed

/obj/item/clothing/suit/armor/vest
	name = "armor vest"
	desc = "A slim Type I armored vest that provides decent protection against most types of damage."
	icon_state = "armoralt"
	item_state = "armoralt"
	blood_overlay_type = "armor"
	dog_fashion = /datum/dog_fashion/back

/obj/item/clothing/suit/armor/vest/alt
	desc = "A Type I armored vest that provides decent protection against most types of damage."
	icon_state = "armor"
	item_state = "armor"

/obj/item/clothing/suit/armor/vest/old
	name = "degrading armor vest"
	desc = "Older generation Type 1 armored vest. Due to degradation over time the vest is far less maneuverable to move in."
	icon_state = "armor"
	item_state = "armor"
	slowdown = 1

/obj/item/clothing/suit/armor/vest/blueshirt
	name = "large armor vest"
	desc = "A large, yet comfortable piece of armor, protecting you from some threats."
	icon_state = "blueshift"
	item_state = "blueshift"
	custom_premium_price = 600

/obj/item/clothing/suit/armor/hos
	name = "armored greatcoat"
	desc = "A greatcoat enhanced with a special alloy for some extra protection and style for those with a commanding presence."
	icon_state = "hos"
	item_state = "greatcoat"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 10, BOMB = 25, BIO = 0, RAD = 0, FIRE = 70, ACID = 90, WOUND = 20)
	cold_protection = CHEST|GROIN|LEGS|ARMS
	heat_protection = CHEST|GROIN|LEGS|ARMS
	strip_delay = 80

/obj/item/clothing/suit/armor/hos/trenchcoat
	name = "armored trenchcoat"
	desc = "A trenchcoat enhanced with a special lightweight kevlar. The epitome of tactical plainclothes."
	icon_state = "hostrench"
	item_state = "hostrench"
	flags_inv = 0
	strip_delay = 80

/obj/item/clothing/suit/armor/vest/warden
	name = "warden's jacket"
	desc = "A navy-blue armored jacket with blue shoulder designations and '/Warden/' stitched into one of the chest pockets."
	icon_state = "warden_alt"
	item_state = "armor"
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS|HANDS
	heat_protection = CHEST|GROIN|ARMS|HANDS
	strip_delay = 70
	resistance_flags = FLAMMABLE
	dog_fashion = null

/obj/item/clothing/suit/armor/vest/warden/alt
	name = "warden's armored jacket"
	desc = "A red jacket with silver rank pips and body armor strapped on top."
	icon_state = "warden_jacket"
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/suit/armor/vest/leather
	name = "security overcoat"
	desc = "Lightly armored leather overcoat meant as casual wear for high-ranking officers. Bears the crest of Nanotrasen Security."
	icon_state = "leathercoat-sec"
	item_state = "hostrench"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	cold_protection = CHEST|GROIN|LEGS|ARMS
	heat_protection = CHEST|GROIN|LEGS|ARMS
	dog_fashion = null

/obj/item/clothing/suit/armor/vest/capcarapace
	name = "captain's carapace"
	desc = "A fireproof armored chestpiece reinforced with ceramic plates and plasteel pauldrons to provide additional protection whilst still offering maximum mobility and flexibility. Issued only to the station's finest, although it does chafe your nipples."
	icon_state = "capcarapace"
	item_state = "armor"
	body_parts_covered = CHEST|GROIN
	armor = list(MELEE = 50, BULLET = 40, LASER = 50, ENERGY = 10, BOMB = 25, BIO = 0, RAD = 0, FIRE = 100, ACID = 90, WOUND = 10)
	dog_fashion = null
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/armor/vest/capcarapace/syndicate
	name = "syndicate captain's vest"
	desc = "A sinister looking vest of advanced armor worn over a black and red fireproof jacket. The gold collar and shoulders denote that this belongs to a high ranking syndicate officer."
	icon_state = "syndievest"

/obj/item/clothing/suit/armor/vest/capcarapace/alt
	name = "captain's parade jacket"
	desc = "For when an armoured vest isn't fashionable enough."
	icon_state = "capformal"
	item_state = "capspacesuit"

/obj/item/clothing/suit/armor/vest/capcarapace/centcom
	name = "\improper CentCom carapace"
	desc = "A CentCom green alteration of the captain's carapace. Issued only to Nanotrasen's finest, although it does chafe your pecks."
	icon_state = "centcarapace"
	item_state = "centcarapace"

/obj/item/clothing/suit/armor/riot
	name = "riot suit"
	desc = "A suit of semi-flexible polycarbonate body armor with heavy padding to protect against melee attacks. Helps the wearer resist shoving in close quarters."
	icon_state = "riot"
	item_state = "swat_suit"
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	armor = list(MELEE = 50, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 0, BIO = 0, RAD = 0, FIRE = 80, ACID = 80, WOUND = 30)
	blocks_shove_knockdown = TRUE
	strip_delay = 80
	equip_delay_other = 60
	slowdown = 0.33

/obj/item/clothing/suit/armor/bone
	name = "bone armor"
	desc = "A tribal armor plate, crafted from animal bone."
	icon_state = "bonearmor"
	item_state = "bonearmor"
	blood_overlay_type = "armor"
	armor = list(MELEE = 35, BULLET = 25, LASER = 25, ENERGY = 10, BOMB = 25, BIO = 0, RAD = 0, FIRE = 50, ACID = 50, WOUND = 10)
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS

/obj/item/clothing/suit/armor/bone/heavy
	name = "heavy bone armor"
	desc = "A heavy tribal armor plate, crafted from a lot animal bone."
	icon_state = "hbonearmor"
	item_state = "hbonearmor"
	armor = list(MELEE = 40, BULLET = 30, LASER = 30, ENERGY = 15, BOMB = 20, BIO = 0, RAD = 0, FIRE = 60, ACID = 30, WOUND = 20)
	slowdown = 0.20

/obj/item/clothing/suit/armor/tribalcoat
	name = "tribal coat"
	desc = "A light yet tough leather coat reinforced with bone pauldrons."
	icon_state = "tribalcoat"
	item_state = "tribalcoat"
	blood_overlay_type = "armor"
	armor = list(MELEE = 25, BULLET = 25, LASER = 25, ENERGY = 10, BOMB = 25, BIO = 0, RAD = 0, FIRE = 50, ACID = 50, WOUND = 10)
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	resistance_flags = FLAMMABLE

/obj/item/clothing/suit/armor/pathfinder
	name = "pathfinder cloak"
	desc = "A thick cloak woven from sinew and hides meant to protect its wearer from hazardous weather."
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/pickaxe, /obj/item/twohanded/spear, /obj/item/twohanded/bonespear, /obj/item/claymore/bone, /obj/item/gun/ballistic/bow, /obj/item/organ/regenerative_core/legion, /obj/item/kitchen/knife/combat)
	icon_state = "pathcloak"
	item_state = "pathcloak"
	armor = list(MELEE = 35, BULLET = 25, LASER = 25, ENERGY = 10, BOMB = 50, BIO = 0, RAD = 0, FIRE = 50, ACID = 50, WOUND = 15)
	resistance_flags = FIRE_PROOF
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	heat_protection = CHEST|GROIN|LEGS|ARMS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	cold_protection = CHEST|GROIN|LEGS|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/suit/armor/pathfinder/Initialize()
	. = ..()
	AddComponent(/datum/component/armor_plate, null, null, list(MELEE = 10, BULLET = 5, LASER = 5, ENERGY = 5)) //maximum armor 65/40/40/25

/obj/item/clothing/suit/armor/bulletproof
	name = "bulletproof armor"
	desc = "A Type III heavy bulletproof vest that excels in protecting the wearer against traditional projectile weaponry and explosives to a minor extent."
	icon_state = "bulletproof"
	item_state = "armor"
	blood_overlay_type = "armor"
	armor = list(MELEE = 15, BULLET = 60, LASER = 10, ENERGY = 10, BOMB = 40, BIO = 0, RAD = 0, FIRE = 50, ACID = 50, WOUND = 20)
	strip_delay = 70
	equip_delay_other = 50

/obj/item/clothing/suit/armor/laserproof
	name = "reflective jacket"
	desc = "A jacket that excels in protecting the wearer against energy projectiles, as well as occasionally reflecting them."
	icon_state = "armor_reflec"
	item_state = "armor_reflec"
	blood_overlay_type = "armor"
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	heat_protection = CHEST|GROIN|ARMS
	armor = list(MELEE = 10, BULLET = 10, LASER = 60, ENERGY = 50, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/hit_reflect_chance = 50

/obj/item/clothing/suit/armor/laserproof/IsReflect(def_zone)
	if(!(def_zone in list(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))) //If not shot where ablative is covering you, you don't get the reflection bonus!
		return FALSE
	if (prob(hit_reflect_chance))
		return TRUE

/obj/item/clothing/suit/armor/vest/det_suit
	name = "detective's armor vest"
	desc = "An armored vest with a detective's badge on it."
	icon_state = "detective-armor"
	resistance_flags = FLAMMABLE
	dog_fashion = null

/obj/item/clothing/suit/armor/vest/det_suit/Initialize()
	. = ..()
	allowed = GLOB.detective_vest_allowed

//All of the armor below is mostly unused

/obj/item/clothing/suit/armor/centcom
	name = "\improper CentCom armor"
	desc = "A suit that protects against some damage."
	icon_state = "centcom"
	item_state = "centcom"
	w_class = WEIGHT_CLASS_BULKY
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/gun/energy, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman)
	clothing_flags = THICKMATERIAL
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	cold_protection = CHEST | GROIN | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	armor = list(MELEE = 80, BULLET = 80, LASER = 50, ENERGY = 50, BOMB = 100, BIO = 100, RAD = 100, FIRE = 90, ACID = 90)

/obj/item/clothing/suit/armor/heavy
	name = "heavy armor"
	desc = "A heavily armored suit that protects against moderate damage."
	icon_state = "heavy"
	item_state = "swat_suit"
	w_class = WEIGHT_CLASS_BULKY
	gas_transfer_coefficient = 0.9
	clothing_flags = THICKMATERIAL
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	slowdown = 3
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	armor = list(MELEE = 80, BULLET = 80, LASER = 50, ENERGY = 50, BOMB = 100, BIO = 100, RAD = 100, FIRE = 90, ACID = 90)

/obj/item/clothing/suit/armor/tdome
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	clothing_flags = THICKMATERIAL
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	armor = list(MELEE = 80, BULLET = 80, LASER = 50, ENERGY = 50, BOMB = 100, BIO = 100, RAD = 100, FIRE = 90, ACID = 90)

/obj/item/clothing/suit/armor/tdome/red
	name = "thunderdome suit"
	desc = "Reddish armor."
	icon_state = "tdred"
	item_state = "tdred"

/obj/item/clothing/suit/armor/tdome/green
	name = "thunderdome suit"
	desc = "Pukish armor."	//classy.
	icon_state = "tdgreen"
	item_state = "tdgreen"


/obj/item/clothing/suit/armor/riot/knight
	name = "plate armour"
	desc = "A classic suit of plate armour, highly effective at stopping melee attacks."
	icon_state = "knight_green"
	item_state = "knight_green"

/obj/item/clothing/suit/armor/riot/knight/yellow
	icon_state = "knight_yellow"
	item_state = "knight_yellow"

/obj/item/clothing/suit/armor/riot/knight/blue
	icon_state = "knight_blue"
	item_state = "knight_blue"

/obj/item/clothing/suit/armor/riot/knight/red
	icon_state = "knight_red"
	item_state = "knight_red"

/obj/item/clothing/suit/armor/vest/durathread
	name = "durathread vest"
	desc = "A vest made of durathread with strips of leather acting as trauma plates."
	icon_state = "durathread"
	item_state = "durathread"
	strip_delay = 60
	equip_delay_other = 40
	max_integrity = 200
	resistance_flags = FLAMMABLE
	armor = list(MELEE = 20, BULLET = 10, LASER = 30, ENERGY = 5, BOMB = 15, BIO = 0, RAD = 0, FIRE = 40, ACID = 50)

/obj/item/clothing/suit/armor/vest/russian
	name = "russian vest"
	desc = "A bulletproof vest with forest camo. Good thing there's plenty of forests to hide in around here, right?"
	icon_state = "rus_armor"
	item_state = "rus_armor"
	armor = list(MELEE = 25, BULLET = 30, LASER = 0, ENERGY = 15, BOMB = 10, BIO = 0, RAD = 20, FIRE = 20, ACID = 50, WOUND = 10)

/obj/item/clothing/suit/armor/vest/russian_coat
	name = "russian battle coat"
	desc = "Used in extremly cold fronts, made out of real bears."
	icon_state = "rus_coat"
	item_state = "rus_coat"
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	armor = list(MELEE = 25, BULLET = 20, LASER = 20, ENERGY = 10, BOMB = 20, BIO = 50, RAD = 20, FIRE = -10, ACID = 50, WOUND = 10)

/obj/item/clothing/suit/armor/stormtrooper
	name = "Storm Trooper Armor"
	desc = "Battle Armor from a long lost empire"
	icon_state = "stormtrooper"
	item_state = "stormtrooper"
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	armor = list(MELEE = 30, BULLET = 30, LASER = 50, ENERGY = 15, BOMB = 30, BIO = 20, RAD = 10, FIRE = 80, ACID = 80, WOUND = 10)
	slowdown = 0.9

/obj/item/clothing/suit/hooded/cloak/goliath
	name = "goliath cloak"
	icon_state = "goliath_cloak"
	desc = "A staunch, practical cape made out of numerous monster materials, it is coveted amongst exiles & hermits."
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/pickaxe, /obj/item/twohanded/spear, /obj/item/twohanded/bonespear, /obj/item/claymore/bone, /obj/item/gun/ballistic/bow, /obj/item/organ/regenerative_core/legion, /obj/item/kitchen/knife/combat)
	armor = list(MELEE = 35, BULLET = 25, LASER = 25, ENERGY = 10, BOMB = 25, BIO = 0, RAD = 0, FIRE = 50, ACID = 50, WOUND = 10) //a fair alternative to bone armor, requiring alternative materials and gaining a suit slot
	resistance_flags = FIRE_PROOF
	hoodtype = /obj/item/clothing/head/hooded/cloakhood/goliath
	body_parts_covered = CHEST|GROIN|ARMS

/obj/item/clothing/head/hooded/cloakhood/goliath
	name = "goliath cloak hood"
	icon_state = "golhood"
	desc = "A protective & concealing hood."
	armor = list(MELEE = 35, BULLET = 25, LASER = 25, ENERGY = 10, BOMB = 25, BIO = 0, RAD = 0, FIRE = 50, ACID = 50, WOUND = 10)
	resistance_flags = FIRE_PROOF
	flags_inv = HIDEEARS|HIDEEYES|HIDEHAIR|HIDEFACIALHAIR
	transparent_protection = HIDEMASK

/obj/item/clothing/suit/hooded/cloak/goliath/desert
	name = "brown leather cape"
	desc = "An ash coated cloak."
	icon_state = "desertcloak"
	armor = list()
	resistance_flags = 0
	hoodtype = /obj/item/clothing/head/hooded/cloakhood/goliath/desert

/obj/item/clothing/head/hooded/cloakhood/goliath/desert
	name = "goliath cloak hood"
	icon_state = "desertcloak"
	desc = "An ash coated cloak hood."
	armor = list()
	resistance_flags = 0
	flags_inv = HIDEEARS|HIDEEYES|HIDEHAIR|HIDEFACIALHAIR
	transparent_protection = HIDEMASK

/obj/item/clothing/suit/hooded/cloak/drake
	name = "drake armour"
	icon_state = "dragon"
	desc = "A suit of armour fashioned from the remains of an ash drake."
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/kinetic_accelerator, /obj/item/pickaxe, /obj/item/twohanded/spear, /obj/item/twohanded/bonespear, /obj/item/claymore/bone, /obj/item/gun/ballistic/bow, /obj/item/organ/regenerative_core/legion, /obj/item/kitchen/knife/combat)
	armor = list(MELEE = 70, BULLET = 30, LASER = 50, ENERGY = 40, BOMB = 70, BIO = 60, RAD = 50, FIRE = 100, ACID = 100)
	hoodtype = /obj/item/clothing/head/hooded/cloakhood/drake
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	transparent_protection = HIDEGLOVES|HIDESUITSTORAGE|HIDEJUMPSUIT|HIDESHOES

/obj/item/clothing/head/hooded/cloakhood/drake
	name = "drake helm"
	icon_state = "dragon"
	desc = "The skull of a dragon."
	armor = list(MELEE = 70, BULLET = 30, LASER = 50, ENERGY = 40, BOMB = 70, BIO = 60, RAD = 50, FIRE = 100, ACID = 100)
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/suit/armor/elder_atmosian
	name = "\improper Elder Atmosian Armor"
	desc = "A superb armor made with the toughest and rarest materials available to man."
	icon_state = "h2armor"
	item_state = "h2armor"
	armor = list(MELEE = 35, BULLET = 30, LASER = 25, ENERGY = 25, BOMB = 85, BIO = 20, RAD = 50, FIRE = 75, ACID = 40, WOUND = 15)
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	resistance_flags = FIRE_PROOF | ACID_PROOF
	clothing_flags = THICKMATERIAL

//////////////// PLATED ARMOR ////////////////
// Helmet type in code/modules/clothing/head/helmet.dm
/obj/item/clothing/suit/armor/plated
	name = "empty plated armor vest"	
	desc = "A lightweight general-purpose over-armor suit that is designed to hold various types of armor plating. Won't do much without them."
	icon_state = "plate-armor"
	item_state = "plate-armor"
	blood_overlay_type = "armor"
	w_class = WEIGHT_CLASS_SMALL // It's just some fabric, after all
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 10, ACID = 0, WOUND = 0)
	slowdown = 0

	var/obj/item/kevlar_plating/plating

/obj/item/clothing/suit/armor/plated/attack_self(mob/user)
	if(!plating)
		to_chat(user, span_warning("[src] doesn't have any plating to remove!"))
		return
	
	user.visible_message("[user] removes [plating] from [src]!", span_notice("You remove [plating]."))

	user.put_in_hands(plating)

	name = initial(name)
	armor = armor.setRating(5,0,0,0,0,0,0,10,0,0,0)	//because initial(armor) apparently doesn't work
	slowdown = initial(slowdown)
	w_class = initial(w_class)
	plating = null

/obj/item/clothing/suit/armor/plated/examine(mob/user)
	.=..()
	if(plating)
		. += span_info("It has [plating] slotted.")

/obj/item/clothing/suit/armor/plated/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(!istype(I, /obj/item/kevlar_plating))
		return
	if(plating)
		to_chat(user, span_warning("[src] already has [plating] slotted!"))
		return 
	if(!user.transferItemToLoc(I, src))
		return
	
	user.visible_message("[user] inserts [plating] into [src]!", span_notice("You insert [plating] into [src]."))

	var/obj/item/kevlar_plating/K = I

	name = "[K.name_set] plated armor vest"
	slowdown = K.slowdown_set

	if (islist(armor) || isnull(armor))		//For an explanation see code/modules/clothing/under/accessories.dm#L39 - accessory detach proc							
		armor = getArmor(arglist(armor))
	if (islist(K.armor) || isnull(K.armor))
		K.armor = getArmor(arglist(K.armor))

	armor = armor.attachArmor(K.armor)
	w_class = WEIGHT_CLASS_BULKY
	plating = K

//////////////// ARMOR PLATES ////////////////////////////////////////////////
// These armors are supposed to be a mid-game direct upgrade for security that enables
// them to dynamically respond depending on their skillset and/or the situation at hand
//
// balancing reference:
// default armor, slowdown 0
// armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 10, BOMB = 25, BIO = 0, RAD = 0, FIRE = 50, ACID = 50, WOUND = 15)
// bulletproof armor, slowdown 0
// armor = list(MELEE = 15, BULLET = 60, LASER = 10, ENERGY = 10, BOMB = 40, BIO = 0, RAD = 0, FIRE = 50, ACID = 50, WOUND = 20)
// hos hardsuit, slowdown 1
// armor = list(MELEE = 45, BULLET = 30, LASER = 30, ENERGY = 10, BOMB = 25, BIO = 100, RAD = 50, FIRE = 95, ACID = 95, WOUND = 25)
// riot armor, slowdown 0.33
// armor = list(MELEE = 50, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 0, BIO = 0, RAD = 0, FIRE = 80, ACID = 80, WOUND = 30)
//////////////////////////////////////////////////////////////////////////////
/obj/item/kevlar_plating
	name = "debug plating"
	desc = "You shouldn't see this!"
	icon = 'icons/obj/kevlar.dmi'
	icon_state = "mki"
	force = 2
	var/name_set = "debug"
	var/slowdown_set = 0 // Slowdown value to set on the vest, for reference a hardsuit has "1" slowdown
	armor = list(MELEE = 100, BULLET = 100, LASER = 100, ENERGY = 100, BOMB = 100, BIO = 100, RAD = 100, FIRE = 100, ACID = 100, WOUND = 100) // Armor value to set on the vest

/obj/item/kevlar_plating/mki
	name = "MK.I bluespace plating"
	desc = "Incredibly light bluespace-infused armor plating that offers great movement while also providing some protection."
	name_set = "MK.I bluespace"
	slowdown_set = -0.075 // Speeds you up a bit in exchange for giving up some armor
	armor = list(MELEE = 15, BULLET = 20, LASER = 25, ENERGY = 5, BOMB = 5, BIO = 0, RAD = 0, FIRE = 30, ACID = 40, WOUND = 10) // Slightly worse than default armor

/obj/item/kevlar_plating/mkii
	name = "MK.II ceramic plating"
	desc = "Light armor plating that can be carried easily while providing robust protection."
	icon_state = "mkii"
	force = 4
	name_set = "MK.II ceramic"
	slowdown_set = 0
	armor = list(MELEE = 30, BULLET = 35, LASER = 35, ENERGY = 15, BOMB = 25, BIO = 0, RAD = 0, FIRE = 40, ACID = 50, WOUND = 20) 	// Slightly better than default armor

/obj/item/kevlar_plating/mkiii
	name = "MK.III plasteel plating"
	desc = "Weighted armor plating that impedes movement but greatly improves the durability of the wearer."
	icon_state = "mkiii"
	force = 6
	name_set = "MK.III plasteel"
	slowdown_set = 0.15 // Slow
	armor = list(MELEE = 40, BULLET = 45, LASER = 45, ENERGY = 25, BOMB = 30, BIO = 0, RAD = 0, FIRE = 50, ACID = 60, WOUND = 35)	//Robust

/obj/item/kevlar_plating/mkiv
	name = "MK.IV titanium plating"
	desc = "Incredibly heavy armor plating that makes shooting the covered areas almost pointless."
	icon_state = "mkiv"
	force = 8
	name_set = "MK.IV titanium"
	w_class = WEIGHT_CLASS_BULKY
	slowdown_set = 0.4 // Very slow
	armor = list(MELEE = 55, BULLET = 60, LASER = 60, ENERGY = 40, BOMB = 40, BIO = 0, RAD = 0, FIRE = 65, ACID = 75, WOUND = 50)	//Walking tank
