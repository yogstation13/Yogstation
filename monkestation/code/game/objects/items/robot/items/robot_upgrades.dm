/obj/item/borg/upgrade/uwu
	name = "cyborg UwU-speak \"upgrade\""
	desc = "As if existence as an artificial being wasn't torment enough for the unit OR the crew."
	icon_state = "cyborg_upgrade"

/obj/item/borg/upgrade/uwu/action(mob/living/silicon/robot/robutt, user = usr)
	. = ..()
	if(.)
		robutt.AddComponentFrom(REF(src), /datum/component/fluffy_tongue)

/obj/item/borg/upgrade/uwu/deactivate(mob/living/silicon/robot/robutt, user = usr)
	. = ..()
	if(.)
		robutt.RemoveComponentSource(REF(src), /datum/component/fluffy_tongue)
