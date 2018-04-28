
// A collection of pre-set uplinks, for admin spawns.
<<<<<<< HEAD
/obj/item/radio/uplink/Initialize(mapload, _owner, _tc_amount = 20)
=======
/obj/item/device/radio/uplink/Initialize(mapload, _owner, _tc_amount = 20)
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	. = ..()
	icon_state = "radio"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	AddComponent(/datum/component/uplink, _owner, FALSE, TRUE, null, _tc_amount)

<<<<<<< HEAD
/obj/item/radio/uplink/nuclear/Initialize()
=======
/obj/item/device/radio/uplink/nuclear/Initialize()
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	. = ..()
	GET_COMPONENT(hidden_uplink, /datum/component/uplink)
	hidden_uplink.set_gamemode(/datum/game_mode/nuclear)

<<<<<<< HEAD
/obj/item/radio/uplink/clownop/Initialize()
=======
/obj/item/device/radio/uplink/clownop/Initialize()
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	. = ..()
	GET_COMPONENT(hidden_uplink, /datum/component/uplink)
	hidden_uplink.set_gamemode(/datum/game_mode/nuclear/clown_ops)

<<<<<<< HEAD
/obj/item/multitool/uplink/Initialize(mapload, _owner, _tc_amount = 20)
=======
/obj/item/device/multitool/uplink/Initialize(mapload, _owner, _tc_amount = 20)
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	. = ..()
	AddComponent(/datum/component/uplink, _owner, FALSE, TRUE, null, _tc_amount)

/obj/item/pen/uplink/Initialize(mapload, _owner, _tc_amount = 20)
	. = ..()
	AddComponent(/datum/component/uplink)
	traitor_unlock_degrees = 360

<<<<<<< HEAD
/obj/item/radio/uplink/old
	name = "dusty radio"
	desc = "A dusty looking radio."

/obj/item/radio/uplink/old/Initialize(mapload, _owner, _tc_amount = 10)
=======
/obj/item/device/radio/uplink/old
	name = "dusty radio"
	desc = "A dusty looking radio."

/obj/item/device/radio/uplink/old/Initialize(mapload, _owner, _tc_amount = 10)
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	. = ..()
	GET_COMPONENT(hidden_uplink, /datum/component/uplink)
	hidden_uplink.name = "dusty radio"
