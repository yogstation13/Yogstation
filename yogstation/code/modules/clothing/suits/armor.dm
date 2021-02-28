/obj/item/clothing/suit/yogs/armor/chitinplate
	name = "chitin plate"
	desc = "A heavily protected and padded version of the bone armor, reinforced with chitin, sinew and bone."
	icon_state = "chitenplate"
	item_state = "chitenplate"
	blood_overlay_type = "armor"
	resistance_flags = FIRE_PROOF
	armor = list(melee = 65, bullet = 35, laser = 15, energy = 10, bomb = 35, fire = 50, bio = 0, rad = 0)
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS
	allowed = list(/obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman) // allows ling armor to carry the usual space suit tanks.

/obj/item/clothing/suit/armor/vest/rycliesarmour
	name = "war armour"
	desc = "Good for protecting your chest during war."
	alternate_worn_icon = 'yogstation/icons/mob/suit.dmi'
	icon = 'yogstation/icons/obj/clothing/suits.dmi'
	icon_state = "rycliesarmour"
	item_state = "rycliesarmour"

/obj/item/clothing/suit/armor/vest/namflakjacket
	name = "nam flak jacket"
	desc = "Good for protecting your chest from napalm and toolboxes!"
	alternate_worn_icon = 'yogstation/icons/mob/suit.dmi'
	icon = 'yogstation/icons/obj/clothing/suits.dmi'
	icon_state = "namflakjacket"
	item_state = "namflakjacket"

/obj/item/clothing/suit/armor/vest/redcoatcoat
	name = "redcoat coat"
	desc = "Security is coming! Security is coming! Also padded with kevlar for protection."
	alternate_worn_icon = 'yogstation/icons/mob/suit.dmi'
	icon = 'yogstation/icons/obj/clothing/suits.dmi'
	icon_state = "red_coat_coat"
	item_state = "red_coat_coat"

/obj/item/clothing/suit/armor/vest/secmiljacket
	name = "sec military jacket"
	desc = "Aviators not included. Now with extra padding!"
	alternate_worn_icon = 'yogstation/icons/mob/suit.dmi'
	icon = 'yogstation/icons/obj/clothing/suits.dmi'
	icon_state = "secmiljacket"
	item_state = "secmiljacket"

/obj/item/clothing/suit/armor/vest/hosjacket
	name = "head of security jacket"
	desc = "all the style of a jacket with all the protection of a armor vest!"
	alternate_worn_icon = 'yogstation/icons/mob/suit.dmi'
	icon = 'yogstation/icons/obj/clothing/suits.dmi'
	icon_state = "hos_jacket"
	item_state = "hos_item"

/obj/item/clothing/suit/armor/vest/wardenjacket
	name = "warden's black jacket"
	desc = "all the style of a jacket with all the protection of a armor vest!"
	alternate_worn_icon = 'yogstation/icons/mob/suit.dmi'
	icon = 'yogstation/icons/obj/clothing/suits.dmi'
	icon_state = "warden_jacket"
	item_state = "warden_item"

/obj/item/clothing/suit/armor/hos/germancoat
	name = "padded german coat"
	desc = "for those cold german winters or for those head of securitys that want to show their true colors."
	alternate_worn_icon = 'yogstation/icons/mob/suit.dmi'
	icon = 'yogstation/icons/obj/clothing/suits.dmi'
	icon_state = "german_coat"
	item_state = "german_item"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 70, "acid" = 90)
	cold_protection = CHEST|GROIN|LEGS|ARMS
	heat_protection = CHEST|GROIN|LEGS|ARMS
	strip_delay = 80

/obj/item/clothing/suit/armor/vest/sovietcoat
	name = "soviet coat"
	desc = "Glory to Arstotzka! Now with padding protection!"
	alternate_worn_icon = 'yogstation/icons/mob/suit.dmi'
	icon = 'yogstation/icons/obj/clothing/suits.dmi'
	icon_state = "soviet_coat"
	item_state = "soviet_item"

/obj/item/clothing/suit/armor/vest/rurmcoat
	name = "russian officer coat"
	desc = "Papers please. Now with padding protection!"
	alternate_worn_icon = 'yogstation/icons/mob/suit.dmi'
	icon = 'yogstation/icons/obj/clothing/suits.dmi'
	icon_state = "ru_rmcoat"
	item_state = "ru_rmcoat"

/obj/item/clothing/suit/armor/heavy/juggernaut
	name = "Juggernaut Suit"
	desc = "I...am...the...JUGGERNAUT!!!"
	alternate_worn_icon = 'yogstation/icons/mob/suit.dmi'
	icon = 'yogstation/icons/obj/clothing/suits.dmi'
	icon_state = "juggernaut"
	item_state = "juggernaut"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS|FEET
	armor = list("melee" = 80, "bullet" = 80, "laser" = 50, "energy" = 50, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 40, "acid" = 90)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	cold_protection = CHEST|GROIN|LEGS|ARMS|FEET
	heat_protection = CHEST|GROIN|LEGS|ARMS|FEET
	strip_delay = 120
	slowdown = 1
	obj_flags = IMMUTABLE_SLOW
	flags_inv = HIDESHOES|HIDEJUMPSUIT