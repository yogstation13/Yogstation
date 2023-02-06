GLOBAL_LIST_EMPTY(data_cores)
GLOBAL_VAR_INIT(primary_data_core, null)

#define CELL_POWERUSE_MULTIPLIER 0.025

/obj/machinery/ai/data_core
	name = "AI data core"
	desc = "A complicated computer system capable of emulating the neural functions of an organic being at near-instantanous speeds."
	icon = 'icons/obj/machines/ai_core.dmi'
	icon_state = "core-offline"

	circuit = /obj/item/circuitboard/machine/ai_data_core
	
	active_power_usage = AI_DATA_CORE_POWER_USAGE
	idle_power_usage = 1000
	use_power = IDLE_POWER_USE

	var/disableheat = FALSE

	critical_machine = TRUE

	var/primary = FALSE

	var/valid_ticks //Limited to MAX_AI_DATA_CORE_TICKS. Decrement by 1 every time we have an invalid tick, opposite when valid 

	var/warning_sent = FALSE
	COOLDOWN_DECLARE(warning_cooldown)

	var/TimerID //party time
	//Heat production multiplied by this
	var/heat_modifier = 1
	//Power modifier, power modified by this. Be aware this indirectly changes heat since power => heat
	var/power_modifier = 1
	
	var/obj/item/stock_parts/cell/integrated_battery

	var/obj/ai_smoke/smoke

	var/obj/item/dead_ai/dead_ai_blackbox


/obj/machinery/ai/data_core/Initialize()
	. = ..()
	valid_ticks = MAX_AI_DATA_CORE_TICKS
	GLOB.data_cores += src
	if(primary && !GLOB.primary_data_core)
		GLOB.primary_data_core = src
	update_icon()
	RefreshParts()

/obj/machinery/ai/data_core/RefreshParts()
	var/new_heat_mod = 1
	var/new_power_mod = 1
	for(var/obj/item/stock_parts/cell/CELL in component_parts)
		integrated_battery = CELL
	
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		new_power_mod -= (C.rating - 1) / 50 //Max -24% at tier 4 parts, min -0% at tier 1

	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		new_heat_mod -= (M.rating - 1) / 15 //Max -40% at tier 4 parts, min -0% at tier 1
	
	heat_modifier = new_heat_mod
	power_modifier = new_power_mod
	active_power_usage = AI_DATA_CORE_POWER_USAGE * power_modifier

/obj/machinery/ai/data_core/process()

/obj/machinery/ai/data_core/process_atmos()
	calculate_validity()

/obj/machinery/ai/data_core/Destroy()
	GLOB.data_cores -= src
	if(GLOB.primary_data_core == src)
		GLOB.primary_data_core = null

	if(network && network.resources)
		var/list/all_ais = network.resources.get_all_ais()

		for(var/mob/living/silicon/ai/AI in contents)
			all_ais -= AI
			if(!AI.is_dying)
				AI.relocate()

		for(var/mob/living/silicon/ai/AI in all_ais)
			if(AI.is_dying)
				continue
			if(!AI.mind && AI.deployed_shell && AI.deployed_shell.mind)
				to_chat(AI.deployed_shell, span_userdanger("Warning! Data Core brought offline in [get_area(src)]! Please verify that no malicious actions were taken."))
			else
				to_chat(AI, span_userdanger("Warning! <A HREF=?src=[REF(AI)];go_to_machine=[REF(src)]>Data Core</A> brought offline in [get_area(src)]! Please verify that no malicious actions were taken."))
	

	disconnect_from_network()
	vis_contents -= smoke
	QDEL_NULL(smoke)
	..()

/obj/machinery/ai/data_core/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/dead_ai))
		if(dead_ai_blackbox)
			to_chat(user, span_warning("There's already a neural core inserted!"))
			return
		if(!can_transfer_ai())
			to_chat(user, span_warning("This core is currently unable to host an AI due to being offline."))
			return
		dead_ai_blackbox = O
		network.reviving_ais |= src
		return TRUE
	if(O.tool_behaviour == TOOL_SCREWDRIVER)
		if(!do_after(user, 5 SECONDS, src))
			to_chat(user, span_warning("You need to stand still to open the panel!"))
			return
		if(default_deconstruction_screwdriver(user, "core-open", "core", O))
			return TRUE

	if(O.tool_behaviour == TOOL_CROWBAR)
		if(!do_after(user, 5 SECONDS, src))
			to_chat(user, span_warning("You need to stand still to deconstruct the core!"))
			return
		if(default_deconstruction_crowbar(O))
			return TRUE	
	if(panel_open && user.a_intent != INTENT_HARM)
		if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
			return // Feedback in proc
		if(HAS_TRAIT(O, TRAIT_NODROP))
			to_chat(user, span_notice("[O] is stuck to your hand!"))
			return
		if(istype(O, /obj/item/stock_parts/cell))
			O.forceMove(src) // Force it out of our hands so we can put the old cell in it		
			if(!user.put_in_hands(integrated_battery))
				integrated_battery.forceMove(get_turf(src))
			component_parts -= integrated_battery // Remove the old cell so the new one spawns when deconstructed
			O.moveToNullspace() // Now get out of contents
			to_chat(user, span_notice("You replace [integrated_battery] with [O]."))
			integrated_battery = O // Set the cell
			component_parts += O // Add new cell
		return

	return ..()

