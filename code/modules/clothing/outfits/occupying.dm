// Peacekeeping force clothing
/obj/item/clothing/under/rank/security/grey/amber/occupying
	name = "peacekeeping force jumpsuit"
	color = "#55ff9b"

/obj/item/clothing/under/rank/security/grey/amber/occupying/Initialize(mob/user)
	. = ..()
	if(prob(50)) // Adds variation to the uniform. 50% will be worn casually.
		rolldown(TRUE)

/obj/item/clothing/head/beret/sec/centcom/occupying
	name = "peacekeeping force beret"
	desc = "A special green beret for the mundane life of an Peacekeeper force commander."
	color = "#55ff9b"

/obj/item/clothing/suit/armor/riot/occupying
	armor = list("melee" = 40, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 40, "acid" = 40)
	name = "peacekeeping force riot suit"
	desc = "A mass produced semi-flexible polycarbonate body armor with decent padding to protect against melee attacks. Not as strong as riot suits typically issued to NT stations."
	color = "#55ff9b"

/obj/item/clothing/head/helmet/riot/raised/occupying
	name = "peacekeeping force riot helmet"
	desc = "It's a helmet specifically designed for the Peacekeeping force to protect against close range attacks."
	color = "#55ff9b"

// Peacekeeping force vest loadouts
// To note: each vest has 7 normal slots - Hopek
/obj/item/storage/belt/military/occupying_officer/ComponentInitialize() // Occupying Officer
	. = ..()
	new /obj/item/ammo_box/magazine/wt550m9/wtr(src)
	new /obj/item/ammo_box/magazine/wt550m9/wtr(src)
	new /obj/item/reagent_containers/hypospray/medipen(src)
	new /obj/item/restraints/handcuffs/cable/zipties(src)
	new /obj/item/restraints/handcuffs/cable/zipties(src)
	new /obj/item/reagent_containers/food/snacks/pizzaslice/pepperoni(src)
	new /obj/item/jawsoflife/jimmy(src)


/obj/item/storage/belt/military/occupying_commander/ComponentInitialize() // Occupying force Commander
	. = ..()
	new /obj/item/ammo_box/magazine/wt550m9/wtr(src)
	new /obj/item/ammo_box/magazine/wt550m9/wtr(src)
	new /obj/item/reagent_containers/hypospray/medipen(src)
	new /obj/item/reagent_containers/food/snacks/pizzaslice/pepperoni(src)
	new /obj/item/megaphone(src)
	new /obj/item/restraints/handcuffs/cable/zipties(src)
	new /obj/item/jawsoflife/jimmy(src)

/obj/item/storage/belt/military/occupying_heavy
	color = "#55ff9b"

/obj/item/storage/belt/military/occupying_heavy/ComponentInitialize() // Occupying Riot Officer
	. = ..()
	new /obj/item/restraints/legcuffs/bola/energy(src)
	new /obj/item/restraints/legcuffs/bola/energy(src)
	new /obj/item/restraints/handcuffs(src)
	new /obj/item/reagent_containers/food/snacks/pizzaslice/pepperoni(src)
	new /obj/item/reagent_containers/hypospray/medipen(src)
	new /obj/item/flashlight/flare(src)
	new /obj/item/jawsoflife/jimmy(src)


/datum/outfit/occupying
	name = "Peacekeeping Officer"
	uniform = /obj/item/clothing/under/rank/security/grey/amber/occupying
	suit = /obj/item/clothing/suit/armor/vest/alt
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/color/black
	ears = /obj/item/radio/headset/headset_cent/alt
	mask = /obj/item/clothing/mask/cigarette/lit
	belt = /obj/item/storage/belt/military/occupying_officer
	suit_store = /obj/item/gun/ballistic/automatic/wt550/occupying
	back = /obj/item/melee/baton/cattleprod/tactical
	head = /obj/item/clothing/head/helmet/sec/occupying
	l_pocket = /obj/item/reagent_containers/food/drinks/beer
	r_pocket = /obj/item/storage/box/fancy/cigarettes
	id = /obj/item/card/id/ert/occupying
	implants = list(/obj/item/implant/mindshield)
	

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
	W.update_label(W.registered_name, W.assignment)

	H.ignores_capitalism = TRUE // Yogs -- Lets the Peacekeeping force buy a damned smoke for christ's sake


/datum/outfit/occupying/commander
	name = "Peacekeeping force Commander"
	head = /obj/item/clothing/head/beret/sec/centcom/occupying
	belt = /obj/item/storage/belt/military/occupying_commander
	l_pocket = /obj/item/pinpointer/nuke
	r_pocket = /obj/item/lighter/greyscale // everyone has ciggies, only commander has a lighter
	mask = /obj/item/clothing/mask/cigarette/cigar/cohiba
	glasses = /obj/item/clothing/glasses/hud/security

/datum/outfit/occupying/heavy
	name = "Peacekeeping Riot Officer"
	belt = /obj/item/storage/belt/military/occupying_heavy
	back = /obj/item/shield/riot
	l_pocket = /obj/item/clothing/ears/earmuffs
	r_pocket = /obj/item/tank/internals/emergency_oxygen/engi
	head = /obj/item/clothing/head/helmet/riot/raised/occupying
	suit = /obj/item/clothing/suit/armor/riot/occupying
	mask = /obj/item/clothing/mask/breath/tactical
	suit_store = /obj/item/melee/baton/loaded 
	glasses = /obj/item/clothing/glasses/sunglasses 