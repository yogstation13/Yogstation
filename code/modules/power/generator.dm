/obj/machinery/power/generator
	name = "thermoelectric generator"
	desc = "It's a high efficiency thermoelectric generator."
	icon = 'icons/obj/machines/thermoelectric.dmi'
	icon_state = "teg-unassembled"
	density = TRUE
	use_power = NO_POWER_USE
	integrity_failure = 75

	var/obj/machinery/atmospherics/components/binary/circulator/cold_circ
	var/obj/machinery/atmospherics/components/binary/circulator/hot_circ

	var/lastgen = 0
	var/lastgenlev = -1

	var/internal_heat_cap = 1000 //needs experimantal data
	var/internal_temp = T0C
	var/powermodifier = 0.3

/obj/machinery/power/generator/Initialize(mapload)
	. = ..()
	find_circs()
	connect_to_network()
	SSair.atmos_machinery += src
	update_icon()
	component_parts = list(new /obj/item/circuitboard/machine/generator)

/obj/machinery/power/generator/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/simple_rotation,ROTATION_ALTCLICK | ROTATION_CLOCKWISE | ROTATION_COUNTERCLOCKWISE | ROTATION_VERBS )

/obj/machinery/power/generator/Destroy()
	kill_circs()
	SSair.atmos_machinery -= src
	return ..()

/obj/machinery/power/generator/update_icon()
	cut_overlays()
	SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)

	if(stat & (BROKEN))
		icon_state = "teg-broken"
		return
	if(hot_circ && cold_circ)
		icon_state = "teg-assembled"
	else
		icon_state = "teg-unassembled"
		if(panel_open)
			add_overlay("teg-panel")
		return
		
	if(!powernet)
		add_overlay("teg-nogrid")
	if(stat & (NOPOWER))
		return 
	else
		var/L = min(round(lastgenlev/100000),11)
		if(L != 0)
			SSvis_overlays.add_vis_overlay(src, icon, "teg-op[L]", ABOVE_LIGHTING_LAYER, ABOVE_LIGHTING_PLANE, dir)

#define GENRATE 800		// generator output coefficient from Q

/obj/machinery/power/generator/process_atmos()

	if(!cold_circ || !hot_circ)
		return

	if(powernet)
		var/datum/gas_mixture/cold_air = cold_circ.return_transfer_air()		//circulators give us air that is moving through
		var/datum/gas_mixture/hot_air = hot_circ.return_transfer_air()

		if(cold_air && hot_air)

			var/cold_air_heat_cap = cold_air.heat_capacity()	// not sure if this isnt pointless
			var/hot_air_heat_cap = hot_air.heat_capacity()

			var/cold_temp = cold_air.return_temperature()
			var/hot_temp = hot_air.return_temperature()

			if((hot_temp - cold_temp) > 0 && cold_air_heat_cap > 0 && hot_air_heat_cap > 0)

				//air moving trough equalises temperature with it subsection
				var/cold_subsection_temp = (cold_air_heat_cap * cold_temp + internal_heat_cap * internal_temp) / (internal_heat_cap + cold_air_heat_cap)	
				var/hot_subsection_temp = (hot_air_heat_cap * hot_temp + internal_heat_cap * internal_temp) / (internal_heat_cap + hot_air_heat_cap)

				hot_air.set_temperature(hot_subsection_temp)	// cooled / heated air gets spit back out
				cold_air.set_temperature(cold_subsection_temp)

				var/efficiency = 0.65

				//how much energy do we have stored in temperature differetial
				var/energy_transfer = (hot_subsection_temp - cold_subsection_temp)*internal_heat_cap

				//produce electricity
				lastgen += (energy_transfer*efficiency) * powermodifier
				lastgen = max(lastgen, 0)

				//transfer rest of energy into waste heat/chill
				internal_temp = cold_subsection_temp + energy_transfer * (1 - efficiency) / (internal_heat_cap * 2)

				//add_avail(lastgen) This is done in process now
		// update icon overlays only if displayed level has changed

		if(hot_air)
			var/datum/gas_mixture/hot_circ_air1 = hot_circ.airs[1]
			hot_circ_air1.merge(hot_air)

		if(cold_air)
			var/datum/gas_mixture/cold_circ_air1 = cold_circ.airs[1]
			cold_circ_air1.merge(cold_air)

	update_icon()

	src.updateDialog()

/obj/machinery/power/generator/process()
	//Setting this number higher just makes the change in power output slower, it doesnt actualy reduce power output cause **math**
	var/power_output = round(lastgen / 10)
	add_avail(power_output)
	lastgenlev = power_output
	lastgen -= power_output
	lastgen = max(lastgen, 0)
	..()

