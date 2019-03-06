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