/// The fraction of stored power that gets sent to the grid every process(). Lower numbers make output more consistent but take more time to ramp up to full production.
#define TESLA_COIL_PROCESS_RATE 0.2

/obj/machinery/power/tesla_coil
	name = "tesla coil"
	desc = "For the union!"
	icon = 'icons/obj/tesla_engine/tesla_coil.dmi'
	icon_state = "coil0"
	base_icon_state = "coil"
	anchored = FALSE
	density = TRUE

	// Executing a traitor caught releasing tesla was never this fun!
	can_buckle = TRUE
	buckle_lying = FALSE
	buckle_requires_restraints = TRUE

	circuit = /obj/item/circuitboard/machine/tesla_coil

	var/tesla_flags = TESLA_MOB_DAMAGE | TESLA_OBJ_DAMAGE
	var/percentage_power_loss = 0 // 0-1. Regular coils don't have power loss.
	var/input_power_multiplier = 0
	var/zap_cooldown = 100

	/// The amount of power built up in the coil.
	var/stored_power = 0

	var/datum/techweb/linked_techweb
	var/research_points_per_zap = 2 // Research points gained per minute is indirectly buffed by having a lower zap cooldown.
									// level 1 coil: 15/m, level coil 2: 20/m, level coil 3: 30/m, level coil 4: 60/m

	var/datum/bank_account/linked_account
	var/money_per_zap = 2 // This is tied to coil cooldown in the same way research points are.

/obj/machinery/power/tesla_coil/power
	circuit = /obj/item/circuitboard/machine/tesla_coil/power

/obj/machinery/power/tesla_coil/Initialize(mapload)
	. = ..()
	wires = new /datum/wires/tesla_coil(src)
	linked_techweb = SSresearch.science_tech
	linked_account = SSeconomy.get_dep_account(ACCOUNT_ENG)

/obj/machinery/power/tesla_coil/RefreshParts()
	input_power_multiplier = 0
	zap_cooldown = 100
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		input_power_multiplier += sqrt(C.rating) // Each level increases power gain by 100%
		zap_cooldown -= (C.rating * 20) // Each level decreases cooldown by 2 seconds

/obj/machinery/power/tesla_coil/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: \
			Power generation at <b>[input_power_multiplier*100]%</b>.<br>\
			Shock interval at <b>[zap_cooldown*0.1]</b> seconds.<br>\
			Stored power at <b>[display_joules(stored_power)]</b><span>")

/obj/machinery/power/tesla_coil/on_construction()
	if(anchored)
		connect_to_network()

/obj/machinery/power/tesla_coil/default_unfasten_wrench(mob/user, obj/item/I, time = 20)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		if(panel_open)
			icon_state = "[base_icon_state]_open[anchored]"
		else
			icon_state = "[base_icon_state][anchored]"
		if(anchored)
			connect_to_network()
		else
			disconnect_from_network()

/obj/machinery/power/tesla_coil/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, "[base_icon_state]_open[anchored]", "[base_icon_state][anchored]", W))
		return

	if(default_unfasten_wrench(user, W))
		return

	if(default_deconstruction_crowbar(W))
		return

	if(is_wire_tool(W) && panel_open)
		wires.interact(user)
		return

	return ..()

/obj/machinery/power/tesla_coil/tesla_act(power, tesla_flags, shocked_targets, zap_gib = FALSE)
	if(anchored && !panel_open)
		obj_flags |= BEING_SHOCKED
		stored_power += power
		flick("[base_icon_state]hit", src)
		playsound(src.loc, 'sound/magic/lightningshock.ogg', 100, 1, extrarange = 5)
		if(istype(linked_account))
			linked_account.adjust_money(money_per_zap)
		if(istype(linked_techweb))
			linked_techweb.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, research_points_per_zap)
		addtimer(CALLBACK(src, PROC_REF(reset_shocked)), zap_cooldown)
		tesla_buckle_check(power)
	else
		return ..()

/obj/machinery/power/tesla_coil/process()
	if(!powernet)
		return
	add_avail((stored_power * TESLA_COIL_PROCESS_RATE * (1 - percentage_power_loss)) * input_power_multiplier)
	stored_power *= (1 - TESLA_COIL_PROCESS_RATE)

/obj/machinery/power/tesla_coil/proc/zap()
	if(!powernet)
		return FALSE
	var/coeff = (20 - ((input_power_multiplier - 1) * 3))
	coeff = max(coeff, 10)
	var/power = (powernet.avail / 2)
	add_load(power)
	playsound(loc, 'sound/magic/lightningshock.ogg', 100, 1, extrarange = 5)
	tesla_zap(src, 10, (stored_power + power) * 2 / coeff, tesla_flags)
	tesla_buckle_check((stored_power + power) * 2 / coeff)

// Tesla R&D researcher
/obj/machinery/power/tesla_coil/research
	name = "Tesla Corona Analyzer"
	desc = "A modified Tesla Coil used to study the effects of Edison's Bane for research."
	icon_state = "rpcoil0"
	base_icon_state = "rpcoil"
	circuit = /obj/item/circuitboard/machine/tesla_coil/research
	percentage_power_loss = 0.95 // Research coils lose 95% of the power (converting power to research or something idk)
	research_points_per_zap = 6 // level 1 coil: 44/m, level coil 2: 60/m, level coil 3: 90/m, level coil 4: 180/m
	money_per_zap = 6

/obj/machinery/power/grounding_rod
	name = "grounding rod"
	desc = "Keep an area from being fried from Edison's Bane."
	icon = 'icons/obj/tesla_engine/tesla_coil.dmi'
	icon_state = "grounding_rod0"
	anchored = FALSE
	density = TRUE
	circuit = /obj/item/circuitboard/machine/grounding_rod
	can_buckle = TRUE
	buckle_lying = FALSE
	buckle_requires_restraints = TRUE

/obj/machinery/power/grounding_rod/default_unfasten_wrench(mob/user, obj/item/I, time = 20)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		if(panel_open)
			icon_state = "grounding_rod_open[anchored]"
		else
			icon_state = "grounding_rod[anchored]"

/obj/machinery/power/grounding_rod/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, "grounding_rod_open[anchored]", "grounding_rod[anchored]", W))
		return

	if(default_unfasten_wrench(user, W))
		return

	if(default_deconstruction_crowbar(W))
		return

	return ..()

/obj/machinery/power/grounding_rod/tesla_act(power, tesla_flags, shocked_targets, zap_gib = FALSE)
	if(anchored && !panel_open)
		flick("grounding_rodhit", src)
		tesla_buckle_check(power)
	else
		return ..()
