#define MAXIMUM_POWER_LIMIT 1000000000000000.0 //1 Petawatt, same as PTL
#define POWER_SOFTCAP_1 75000000.0 //75MJ, or 250KW/s for 300s, which is the cycle time of SSeconomy, power below this threshold gets treated differently.
#define POWER_SOFTCAP_2 3000000000.0 //3GJ or 10MW/s for 300s
#define SOFTCAP_BUDGET_1 2000 //reward for reaching the first softcap
#define SOFTCAP_BUDGET_2 3000 //extra money added on top of the first softcap for going beyond it, until softcap 2
#define HARDCAP_BUDGET 5000 //last tranche of money for going above and beyond the call of duty until hitting the hardcap

/obj/item/energy_harvester
	desc = "A Device which upon connection to a node, will harvest the energy and send it to engineerless stations in return for credits, derived from a syndicate powersink model."
	name = "Energy Harvesting Module"
	icon_state = "powersink0"
	icon = 'icons/obj/device.dmi'
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class= WEIGHT_CLASS_BULKY
	flags_1 = CONDUCT_1
	throwforce = 1
	throw_speed = 1
	throw_range = 1
	materials = list(/datum/material/iron=750)
	///amount of power consumed by the harvester, incremented every tick and reset every budget cycle
	var/accumulated_power = 0
	///stores last REALTIMEOFDAY tick. SSEconomy runs off of that, don't see why this one shouldn't too
	var/last_tick = 0
	///cached powernet, assigned when attached to a wirenet with a powernet
	var/datum/powernet/PN = null
	///manual power setting to limit the maximum draw of the machine
	var/manual_power_setting = MAXIMUM_POWER_LIMIT
	///manual on/off switch
	var/manual_switch = FALSE
	///energy inputted into machine
	var/input_energy = 0

	//archived data for the UI, extra information always helps
	///last payout recieved, so CE can gleefully rub his hands every time the paycheck comes in
	var/last_payout = 0
	///last amount of energy transmitted before being reset by budget cycle, so CE can check if his engine modifications are making more power
	var/last_accumulated_power = 0

obj/item/energy_harvester/Initialize()
	. = ..()
	///links this to SSeconomy so it can be added to the budget cycle calculations
	SSeconomy.moneysink = src
	///for when a mapper connects it to the power room roundstart
	if(anchored)
		connect_to_network()

/** Locates a power node on the turf the harvester is on, then caches a reference to its powernet and queues up in processing
  * Taken from obj/machinery/power which has it natively, but this is an obj/item
  */
/obj/item/energy_harvester/proc/connect_to_network()
	var/turf/T = src.loc
	if(!T || !istype(T))
		return FALSE

	var/obj/structure/cable/C = T.get_cable_node() //check if we have a node cable on the machine turf, the first found is picked
	if(!C || !C.powernet)
		return FALSE
	PN = C.powernet
	set_light(5)
	START_PROCESSING(SSobj, src)
	return TRUE

/** Disconnects from the powernet and sets cached powernet reference to null, then takes it out of processing queue
  * Taken from obj/machinery/power which has it natively, but this is an obj/item
  */
/obj/item/energy_harvester/proc/disconnect_from_network()
	if(!PN)
		return FALSE
	PN = null
	last_tick = 0
	STOP_PROCESSING(SSobj, src)
	set_light(0)

/obj/item/energy_harvester/attack_hand(mob/user, params)
	if(anchored && user.a_intent != INTENT_HARM)
		ui_interact(user)
	return ..()

/** Standard checks for connecting a machine to an open cable node
  */
/obj/item/energy_harvester/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER && I.use_tool(src, user, 20, volume=50))
		if(!anchored)
			if(connect_to_network())
				if(isnull(SSeconomy.moneysink))
					SSeconomy.moneysink = src
				anchored = 1
				density = 1
				user.visible_message( \
					"[user] attaches \the [src] to the cable.", \
					"<span class='notice'>You attach \the [src] to the cable.</span>",
					"<span class='italics'>You hear some wires being connected to something.</span>")
			else
				to_chat(user, "<span class='warning'>This device must be placed over an exposed, powered cable node!</span>")
		else
			anchored = 0
			density = 0
			disconnect_from_network()
			user.visible_message( \
				"[user] detaches \the [src] from the cable.", \
				"<span class='notice'>You detach \the [src] from the cable.</span>",
				"<span class='italics'>You hear some wires being disconnected from something.</span>")

