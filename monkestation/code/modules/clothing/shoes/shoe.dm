/obj/item/clothing/shoes/phantom
	name = "phantom shoes"
	desc = "Excellent for when you need to do cool flashy flips."
	icon = 'monkestation/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/feet.dmi'
	icon_state = "phantom_shoes"

/obj/item/clothing/shoes/saints
	name = "saints sneakers"
	desc = "Officially branded Saints sneakers. Incredibly valuable!"
	icon = 'monkestation/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/feet.dmi'
	icon_state = "saints_shoes"

/obj/item/clothing/shoes/morningstar
	name = "morningstar boots"
	desc = "The most expensive boots on this station. Wearing them dropped the value by about 50%."
	icon = 'monkestation/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/feet.dmi'
	icon_state = "morningstar_shoes"

/obj/item/clothing/shoes/driscoll
	name = "driscoll boots"
	desc = "A special pair of leather boots, for those who dont need spurs"
	icon = 'monkestation/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/feet.dmi'
	icon_state = "driscoll_boots"

/obj/item/clothing/shoes/cowboyboots
	name = "cowboy boots"
	desc = "A standard pair of brown cowboy boots."
	icon = 'monkestation/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/feet.dmi'
	icon_state = "cowboyboots"

/obj/item/clothing/shoes/cowboyboots/black
	name = "black cowboy boots"
	desc = "A pair of black cowboy boots, pretty easy to scuff up."
	icon = 'monkestation/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/feet.dmi'
	icon_state = "cowboyboots_black"

/obj/item/clothing/shoes/crueltysquad_shoes
	name = "CSIJ level I combat boots"
	desc = "Boots specifically designed to fit into the CSIJ level I body armor."
	icon = 'monkestation/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/feet.dmi'
	icon_state = "crueltysquad_shoes"

/obj/item/clothing/shoes/costume_2021/infinity_shoes
	name = "infinity sneakers"
	desc = "Even for offbrand sneakers, these are outdated for the Kung Company."
	icon = 'monkestation/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/feet.dmi'
	icon_state = "infinity_shoes"

/obj/item/clothing/shoes/bb_slippers
	name = "bb slippers"
	desc = "Despite looking like they'd fall off at any moment, they seem to stay on perfectly."
	icon = 'monkestation/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/feet.dmi'
	icon_state = "bb_slippers"

/obj/item/clothing/shoes/civilprotection_boots
	name = "civil protection boots"
	desc = "for the officers chasing engineers."
	icon = 'monkestation/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/feet.dmi'
	icon_state = "civilprotection_boots"

/obj/item/clothing/shoes/civilprotection_boots/Initialize(mapload)//copied from jackboots (should these be a subtype of jackboots?)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/shoes)
	AddComponent(/datum/component/shoesteps/combine_boot_sounds)

//START HEELS

/obj/item/clothing/shoes/heels
	name = "heels"
	desc = "A both professional and stylish pair of footwear that are difficult to walk in."
	icon = 'monkestation/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/feet.dmi'
	icon_state = "heels"
	can_be_tied = FALSE
	greyscale_colors = "#39393f"
	greyscale_config = /datum/greyscale_config/heels
	greyscale_config_worn = /datum/greyscale_config/heels_worn
	greyscale_config_worn_digitigrade = /datum/greyscale_config/heels_worn/digitigrade
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/shoes/heels/syndicate
	name = "heels"
	desc = "A both professional and stylish pair of footwear that are shockingly comfortable to walk in. They have have been sharpened to allow them to be used as a rudimentary weapon."
	icon_state = "heels_syndi"
	hitsound = 'sound/weapons/bladeslice.ogg'
	strip_delay = 2 SECONDS
	force = 10
	throwforce = 15
	sharpness = SHARP_POINTY
	attack_verb_continuous = list("attacks", "slices", "slashes", "cuts", "stabs")
	attack_verb_simple = list("attack", "slice", "slash", "cut", "stab")
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_config_worn_digitigrade = null

/obj/item/clothing/shoes/heels/magician
	name = "magical heels"
	desc = "A pair of heels that seem to magically solve all the problems with walking in heels."
	icon_state = "heels_wiz"
	strip_delay = 2 SECONDS
	resistance_flags = FIRE_PROOF | ACID_PROOF
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_config_worn_digitigrade = null

/obj/item/clothing/shoes/heels/centcom
	name = "green heels"
	desc = "A stylish piece of corporate footwear, its ergonomic design makes it easier to both run and work in than the average pair of heels."
	icon_state = "heels_centcom"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_config_worn_digitigrade = null

/obj/item/clothing/shoes/heels/red
	name = "red heels"
	desc = "A pair of classy red heels."
	icon_state = "heels_red"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_config_worn_digitigrade = null

/obj/item/clothing/shoes/heels/blue
	name = "blue heels"
	desc = "A pair of classy blue heels."
	icon_state = "heels_blue"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_config_worn_digitigrade = null

/obj/item/clothing/shoes/heels/enviroheels
	name = "enviroheels"
	desc = "A pair of heels designed to function marginally better with envirosuits."
	icon_state = "enviroheels"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_config_worn_digitigrade = null

/obj/item/clothing/shoes/ballheels
	name = "ball heels"
	desc = "A stylish pair of footwear that are difficult to walk in, somehow you are expected to dance in these."
	icon = 'icons/obj/clothing/shoes.dmi'
	worn_icon = 'icons/mob/clothing/feet.dmi'
	icon_state = "ballheels"
	inhand_icon_state = "ballheels"
	can_be_tied = FALSE

//END HEELS
