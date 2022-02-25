/obj/item/clothing/shoes/yogs/fuzzy_slippers
	name = "fuzzy bunny slippers"
	desc = "No animals were harmed in the making of these fuzzy slippers."
	icon_state = "fuzzyslippers"
	item_state = "fuzzyslippers"

/obj/item/clothing/shoes/yogs/chitintreads // Whats funny about these is that they require something only ashwalkers have to make but ashwalkers cant even wear em heh
	name = "chitin boots"
	desc = "Compact boots crafted from a weaver's chitin with interlacing sinew."
	icon_state = "chitentreads"
	item_state = "chitentreads"
	body_parts_covered = LEGS|FEET
	resistance_flags = FIRE_PROOF
	armor = list(melee = 35, bullet = 35, laser = 0, energy = 10, bomb = 25, bio = 0, rad = 0)

/obj/item/clothing/shoes/clown_shoes/scaryclown
	name = "scary clown shoes"
	desc = "Clown shoes often seen being worn by sewer clowns."
	icon = 'yogstation/icons/obj/clothing/shoes.dmi'
	alternate_worn_icon = 'yogstation/icons/mob/feet.dmi'
	icon_state = "scaryclownshoes"
	item_state = "scaryclownshoes"

/obj/item/clothing/shoes/clown_shoes/beeshoes
	name = "bee shoes"
	desc = "It's hip to wear bees."
	icon = 'yogstation/icons/obj/clothing/shoes.dmi'
	alternate_worn_icon = 'yogstation/icons/mob/feet.dmi'
	icon_state = "bee_shoes"
	item_state = "bee_shoes"

/obj/item/clothing/shoes/yogs/namboots
	name = "nam boots"
	desc = "Come on, you sons of bitches, do you want to live forever?!?!"
	icon_state = "namboots"
	item_state = "namboots"
	strip_delay = 50
	equip_delay_other = 50
	resistance_flags = NONE
	permeability_coefficient = 0.05 //Thick soles, and covers the ankle
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/shoes

/obj/item/clothing/shoes/yogs/fire_crocs
	name = "fire crocs"
	desc = "You are now the coolest kid on the station."
	icon = 'icons/obj/clothing/shoes.dmi'
	alternate_worn_icon = 'icons/mob/feet.dmi'
	icon_state = "fire_crocs"
	item_state = "fire_crocs"