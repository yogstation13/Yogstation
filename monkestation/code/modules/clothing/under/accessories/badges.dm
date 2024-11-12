/obj/item/clothing/accessory/pride/accessory_equipped(obj/item/clothing/under/clothes, mob/living/user)
	if(HAS_TRAIT(user, TRAIT_PRIDE_PIN))
		user.add_mood_event("pride_pin", /datum/mood_event/pride_pin)

/obj/item/clothing/accessory/pride/accessory_dropped(obj/item/clothing/under/clothes, mob/living/user)
	user.clear_mood_event("pride_pin")
