/obj/item/clothing/suit/yogs/armor/chitinplate
	name = "chitin plate"
	desc = "A heavily protected and padded version of the bone armor, reinforced with chitin, sinew and bone."
	icon_state = "chitenplate"
	item_state = "chitenplate"
	blood_overlay_type = "armor"
	resistance_flags = FIRE_PROOF
	armor = list(melee = 65, bullet = 35, laser = 15, energy = 10, bomb = 35, fire = 50, bio = 0, rad = 0)
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS

/obj/item/clothing/suit/yogs/armor/rycliesarmour
	name = "war armour"
	desc = "Good for protecting your chest during war."
	icon_state = "rycliesarmour"
	item_state = "rycliesarmour"

/obj/item/clothing/suit/yogs/armor/namflakjacket
	name = "nam flak jacket"
	desc = "Good for protecting your chest from napalm and toolboxes!"
	icon_state = "namflakjacket"
	item_state = "namflakjacket"

/obj/item/clothing/suit/yogs/armor/redcoatcoat
	name = "redcoat coat"
	desc = "Security is coming! Security is coming! Also padded with kevlar for protection."
	icon_state = "red_coat_coat"
	item_state = "red_coat_coat"

/obj/item/clothing/suit/yogs/armor/secmiljacket
	name = "sec military jacket"
	desc = "Aviators not included. Now with extra padding!"
	icon_state = "secmiljacket"
	item_state = "secmiljacket"

/obj/item/clothing/suit/yogs/armor/hosjacket
	name = "head of security jacket"
	desc = "all the style of a jacket with all the protection of a armor vest!"
	icon_state = "hos_jacket"
	item_state = "hos_item"

/obj/item/clothing/suit/yogs/armor/wardenjacket
	name = "warden's black jacket"
	desc = "all the style of a jacket with all the protection of a armor vest!"
	icon_state = "warden_jacket"
	item_state = "warden_item"

/obj/item/clothing/suit/yogs/armor/germancoat
	name = "padded german coat"
	desc = "for those cold german winters or for those head of securitys that want to show their true colors."
	icon_state = "german_coat"
	item_state = "german_item"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 70, "acid" = 90)
	cold_protection = CHEST|GROIN|LEGS|ARMS
	heat_protection = CHEST|GROIN|LEGS|ARMS
	strip_delay = 80