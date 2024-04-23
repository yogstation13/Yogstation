/obj/machinery/mass_driver
	name = "mass driver"
	desc = "A miniaturized mass driver, the finest in hydraulic piston technology." // Imagine what an actual mass driver would look like
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "mass_driver"
	circuit = /obj/item/circuitboard/machine/mass_driver
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 50
	var/power = 1
	var/code = 1
	var/id = 1
	var/drive_range = 10
	var/power_per_obj = 500

/obj/machinery/mass_driver/Initialize(mapload)
	. = ..()
	wires = new /datum/wires/mass_driver(src)

/obj/machinery/mass_driver/Destroy()
	QDEL_NULL(wires)
	. = ..()

/obj/machinery/mass_driver/connect_to_shuttle(mapload, obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	id = "[port.shuttle_id]_[id]"

/obj/machinery/mass_driver/proc/drive(amount)
	if(stat & (BROKEN|NOPOWER) || panel_open)
		return
	use_power(power_per_obj)
	var/O_limit
	var/atom/target = get_edge_target_turf(src, dir)
	for(var/atom/movable/O in loc)
		if(!O.anchored || ismecha(O))	//Mechs need their launch platforms.
			if(ismob(O) && !isliving(O))
				continue
			O_limit++
			if(O_limit >= 20)
				audible_message(span_notice("[src] lets out a screech, it doesn't seem to be able to handle the load."))
				break
			use_power(power_per_obj)
			O.throw_at(target, drive_range * power, power)
	playsound(get_turf(src), 'sound/machines/mass_driver.ogg', 75)
	flick("mass_driver1", src)

/obj/machinery/mass_driver/attackby(obj/item/I, mob/living/user, params)

	if(is_wire_tool(I) && panel_open)
		wires.interact(user)
		return
	if(default_deconstruction_screwdriver(user, "mass_driveropen", "mass_driver", I))
		return
	if(default_change_direction_wrench(user, I))
		return
	if(default_deconstruction_crowbar(I))
		return

	return ..()

/obj/machinery/mass_driver/RefreshParts()
	. = ..()
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		drive_range += 10 * C.rating

/obj/machinery/mass_driver/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(stat & (BROKEN|NOPOWER) || panel_open)
		return
	drive()