//NOTE: See /obj/machinery/status_display/examine in ai_core_display.dm
/obj/machinery/ai/data_core/examine(mob/user)
	. = ..()
	var/holder_status = get_holder_status()
	if(holder_status)
		. += span_warning("Machinery non-functional. Reason: [holder_status]")
	if(!isobserver(user))
		return
	. += "<b>Networked AI Laws:</b>"
	if(network && network.resources)
		var/list/connected_ais = network.resources.get_all_ais()
		for(var/mob/living/silicon/ai/AI in connected_ais)
			var/active_status = "(Core: [FOLLOW_LINK(user, AI.loc)], Eye: [FOLLOW_LINK(user, AI.eyeobj)])"
			if(!AI.mind && AI.deployed_shell)
				active_status = "(Controlling [FOLLOW_LINK(user, AI.deployed_shell)][AI.deployed_shell.name])"
			else if(!AI.mind)
				active_status = "([span_warning("OFFLINE")])"
				
			. += "<b>[AI] [active_status] has the following laws: </b>"
			for(var/law in AI.laws.get_law_list(include_zeroth = TRUE))
				. += law

/obj/machinery/ai/data_core/has_power()
	if((stat & (NOPOWER)) && integrated_battery)
		if(integrated_battery.charge > (active_power_usage * CELL_POWERUSE_MULTIPLIER))
			return TRUE
	else
		return TRUE
	return FALSE

/obj/machinery/ai/data_core/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0)
	. = ..()
	for(var/mob/living/silicon/ai/AI in contents)
		AI.disconnect_shell()

/obj/machinery/ai/data_core/proc/valid_data_core()
	if(valid_ticks > 0 && network && network.total_cpu() >= AI_CORE_CPU_REQUIREMENT && network.total_ram() >= AI_CORE_RAM_REQUIREMENT)
		return TRUE
	return FALSE


/obj/machinery/ai/data_core/proc/calculate_validity()
	valid_ticks = clamp(valid_ticks, 0, MAX_AI_DATA_CORE_TICKS)
	
	if(valid_holder())
		valid_ticks++
		if(valid_ticks == 1)
			update_icon()
		if(icon_state == "core-offline")
			update_icon()
		if(smoke)
			vis_contents -= smoke
			QDEL_NULL(smoke)
		use_power = ACTIVE_POWER_USE
		if((stat & NOPOWER))
			integrated_battery.use(active_power_usage * CELL_POWERUSE_MULTIPLIER)
		warning_sent = FALSE
	else
		valid_ticks--
		if(!smoke)
			if(get_holder_status() == AI_MACHINE_TOO_HOT)
				smoke = new()
				vis_contents += smoke
		if(valid_ticks <= 0)
			use_power = IDLE_POWER_USE
			update_icon()
			for(var/mob/living/silicon/ai/AI in contents)
				if(!AI.is_dying)
					AI.relocate()
		if(network && network.resources)
			if(!warning_sent && COOLDOWN_FINISHED(src, warning_cooldown))
				warning_sent = TRUE
				COOLDOWN_START(src, warning_cooldown, AI_DATA_CORE_WARNING_COOLDOWN)
				var/list/send_to = network.resources.get_all_ais()
				for(var/mob/living/silicon/ai/AI in send_to)
					if(AI.is_dying)
						continue
					if(!AI.mind && AI.deployed_shell.mind)
						to_chat(AI.deployed_shell, span_userdanger("Data core in [get_area(src)] is on the verge of failing! Immediate action required to prevent failure."))
					else
						to_chat(AI, span_userdanger("<A HREF=?src=[REF(AI)];go_to_machine=[REF(src)]>Data core</A> in [get_area(src)] is on the verge of failing! Immediate action required to prevent failure."))
					AI.playsound_local(AI, 'sound/machines/engine_alert2.ogg', 30)
			

	if(!(stat & (BROKEN|EMPED)) && has_power())
		var/turf/T = get_turf(src)
		var/datum/gas_mixture/env = T.return_air()
		if(!disableheat)
			if(env.heat_capacity())
				var/temp_active_usage = stat & NOPOWER ? active_power_usage * CELL_POWERUSE_MULTIPLIER : active_power_usage
				var/temperature_increase = (temp_active_usage / env.heat_capacity()) * heat_modifier //1 CPU = 1000W. Heat capacity = somewhere around 3000-4000. Aka we generate 0.25 - 0.33 K per second, per CPU. 
				env.set_temperature(env.return_temperature() + temperature_increase * AI_TEMPERATURE_MULTIPLIER) //assume all input power is dissipated
				T.air_update_turf()
	
