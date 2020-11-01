/obj/machinery/chem_heater
	name = "chemical heater"
	density = TRUE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0b"
	use_power = IDLE_POWER_USE
	idle_power_usage = 40
	resistance_flags = FIRE_PROOF | ACID_PROOF
	circuit = /obj/item/circuitboard/machine/chem_heater
	var/obj/item/reagent_containers/beaker = null
	var/currentspeed = 2
	var/heater_speed = 2
	var/coil = 1
	var/on = FALSE

/obj/machinery/chem_heater/Destroy()
	QDEL_NULL(beaker)
	return ..()

/obj/machinery/chem_heater/handle_atom_del(atom/A)
	. = ..()
	if(A == beaker)
		beaker = null
		update_icon()

/obj/machinery/chem_heater/update_icon()
	icon_state = "mixer[beaker ? 1 : 0][on ? "a" : "b"]"

/obj/machinery/chem_heater/CtrlClick(mob/user)
	if(!user.canUseTopic(src, !issilicon(user)))
		return
	on = !on
	update_icon()

/obj/machinery/chem_heater/AltClick(mob/living/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	replace_beaker(user)
	return

/obj/machinery/chem_heater/proc/replace_beaker(mob/living/user, obj/item/reagent_containers/new_beaker)
	if(beaker)
		beaker.forceMove(drop_location())
		if(user && Adjacent(user) && !issiliconoradminghost(user))
			user.put_in_hands(beaker)
	if(new_beaker)
		beaker = new_beaker
	else
		beaker = null
	update_icon()
	return TRUE

/obj/machinery/chem_heater/RefreshParts()
  	heater_speed = 2
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		heater_speed *= M.rating

/obj/machinery/chem_heater/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user)) // x5 for maximum coil power
		. += "<span class='notice'>The status display reads: Heating reagents up to <b>[heater_speed*5]K</b> per cycle.<span>"

/obj/machinery/chem_heater/process()
	..()
	if(stat & NOPOWER)
		return
	if(on && beaker?.reagents.total_volume)
		currentspeed = heater_speed * coil
		beaker.reagents.adjust_thermal_energy(currentspeed * SPECIFIC_HEAT_DEFAULT * beaker.reagents.total_volume)
		beaker.reagents.handle_reactions()

/obj/machinery/chem_heater/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "mixer0b", "mixer0b", I))
		return

	if(default_deconstruction_crowbar(I))
		return

	if(istype(I, /obj/item/reagent_containers) && !(I.item_flags & ABSTRACT) && I.is_open_container())
		. = TRUE //no afterattack
		var/obj/item/reagent_containers/B = I
		if(!user.transferItemToLoc(B, src))
			return
		replace_beaker(user, B)
		to_chat(user, "<span class='notice'>You add [B] to [src].</span>")
		updateUsrDialog()
		update_icon()
		return
	return ..()

/obj/machinery/chem_heater/on_deconstruction()
	replace_beaker()
	return ..()

/obj/machinery/chem_heater/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemHeater", name)
		ui.open()

/obj/machinery/chem_heater/ui_data()
	var/data = list()
	data["isActive"] = on
	data["isBeakerLoaded"] = beaker ? 1 : 0

	data["currentTemp"] = beaker ? beaker.reagents.chem_temp : null
	data["beakerCurrentVolume"] = beaker ? beaker.reagents.total_volume : null
	data["beakerMaxVolume"] = beaker ? beaker.volume : null

	data["coil"] = coil
	data["coilheating"] = heater_speed

	var/beakerContents[0]
	if(beaker)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "volume" = R.volume))) // list in a list because Byond merges the first list...
	data["beakerContents"] = beakerContents
	return data

/obj/machinery/chem_heater/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("power")
			on = !on
			. = TRUE
			update_icon()
		if("eject")
			on = FALSE
			replace_beaker(usr)
			. = TRUE
		if("lower_coil")
			coil = clamp(coil-1, -5, 5)
		if("higher_coil")
			coil = clamp(coil+1, -5, 5)
