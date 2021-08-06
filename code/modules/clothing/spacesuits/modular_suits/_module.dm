/obj/item/hardsuit_upgrade
	name = "broken hardsuit upgrade"
	desc = "File a bug report"
	var/enabled = FALSE

/obj/item/hardsuit_upgrade/proc/passive_effect(suit)
	return

/obj/item/hardsuit_upgrade/proc/removal_effect(suit)
	return

/obj/item/hardsuit_upgrade/proc/can_toggle()
	return TRUE

/obj/item/hardsuit_upgrade/proc/toggle(suit)
	if(!can_toggle())
		return
	enabled = !enabled
	if(enabled)
		active_effect(suit)
	else
		disable_effect(suit)

/obj/item/hardsuit_upgrade/proc/active_effect(suit)
	return

/obj/item/hardsuit_upgrade/proc/disable_effect(suit)
	return
