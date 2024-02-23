/obj/machinery/smartfridge
	icon = 'modular_dripstation/icons/obj/vending.dmi'
	var/light_mask = "smartfridge-light-mask"

/obj/machinery/smartfridge/update_overlays()
	. = ..()
	if(light_mask && !(stat & BROKEN) && powered())
		. += emissive_appearance(icon, light_mask, src)
	if(panel_open)
		. += mutable_appearance(icon, "[initial(icon_state)]-panel")
