/// Badges: Like an accessory for your armor vest
/obj/item/badge
	name = "badge"
	desc = "A badge representing... something."
	icon = 'icons/obj/clothing/badges.dmi'
	icon_state = "badge"
	item_state = ""
	mob_overlay_icon = 'icons/mob/clothing/badges.dmi'
	w_class = WEIGHT_CLASS_TINY
	var/owner_string

/obj/item/badge/proc/try_attach(obj/item/clothing/suit/suit_target, mob/user)
	if(suit_target.attached_badge)
		to_chat(user, span_warning("There's already a badge on \the [suit_target]."))
		return FALSE
	suit_target.attached_badge = src
	forceMove(suit_target)
	layer = FLOAT_LAYER
	plane = FLOAT_PLANE
	transform *= 0.5 //halve the size so it doesn't overpower the under
	pixel_x += 8
	pixel_y -= 8
	suit_target.add_overlay(src)
	return TRUE

/obj/item/badge/proc/detach(obj/item/clothing/suit/suit_target, mob/user)
	transform *= 2
	pixel_x -= 8
	pixel_y += 8
	layer = initial(layer)
	plane = initial(plane)
	suit_target.cut_overlays()
	suit_target.attached_badge = null
	suit_target.badge_overlay = null

/obj/item/badge/examine(mob/user)
	. = ..()
	if(owner_string)
		. += span_notice("Property of [owner_string].")

/obj/item/badge/security
	name = "security badge"
	desc = "A badge representing a member of security's work on the force."
