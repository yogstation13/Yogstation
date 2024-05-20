/*
 * The 'fancy' path is for objects like donut boxes that show how many items are in the storage item on the sprite itself
 * .. Sorry for the shitty path name, I couldnt think of a better one.
 *
 * WARNING: var/icon_type is used for both examine text and sprite name. Please look at the procs below and adjust your sprite names accordingly
 *		TODO: Cigarette boxes should be ported to this standard
 *
 * Contains:
 *		Donut Box
 *		Egg Box
 *		Candle Box
 *		Cigarette Box
 *		Cigar Case
 *		Heart Shaped Box w/ Chocolates
 */

/obj/item/storage/fancy
	icon = 'icons/obj/food/containers.dmi'
	resistance_flags = FLAMMABLE
	var/icon_type = "donut"
	var/spawn_type = null
	var/fancy_open = FALSE
	var/can_toggle = TRUE //some things are always open like candles

/obj/item/storage/fancy/PopulateContents()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	for(var/i = 1 to STR.max_items)
		new spawn_type(src)

/obj/item/storage/fancy/update_icon_state()
	. = ..()
	if(fancy_open)
		icon_state = "[icon_type]box[contents.len]"
	else
		icon_state = "[icon_type]box"

/obj/item/storage/fancy/examine(mob/user)
	. = ..()
	if(fancy_open)
		if(length(contents) == 1)
			. += "There is one [icon_type] left."
		else
			. += "There are [contents.len <= 0 ? "no" : "[contents.len]"] [icon_type]s left."

/obj/item/storage/fancy/attack_self(mob/user)
	if(can_toggle)
		fancy_open = !fancy_open
		update_appearance(UPDATE_ICON)
	return ..()

/obj/item/storage/fancy/Exited()
	. = ..()
	fancy_open = TRUE
	update_appearance(UPDATE_ICON)

/obj/item/storage/fancy/Entered()
	. = ..()
	fancy_open = TRUE
	update_appearance(UPDATE_ICON)

#define DONUT_INBOX_SPRITE_WIDTH 3

/*
 * Donut Box
 */

/obj/item/storage/fancy/donut_box
	name = "donut box"
	desc = "Mmm. Donuts."
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "donutbox_inner"
	icon_type = "donut"
	spawn_type = /obj/item/reagent_containers/food/snacks/donut
	fancy_open = TRUE
	appearance_flags = KEEP_TOGETHER

/obj/item/storage/fancy/donut_box/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6
	STR.set_holdable(list(/obj/item/reagent_containers/food/snacks/donut))

/obj/item/storage/fancy/donut_box/PopulateContents()
	for(var/i in 1 to 6)
		new spawn_type(src)

/obj/item/storage/fancy/donut_box/PopulateContents()
	. = ..()
	update_appearance(UPDATE_ICON)

/obj/item/storage/fancy/donut_box/update_icon_state()
	. = ..()
	if(fancy_open)
		icon_state = "donutbox_inner"
	else
		icon_state = "donutbox"

/obj/item/storage/fancy/donut_box/update_overlays()
	. = ..()

	if (!fancy_open)
		return

	var/donuts = 0

	for (var/obj/item/reagent_containers/food/snacks/donut/donut in contents)

		. += image(icon = initial(icon), icon_state = donut.in_box_sprite(), pixel_x = donuts * DONUT_INBOX_SPRITE_WIDTH)
		donuts += 1

	. += image(icon = initial(icon), icon_state = "donutbox_top")

/obj/item/storage/fancy/donut_box/deadly
	spawn_type = /obj/item/reagent_containers/food/snacks/donut/deadly

#undef DONUT_INBOX_SPRITE_WIDTH
/*
 * Egg Box
 */

/obj/item/storage/fancy/egg_box
	icon = 'icons/obj/food/containers.dmi'
	item_state = "eggbox"
	icon_state = "eggbox"
	icon_type = "egg"
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	name = "egg box"
	desc = "A carton for containing eggs."
	spawn_type = /obj/item/reagent_containers/food/snacks/egg

/obj/item/storage/fancy/egg_box/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 12
	STR.set_holdable(list(/obj/item/reagent_containers/food/snacks/egg))

/obj/item/storage/fancy/egg_box/PopulateContents()
	for(var/i in 1 to 12)
		new /obj/item/reagent_containers/food/snacks/egg(src)

