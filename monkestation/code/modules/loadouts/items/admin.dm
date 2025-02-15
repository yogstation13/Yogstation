/datum/loadout_item/neck/admin_cloak
	name = "Admin Cloak"
	requires_purchase = FALSE
	admin_only = TRUE
	item_path = /obj/item/clothing/neck/admincloak


/datum/loadout_item/neck/mentor_cloak
	name = "Mentor Cloak"
	requires_purchase = FALSE
	mentor_only = TRUE
	item_path = /obj/item/clothing/neck/mentorcloak

/datum/loadout_item/neck/mentor_cloak/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only, override_items)
	if(!visuals_only)
		spawn_in_backpack(outfit, item_path, equipper)
