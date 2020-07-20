#define MAXIMUM_POWER_LIMIT 1000000000000000 //1 Petawatt, same as PTL
#define POWER_SOFTCAP_1 75000000 //75MJ, or 250KW/s for 300s, which is the cycle time of SSeconomy, power below this threshold gets treated differently.
#define POWER_SOFTCAP_2 3000000000 //3GJ or 10MW/s for 300s
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
	materials = list(MAT_METAL=750)
	var/accumulated_power = 0
	var/obj/structure/cable/attached
	var/datum/powernet/PN = null //cached when found
	var/manual_power_setting = MAXIMUM_POWER_LIMIT
	var/manual_switch = FALSE
	var/input_energy = 0

	//archived data for the UI, extra information always helps
	var/last_payout
	var/last_accumulated_power

	var/ui_x = 300
	var/ui_y = 300

obj/item/energy_harvester/Initialize()
	. = ..()
	SSeconomy.moneysink = src

/obj/item/energy_harvester/attack_hand(mob/user, params)
	say("attack_hand() proc called with intent: ")
	say(user.a_intent)
	say("attached = " + isnull(attached))
	say("anchored = " + anchored)
	if(anchored && !isnull(attached) && user.a_intent == INTENT_HELP)
		ui_interact(user)
	return ..()

/obj/item/energy_harvester/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		if(!anchored)
			var/turf/T = loc
			if(isturf(T) && !T.intact)
				attached = locate() in T
				if(!attached)
					to_chat(user, "<span class='warning'>This device must be placed over an exposed, powered cable node!</span>")
				else
					START_PROCESSING(SSobj, src)
					if(!SSeconomy.moneysink)
						SSeconomy.moneysink = src
					PN = attached.powernet
					anchored = 1
					density = 1
					user.visible_message( \
						"[user] attaches \the [src] to the cable.", \
						"<span class='notice'>You attach \the [src] to the cable.</span>",
						"<span class='italics'>You hear some wires being connected to something.</span>")
			else
				to_chat(user, "<span class='warning'>This device must be placed over an exposed, powered cable node!</span>")
		else
			STOP_PROCESSING(SSobj, src)
			anchored = 0
			density = 0
			user.visible_message( \
				"[user] detaches \the [src] from the cable.", \
				"<span class='notice'>You detach \the [src] from the cable.</span>",
				"<span class='italics'>You hear some wires being disconnected from something.</span>")

/obj/item/energy_harvester/process()
	if(!attached || !anchored || !manual_switch)
		return PROCESS_KILL

	if(PN)
		set_light(5)
		if(PN.netexcess <= 0)
			return
		input_energy = min(PN.netexcess, manual_power_setting, MAXIMUM_POWER_LIMIT)
		attached.add_delayedload(input_energy)
		accumulated_power += input_energy

/obj/item/energy_harvester/proc/calculateMoney()
	var/softcap_1_payout = clamp(SOFTCAP_BUDGET_1 * (accumulated_power/POWER_SOFTCAP_1), 0, SOFTCAP_BUDGET_1)
	var/softcap_2_payout = clamp(((log(10, accumulated_power) - log(10, POWER_SOFTCAP_1)) / (log(10, POWER_SOFTCAP_2) - log(10, POWER_SOFTCAP_1)))*SOFTCAP_BUDGET_2, 0, SOFTCAP_BUDGET_2) 
	var/hardcap_payout = clamp(((log(10, accumulated_power) - log(10, POWER_SOFTCAP_2)) / (log(10, POWER_SOFTCAP_2) - log(10, POWER_SOFTCAP_1)))*SOFTCAP_BUDGET_2, 0, SOFTCAP_BUDGET_2) 
	var/potential_payout = softcap_1_payout + softcap_2_payout + hardcap_payout
	return potential_payout

/obj/item/energy_harvester/proc/payout()
	if(accumulated_power == 0)
		return 0
	var/payout = calculateMoney()
	last_payout = payout
	last_accumulated_power = accumulated_power
	accumulated_power = 0
	say("Payout for energy exports received! Payout valued at [payout]!")
	return payout

/obj/item/energy_harvester/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, 
										datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "EnergyHarvester", name, 300, 300, master_ui, state)
		ui.open()

/obj/item/energy_harvester/ui_data(mob/user)
	var/list/data = list(
	"manualSwitch" = manual_switch,
	"manualPowerSetting" = DisplayPower(manual_power_setting),
	"inputEnergy" = DisplayPower(input_energy),
	"accumulatedPower" = DisplayJoules(accumulated_power),
	"projectedIncome" = calculateMoney(),
	"lastPayout" = last_payout,
	"lastAccumulatedPower" = DisplayJoules(last_accumulated_power)
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
			. = TRUE
		if("setinput")
			var/target = params["target"]
			if(target == "input")
				//target = input("New input target (0-[MAXIMUM_POWER_LIMIT]):", name, input_level) as num|null
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
			if(.)
				manual_power_setting = clamp(target, 0, MAXIMUM_POWER_LIMIT)

#undef MAXIMUM_POWER_LIMIT
#undef POWER_SOFTCAP
