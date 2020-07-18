#define MONEYSCALE 300 //change to nerf/buff the money this thing makes
#define MAXIMUM_POWER_LIMIT 1000000000000000 //1 Petawatt, same as PTL
#define POWER_SOFTCAP 300000000 //300MJ, or 1MW/s for 300s, which is the cycle time of SSeconomy, power below this threshold gets treated differently.
#define BELOW_SOFTCAP_MULTIPLIER 10 //multiplied by MONEYSCALE

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
	var/stored_energy = 0
	var/obj/structure/cable/attached
	var/datum/powernet/PN = null //cached when found
	var/power_avaliable

obj/item/energy_harvester/Initialize()
	. = ..()
	SSeconomy.moneysink = src

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
					if(!SSeconomy.monkeysink)
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
	if(!attached || !anchored)
		return PROCESS_KILL

	if(PN)
		set_light(5)
		if(power_avaliable <= PN.netexcess)
			return
		power_avaliable = min(power_avaliable, MAXIMUM_POWER_LIMIT)
		attached.add_delayedload(power_avaliable)
		stored_energy += power_avaliable

/obj/item/energy_harvester/proc/calculateMoney()
	var/potential_payout = 0
	if(stored_energy<POWER_SOFTCAP)
		potential_payout = BELOW_SOFTCAP_MULTIPLIER * MONEYSCALE * (stored_energy / POWER_SOFTCAP)
	else
		potential_payout = MONEYSCALE * ((log(10, stored_energy) - log(10, POWER_SOFTCAP)) + BELOW_SOFTCAP_MULTIPLIER)
	potential_payout = round(potential_payout,1)
	return potential_payout

/obj/item/energy_harvester/proc/payout()
	if(stored_energy = 0)
		return 0
	var/payout = calculateMoney()
	stored_energy = 0
	say("Payout for energy exports received! Payout valued at [payout]!")
	return payout


/obj/item/energy_harvester/ui_interact(mob/user, ui_key = "", datum/tgui/ui = null, force_open = "0", datum/tgui/master_ui = null, datum/ui_state/state = default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "energy_harvester", name, 300, 300, master_ui, state)
		ui.open()

/obj/item/energy_harvester/ui_data(mob/user)
	var/list/data = list()
	data["input_energy"] = DisplayPower(power_avaliable)
	data["stored_energy"] = DisplayJoules(stored_energy)
	data["projected_income"] = calculateMoney()

#undef MONEYSCALE
#undef MAXIMUM_POWER_LIMIT