/obj/machinery/power/generator/proc/get_menu(include_link = TRUE)
	var/t = ""
	if(!powernet)
		t += span_bad("Unable to connect to the power network!")
	else if(cold_circ && hot_circ)
		var/datum/gas_mixture/cold_circ_air1 = cold_circ.airs[1]
		var/datum/gas_mixture/cold_circ_air2 = cold_circ.airs[2]
		var/datum/gas_mixture/hot_circ_air1 = hot_circ.airs[1]
		var/datum/gas_mixture/hot_circ_air2 = hot_circ.airs[2]

		t += "<div class='statusDisplay'>"

		t += "Output: [DisplayPower(lastgenlev)]"

		t += "<BR>"

		t += "<B><font color='blue'>Cold loop</font></B><BR>"
		t += "Temperature Inlet: [round(cold_circ_air2.return_temperature(), 0.1)] K / Outlet: [round(cold_circ_air1.return_temperature(), 0.1)] K<BR>"
		t += "Pressure Inlet: [round(cold_circ_air2.return_pressure(), 0.1)] kPa /  Outlet: [round(cold_circ_air1.return_pressure(), 0.1)] kPa<BR>"

		t += "<B><font color='red'>Hot loop</font></B><BR>"
		t += "Temperature Inlet: [round(hot_circ_air2.return_temperature(), 0.1)] K / Outlet: [round(hot_circ_air1.return_temperature(), 0.1)] K<BR>"
		t += "Pressure Inlet: [round(hot_circ_air2.return_pressure(), 0.1)] kPa / Outlet: [round(hot_circ_air1.return_pressure(), 0.1)] kPa<BR>"

		t += "</div>"
	else if(!hot_circ && cold_circ)
		t += span_bad("Unable to locate hot circulator!")
	else if(hot_circ && !cold_circ)
		t += span_bad("Unable to locate cold circulator!")
	else
		t += span_bad("Unable to locate any parts!")
	if(include_link)
		t += "<BR><A href='?src=[REF(src)];close=1'>Close</A>"

	return t

/obj/machinery/power/generator/ui_interact(mob/user)
	. = ..()
	var/datum/browser/popup = new(user, "teg", "Thermo-Electric Generator", 460, 300)
	popup.set_content(get_menu())
	popup.open()

/obj/machinery/power/generator/Topic(href, href_list)
	if(..())
		return
	if( href_list["close"] )
		usr << browse(null, "window=teg")
		usr.unset_machine()
		return FALSE
	return TRUE

/obj/machinery/power/generator/proc/find_circs()
	kill_circs()
	var/list/circs = list()
	var/obj/machinery/atmospherics/components/binary/circulator/C
	var/circpath = /obj/machinery/atmospherics/components/binary/circulator
	if(dir == NORTH || dir == SOUTH)
		C = locate(circpath) in get_step(src, EAST)
		if(C && C.dir == WEST && C.anchored && !(C.stat &(BROKEN)) && !C.panel_open)
			circs += C

		C = locate(circpath) in get_step(src, WEST)
		if(C && C.dir == EAST && C.anchored && !(C.stat &(BROKEN)) && !C.panel_open)
			circs += C

	else
		C = locate(circpath) in get_step(src, NORTH)
		if(C && C.dir == SOUTH && C.anchored && !(C.stat &(BROKEN)) && !C.panel_open)
			circs += C

		C = locate(circpath) in get_step(src, SOUTH)
		if(C && C.dir == NORTH && C.anchored && !(C.stat &(BROKEN)) && !C.panel_open)
			circs += C

	if(circs.len == 2)
		for(C in circs)
			if(C.mode == CIRCULATOR_COLD && !cold_circ)
				cold_circ = C
				C.generator = src
			else if(C.mode == CIRCULATOR_HOT && !hot_circ)
				hot_circ = C
				C.generator = src
		if(!hot_circ || !cold_circ)
			kill_circs()
			return 3
	return circs.len

/obj/machinery/power/generator/wrench_act(mob/living/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)
		return

	if(!panel_open) //connect/disconnect circulators
		if(!anchored)
			to_chat(user, span_warning("Anchor [src] before trying to connect the circulators!"))
			return TRUE
		else
			if(hot_circ && cold_circ)
				to_chat(user, span_notice("You start removing the circulators..."))
				if(I.use_tool(src, user, 30, volume=50))
					kill_circs()
					update_icon()
					to_chat(user, span_notice("You disconnect [src]'s circulator links."))
					playsound(src, 'sound/misc/box_deploy.ogg', 50)
				return TRUE

			to_chat(user, span_notice("You attempt to attach the circulators..."))
			if(I.use_tool(src, user, 30, volume=50))
				switch(find_circs())
					if(0)
						to_chat(user, span_warning("No circulators found!"))
					if(1)
						to_chat(user, span_warning("Only one circulator found!"))
					if(2)
						to_chat(user, span_notice("You connect [src]'s circulator links."))
						playsound(src, 'sound/misc/box_deploy.ogg', 50)
						return TRUE
					if(3)
						to_chat(user, span_warning("Both circulators are the same mode!"))
				return TRUE

	anchored = !anchored
	I.play_tool_sound(src)
	if(!anchored)
		kill_circs()
	connect_to_network()
	to_chat(user, span_notice("You [anchored?"secure":"unsecure"] [src]."))
	update_icon()
	return TRUE

/obj/machinery/power/generator/screwdriver_act(mob/user, obj/item/I)
	if(..())
		return TRUE
	if(user.a_intent == INTENT_HARM)
		return

	if(hot_circ && cold_circ)
		to_chat(user, span_warning("Disconnect the circulators first!"))
		return TRUE
	panel_open = !panel_open
	I.play_tool_sound(src)
	to_chat(user, span_notice("You [panel_open?"open":"close"] the panel on [src]."))
	update_icon()
	return TRUE

/obj/machinery/power/generator/crowbar_act(mob/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)
		return

	if(anchored)
		to_chat(user, span_warning("[src] is anchored!"))
		return TRUE
	else if(!panel_open)
		to_chat(user, span_warning("Open the panel first!"))
		return TRUE
	else
		default_deconstruction_crowbar(I)
		return TRUE

/obj/machinery/power/generator/on_deconstruction()
	kill_circs()

/obj/machinery/power/generator/proc/kill_circs()
	if(hot_circ)
		hot_circ.generator = null
		hot_circ.update_icon()
		hot_circ = null
	if(cold_circ)
		cold_circ.generator = null
		cold_circ.update_icon()
		cold_circ = null

/obj/machinery/power/generator/obj_break(damage_flag)
	kill_circs()
	..()
	
