/obj/item/uplink/Russian
	name = "Russian Uplink"
	desc = "A uplink used to transport items between various russian militairy has the soviet union insignia on the back."

/obj/item/uplink/Russian/Initialize(mapload, owner, tc_amount = 10)
	. = ..()
	var/datum/component/uplink/hidden_uplink = GetComponent(/datum/component/uplink)
	hidden_uplink.name = "Russian Uplink"
