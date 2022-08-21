/obj/item/storage/tacklebox
	name = "tackle box"
	desc = "Holds all your fishing items!"
	icon = 'yogstation/icons/obj/storage.dmi'
	icon_state = "tacklebox_blue"
	item_state = "toolbox_default"
	lefthand_file = 'icons/mob/inhands/equipment/toolbox_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/toolbox_righthand.dmi'
	flags_1 = CONDUCT_1
	force = 8
	throwforce = 8
	throw_speed = 2
	throw_range = 6
	w_class = WEIGHT_CLASS_HUGE
	materials = list(/datum/material/iron = 500)
	attack_verb = list("robusted")
	hitsound = 'sound/weapons/smash.ogg'
	drop_sound = 'sound/items/handling/toolbox_drop.ogg'
	pickup_sound =  'sound/items/handling/toolbox_pickup.ogg'
	custom_materials = list(/datum/material/iron = 500)

/obj/item/storage/tacklebox/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 8
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 24
	STR.set_holdable(list(
		/obj/item/twohanded/fishingrod/collapsable,
		/obj/item/reagent_containers/food/snacks/bait,
		/obj/item/reagent_containers/food/snacks/chum
	))

/obj/item/storage/tacklebox/syndicate
	name = "suspicious tackle box"
	desc = "Holds all your suspicious fishing items!"
	icon_state = "tackebox_syndicate"
	item_state = "toolbox_syndi"
	syndicate = TRUE

/obj/item/storage/tacklebox/syndicate/PopulateContents()
	new /obj/item/reagent_containers/food/snacks/bait/type(src)
	new /obj/item/reagent_containers/food/snacks/bait/type(src)
	new /obj/item/reagent_containers/food/snacks/bait/type(src)
	