/obj/machinery/ai/data_core/proc/can_transfer_ai()
	if(stat & (BROKEN|EMPED) || !has_power())
		return FALSE
	if(!valid_data_core())
		return FALSE
	return TRUE
	
/obj/machinery/ai/data_core/proc/transfer_AI(mob/living/silicon/ai/AI)
	AI.forceMove(src)
	if(AI.eyeobj)
		AI.eyeobj.forceMove(get_turf(src))
	
	if(network != AI.ai_network)
		if(AI.ai_network)
			AI.ai_network.remove_ai(AI)
		var/old_net = AI.ai_network
		AI.ai_network = network
		network.ai_list += AI
		AI.switch_ainet(old_net, network)

/obj/machinery/ai/data_core/update_icon()
	cut_overlays()
	
	if(!(stat & (BROKEN|EMPED)) && has_power())
		if(!valid_data_core())
			return
		icon_state = "core"
	else
		icon_state = "core-offline"

/obj/machinery/ai/data_core/connect_to_network() //If we ever get connected to a network (or a new one gets created) we get the AIs to the correct one too
	. = ..()
	for(var/mob/living/silicon/ai/AI in contents)
		if(!AI.ai_network)
			network.ai_list |= AI
			var/old_net = AI.ai_network
			AI.ai_network = network
			AI.switch_ainet(old_net, network)

		if(AI.ai_network != network)
			if(AI.ai_network)
				AI.ai_network.remove_ai(AI)
			var/old_net = AI.ai_network
			AI.ai_network = network
			network.ai_list |= AI
			AI.switch_ainet(old_net, network)



/obj/machinery/ai/data_core/proc/partytime()
	var/current_color = random_color()
	set_light(7, 3, current_color)
	TimerID = addtimer(CALLBACK(src, .proc/partytime), 0.5 SECONDS, TIMER_STOPPABLE)

/obj/machinery/ai/data_core/proc/stoptheparty()
	set_light(0)
	if(TimerID)
		deltimer(TimerID)
		TimerID = null



/obj/machinery/ai/data_core/primary
	name = "primary AI Data Core"
	desc = "A complicated computer system capable of emulating the neural functions of a human at near-instantanous speeds. This one has a scrawny and faded note saying: 'Primary AI Data Core'"
	primary = TRUE



/*
This is a good place for AI-related object verbs so I'm sticking it here.
If adding stuff to this, don't forget that an AI need to cancel_camera() whenever it physically moves to a different location.
That prevents a few funky behaviors.
*/
//The type of interaction, the player performing the operation, the AI itself, and the card object, if any.


/atom/proc/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	if(istype(card))
		if(card.flush)
			to_chat(user, "[span_boldannounce("ERROR")]: AI flush is in progress, cannot execute transfer protocol.")
			return FALSE
	return TRUE

/* Unused for now, just here for reference
/obj/structure/AIcore/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	if(state != AI_READY_CORE || !..())
		return
 //Transferring a carded AI to a core.
	if(interaction == AI_TRANS_FROM_CARD)
		AI.control_disabled = FALSE
		AI.radio_enabled = TRUE
		AI.forceMove(loc) // to replace the terminal.
		to_chat(AI, "You have been uploaded to a stationary terminal. Remote device connection restored.")
		to_chat(user, "[span_boldnotice("Transfer successful")]: [AI.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed.")
		card.AI = null
		AI.battery = circuit.battery
		qdel(src)
	else //If for some reason you use an empty card on an empty AI terminal.
		to_chat(user, "There is no AI loaded on this terminal!")

*/

#undef CELL_POWERUSE_MULTIPLIER
