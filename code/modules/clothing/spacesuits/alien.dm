// Vox space gear (vaccuum suit, low pressure armour)
// Can't be equipped by any other species due to bone structure and vox cybernetics.

/obj/item/clothing/suit/space/vox
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/transforming/energy/sword, \
	/obj/item/restraints/handcuffs, /obj/item/tank/internals)
	armor = list(MELEE = 40, BULLET = 40, LASER = 30, ENERGY = 15, BOMB = 30, BIO = 30, RAD = 30, FIRE = 80, ACID = 85)
	icon = 'icons/obj/clothing/species/vox/suits.dmi'
	species_restricted = list("Vox")
	slowdown = 2

/obj/item/clothing/head/helmet/space/vox
	armor = list(MELEE = 40, BULLET = 40, LASER = 30, ENERGY = 15, BOMB = 30, BIO = 30, RAD = 30, FIRE = 80, ACID = 85)
	clothing_flags = STOPSPRESSUREDAMAGE
	flags_cover = HEADCOVERSEYES
	icon = 'icons/obj/clothing/species/vox/hats.dmi'
	species_restricted = list("Vox")
	sprite_sheets = list("Vox" = VOX_HEAD_FILE)

/obj/item/clothing/head/helmet/space/vox/pressure
	name = "alien helmet"
	icon_state = "vox-pressure"
	item_state = "vox-pressure"
	desc = "Hey, wasn't this a prop in \'The Abyss\'?"

/obj/item/clothing/suit/space/vox/pressure
	name = "alien pressure suit"
	icon_state = "vox-pressure"
	item_state = "vox-pressure"
	desc = "A huge, armoured, pressurized suit, designed for distinctly nonhuman proportions."

/obj/item/clothing/head/helmet/space/vox/carapace
	name = "alien visor"
	icon_state = "vox-carapace"
	item_state = "vox-carapace"
	desc = "A glowing visor, perhaps stolen from a depressed Cylon."

/obj/item/clothing/suit/space/vox/carapace
	name = "alien carapace armour"
	icon_state = "vox-carapace"
	item_state = "vox-carapace"
	desc = "An armoured, segmented carapace with glowing purple lights. It looks pretty run-down."
	slowdown = 1

/obj/item/clothing/head/helmet/space/vox/stealth
	name = "alien stealth helmet"
	icon_state = "vox-stealth"
	item_state = "vox-stealth"
	desc = "A smoothly contoured, matte-black alien helmet."

/obj/item/clothing/suit/space/vox/stealth
	name = "alien stealth suit"
	icon_state = "vox-stealth"
	item_state = "vox-stealth"
	desc = "A sleek black suit. It seems to have a tail, and is very heavy."

/obj/item/clothing/head/helmet/space/vox/medic
	name = "alien goggled helmet"
	icon_state = "vox-medic"
	item_state = "vox-medic"
	desc = "An alien helmet with enormous goggled lenses."

/obj/item/clothing/suit/space/vox/medic
	name = "alien armour"
	icon_state = "vox-medic"
	item_state = "vox-medic"
	desc = "An almost organic looking nonhuman pressure suit."
