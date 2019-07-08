/obj/item/clothing/head/yogs/goatpelt
	name = "goat pelt hat"
	desc = "Fuzzy and Warm!"
	icon_state = "goatpelt"
	item_state = "goatpelt"


/obj/item/clothing/head/yogs/goatpelt/king
	name = "king goat pelt hat"
	desc = "Fuzzy, Warm and Robust!"
	icon_state = "goatpelt"
	item_state = "goatpelt"
	color = "#ffd700"
	body_parts_covered = HEAD
	armor = list("melee" = 60, "bullet" = 55, "laser" = 55, "energy" = 45, "bomb" = 100, "bio" = 20, "rad" = 20, "fire" = 100, "acid" = 100)
	dog_fashion = null
	resistance_flags = FIRE_PROOF

/obj/item/clothing/head/yogs/goatpelt/king/equipped(mob/living/carbon/human/user, slot)
	..()
	if (slot == SLOT_HEAD)
		user.faction |= "goat"

/obj/item/clothing/head/yogs/goatpelt/king/dropped(mob/living/carbon/human/user)
	..()
	if (user.head == src)
		user.faction -= "goat"

/obj/item/clothing/head/helmet/juggernaut
	name = "Juggernaut Helmet"
	desc = "I...am...the...JUGGERNAUT!!!."
	alternate_worn_icon = 'yogstation/icons/mob/head.dmi'
	icon = 'yogstation/icons/obj/clothing/hats.dmi'
	icon_state = "juggernauthelm"
	item_state = "juggernauthelm"
	armor = list("melee" = 80, "bullet" = 80, "laser" = 50, "energy" = 50, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 40, "acid" = 90)
	strip_delay = 120
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flash_protect = TRUE
	obj_flags = IMMUTABLE_SLOW
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	slowdown = 1

/obj/item/clothing/head/yogs/whitecap
	name = "white cap"
	desc = "A white cap. For some reason it smells like metal."
	icon_state = "chernobyl"
	item_state = "chernobyl"

/obj/item/clothing/head/yogs/goatpope
	name = "goat pope hat"
	desc = "And on the seventh day King Goat said there will be cabbage!"
	alternate_worn_icon = 'yogstation/icons/mob/large-worn-icons/64x64/head.dmi'
	icon_state = "goatpope"
	item_state = "goatpope"
	worn_x_dimension = 64
	worn_y_dimension = 64
	resistance_flags = FLAMMABLE

/obj/item/clothing/head/yogs/goatpope/equipped(mob/living/carbon/human/user, slot)
	..()
	if (slot == SLOT_HEAD)
		user.faction |= "goat"