/*
 * Candle Box
 */

/obj/item/storage/fancy/candle_box
	name = "candle pack"
	desc = "A pack of red candles."
	icon = 'icons/obj/candle.dmi'
	icon_state = "candlebox5"
	icon_type = "candle"
	item_state = "candlebox5"
	throwforce = 2
	slot_flags = ITEM_SLOT_BELT
	spawn_type = /obj/item/candle
	fancy_open = TRUE
	can_toggle = FALSE


/obj/item/storage/fancy/candle_box/attack_self(mob_user)
	. = ..()
	update_appearance(UPDATE_ICON)

/obj/item/storage/fancy/candle_box/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 5

/obj/item/storage/fancy/candle_box/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/candle(src)


////////////
//CIG PACK//
////////////
/obj/item/storage/fancy/cigarettes
	name = "\improper Space Cigarettes packet"
	desc = "The most popular brand of cigarettes, sponsors of the Space Olympics."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cig"
	item_state = "cigpacket"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	slot_flags = ITEM_SLOT_BELT
	icon_type = "cigarette"
	spawn_type = /obj/item/clothing/mask/cigarette/space_cigarette
	age_restricted = TRUE
	///Do we not have our own handling for cig overlays?
	var/display_cigs = TRUE

/obj/item/storage/fancy/cigarettes/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6
	STR.set_holdable(list(/obj/item/clothing/mask/cigarette, /obj/item/lighter))

/obj/item/storage/fancy/cigarettes/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/clothing/mask/cigarette/space_cigarette(src)

/obj/item/storage/fancy/cigarettes/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click to extract contents.")

/obj/item/storage/fancy/cigarettes/AltClick(mob/living/carbon/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	var/obj/item/clothing/mask/cigarette/W = locate(/obj/item/clothing/mask/cigarette) in contents
	if(W && contents.len > 0)
		SEND_SIGNAL(src, COMSIG_TRY_STORAGE_TAKE, W, user)
		user.put_in_hands(W)
		contents -= W
		to_chat(user, span_notice("You take \a [W] out of the pack."))
	else
		to_chat(user, span_notice("There are no [icon_type]s left in the pack."))

/obj/item/storage/fancy/cigarettes/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)][contents.len ? null : "_empty"]"

/obj/item/storage/fancy/cigarettes/update_overlays()
	. = ..()
	if(!fancy_open)
		return

	. += "[icon_state]_open"

	if(!display_cigs)
		return

	var/cig_position = 1
	for(var/C in contents)
		var/use_icon_state = ""

		if(istype(C, /obj/item/lighter/greyscale))
			use_icon_state = "lighter_in"
		else if(istype(C, /obj/item/lighter))
			use_icon_state = "zippo_in"
		else
			use_icon_state = "cigarette"

		. += "[use_icon_state]_[cig_position]"
		cig_position++

/obj/item/storage/fancy/cigarettes/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!ismob(M))
		return
	var/obj/item/clothing/mask/cigarette/cig = locate(/obj/item/clothing/mask/cigarette) in contents
	if(cig)
		if(M == user && contents.len > 0 && !user.wear_mask)
			var/obj/item/clothing/mask/cigarette/W = cig
			SEND_SIGNAL(src, COMSIG_TRY_STORAGE_TAKE, W, M)
			M.equip_to_slot_if_possible(W, ITEM_SLOT_MASK)
			contents -= W
			to_chat(user, span_notice("You take \a [W] out of the pack."))
		else
			..()
	else
		to_chat(user, span_notice("There are no [icon_type]s left in the pack."))

/obj/item/storage/fancy/cigarettes/dromedaryco
	name = "\improper DromedaryCo packet"
	desc = "A packet of six imported DromedaryCo cancer sticks. A label on the packaging reads, \"Wouldn't a slow death make a change?\""
	icon_state = "dromedary"
	spawn_type = /obj/item/clothing/mask/cigarette/dromedary

/obj/item/storage/fancy/cigarettes/dromedaryco/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/clothing/mask/cigarette/dromedary(src)

/obj/item/storage/fancy/cigarettes/cigpack_uplift
	name = "\improper Uplift Smooth packet"
	desc = "Your favorite brand, now menthol flavored."
	icon_state = "uplift"
	spawn_type = /obj/item/clothing/mask/cigarette/uplift

