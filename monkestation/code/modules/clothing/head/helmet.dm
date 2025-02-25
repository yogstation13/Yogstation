/obj/item/clothing/head/helmet
	var/hud_attachable = FALSE
	var/obj/item/clothing/glasses/hud/hud_glasses = null
	var/datum/atom_hud/our_hud = null
	var/hud_trait = null

/obj/item/clothing/head/helmet/equipped(mob/living/carbon/human/user, slot)
	..()
	if(!(slot & ITEM_SLOT_HEAD))
		return
	give_hud(user)

/obj/item/clothing/head/helmet/dropped(mob/living/carbon/human/user)
	..()
	if(!istype(user) || user.head != src)
		return
	remove_hud(user)

/obj/item/clothing/head/helmet/proc/give_hud(mob/living/carbon/human/user)
	if(!hud_glasses)
		return
	if(hud_glasses.hud_type)
		our_hud = GLOB.huds[hud_glasses.hud_type]
		our_hud.show_to(user)
	if(hud_glasses.hud_trait)
		hud_trait = hud_glasses.hud_trait
		ADD_TRAIT(user, hud_trait, HELMET_TRAIT)

/obj/item/clothing/head/helmet/proc/remove_hud(mob/living/carbon/human/user)
	if(our_hud)
		our_hud.hide_from(user)
		our_hud = null
	if(hud_trait)
		REMOVE_TRAIT(user, hud_trait, HELMET_TRAIT)
		hud_trait = null

/obj/item/clothing/head/helmet/attackby(obj/item/I, mob/user, params)
	if(hud_attachable && !hud_glasses && istype(I, /obj/item/clothing/glasses/hud))
		user.transferItemToLoc(I, src)
		hud_glasses = I

		balloon_alert(user, "attached [I]")

		var/mob/living/carbon/human/wearer = loc
		if (istype(wearer) && wearer.head == src)
			give_hud(wearer)
	else
		return ..()

/obj/item/clothing/head/helmet/screwdriver_act(mob/living/user, obj/item/tool)
	if(hud_attachable && hud_glasses)
		tool?.play_tool_sound(src)
		balloon_alert(user, "unscrewed [hud_glasses]")

		var/obj/item/to_remove = hud_glasses

		// The forcemove here will call exited on the glasses, and automatically update our references / etc
		to_remove.forceMove(drop_location())
		if(Adjacent(user) && !issilicon(user))
			user.put_in_hands(to_remove)
	else
		return ..()

/obj/item/clothing/head/helmet/Exited(atom/movable/gone, direction)
	if (gone == hud_glasses)
		hud_glasses = null

		var/mob/living/carbon/human/wearer = loc
		if (istype(wearer) && wearer.head == src)
			remove_hud(wearer)
	else
		return ..()

/obj/item/clothing/head/helmet/sec
	hud_attachable = TRUE

/obj/item/clothing/head/helmet/alt
	hud_attachable = TRUE

/obj/item/clothing/head/helmet/examine(mob/user)
	. = ..()
	if(hud_glasses)
		. += "It has \a [hud_glasses] [hud_attachable ? "mounted on it with a few <b>screws</b>" : "permanently mounted on it"]."
	else if (hud_attachable)
		. += "It has a mounting point for some <b>HUD</b> glasses."
