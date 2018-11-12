/obj/structure/closet/bluespace
	name = "bluespace locker"

/obj/structure/closet/bluespace/proc/get_other_locker()
	return SSbluespace_locker.internal_locker

/obj/structure/closet/bluespace/open()
	var/obj/structure/closet/other = get_other_locker()
	if(!other)
		return ..()
	if(!opened)
		. = ..()
		other.close()
		dump_contents()

/obj/structure/closet/bluespace/close()
	var/obj/structure/closet/other = get_other_locker()
	if(!other)
		return ..()
	if(opened)
		. = ..()
		other.contents += contents
		other.open()

/obj/structure/closet/bluespace/internal
	name = "bluespace locker portal"
	icon_state = null
	desc = ""
	cutting_tool = null
	can_weld_shut = FALSE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/structure/closet/bluespace/internal/Initialize()
	if(SSbluespace_locker.internal_locker && SSbluespace_locker.internal_locker != src)
		qdel(src)
		return
	SSbluespace_locker.internal_locker = src
	..()

/obj/structure/closet/bluespace/internal/get_other_locker()
	return SSbluespace_locker.external_locker

/obj/structure/closet/bluespace/internal/can_open(user)
	var/obj/structure/closet/other = get_other_locker()
	if(!other)
		return FALSE
	if(!other.opened)
		return TRUE
	return other.can_close(user)
/obj/structure/closet/bluespace/internal/can_close(user)
	var/obj/structure/closet/other = get_other_locker()
	if(!other || other.opened)
		return TRUE
	return other.can_open(user)

/obj/structure/closet/bluespace/internal/tool_interact(obj/item/W, mob/user)
	return

/obj/structure/closet/bluespace/internal/attack_hand(mob/living/user)
	var/obj/structure/closet/other = get_other_locker()
	if(!other)
		return ..()
	if(!other.opened && (other.welded || other.locked))
		if(ismovableatom(other.loc))
			user.changeNext_move(CLICK_CD_BREAKOUT)
			user.last_special = world.time + CLICK_CD_BREAKOUT
			var/atom/movable/AM = other.loc
			AM.relay_container_resist(user, other)
			return

		//okay, so the closet is either welded or locked... resist!!!
		user.changeNext_move(CLICK_CD_BREAKOUT)
		user.last_special = world.time + CLICK_CD_BREAKOUT
		other.visible_message("<span class='warning'>[other] begins to shake violently!</span>")
		to_chat(user, "<span class='notice'>You start pushing the door open... (this will take about [DisplayTimeText(other.breakout_time)].)</span>")
		if(do_after(user,(other.breakout_time), target = src))
			if(!user || user.stat != CONSCIOUS || other.opened || (!other.locked && !other.welded))
				return
			//we check after a while whether there is a point of resisting anymore and whether the user is capable of resisting
			other.bust_open()
			user.visible_message("<span class='danger'>[user] successfully broke out of [other]!</span>",
								"<span class='notice'>You successfully break out of [other]!</span>")
		else
			if(!other.opened) //so we don't get the message if we resisted multiple times and succeeded.
				to_chat(user, "<span class='warning'>You fail to break out of [other]!</span>")
	else
		return ..()

/obj/structure/closet/bluespace/internal/update_icon()
	cut_overlays()
	var/obj/structure/closet/other = get_other_locker()
	if(!other)
		other = src
	var/mutable_appearance/masked_icon = mutable_appearance('yogstation/icons/obj/closet.dmi', "bluespace_locker_mask")
	masked_icon.appearance_flags = KEEP_TOGETHER
	var/mutable_appearance/masking_icon = mutable_appearance(other.icon, other.icon_state)
	masking_icon.blend_mode = BLEND_MULTIPLY
	masked_icon.add_overlay(masking_icon)
	//add_overlay(image('yogstation/icons/obj/closet.dmi', "bluespace_locker_frame"))
	add_overlay(masked_icon)
	if(!opened)
		layer = OBJ_LAYER
		if(other.icon_door)
			add_overlay(image(other.icon, "[other.icon_door]_door"))
		else
			add_overlay(image(other.icon, "[other.icon_state]_door"))
	else
		layer = BELOW_OBJ_LAYER
		if(other.icon_door_override)
			add_overlay(image(other.icon, "[other.icon_door]_open"))
		else
			add_overlay(image(other.icon, "[other.icon_state]_open"))

/obj/structure/closet/bluespace/external/Initialize()
	if(SSbluespace_locker.external_locker && SSbluespace_locker.external_locker != src)
		qdel(src)
		return
	SSbluespace_locker.external_locker = src
	..()

/obj/structure/closet/bluespace/external/Destroy()
	SSbluespace_locker.external_locker = null
	SSbluespace_locker.bluespaceify_random_locker()
	return ..()

/obj/structure/closet/bluespace/external/can_open()
	if(welded || locked)
		return FALSE
	return TRUE
