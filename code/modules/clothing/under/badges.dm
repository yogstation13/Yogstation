/// Badges: Like an accessory for your armor vest
/obj/item/badge
	name = "badge"
	desc = "A badge representing... something."
	icon = 'icons/obj/clothing/badges.dmi'
	icon_state = "sec1"
	item_state = ""
	mob_overlay_icon = 'icons/mob/clothing/badges.dmi'
	w_class = WEIGHT_CLASS_TINY
	/// State of worn icon
	var/accessory_state = "worn_chest_gold"
	/// Owner's name, which will be attached to the examine
	var/owner_string

/obj/item/badge/proc/try_attach(obj/item/clothing/suit/suit_target, mob/user)
	if (suit_target.attached_badge)
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
	SET_PLANE_IMPLICIT(src, initial(plane))
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

/obj/item/badge/security/officer1
	name = "security badge (Corporal)"
	icon_state = "sec1"

/obj/item/badge/security/officer2
	name = "security badge (Sergeant)"
	icon_state = "sec2"

/obj/item/badge/security/officer3
	name = "security badge (Staff Sergeant)"
	icon_state = "sec3"

/obj/item/badge/security/warden1
	name = "security badge (2nd Lieutenant)"
	icon_state = "warden1"
	accessory_state = "worn_chest_silver"

/obj/item/badge/security/warden2
	name = "security badge (1st Lieutenant)"
	icon_state = "warden2"

/obj/item/badge/security/warden3
	name = "security badge (Brig Captain)"
	icon_state = "warden3"

/obj/item/badge/security/hos1
	name = "security badge (Major)"
	icon_state = "hos1"

/obj/item/badge/security/hos2
	name = "security badge (Colonel)"
	icon_state = "hos2"

/obj/item/badge/security/hos3
	name = "security badge (Commissioner)"
	icon_state = "hos3"

/obj/item/badge/security/det1
	name = "security badge (Deputy)"
	icon_state = "det1"
	accessory_state = "worn_belt_gold"

/obj/item/badge/security/det2
	name = "security badge (Investigator)"
	icon_state = "det2"
	accessory_state = "worn_belt_gold"

/obj/item/badge/security/det3
	name = "security badge (Chief Inspector)"
	icon_state = "det3"
	accessory_state = "worn_belt_gold"