/obj/item/storage/fancy/cigarettes/cigpack_uplift/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/clothing/mask/cigarette/uplift(src)

/obj/item/storage/fancy/cigarettes/cigpack_robust
	name = "\improper Robust packet"
	desc = "Smoked by the robust."
	icon_state = "robust"
	spawn_type = /obj/item/clothing/mask/cigarette/robust

/obj/item/storage/fancy/cigarettes/cigpack_robust/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/clothing/mask/cigarette/robust(src)

/obj/item/storage/fancy/cigarettes/cigpack_robustgold
	name = "\improper Robust Gold packet"
	desc = "Smoked by the truly robust."
	icon_state = "robustg"
	spawn_type = /obj/item/clothing/mask/cigarette/robustgold

/obj/item/storage/fancy/cigarettes/cigpack_robustgold/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/clothing/mask/cigarette/robustgold(src)

/obj/item/storage/fancy/cigarettes/cigpack_carp
	name = "\improper Carp Classic packet"
	desc = "Since 2313."
	icon_state = "carp"
	spawn_type = /obj/item/clothing/mask/cigarette/carp

/obj/item/storage/fancy/cigarettes/cigpack_carp/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/clothing/mask/cigarette/carp(src)

/obj/item/storage/fancy/cigarettes/cigpack_syndicate
	name = "cigarette packet"
	desc = "An obscure brand of cigarettes."
	icon_state = "syndie"
	spawn_type = /obj/item/clothing/mask/cigarette/syndicate

/obj/item/storage/fancy/cigarettes/cigpack_syndicate/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/clothing/mask/cigarette/syndicate(src)

/obj/item/storage/fancy/cigarettes/cigpack_midori
	name = "\improper Midori Tabako packet"
	desc = "You can't understand the runes, but the packet smells funny."
	icon_state = "midori"
	spawn_type = /obj/item/clothing/mask/cigarette/rollie/nicotine

/obj/item/storage/fancy/cigarettes/cigpack_midori/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/clothing/mask/cigarette/rollie/nicotine(src)

/obj/item/storage/fancy/cigarettes/cigpack_shadyjims
	name = "\improper Shady Jim's Super Slims packet"
	desc = "Is your weight slowing you down? Having trouble running away from gravitational singularities? Can't stop stuffing your mouth? Smoke Shady Jim's Super Slims and watch all that fat burn away. Guaranteed results!"
	icon_state = "shadyjim"
	spawn_type = /obj/item/clothing/mask/cigarette/shadyjims

/obj/item/storage/fancy/cigarettes/cigpack_shadyjims/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/clothing/mask/cigarette/shadyjims(src)

/obj/item/storage/fancy/cigarettes/cigpack_xeno
	name = "\improper Xeno Filtered packet"
	desc = "Loaded with 100% pure slime. And also nicotine."
	icon_state = "slime"
	spawn_type = /obj/item/clothing/mask/cigarette/xeno

/obj/item/storage/fancy/cigarettes/cigpack_xeno/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/clothing/mask/cigarette/xeno(src)

/obj/item/storage/fancy/cigarettes/cigpack_nonico
	name = "nicotine-free cigarette packet"
	desc = "A dull-looking pack of cigarettes."
	icon_state = "nonico"
	spawn_type = /obj/item/clothing/mask/cigarette/nonico

/obj/item/storage/fancy/cigarettes/cigpack_nonico/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/clothing/mask/cigarette/nonico(src)

/obj/item/storage/fancy/cigarettes/cigpack_cannabis
	name = "\improper Freak Brothers' Special packet"
	desc = "A label on the packaging reads, \"Endorsed by Phineas, Freddy and Franklin.\""
	icon_state = "midori"
	spawn_type = /obj/item/clothing/mask/cigarette/rollie/cannabis

/obj/item/storage/fancy/cigarettes/cigpack_cannabis/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/clothing/mask/cigarette/rollie/cannabis(src)

/obj/item/storage/fancy/cigarettes/cigpack_mindbreaker
	name = "\improper Leary's Delight packet"
	desc = "Banned in over 36 galaxies."
	icon_state = "shadyjim"
	spawn_type = /obj/item/clothing/mask/cigarette/rollie/mindbreaker

/obj/item/storage/fancy/cigarettes/cigpack_mindbreaker/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/clothing/mask/cigarette/rollie/mindbreaker(src)

