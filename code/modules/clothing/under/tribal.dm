// Ashwalker Clothes
/obj/item/clothing/under/tribal
	has_sensor = NO_SENSORS
	can_adjust = FALSE
	worn_icon = 'icons/mob/clothing/uniform/tribal.dmi'

/obj/item/clothing/under/tribal/chestwrap
	name = "loincloth and chestwrap"
	desc = "A poorly sewn dress made of leather."
	icon_state = "chestwrap"
	body_parts_covered = CHEST|GROIN
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/tribal/raider_leather
	name = "scavenged rags"
	desc = "A porly made outfit made of scrapped materials."
	icon_state = "raider_leather"
	item_state = "raider_leather"
	armor = list(MELEE = 5, FIRE = 5)
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/tribal/plated
	name = "metal plated rags"
	desc = "Thin metal bolted over poorly tanned leather."
	icon_state = "tribal"
	item_state = "tribal"
	body_parts_covered = CHEST|GROIN|ARMS
	armor = list(MELEE = 5)

/obj/item/clothing/under/tribal/ash_robe
	name = "tribal robes"
	desc = "A robe from the ashlands. This one seems to be for common tribespeople."
	icon_state = "robe_liz"
	item_state = "robe_liz"
	fitted = NO_FEMALE_UNIFORM
	body_parts_covered = CHEST|GROIN

/obj/item/clothing/under/tribal/ash_robe/young
	name = "tribal rags"
	desc = "Rags from Lavaland, coated with light ash. This one seems to be for the juniors of a tribe."
	icon_state = "tribalrags"

/obj/item/clothing/under/tribal/ash_robe/hunter
	name = "hunter tribal rags"
	desc = "A robe from the ashlands. This one seems to be for hunters."
	icon_state = "hhunterrags"
	item_state = "hhunterrags"

/obj/item/clothing/under/tribal/ash_robe/chief
	name = "chief tribal rags"
	desc = "Rags from Lavaland, coated with heavy ash. This one seems to be for the elders of a tribe."
	icon_state = "chiefrags"
	item_state = "chiefrags"

/obj/item/clothing/under/tribal/ash_robe/shaman
	name = "shaman tribal rags"
	desc = "Rags from Lavaland, drenched with ash, it has fine jewel coated bones sewn around the neck. This one seems to be for the shaman of a tribe."
	icon_state = "shamanrags"
	item_state = "shamanrags"

/obj/item/clothing/under/tribal/ash_robe/tunic
	name = "tribal tunic"
	desc = "A tattered red tunic of reddened fabric."
	icon_state = "caesar_clothes"
	item_state = "caesar_clothes"

/obj/item/clothing/under/tribal/ash_robe/dress
	name = "tribal dress"
	desc = "A tattered dress of white fabric."
	icon_state = "cheongsam_s"
	item_state = "cheongsam_s"

/obj/item/clothing/under/tribal/ash_robe/hunter/jungle
	name = "primal rags"
	desc = "Light primal rags that are fashionable and practical, while still maximizing photosynthesis capability for plantpeople."
