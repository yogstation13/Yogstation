/obj/item/uplink/Russian
	name = "Russian Uplink"
	icon = 'icons/obj/radio.dmi'
	icon_state = "radio"
	desc = "A uplink used to transport items between various russian militairy has the soviet union insignia on the back."
	item_state = "walkietalkie"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	
  flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_SMALL


/obj/item/uplink/Russian/Initialize(mapload, owner, tc_amount = 10)
	. = ..()
	var/datum/component/uplink/hidden_uplink = GetComponent(/datum/component/uplink)
	hidden_uplink.name = "Russian Uplink"
