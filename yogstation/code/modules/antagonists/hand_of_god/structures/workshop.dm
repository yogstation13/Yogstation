/obj/structure/destructible/hog_structure/item_maker/workshop
	name = "celestial workshop"
	desc = "a magical structure, capable of creating otherworldy objects"
	break_message = span_warning("the celestial workshop shatters into pieces!") 
	god_actions_add = list(/datum/hog_god_interaction/structure/overcharge, /datum/hog_god_interaction/structure/shield)
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_originalname = "workshop"
	max_integrity = 100
	products = list(/datum/hog_product/sword, /datum/hog_product/shield, /datum/hog_product/war_robe)

/datum/hog_product/sword
	name = "Cult sword"
	description = "A divine sword, that is a pretty robust weapon, and also can be upgraded to become even more powerfull."
	time_to_make = 30 SECONDS
	cost = 85
	result = /obj/item/hog_item/upgradeable/sword

/datum/hog_product/shield
	name = "Cult shield"
	description = "A magical shield, that is capable of blocking some of attacks, if is used by a believer."
	time_to_make = 20 SECONDS
	cost = 70
	result = /obj/item/hog_item/upgradeable/shield

/datum/hog_product/war_robe
	name = "Warrior Robe"
	description = "An armored magical robe."
	time_to_make = 50 SECONDS
	cost = 95
	result = /obj/item/clothing/suit/hooded/hog_robe_warrior

/datum/hog_god_interaction/targeted/construction/workshop
	name = "Construct a celestial workshop"
	description = "Construct a celestial workshop, that can produce combat items for your servants."
	cost = 160
	time_builded = 40 SECONDS
	warp_name = "celestial workshop"
	warp_description = "a pulsating mass of energy in a form of a strange looking machine"
	structure_type = /obj/structure/destructible/hog_structure/item_maker/workshop
	max_constructible_health = 100
	integrity_per_process = 6
	icon_name = "workshop_constructing"