/obj/item/reagent_containers/food/snacks/canned
	name = "Can of nothing"
	desc = "Cry about it"
	icon = 'icons/obj/food/food.dmi'
	icon_state = null
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	obj_flags = UNIQUE_RENAME
	tastes = list("nothing" = 1)
	var/is_opened = FALSE
	var/has_opened_icon = FALSE

/obj/item/reagent_containers/food/snacks/canned/attack_self(mob/living/user)
	if(!is_opened)
		playsound(src.loc, 'sound/items/poster_ripped.ogg', 50, 1)
		if(HAS_TRAIT(user, TRAIT_CLUMSY))
			to_chat(user, span_warning("You rip open the [src]!"))
		else
			to_chat(user, span_notice("You open the [src]."))
		if(has_opened_icon)
			icon_state += "_opened"
		opened = TRUE
	. = ..()


/obj/item/reagent_containers/food/snacks/canned/attack(mob/living/M, mob/user, def_zone)
	if(!is_opened)
		to_chat(user, span_warning("[src] hasn't been opened!"))
		return FALSE
	return ..()

/obj/item/reagent_containers/food/snacks/canned/examine(mob/user)
	. = ..()
	if(!is_opened)
		+= "[src] isn't opened!"
	else
		+= "[src] is opened!"