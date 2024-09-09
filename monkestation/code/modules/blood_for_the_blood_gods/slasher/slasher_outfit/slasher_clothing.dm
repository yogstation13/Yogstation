/obj/item/clothing/shoes/slasher_shoes
	name = "Industrial Boots"
	icon_state = "jackboots"
	inhand_icon_state = "jackboots"
	clothing_traits = list(TRAIT_NO_SLIP_ALL)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/clothing/shoes/slasher_shoes/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, "slasher")

/obj/item/clothing/mask/gas/slasher
	name = "slasher's gas mask"
	desc = "A close-fitting sealed gas mask, this one seems to be protruding some kind of dark aura."

	icon = 'icons/obj/clothing/head/utility.dmi'
	worn_icon = 'icons/mob/clothing/head/utility.dmi'
	icon_state = "welding"
	inhand_icon_state = "welding"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	slowdown = 1

/obj/item/clothing/mask/gas/slasher/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, "slasher")

/obj/item/clothing/mask/gas/slasher/adjustmask()
	return

/obj/item/clothing/suit/apron/slasher
	name = "butcher's apron"
	desc = "A brown butcher's apron, you can feel an aura of something dark radiating off of it."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	icon_state = "slasher"
	inhand_icon_state = null

/obj/item/clothing/suit/apron/slasher/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, "slasher")

/obj/item/clothing/under/color/random/slasher
	name = "butcher's jumpsuit"
	clothing_traits = list(TRAIT_NODROP)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

