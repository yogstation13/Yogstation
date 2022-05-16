GLOBAL_LIST_EMPTY(server_cabinets)

/obj/machinery/ai/server_cabinet
	name = "Server Cabinet"
	desc = "A simple cabinet of bPCIe slots for installing server racks."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "expansion_bus"
	
	circuit = /obj/item/circuitboard/machine/server_cabinet

	var/list/installed_racks

	var/total_cpu = 0
	var/total_ram = 0
	//Idle power usage when no cards inserted. Not free running idle my friend
	idle_power_usage = 100
	//We manually calculate how power the cards + CPU give, so this is accounted for by that
	active_power_usage = 0

	var/cached_power_usage = 0

	var/max_racks = 2

	var/hardware_synced = FALSE

	var/was_valid_holder = FALSE
	//Atmos hasn't run at the start so this has to be set to true if you map it in
	var/roundstart = FALSE
	///How many ticks we can go without fulfilling the criteria before shutting off
	var/valid_ticks = MAX_AI_EXPANSION_TICKS


/obj/machinery/ai/server_cabinet/Initialize(mapload)
	..()
	roundstart = mapload
	installed_racks = list()
	GLOB.server_cabinets += src
	update_icon()

/obj/machinery/ai/server_cabinet/Destroy()
	installed_racks = list()
	GLOB.server_cabinets -= src
	//Recalculate all the CPUs and RAM :)
	GLOB.ai_os.update_hardware()
	..()

/obj/machinery/ai/server_cabinet/process()
	valid_ticks = clamp(valid_ticks, 0, MAX_AI_EXPANSION_TICKS)
	if(valid_holder())
		var/total_usage = cached_power_usage
		use_power(total_usage)

		var/turf/T = get_turf(src)
		var/datum/gas_mixture/env = T.return_air()
		if(env.heat_capacity())
			var/temperature_increase = total_usage / env.heat_capacity()
			env.set_temperature(env.return_temperature() + temperature_increase * AI_TEMPERATURE_MULTIPLIER) //assume all input power is dissipated
			T.air_update_turf()
		
		valid_ticks++
		if(!was_valid_holder)
			update_icon()
		was_valid_holder = TRUE

		if(!hardware_synced)
			GLOB.ai_os.update_hardware()
			hardware_synced = TRUE
	else 
		valid_ticks--
		if(was_valid_holder)
			if(valid_ticks > 0)
				return
			was_valid_holder = FALSE
			cut_overlays()
			hardware_synced = FALSE
			GLOB.ai_os.update_hardware()


/obj/machinery/ai/server_cabinet/update_icon()
	cut_overlays()

	if(installed_racks.len > 0) 
		var/mutable_appearance/top_overlay = mutable_appearance(icon, "expansion_bus_top")
		add_overlay(top_overlay)
	if(installed_racks.len > 1) 
		var/mutable_appearance/bottom_overlay = mutable_appearance(icon, "expansion_bus_bottom")
		add_overlay(bottom_overlay)
	if(!(stat & (BROKEN|NOPOWER|EMPED)))
		var/mutable_appearance/on_overlay = mutable_appearance(icon, "expansion_bus_on")
		add_overlay(on_overlay)
		if(!valid_ticks)
			return
		if(installed_racks.len > 0)
			var/mutable_appearance/on_top_overlay = mutable_appearance(icon, "expansion_bus_top_on")
			add_overlay(on_top_overlay)
		if(installed_racks.len > 1)
			var/mutable_appearance/on_bottom_overlay = mutable_appearance(icon, "expansion_bus_bottom_on")
			add_overlay(on_bottom_overlay)

/obj/machinery/ai/server_cabinet/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/server_rack))
		if(installed_racks.len >= max_racks)
			to_chat(user, span_warning("[src] cannot fit the [W]!"))
			return ..()
		to_chat(user, span_notice("You install [W] into [src]."))
		W.forceMove(src)
		installed_racks += W
		var/obj/item/server_rack/rack = W
		total_cpu += rack.get_cpu()
		total_ram += rack.get_ram()
		cached_power_usage += rack.get_power_usage()
		GLOB.ai_os.update_hardware()
		use_power = ACTIVE_POWER_USE
		update_icon()
		return FALSE
	if(W.tool_behaviour == TOOL_CROWBAR)
		if(installed_racks.len)
			var/turf/T = get_turf(src)
			for(var/obj/item/C in installed_racks)
				C.forceMove(T)
			installed_racks.len = 0
			total_cpu = 0
			total_ram = 0
			cached_power_usage = 0
			GLOB.ai_os.update_hardware()
			to_chat(user, span_notice("You remove all the racks from [src]"))
			use_power = IDLE_POWER_USE
			update_icon()
			return FALSE
		else
			if(default_deconstruction_crowbar(W))
				return TRUE

	if(default_deconstruction_screwdriver(user, "expansion_bus_o", "expansion_bus", W))
		return TRUE

	return ..()

/obj/machinery/ai/server_cabinet/examine()
	. = ..()
	if(!valid_ticks)
		. += "A small screen is displaying the words 'OFFLINE.'"
	. += "The machine has [installed_racks.len] racks out of a maximum of [max_racks] installed."

	for(var/obj/item/server_rack/R in installed_racks)
		. += "There is a rack installed with a processing capacity of [R.get_cpu()]THz and a memory capacity of [R.get_ram()]TB" 
	. += "Use a crowbar to remove all currently inserted racks."


/obj/machinery/ai/server_cabinet/prefilled/Initialize()
	..()
	var/obj/item/server_rack/roundstart/rack = new(src)
	total_cpu += rack.get_cpu()
	total_ram += rack.get_ram()
	cached_power_usage += rack.get_power_usage()
	installed_racks += rack
	GLOB.ai_os.update_hardware()
