GLOBAL_LIST_EMPTY(expansion_card_holders)

/obj/machinery/ai/expansion_card_holder
	name = "Expansion Card Bus"
	desc = "A simple rack of bPCIe slots for installing expansion cards."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "expansion_bus"
	
	circuit = /obj/item/circuitboard/machine/expansion_card_holder

	var/list/installed_cards

	var/total_cpu = 0
	var/total_ram = 0
	//Idle power usage when no cards inserted. Not free running idle my friend
	idle_power_usage = 100
	//We manually calculate how power the cards + CPU give, so this is accounted for by that
	active_power_usage = 0

	var/max_cards = 2

	var/hardware_synced = FALSE

	var/was_valid_holder = FALSE
	//Atmos hasn't run at the start so this has to be set to true if you map it in
	var/roundstart = FALSE
	///How many ticks we can go without fulfilling the criteria before shutting off
	var/valid_ticks = MAX_AI_EXPANSION_TICKS


/obj/machinery/ai/expansion_card_holder/Initialize(mapload)
	..()
	roundstart = mapload
	installed_cards = list()
	GLOB.expansion_card_holders += src
	update_icon()

/obj/machinery/ai/expansion_card_holder/Destroy()
	installed_cards = list()
	GLOB.expansion_card_holders -= src
	//Recalculate all the CPUs and RAM :)
	GLOB.ai_os.update_hardware()
	..()

/obj/machinery/ai/expansion_card_holder/process()
	valid_ticks = clamp(valid_ticks, 0, MAX_AI_EXPANSION_TICKS)
	if(valid_holder())

		var/power_multiple = total_cpu ** (0.95) //Very slightly more efficient to centralize CPU.

		var/total_usage = (power_multiple * AI_BASE_POWER_PER_CPU) + AI_POWER_PER_CARD * installed_cards.len
		use_power(total_usage)

		var/turf/T = get_turf(src)
		var/datum/gas_mixture/env = T.return_air()
		if(env.heat_capacity())
			var/temperature_increase = total_usage / env.heat_capacity() //1 CPU = 1000W. Heat capacity = somewhere around 3000-4000. Aka we generate 0.25 - 0.33 K per second, per CPU. 
			env.set_temperature(env.return_temperature() + temperature_increase * AI_TEMPERATURE_MULTIPLIER) //assume all input power is dissipated
			T.air_update_turf()
		
		if(!hardware_synced)
			GLOB.ai_os.update_hardware()
			hardware_synced = TRUE
		
	else if(was_valid_holder)
		if(valid_ticks > 0)
			return
		was_valid_holder = FALSE
		cut_overlays()
		hardware_synced = FALSE
		GLOB.ai_os.update_hardware()
	
/obj/machinery/ai/expansion_card_holder/valid_holder()
	. = ..()
	valid_ticks = clamp(valid_ticks, 0, MAX_AI_EXPANSION_TICKS)
	if(!.)
		valid_ticks--
		return .
	valid_ticks++
	if(!was_valid_holder)
		update_icon()
	was_valid_holder = TRUE


/obj/machinery/ai/expansion_card_holder/update_icon()
	cut_overlays()

	if(installed_cards.len > 0) 
		var/mutable_appearance/top_overlay = mutable_appearance(icon, "expansion_bus_top")
		add_overlay(top_overlay)
	if(installed_cards.len > 1) 
		var/mutable_appearance/bottom_overlay = mutable_appearance(icon, "expansion_bus_bottom")
		add_overlay(bottom_overlay)
	if(!(stat & (BROKEN|NOPOWER|EMPED)))
		var/mutable_appearance/on_overlay = mutable_appearance(icon, "expansion_bus_on")
		add_overlay(on_overlay)
		if(installed_cards.len > 0)
			var/mutable_appearance/on_top_overlay = mutable_appearance(icon, "expansion_bus_top_on")
			add_overlay(on_top_overlay)
		if(installed_cards.len > 1)
			var/mutable_appearance/on_bottom_overlay = mutable_appearance(icon, "expansion_bus_bottom_on")
			add_overlay(on_bottom_overlay)

/obj/machinery/ai/expansion_card_holder/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/processing_card) || istype(W, /obj/item/memory_card))
		if(installed_cards.len >= max_cards)
			to_chat(user, span_warning("[src] cannot fit the [W]!"))
			return ..()
		to_chat(user, span_notice("You install [W] into [src]."))
		W.forceMove(src)
		installed_cards += W
		GLOB.ai_os.update_hardware()
		if(istype(W, /obj/item/processing_card))
			var/obj/item/processing_card/cpu_card = W
			total_cpu += cpu_card.tier
		if(istype(W, /obj/item/memory_card))
			var/obj/item/memory_card/ram_card = W
			total_ram += ram_card.tier
		use_power = ACTIVE_POWER_USE
		update_icon()
		return FALSE
	if(W.tool_behaviour == TOOL_CROWBAR)
		if(installed_cards.len)
			var/turf/T = get_turf(src)
			for(var/obj/item/C in installed_cards)
				C.forceMove(T)
			installed_cards.len = 0
			total_cpu = 0
			total_ram = 0
			GLOB.ai_os.update_hardware()
			to_chat(user, span_notice("You remove all the cards from [src]"))
			use_power = IDLE_POWER_USE
			update_icon()
			return FALSE
		else
			if(default_deconstruction_crowbar(W))
				return TRUE

	if(default_deconstruction_screwdriver(user, "expansion_bus_o", "expansion_bus", W))
		return TRUE

	return ..()

/obj/machinery/ai/expansion_card_holder/examine()
	. = ..()
	if(!valid_holder())
		. += "A small screen is displaying the words 'OFFLINE.'"
	. += "The machine has [installed_cards.len] cards out of a maximum of [max_cards] installed."
	for(var/C in installed_cards)
		. += "There is a [C] installed."
	. += "Use a crowbar to remove cards."


/obj/machinery/ai/expansion_card_holder/prefilled/Initialize()
	..()
	var/obj/item/processing_card/cpu = new /obj/item/processing_card()
	var/obj/item/memory_card/ram = new /obj/item/memory_card()

	cpu.forceMove(src)
	total_cpu++
	ram.forceMove(src)
	total_ram++
	installed_cards += cpu
	installed_cards += ram
	GLOB.ai_os.update_hardware()