/obj/item/storage/fancy/rollingpapers
	name = "rolling paper pack"
	desc = "A pack of Nanotrasen brand rolling papers."
	w_class = WEIGHT_CLASS_TINY
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cig_paper_pack"
	icon_type = "rolling paper"
	spawn_type = /obj/item/rollingpaper

/obj/item/storage/fancy/rollingpapers/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 10
	STR.set_holdable(list(/obj/item/rollingpaper))

/obj/item/storage/fancy/rollingpapers/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/rollingpaper(src)

/obj/item/storage/fancy/rollingpapers/update_overlays()
	. = ..()
	if(!contents.len)
		. += "[icon_state]_empty"

/////////////
//CIGAR BOX//
/////////////

/obj/item/storage/fancy/cigarettes/cigars
	name = "\improper premium cigar case"
	desc = "A case of premium cigars. Very expensive."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cigarcase"
	w_class = WEIGHT_CLASS_NORMAL
	icon_type = "premium cigar"
	spawn_type = /obj/item/clothing/mask/cigarette/cigar
	display_cigs = FALSE

/obj/item/storage/fancy/cigarettes/cigars/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 5
	STR.set_holdable(list(/obj/item/clothing/mask/cigarette/cigar))

/obj/item/storage/fancy/cigarettes/cigars/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/clothing/mask/cigarette/cigar(src)

/obj/item/storage/fancy/cigarettes/cigars/update_icon_state()
	. = ..()
	//reset any changes the parent call may have made
	icon_state = initial(icon_state)

/obj/item/storage/fancy/cigarettes/cigars/update_overlays()
	. = ..()
	if(!fancy_open)
		return
	var/cigar_position = 1 //generate sprites for cigars in the box
	for(var/obj/item/clothing/mask/cigarette/cigar/smokes in contents)
		. += "[smokes.icon_off]_[cigar_position]"
		cigar_position++

/obj/item/storage/fancy/cigarettes/cigars/cohiba
	name = "\improper Cohiba Robusto cigar case"
	desc = "A case of imported Cohiba cigars, renowned for their strong flavor. The warning label states that the cigar is extremely potent."
	icon_state = "cohibacase"
	spawn_type = /obj/item/clothing/mask/cigarette/cigar/cohiba

/obj/item/storage/fancy/cigarettes/cigars/cohiba/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/clothing/mask/cigarette/cigar/cohiba(src)

/obj/item/storage/fancy/cigarettes/cigars/havana
	name = "\improper premium Havanian cigar case"
	desc = "A case of classy Havanian cigars."
	icon_state = "cohibacase"
	spawn_type = /obj/item/clothing/mask/cigarette/cigar/havana

/obj/item/storage/fancy/cigarettes/cigars/havana/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/clothing/mask/cigarette/cigar/havana(src)

/*
 * Heart Shaped Box w/ Chocolates
 */

/obj/item/storage/fancy/heart_box
	name = "heart-shaped box"
	desc = "A heart-shaped box for holding tiny chocolates."
	icon = 'icons/obj/food/containers.dmi'
	item_state = "chocolatebox"
	icon_state = "chocolatebox"
	icon_type = "chocolate"
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	spawn_type = /obj/item/reagent_containers/food/snacks/tinychocolate

/obj/item/storage/fancy/heart_box/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 8
	STR.set_holdable(list(/obj/item/reagent_containers/food/snacks/tinychocolate))

/obj/item/storage/fancy/heart_box/PopulateContents()
	for(var/i in 1 to 8)
		new /obj/item/reagent_containers/food/snacks/tinychocolate(src)

//////////////
//NUGGET BOX//
//////////////
/obj/item/storage/fancy/nugget_box
	name = "nugget box"
	desc = "A cardboard box used for holding chicken nuggies."
	icon = 'icons/obj/food/containers.dmi'
	item_state = "nuggetbox"
	icon_state = "nuggetbox"
	icon_type = "nugget"
	spawn_type = /obj/item/reagent_containers/food/snacks/nugget

/obj/item/storage/fancy/nugget_box/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6
	STR.set_holdable(list(/obj/item/reagent_containers/food/snacks/nugget))

/obj/item/storage/fancy/nugget_box/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/reagent_containers/food/snacks/nugget(src)


