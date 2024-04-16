// TURBINE v2 AKA rev4407 Engine reborn!

// How to use it? - Mappers
//
// This is a very good power generating mechanism. All you need is a blast furnace with soaring flames and output.
// Not everything is included yet so the turbine can run out of fuel quiet quickly. The best thing about the turbine is that even
// though something is on fire that passes through it, it won't be on fire as it passes out of it. So the exhaust fumes can still
// containt unreacted fuel - plasma and oxygen that needs to be filtered out and re-routed back. This of course requires smart piping
// For a computer to work with the turbine the compressor requires a comp_id matching with the turbine computer's id. This will be
// subjected to a change in the near future mind you. Right now this method of generating power is a good backup but don't expect it
// become a main power source unless some work is done. Have fun. At 50k RPM it generates 60k power. So more than one turbine is needed!
//
// - Numbers
//
// Example setup	 S - sparker
//					 B - Blast doors into space for venting
// *BBB****BBB*		 C - Compressor
// S    CT    *		 T - Turbine
// * ^ *  * V *		 D - Doors with firedoor
// **|***D**|**      ^ - Fuel feed (Not vent, but a gas outlet)
//   |      |        V - Suction vent (Like the ones in atmos
//


/obj/machinery/power/compressor
	name = "compressor"
	desc = "The compressor stage of a gas turbine generator."
	icon = 'icons/obj/atmospherics/components/turbine.dmi'
	icon_state = "compressor"
	density = TRUE
	resistance_flags = FIRE_PROOF
	can_atmos_pass = ATMOS_PASS_DENSITY
	use_power = NO_POWER_USE // powered by gas flow
	circuit = /obj/item/circuitboard/machine/power_compressor
	var/obj/machinery/power/turbine/turbine
	var/datum/gas_mixture/gas_contained
	var/turf/inturf
	var/starter = 0
	var/rpm = 0
	var/rpmtarget = 0
	var/capacity = 1e6
	var/comp_id = 0
	var/efficiency
	var/intake_ratio = 0.1 // might add a way to adjust this in-game later

/obj/machinery/power/compressor/Destroy()
	SSair.stop_processing_machine(src)
	if (turbine && turbine.compressor == src)
		turbine.compressor = null
	var/turf/T = get_turf(src)
	if(T)
		T.assume_air(gas_contained)
		air_update_turf()
		playsound(T, 'sound/effects/spray.ogg', 10, 1, -3)
	turbine = null
	return ..()

/obj/machinery/power/turbine
	name = "gas turbine generator"
	desc = "A gas turbine used for backup power generation."
	icon = 'icons/obj/atmospherics/components/turbine.dmi'
	icon_state = "turbine"
	density = TRUE
	resistance_flags = FIRE_PROOF
	can_atmos_pass = ATMOS_PASS_DENSITY
	use_power = NO_POWER_USE // powered by gas flow
	circuit = /obj/item/circuitboard/machine/power_turbine
	var/opened = 0
	var/obj/machinery/power/compressor/compressor
	var/turf/outturf
	var/lastgen = 0
	var/productivity = 1

/obj/machinery/power/turbine/Destroy()
	SSair.stop_processing_machine(src)
	if (compressor && compressor.turbine == src)
		compressor.turbine = null
	compressor = null
	return ..()

/obj/machinery/computer/turbine_computer
	name = "gas turbine control computer"
	desc = "A computer to remotely control a gas turbine."
	icon_screen = "turbinecomp"
	icon_keyboard = "tech_key"
	circuit = /obj/item/circuitboard/computer/turbine_computer
	var/obj/machinery/power/compressor/compressor
	var/id = 0

// the inlet stage of the gas turbine electricity generator

/obj/machinery/power/compressor/Initialize(mapload)
	. = ..()
	SSair.start_processing_machine(src)
	// The inlet of the compressor is the direction it faces
	gas_contained = new
	inturf = get_step(src, dir)
	locate_machinery()
	if(!turbine)
		atom_break()


#define COMPFRICTION 5e5


/obj/machinery/power/compressor/locate_machinery()
	if(turbine)
		return
	turbine = locate() in get_step(src, get_dir(inturf, src))
	if(turbine)
		turbine.locate_machinery()

/obj/machinery/power/compressor/multitool_act(mob/living/user, obj/item/multitool/tool)
	multitool_set_buffer(user, tool, src)
	user.balloon_alert(user, "saved to buffer")
	return TRUE

/obj/machinery/power/compressor/RefreshParts()
	var/E = 0
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		E += M.rating
	efficiency = E / 6

/obj/machinery/power/compressor/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Efficiency at <b>[efficiency*100]%</b>.")

