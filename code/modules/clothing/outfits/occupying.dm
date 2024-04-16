// Peacekeeping force clothing
/obj/item/clothing/under/rank/security/grey/amber/occupying
	name = "peacekeeping officer jumpsuit"
	desc = "A Peacekeeper uniform with red marking denoting officers and heavies."
	icon_state = "occuniformofficer"
	item_state = "occuniformofficer"

/obj/item/clothing/under/rank/security/grey/amber/occupying/commander
	name = "peacekeeping commander jumpsuit"
	desc = "A Peacekeeper uniform with blue markings denoting commanders"
	icon_state = "occuniformcommander"
	item_state = "occuniformcommander"

/obj/item/clothing/under/rank/security/grey/amber/occupying/Initialize(mapload, mob/user)
	. = ..()
	if(prob(50)) // Adds variation to the uniform. 50% will be worn casually.
		rolldown(TRUE)

/obj/item/clothing/head/beret/sec/centcom/occupying
	name = "peacekeeping force beret"
	desc = "A special white beret for the mundane life of a Peacekeeper force commander."
	icon_state = "occberet"
	item_state = "occberet"

/obj/item/clothing/suit/armor/vest/alt/occupying
	name = "peacekeeping force vest"
	desc = "A blue armored vest worn by Peacekeeper officers."
	icon_state = "occvest"
	item_state = "occvest"

/obj/item/clothing/suit/armor/riot/occupying
	armor = list(MELEE = 40, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 0, BIO = 0, RAD = 0, FIRE = 40, ACID = 40)
	name = "peacekeeping force riot suit"
	desc = "A reinforced version of the standard Peacekeeper vest with extra padding to protect against melee attacks. Not as strong as riot suits typically issued to NT stations."
	icon_state = "occriotsuit"
	item_state = "occriotsuit"
	mutantrace_variation = NO_MUTANTRACE_VARIATION

/obj/item/clothing/head/helmet/riot/raised/occupying
	name = "peacekeeping force riot helmet"
	desc = "A blue helmet specifically designed for the Peacekeeping force to protect against close range attacks."
	icon_state = "occriothelm"
	item_state = "occriothelm"

/obj/item/storage/belt/military/occbelt
	name = "peacekeeping force belt"
	desc = "A blue belt used by Peacekeepers to store their gear."
	icon_state = "occbelt"
	item_state = "occbelt"

// Peacekeeping force vest loadouts
// To note: each vest has 7 normal slots - Hopek
/obj/item/storage/belt/military/occbelt/occupying_officer/Initialize(mapload) // Occupying Officer
	. = ..()
	new /obj/item/ammo_box/magazine/wt550m9/wtr(src)
	new /obj/item/ammo_box/magazine/wt550m9/wtr(src)
	new /obj/item/reagent_containers/autoinjector/medipen(src)
	new /obj/item/restraints/handcuffs/cable/zipties(src)
	new /obj/item/restraints/handcuffs/cable/zipties(src)
	new /obj/item/reagent_containers/food/snacks/pizzaslice/pepperoni(src)
	new /obj/item/jawsoflife/jimmy(src)


/obj/item/storage/belt/military/occbelt/occupying_commander/Initialize(mapload) // Occupying force Commander
	. = ..()
	new /obj/item/ammo_box/magazine/wt550m9/wtr(src)
	new /obj/item/ammo_box/magazine/wt550m9/wtr(src)
	new /obj/item/reagent_containers/autoinjector/medipen(src)
	new /obj/item/reagent_containers/food/snacks/pizzaslice/pepperoni(src)
	new /obj/item/megaphone(src)
	new /obj/item/restraints/handcuffs/cable/zipties(src)
	new /obj/item/jawsoflife/jimmy(src)


/obj/item/storage/belt/military/occbelt/occupying_heavy/Initialize(mapload) // Occupying Riot Officer
	. = ..()
	new /obj/item/restraints/legcuffs/bola/energy(src)
	new /obj/item/restraints/legcuffs/bola/energy(src)
	new /obj/item/restraints/handcuffs(src)
	new /obj/item/reagent_containers/food/snacks/pizzaslice/pepperoni(src)
	new /obj/item/reagent_containers/autoinjector/medipen(src)
	new /obj/item/flashlight/flare(src)
	new /obj/item/jawsoflife/jimmy(src)


/datum/outfit/occupying
	name = "Peacekeeping Officer"
	uniform = /obj/item/clothing/under/rank/security/grey/amber/occupying
	suit = /obj/item/clothing/suit/armor/vest/alt/occupying
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/color/black
	ears = /obj/item/radio/headset/headset_cent/alt
	mask = /obj/item/clothing/mask/cigarette/lit
	belt = /obj/item/storage/belt/military/occbelt/occupying_officer
	suit_store = /obj/item/gun/ballistic/automatic/wt550/armory
	back = /obj/item/melee/baton/cattleprod/tactical
	head = /obj/item/clothing/head/helmet/sec/occupying
	l_pocket = /obj/item/reagent_containers/food/drinks/beer
	r_pocket = /obj/item/storage/fancy/cigarettes
	id = /obj/item/card/id/ert/occupying
	implants = list(/obj/item/implant/mindshield, /obj/item/implant/biosig_ert)
	

/datum/outfit/occupying/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	H.facial_hair_style = "None" // Everyone in the Peacekeeping force is bald and has no facial hair
	H.hair_style = "None"
	
	var/obj/item/radio/R = H.ears
	R.set_frequency(FREQ_CENTCOM)
	R.freqlock = TRUE

	var/obj/item/card/id/W = H.wear_id
	W.icon_state = "centcom"
	W.registered_name = "Unknown" // continuing the tradition of these ID's not being assigned to a particular person
	W.assignment = "Peacekeeping Force"
	W.originalassignment = "Peacekeeping Force"
	W.update_label(W.registered_name, W.assignment)

	H.ignores_capitalism = TRUE // Yogs -- Lets the Peacekeeping force buy a damned smoke for christ's sake


/datum/outfit/occupying/commander
	name = "Peacekeeping force Commander"
	uniform = /obj/item/clothing/under/rank/security/grey/amber/occupying/commander
	head = /obj/item/clothing/head/beret/sec/centcom/occupying
	belt = /obj/item/storage/belt/military/occbelt/occupying_commander
	l_pocket = /obj/item/pinpointer/nuke
	r_pocket = /obj/item/lighter/greyscale // everyone has ciggies, only commander has a lighter
	mask = /obj/item/clothing/mask/cigarette/cigar/cohiba
	glasses = /obj/item/clothing/glasses/hud/security

/datum/outfit/occupying/heavy
	name = "Peacekeeping Riot Officer"
	belt = /obj/item/storage/belt/military/occbelt/occupying_heavy
	back = /obj/item/shield/riot
	l_pocket = /obj/item/clothing/ears/earmuffs
	r_pocket = /obj/item/tank/internals/emergency_oxygen/engi
	head = /obj/item/clothing/head/helmet/riot/raised/occupying
	suit = /obj/item/clothing/suit/armor/riot/occupying
	mask = /obj/item/clothing/mask/breath/tactical
	suit_store = /obj/item/melee/baton/loaded 
	glasses = /obj/item/clothing/glasses/sunglasses 
