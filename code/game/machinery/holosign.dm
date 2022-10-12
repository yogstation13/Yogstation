////////////////////HOLOSIGN///////////////////////////////////////
/obj/machinery/holosign
	name = "holosign"
	desc = "Small wall-mounted holographic projector"
	icon = 'icons/obj/holosign.dmi'
	icon_state = "sign_off"
	layer = 4
	var/lit = FALSE
	var/id = null
	var/on_icon = "sign_on"

/obj/machinery/holosign/proc/toggle()
	if(!is_operational())
		lit = FALSE
	else
		lit = !lit
	update_icon()

/obj/machinery/holosign/update_icon()
	if(!lit)
		icon_state = initial(icon_state)
		set_light(0)
	else
		icon_state = on_icon
		set_light(1, 0.5, l_color = COLOR_BLUE_LIGHT)

/obj/machinery/holosign/power_change()
	if(!is_operational())
		lit = FALSE
	update_icon()

/obj/machinery/holosign/surgery
	name = "surgery holosign"
	desc = "Small wall-mounted holographic projector. This one reads SURGERY."
	on_icon = "surgery"