/obj/machinery/power/compressor/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, initial(icon_state), initial(icon_state), I))
		return

	if(default_change_direction_wrench(user, I))
		turbine = null
		inturf = get_step(src, dir)
		locate_machinery()
		if(turbine)
			to_chat(user, span_notice("Turbine connected."))
			stat &= ~BROKEN
		else
			to_chat(user, span_alert("Turbine not connected."))
			atom_break()
		return

	default_deconstruction_crowbar(I)

/obj/machinery/power/compressor/process(delta_time)
	return

/obj/machinery/power/compressor/process_atmos(delta_time)
	cut_overlays()

	// RPM function to include compression friction - be advised that too low/high of a compfriction value can make things screwy
	rpm -= 1
	rpm = (0.9 * rpm) + (0.1 * rpmtarget)
	rpm = min(rpm, (COMPFRICTION*efficiency)/2)
	rpm = max(0, rpm - (rpm*rpm)/(COMPFRICTION*efficiency))

	if(!turbine || (turbine.stat & BROKEN))
		starter = FALSE

	if(stat & BROKEN || panel_open)
		starter = FALSE

	if(!starter)
		rpmtarget = 0
		return

	var/datum/gas_mixture/environment = inturf.return_air()
	var/external_pressure = environment.return_pressure()
	var/pressure_delta = external_pressure - gas_contained.return_pressure()

	// Equalize the gas between the environment and the internal gas mix
	if(pressure_delta > 0)
		var/datum/gas_mixture/removed = environment.remove_ratio((1 - ((1 - intake_ratio)**delta_time)) * pressure_delta / (external_pressure * 2)) // silly math to keep it consistent with delta_time
		gas_contained.merge(removed)
		inturf.air_update_turf()

	if(rpm>50000)
		add_overlay(mutable_appearance(icon, "comp-o4", FLY_LAYER))
	else if(rpm>10000)
		add_overlay(mutable_appearance(icon, "comp-o3", FLY_LAYER))
	else if(rpm>2000)
		add_overlay(mutable_appearance(icon, "comp-o2", FLY_LAYER))
	else if(rpm>500)
		add_overlay(mutable_appearance(icon, "comp-o1", FLY_LAYER))
	 //TODO: DEFERRED

// These are crucial to working of a turbine - the stats modify the power output. TurbGenQ modifies how much raw energy can you get from
// rpms, TurbGenG modifies the shape of the curve - the lower the value the less straight the curve is.

#define TURBGENQ 100000
#define TURBGENG 0.5

/obj/machinery/power/turbine/Initialize(mapload)
	. = ..()
	SSair.start_processing_machine(src)
	// The outlet is pointed at the direction of the turbine component
	outturf = get_step(src, dir)
	locate_machinery()
	if(!compressor)
		atom_break()
	connect_to_network()

/obj/machinery/power/turbine/RefreshParts()
	var/P = 0
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		P += C.rating
	productivity = P / 6

/obj/machinery/power/turbine/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>The status display reads: Productivity at <b>[productivity*100]%</b>.<span>"

/obj/machinery/power/turbine/locate_machinery()
	if(compressor)
		return
	compressor = locate() in get_step(src, get_dir(outturf, src))
	if(compressor)
		compressor.locate_machinery()

/obj/machinery/power/turbine/multitool_act(mob/living/user, obj/item/multitool/tool)
	if(!compressor)
		user.balloon_alert(user, "no compressor!")
		return TRUE
	multitool_set_buffer(user, tool, compressor)
	user.balloon_alert(user, "saved to buffer")
	return TRUE

/obj/machinery/power/turbine/process(delta_time)
	add_avail(lastgen) // add power in process() so it doesn't update power output separately from the rest of the powernet (bad)

/obj/machinery/power/turbine/process_atmos(delta_time)
	if(!compressor)
		stat = BROKEN

	if((stat & BROKEN) || panel_open)
		return
	cut_overlays()

	// This is the power generation function. If anything is needed it's good to plot it in EXCEL before modifying
	// the TURBGENQ and TURBGENG values

	lastgen = ((compressor.rpm / TURBGENQ)**TURBGENG) * TURBGENQ * productivity

	var/output_blocked = TRUE
	if(!isclosedturf(outturf))
		output_blocked = FALSE
		for(var/atom/A in outturf)
			if(!CANATMOSPASS(A, outturf, FALSE))
				output_blocked = TRUE
				break

	if(!output_blocked)
		var/datum/gas_mixture/environment = outturf.return_air()
		var/internal_pressure = compressor.gas_contained.return_pressure()
		var/pressure_delta = internal_pressure - environment.return_pressure()

		// Equalize the gas between the internal gas mix and the environment
		if(pressure_delta > 0)
			var/datum/gas_mixture/removed = compressor.gas_contained.remove_ratio(pressure_delta / (internal_pressure * 2))
			outturf.assume_air(removed)
			outturf.air_update_turf()

		compressor.rpmtarget = max(0, pressure_delta * compressor.gas_contained.return_volume() / (R_IDEAL_GAS_EQUATION * 4))
	else
		compressor.rpmtarget = 0

	// If it works, put an overlay that it works!

	if(lastgen > 100)
		add_overlay(mutable_appearance(icon, "turb-o", FLY_LAYER))

	updateDialog()