/** Checks if machine works or is still attached to a power node, shuts itself down if nonfunctional and takes itself out of processing queue
  * If functional, sucks up all the excess power from the powernet and adds it to the accumulated_power var
  * Uses REALTIMEOFDAY since that's what SSEconomy runs off. If using regular tick time, a lag spike will slow down the rate of power absorption and thus the money output.
  */
/obj/item/energy_harvester/process()
	if(!anchored || !manual_switch ||!PN)
		disconnect_from_network()
		return PROCESS_KILL
	if(PN.netexcess <= 0)
		return
	if(last_tick == 0)
		last_tick = REALTIMEOFDAY
	input_energy = min(PN.netexcess, manual_power_setting, MAXIMUM_POWER_LIMIT)*((REALTIMEOFDAY-last_tick)/10)
	last_tick = REALTIMEOFDAY
	PN.delayedload += input_energy
	accumulated_power += input_energy

/** Computes money reward for power transmitted. Balancing goes here.
  * Uses a piecewise function with three defined thresholds and three separate formulas. First linear formula instead of logarithmic so that you don't make
  * a not insignificant amount of money by charging it with 300W. The other two formulas scale logarithmically and are designed to be balanced against extreme
  * engine setups such as rad-dupe SMs and fusion TEGs.
  */
/obj/item/energy_harvester/proc/calculateMoney()
	if(accumulated_power == 0 || !accumulated_power)
		return 0
	var/softcap_1_payout = clamp(SOFTCAP_BUDGET_1 * (accumulated_power/POWER_SOFTCAP_1), 0, SOFTCAP_BUDGET_1)
	var/softcap_2_payout = clamp(((log(10, accumulated_power) - log(10, POWER_SOFTCAP_1)) / (log(10, POWER_SOFTCAP_2) - log(10, POWER_SOFTCAP_1)))*SOFTCAP_BUDGET_2, 0, SOFTCAP_BUDGET_2)
	var/hardcap_payout = clamp(((log(10, accumulated_power) - log(10, POWER_SOFTCAP_2)) / (log(10, POWER_SOFTCAP_2) - log(10, POWER_SOFTCAP_1)))*SOFTCAP_BUDGET_2, 0, SOFTCAP_BUDGET_2)
	var/potential_payout = softcap_1_payout + softcap_2_payout + hardcap_payout
	return potential_payout

/** Actually sends money to the engineering budget. Called exclusively by the SSEconomy subsystem in [economy.dm][/code/controllers/subsystem/economy.dm].
  * Resets accumulated power to 0 and archives payout received and power generated.
  */
/obj/item/energy_harvester/proc/payout()
	if(accumulated_power == 0)
		return 0
	var/payout = calculateMoney()
	last_payout = payout
	last_accumulated_power = accumulated_power
	accumulated_power = 0
	say("Payout for energy exports received! Payout valued at [payout]!")
	return payout

/obj/item/energy_harvester/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "EnergyHarvester", name)
		ui.open()

/obj/item/energy_harvester/ui_data(mob/user)
	var/list/data = list(
	"manualSwitch" = manual_switch,
	"manualPowerSetting" = manual_power_setting,
	"inputEnergy" = input_energy,
	"accumulatedPower" = accumulated_power,
	"projectedIncome" = calculateMoney(),
	"lastPayout" = last_payout,
	"lastAccumulatedPower" = last_accumulated_power
	)
	return data

/obj/item/energy_harvester/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("switch")
			manual_switch = !manual_switch
			if(manual_switch)
				START_PROCESSING(SSobj, src)
			else
				STOP_PROCESSING(SSobj, src)
			. = TRUE
		if("setinput")
			var/target = params["target"]
			if(target == "input")
				target = input("New input target (0-[MAXIMUM_POWER_LIMIT]):", name, manual_power_setting) as num|null
				if(!isnull(target) && !..())
					. = TRUE
			else if(target == "min")
				target = 0
				. = TRUE
			else if(target == "max")
				target = MAXIMUM_POWER_LIMIT
				. = TRUE
			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			else if(isnum(target))
				. = TRUE
			if(.)
				manual_power_setting = clamp(target, 0, MAXIMUM_POWER_LIMIT)

#undef MAXIMUM_POWER_LIMIT
