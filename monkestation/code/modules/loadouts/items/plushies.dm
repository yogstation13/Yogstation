GLOBAL_LIST_INIT(loadout_plushies, generate_loadout_items(/datum/loadout_item/plushies))

/datum/loadout_item/plushies
	category = LOADOUT_ITEM_PLUSHIES
	can_be_named = TRUE
/datum/loadout_item/plushies/pre_equip_item(datum/outfit/outfit, datum/outfit/outfit_important_for_life, mob/living/carbon/human/equipper, visuals_only = FALSE)  // these go in the backpack
	return FALSE
/datum/loadout_item/plushies/bee
	name = "Bee Plushie"
	item_path = /obj/item/toy/plush/beeplushie

/datum/loadout_item/plushies/carp
	name = "Carp Plushie"
	item_path = /obj/item/toy/plush/carpplushie

/datum/loadout_item/plushies/lizard_greyscale
	name = "Greyscale Lizard Plushie"
	item_path = /obj/item/toy/plush/lizard_plushie

/datum/loadout_item/plushies/moth
	name = "Moth Plushie"
	item_path = /obj/item/toy/plush/moth

/datum/loadout_item/plushies/narsie
	name = "Nar'sie Plushie"
	item_path = /obj/item/toy/plush/narplush
	restricted_roles = list(JOB_CHAPLAIN)

/datum/loadout_item/plushies/nukie
	name = "Nukie Plushie"
	item_path = /obj/item/toy/plush/nukeplushie

/datum/loadout_item/plushies/peacekeeper
	name = "Peacekeeper Plushie"
	item_path = /obj/item/toy/plush/pkplush

/datum/loadout_item/plushies/plasmaman
	name = "Plasmaman Plushie"
	item_path = /obj/item/toy/plush/plasmamanplushie

/datum/loadout_item/plushies/ratvar
	name = "Ratvar Plushie"
	item_path = /obj/item/toy/plush/ratplush
	restricted_roles = list(JOB_CHAPLAIN)

/datum/loadout_item/plushies/rouny
	name = "Rouny Plushie"
	item_path = /obj/item/toy/plush/rouny

/datum/loadout_item/plushies/snake
	name = "Snake Plushie"
	item_path = /obj/item/toy/plush/snakeplushie

/datum/loadout_item/plushies/slime
	name = "Slime Plushie"
	item_path = /obj/item/toy/plush/slimeplushie

/datum/loadout_item/plushies/bubble
	name = "Bubblegum Plushie"
	item_path = /obj/item/toy/plush/bubbleplush

/datum/loadout_item/plushies/goat
	name = "Strange Goat Plushie"
	item_path = /obj/item/toy/plush/goatplushie

/datum/loadout_item/plushies/knight
	name = "Knight Plushie"
	item_path = /obj/item/toy/plush/knightplush

/datum/loadout_item/plushies/turnip
	name = "Turnip Plushie"
	item_path = /obj/item/toy/plush/turnipplush

/datum/loadout_item/plushies/tinywitch
	name = "Tiny Witch Plush"
	item_path = /obj/item/toy/plush/tinywitchplush

/datum/loadout_item/plushies/chefomancer
	name = "Chef-o-Mancer Plush"
	item_path = /obj/item/toy/plush/chefomancer

/datum/loadout_item/plushies/tyria
	name = "Tyria Plush"
	item_path = /obj/item/toy/plush/moth/tyriaplush

/datum/loadout_item/plushies/ook
	name = "Ook Plush"
	item_path = /obj/item/toy/plush/moth/ookplush

/datum/loadout_item/plushies/ducky_plush
	name = "Ducky Plush"
	item_path = /obj/item/toy/plush/duckyplush

/datum/loadout_item/plushies/sammi_plush
	name = "Sammi Plush"
	item_path = /obj/item/toy/plush/sammiplush

/datum/loadout_item/plushies/cirno_plush
	name = "Cirno Plush"
	item_path = /obj/item/toy/plush/cirno_plush

/datum/loadout_item/plushies/cirno_ballin
	name = "Cirno Ballin"
	item_path = /obj/item/toy/plush/cirno_plush/ballin
	requires_purchase = FALSE
	ckeywhitelist = list("dwasint")

/datum/loadout_item/plushies/durrcell
	name = "Durrcell Plush"
	item_path = /obj/item/toy/plush/durrcell
/*
/datum/loadout_item/plushies/Eeble
	name = "Eeble Plushie"
	item_path = /obj/item/toy/plush/Eeble
*/
/datum/loadout_item/plushies/big_bad_wolf
	name = "Big And Will Be Bad Wolf Plushie"
	item_path = /obj/item/toy/plush/lobotomy/big_bad_wolf

/datum/loadout_item/plushies/scorched_girl
	name = "Scorched Girl Plushie"
	item_path = /obj/item/toy/plush/lobotomy/scorched