/obj/machinery/power/turbine/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, initial(icon_state), initial(icon_state), I))
		return

	if(default_change_direction_wrench(user, I))
		compressor = null
		outturf = get_step(src, dir)
		locate_machinery()
		if(compressor)
			to_chat(user, span_notice("Compressor connected."))
			stat &= ~BROKEN
		else
			to_chat(user, span_alert("Compressor not connected."))
			atom_break()
		return

	default_deconstruction_crowbar(I)

/obj/machinery/power/turbine/ui_interact(mob/user)

	if(!Adjacent(user)  || (stat & (NOPOWER|BROKEN)) && !issilicon(user))
		user.unset_machine(src)
		user << browse(null, "window=turbine")
		return

	var/t = "<TT><B>Gas Turbine Generator</B><HR><PRE>"

	t += "Generated power : [DisplayPower(lastgen)]<BR><BR>"

	t += "Turbine: [round(compressor.rpm)] RPM<BR>"

	t += "Starter: [ compressor.starter ? "<A href='?src=[REF(src)];str=1'>Off</A> <B>On</B>" : "<B>Off</B> <A href='?src=[REF(src)];str=1'>On</A>"]"

	t += "</PRE><HR><A href='?src=[REF(src)];close=1'>Close</A>"

	t += "</TT>"
	var/datum/browser/popup = new(user, "turbine", name)
	popup.set_content(t)
	popup.open()

	return

/obj/machinery/power/turbine/Topic(href, href_list)
	if(..())
		return

	if( href_list["close"] )
		usr << browse(null, "window=turbine")
		usr.unset_machine(src)
		return

	else if( href_list["str"] )
		if(compressor)
			compressor.starter = !compressor.starter

	updateDialog()





/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// COMPUTER NEEDS A SERIOUS REWRITE.



/obj/machinery/computer/turbine_computer/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/turbine_computer/LateInitialize()
	locate_machinery()

/obj/machinery/computer/turbine_computer/locate_machinery()
	if(id)
		for(var/obj/machinery/power/compressor/C in GLOB.machines)
			if(C.comp_id == id)
				compressor = C
				return
	else
		compressor = locate(/obj/machinery/power/compressor) in range(7, src)

/obj/machinery/computer/turbine_computer/multitool_act(mob/living/user, obj/item/multitool/tool)
	var/atom/buffer_atom = multitool_get_buffer(user, tool)
	if(istype(buffer_atom, /obj/machinery/power/compressor))
		var/obj/machinery/power/compressor/new_link = buffer_atom
		if(!new_link.comp_id)
			new_link.comp_id = getnewid()
		id = new_link.comp_id
		user.balloon_alert(user, "linked!")
	return TRUE

/obj/machinery/computer/turbine_computer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TurbineComputer", name)
		ui.open()

/obj/machinery/computer/turbine_computer/ui_data(mob/user)
	var/list/data = list()

	data["compressor"] = compressor ? TRUE : FALSE
	data["compressor_broke"] = (!compressor || (compressor.stat & BROKEN)) ? TRUE : FALSE
	data["turbine"] = compressor?.turbine ? TRUE : FALSE
	data["turbine_broke"] = (!compressor || !compressor.turbine || (compressor.turbine.stat & BROKEN)) ? TRUE : FALSE
	data["online"] = compressor?.starter

	data["power"] = DisplayPower(compressor?.turbine?.lastgen)
	data["rpm"] = compressor?.rpm
	data["temp"] = compressor?.gas_contained.return_temperature()
	data["pressure"] = compressor?.gas_contained.return_pressure()

	return data

/obj/machinery/computer/turbine_computer/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("toggle_power")
			if(compressor && compressor.turbine)
				compressor.starter = !compressor.starter
				. = TRUE
		if("reconnect")
			locate_machinery()
			. = TRUE

#undef COMPFRICTION
#undef TURBGENQ
#undef TURBGENG
