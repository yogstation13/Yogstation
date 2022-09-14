//For my sanity :))

#define COOLANT_INPUT_GATE airs[1]
#define MODERATOR_INPUT_GATE airs[2]
#define COOLANT_OUTPUT_GATE airs[3]

#define RBMK_TEMPERATURE_OPERATING 640 //Celsius
#define RBMK_TEMPERATURE_CRITICAL 1000 //At this point the entire ship is alerted to a meltdown. This may need altering
#define RBMK_TEMPERATURE_MELTDOWN 1200

#define RBMK_NO_COOLANT_TOLERANCE 5 //How many process()ing ticks the reactor can sustain without coolant before slowly taking damage

#define RBMK_PRESSURE_OPERATING 1500 //PSI
#define RBMK_PRESSURE_CRITICAL 2000 //PSI

#define RBMK_MAX_CRITICALITY 3 //No more criticality than N for now.

#define RBMK_POWER_FLAVOURISER 8000 //To turn those KWs into something usable

//Math. Lame.
#define KPA_TO_PSI(A) (A/6.895)
#define PSI_TO_KPA(A) (A*6.895)
#define KELVIN_TO_CELSIUS(A) (A-273.15)
#define MEGAWATTS /1e+6
#define CELSIUS_TO_KELVIN(T_K)	((T_K) + T0C)

//Reference: Heaters go up to 500K.
//Hot plasmaburn: 14164.95 C.

/**
What is this?
Moderators list (Not gonna keep this accurate forever):
Fuel Type:
Oxygen: Power production multiplier. Allows you to run a low plasma, high oxy mix, and still get a lot of power.
Plasma: Power production gas. More plasma -> more power, but it enriches your fuel and makes the reactor much, much harder to control.
Tritium: Extremely efficient power production gas. Will cause chernobyl if used improperly.
Moderation Type:
N2: Helps you regain control of the reaction by increasing control rod effectiveness, will massively boost the rad production of the reactor.
CO2: Super effective shutdown gas for runaway reactions. MASSIVE RADIATION PENALTY!
Pluoxium: Same as N2, but no cancer-rads!
Permeability Type:
BZ: Increases your reactor's ability to transfer its heat to the coolant, thus letting you cool it down faster (but your output will get hotter)
Water Vapour: More efficient permeability modifier
Hyper Noblium: Extremely efficient permeability increase. (10x as efficient as bz)
Depletion type:
Nitryl: When you need weapons grade plutonium yesterday. Causes your fuel to deplete much, much faster. Not a huge amount of use outside of sabotage.
Sabotage:
Meltdown:
Flood reactor moderator with plasma, they won't be able to mitigate the reaction with control rods.
Shut off coolant entirely. Raise control rods.
Swap all fuel out with spent fuel, as it's way stronger.
Blowout:
Shut off exit valve for quick overpressure.
Cause a pipefire in the coolant line (LETHAL).
Tack heater onto coolant line (can also cause straight meltdown)
Tips:
Be careful to not exhaust your plasma supply. I recommend you DON'T max out the moderator input when youre running plasma + o2, or you're at a tangible risk of running out of those gasses from atmos.
The reactor CHEWS through moderator. It does not do this slowly. Be very careful with that!
*/

//Remember kids. If the reactor itself is not physically powered by an APC, it cannot shove coolant in!

//Helper proc to set a new looping ambience, and play it to any mobs already inside of that area.


/obj/machinery/atmospherics/components/trinary/nuclear_reactor
	name = "\improper Advanced Gas-Cooled Nuclear Reactor"
	desc = "A tried and tested design which can output stable power at an acceptably low risk. The moderator can be changed to provide different effects."
	icon = 'icons/obj/machines/rbmk.dmi'
	icon_state = "reactor_map"
	pixel_x = -32
	pixel_y = -32
	density = FALSE //It burns you if you're stupid enough to walk over it.
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	light_color = LIGHT_COLOR_CYAN
	dir = 8 //Less headache inducing :))
	var/id = null //Change me mappers
	//Variables essential to operation
	var/temperature = 0 //Lose control of this -> Meltdown
	var/vessel_integrity = 400 //How long can the reactor withstand overpressure / meltdown? This gives you a fair chance to react to even a massive pipe fire
	var/pressure = 0 //Lose control of this -> Blowout
	var/K = 0 //Rate of reaction.
	var/desired_k = 0
	var/control_rod_effectiveness = 0.65 //Starts off with a lot of control over K. If you flood this thing with plasma, you lose your ability to control K as easily.
	var/power = 0 //0-100%. A function of the maximum heat you can achieve within operating temperature
	var/power_modifier = 1 //Upgrade me with parts, science! Flat out increase to physical power output when loaded with plasma.
	var/list/fuel_rods = list()
	//Secondary variables.
	var/next_slowprocess = 0
	var/gas_absorption_effectiveness = 0.5
	var/gas_absorption_constant = 0.5 //We refer to this one as it's set on init, randomized.
	var/minimum_coolant_level = 5
	var/warning = FALSE //Have we begun warning the crew of their impending death?
	var/next_warning = 0 //To avoid spam.
	var/last_power_produced = 0 //For logging purposes
	var/next_flicker = 0 //Light flicker timer
	var/base_power_modifier = RBMK_POWER_FLAVOURISER
	var/slagged = FALSE //Is this reactor even usable any more?
	//Console statistics.
	var/last_coolant_temperature = 0
	var/last_output_temperature = 0
	var/last_heat_delta = 0 //For administrative cheating only. Knowing the delta lets you know EXACTLY what to set K at.
	var/no_coolant_ticks = 0	//How many times in succession did we not have enough coolant? Decays twice as fast as it accumulates.
	var/last_user = null
	var/current_desired_k = null
	var/datum/powernet/powernet = null

	var/has_hit_emergency = FALSE

//Use this in your maps if you want everything to be preset.
/obj/machinery/atmospherics/components/trinary/nuclear_reactor/preset
	id = "default_reactor_for_lazy_mappers"

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/examine(mob/user)
	. = ..()
	if(Adjacent(src, user))
		if(do_after(user, 1 SECONDS, target=src))
			var/percent = vessel_integrity / initial(vessel_integrity) * 100
			var/msg = "<span class='warning'>The reactor looks operational.</span>"
			switch(percent)
				if(0 to 10)
					msg = "<span class='boldwarning'>[src]'s seals are dangerously warped and you can see cracks all over the reactor vessel! </span>"
				if(10 to 40)
					msg = "<span class='boldwarning'>[src]'s seals are heavily warped and cracked! </span>"
				if(40 to 60)
					msg = "<span class='warning'>[src]'s seals are holding, but barely. You can see some micro-fractures forming in the reactor vessel.</span>"
				if(60 to 80)
					msg = "<span class='warning'>[src]'s seals are in-tact, but slightly worn. There are no visible cracks in the reactor vessel.</span>"
				if(80 to 90)
					msg = "<span class='notice'>[src]'s seals are in good shape, and there are no visible cracks in the reactor vessel.</span>"
				if(95 to 100)
					msg = "<span class='notice'>[src]'s seals look factory new, and the reactor's in excellent shape.</span>"
			. += msg

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/fuel_rod))
		if(power >= 20)
			to_chat(user, "<span class='notice'>You cannot insert fuel into [src] when it has been raised above 20% power.</span>")
			return FALSE
		if(fuel_rods.len >= 5)
			to_chat(user, "<span class='warning'>[src] is already at maximum fuel load.</span>")
			return FALSE
		to_chat(user, "<span class='notice'>You start to insert [W] into [src]...</span>")
		radiation_pulse(src, temperature)
		if(do_after(user, 5 SECONDS, target=src))
			if(!fuel_rods.len)
				start_up() //That was the first fuel rod. Let's heat it up.
				message_admins("Reactor first started up by [ADMIN_LOOKUPFLW(user)] in [ADMIN_VERBOSEJMP(src)]")
				investigate_log("Reactor first started by [key_name(user)] at [AREACOORD(src)]", INVESTIGATE_SINGULO)
			fuel_rods += W
			W.forceMove(src)
			radiation_pulse(src, temperature) //Wear protective equipment when even breathing near a reactor!
			investigate_log("Rod added to reactor by [key_name(user)] at [AREACOORD(src)]", INVESTIGATE_SINGULO)
		return TRUE
	if(istype(W, /obj/item/sealant))
		if(power >= 20)
			to_chat(user, "<span class='notice'>You cannot repair [src] while it is running at above 20% power.</span>")
			return FALSE
		if(vessel_integrity >= 350)
			to_chat(user, "<span class='notice'>[src]'s seals are already in-tact, repairing them further would require a new set of seals.</span>")
			return FALSE
		if(vessel_integrity <= 0.5 * initial(vessel_integrity)) //Heavily damaged.
			to_chat(user, "<span class='notice'>[src]'s reactor vessel is cracked and worn, you need to repair the cracks with a welder before you can repair the seals.</span>")
			return FALSE
		if(do_after(user, 5 SECONDS, target=src))
			if(vessel_integrity >= 350)	//They might've stacked doafters
				to_chat(user, "<span class='notice'>[src]'s seals are already in-tact, repairing them further would require a new set of seals.</span>")
				return FALSE
			playsound(src, 'sound/effects/spray2.ogg', 50, 1, -6)
			user.visible_message("<span class='warning'>[user] applies sealant to some of [src]'s worn out seals.</span>", "<span class='notice'>You apply sealant to some of [src]'s worn out seals.</span>")
			vessel_integrity += 10
			vessel_integrity = clamp(vessel_integrity, 0, initial(vessel_integrity))
		return TRUE
	return ..()

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/welder_act(mob/living/user, obj/item/I)
	if(power >= 20)
		to_chat(user, "<span class='notice'>You can't repair [src] while it is running at above 20% power.</span>")
		return FALSE
	if(vessel_integrity > 0.5 * initial(vessel_integrity))
		to_chat(user, "<span class='notice'>[src] is free from cracks. Further repairs must be carried out with flexi-seal sealant.</span>")
		return FALSE
	if(I.use_tool(src, user, 0, volume=40))
		if(vessel_integrity > 0.5 * initial(vessel_integrity))
			to_chat(user, "<span class='notice'>[src] is free from cracks. Further repairs must be carried out with flexi-seal sealant.</span>")
			return FALSE
		vessel_integrity += 20
		to_chat(user, "<span class='notice'>You weld together some of [src]'s cracks. This'll do for now.</span>")
	return TRUE

//Admin procs to mess with the reaction environment.

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/lazy_startup()
	for(var/I=0;I<5;I++)
		fuel_rods += new /obj/item/fuel_rod(src)
	message_admins("Reactor started up by admins in [ADMIN_VERBOSEJMP(src)]")
	start_up()

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/deplete()
	for(var/obj/item/fuel_rod/FR in fuel_rods)
		FR.depletion = 100

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/Initialize()
	. = ..()
	icon_state = "reactor_off"
	gas_absorption_effectiveness = rand(5, 6)/10 //All reactors are slightly different. This will result in you having to figure out what the balance is for K.
	gas_absorption_constant = gas_absorption_effectiveness //And set this up for the rest of the round.
	STOP_PROCESSING(SSmachines, src) //We'll handle this one ourselves.
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/LateInitialize()
	. = ..()
	connect_to_network()

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/Crossed(atom/movable/AM, oldloc)
	. = ..()
	if(isliving(AM) && temperature > 0)
		var/mob/living/L = AM
		L.adjust_bodytemperature(clamp(temperature, BODYTEMP_COOLING_MAX, BODYTEMP_HEATING_MAX)) //If you're on fire, you heat up!

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/process()
	//Let's get our gasses sorted out.
	var/datum/gas_mixture/coolant_input = COOLANT_INPUT_GATE
	var/datum/gas_mixture/moderator_input = MODERATOR_INPUT_GATE
	var/datum/gas_mixture/coolant_output = COOLANT_OUTPUT_GATE

	//Firstly, heat up the reactor based off of K.
	var/input_moles = coolant_input.total_moles() //Firstly. Do we have enough moles of coolant?
	if(input_moles >= minimum_coolant_level)
		last_coolant_temperature = KELVIN_TO_CELSIUS(coolant_input.return_temperature())
		//Important thing to remember, once you slot in the fuel rods, this thing will not stop making heat, at least, not unless you can live to be thousands of years old which is when the spent fuel finally depletes fully.
		var/heat_delta = (KELVIN_TO_CELSIUS(coolant_input.return_temperature()) / 100) * gas_absorption_effectiveness //Take in the gas as a cooled input, cool the reactor a bit. The optimum, 100% balanced reaction sits at K=1, coolant input temp of 200K / -73 celsius.
		last_heat_delta = heat_delta
		temperature += heat_delta
		coolant_output.merge(coolant_input) //And now, shove the input into the output.
		coolant_input.clear() //Clear out anything left in the input gate.
		color = null
		no_coolant_ticks = max(0, no_coolant_ticks-2)	//Needs half as much time to recover the ticks than to acquire them
	else
		if(has_fuel())
			no_coolant_ticks++
			if(no_coolant_ticks > RBMK_NO_COOLANT_TOLERANCE)
				temperature += temperature / 500 //This isn't really harmful early game, but when your reactor is up to full power, this can get out of hand quite quickly.
				vessel_integrity -= temperature / 200 //Think fast loser.
				take_damage(10) //Just for the sound effect, to let you know you've fucked up.
				color = "[COLOR_RED]"
				investigate_log("Reactor taking damage from the lack of coolant", INVESTIGATE_SINGULO)
	//Now, heat up the output and set our pressure.
	coolant_output.set_temperature(CELSIUS_TO_KELVIN(temperature)) //Heat the coolant output gas that we just had pass through us.
	last_output_temperature = KELVIN_TO_CELSIUS(coolant_output.return_temperature())
	pressure = KPA_TO_PSI(coolant_output.return_pressure())
	power = (temperature / RBMK_TEMPERATURE_CRITICAL) * 100
	var/radioactivity_spice_multiplier = 1 //Some gasses make the reactor a bit spicy.
	var/depletion_modifier = 0.035 //How rapidly do your rods decay
	gas_absorption_effectiveness = gas_absorption_constant
	//Next up, handle moderators!
	if(moderator_input.total_moles() >= minimum_coolant_level)
		var/total_fuel_moles = moderator_input.get_moles(/datum/gas/plasma) + (moderator_input.get_moles(/datum/gas/tritium)*10) //Constricted plasma is 50% more efficient as fuel than plasma, but we dont have it :)
		var/power_modifier = max((moderator_input.get_moles(/datum/gas/oxygen) / moderator_input.total_moles() * 10), 1) //You can never have negative IPM. For now.
		if(total_fuel_moles >= minimum_coolant_level) //You at least need SOME fuel.
			var/power_produced = max((total_fuel_moles / moderator_input.total_moles() * 10), 1)
			last_power_produced = max(0,((power_produced*power_modifier)*moderator_input.total_moles()))
			last_power_produced *= (max(0,power)/100) //Aaaand here comes the cap. Hotter reactor => more power.
			last_power_produced *= base_power_modifier //Finally, we turn it into actual usable numbers.
			radioactivity_spice_multiplier += moderator_input.get_moles(/datum/gas/tritium) / 5 //Chernobyl 2.
			var/turf/T = get_turf(src)
			if(power >= 20)
				coolant_output.adjust_moles(/datum/gas/nitryl, total_fuel_moles/20) //Shove out nitryl into the air when it's fuelled. You need to filter this off, or you're gonna have a bad time.
			var/obj/structure/cable/C = T.get_cable_node()
			if(!C?.powernet)
				return
			else
				add_avail(last_power_produced)
		var/total_control_moles = moderator_input.get_moles(/datum/gas/nitrogen) + (moderator_input.get_moles(/datum/gas/carbon_dioxide)*2) + (moderator_input.get_moles(/datum/gas/pluoxium)*3) //N2 helps you control the reaction at the cost of making it absolutely blast you with rads. Pluoxium has the same effect but without the rads!
		if(total_control_moles >= minimum_coolant_level)
			var/control_bonus = total_control_moles / 250 //1 mol of n2 -> 0.002 bonus control rod effectiveness, if you want a super controlled reaction, you'll have to sacrifice some power.
			control_rod_effectiveness = initial(control_rod_effectiveness) + control_bonus
			radioactivity_spice_multiplier += moderator_input.get_moles(/datum/gas/nitrogen) / 25 //An example setup of 50 moles of n2 (for dealing with spent fuel) leaves us with a radioactivity spice multiplier of 3.
			radioactivity_spice_multiplier += moderator_input.get_moles(/datum/gas/carbon_dioxide) / 12.5
		var/total_permeability_moles = moderator_input.get_moles(/datum/gas/bz) + (moderator_input.get_moles(/datum/gas/water_vapor)*2) + (moderator_input.get_moles(/datum/gas/hypernoblium)*10)
		if(total_permeability_moles >= minimum_coolant_level)
			var/permeability_bonus = total_permeability_moles / 500
			gas_absorption_effectiveness = gas_absorption_constant + permeability_bonus
		var/total_degradation_moles = moderator_input.get_moles(/datum/gas/nitryl) //Because it's quite hard to get.
		if(total_degradation_moles >= minimum_coolant_level*0.5) //I'll be nice.
			depletion_modifier += total_degradation_moles / 15 //Oops! All depletion. This causes your fuel rods to get SPICY.
			playsound(src, pick('sound/machines/sm/accent/normal/1.ogg','sound/machines/sm/accent/normal/2.ogg','sound/machines/sm/accent/normal/3.ogg','sound/machines/sm/accent/normal/4.ogg','sound/machines/sm/accent/normal/5.ogg'), 100, TRUE)
		//From this point onwards, we clear out the remaining gasses.
		moderator_input.clear() //Woosh. And the soul is gone.
		K += total_fuel_moles / 1000
	var/fuel_power = 0 //So that you can't magically generate K with your control rods.
	if(!has_fuel())  //Reactor must be fuelled and ready to go before we can heat it up boys.
		K = 0
	else
		for(var/obj/item/fuel_rod/FR in fuel_rods)
			K += FR.fuel_power
			fuel_power += FR.fuel_power
			FR.deplete(depletion_modifier)
	//Firstly, find the difference between the two numbers.
	var/difference = abs(K - desired_k)
	//Then, hit as much of that goal with our cooling per tick as we possibly can.
	difference = clamp(difference, 0, control_rod_effectiveness) //And we can't instantly zap the K to what we want, so let's zap as much of it as we can manage....
	if(difference > fuel_power && desired_k > K)
		investigate_log("Reactor has not enough fuel to get [difference]. We have fuel [fuel_power]", INVESTIGATE_SINGULO)
		difference = fuel_power //Again, to stop you being able to run off of 1 fuel rod.
	if(K != desired_k)
		if(desired_k > K)
			K += difference
		else if(desired_k < K)
			K -= difference
		if(K == desired_k && last_user && current_desired_k != desired_k)
			current_desired_k = desired_k
			message_admins("Reactor desired criticality set to [desired_k] by [ADMIN_LOOKUPFLW(last_user)] in [ADMIN_VERBOSEJMP(src)]")
			investigate_log("reactor desired criticality set to [desired_k] by [key_name(last_user)] at [AREACOORD(src)]", INVESTIGATE_SINGULO)
	K = clamp(K, 0, RBMK_MAX_CRITICALITY)
	if(has_fuel())
		temperature += K
	else
		temperature -= 10 //Nothing to heat us up, so.
	handle_alerts() //Let's check if they're about to die, and let them know.
	update_icon()
	radiation_pulse(src, temperature*radioactivity_spice_multiplier)
	if(power >= 90 && world.time >= next_flicker) //You're overloading the reactor. Give a more subtle warning that power is getting out of control.
		next_flicker = world.time + 1.5 MINUTES
		for(var/obj/machinery/light/L in GLOB.machines)
			if(prob(25) && L.z == z) //If youre running the reactor cold though, no need to flicker the lights.
				L.flicker()
		investigate_log("Reactor overloading at [power]% power", INVESTIGATE_SINGULO)
	for(var/atom/movable/I in get_turf(src))
		if(isliving(I))
			var/mob/living/L = I
			if(temperature > 0)
				L.adjust_bodytemperature(clamp(temperature, BODYTEMP_COOLING_MAX, BODYTEMP_HEATING_MAX)) //If you're on fire, you heat up!
		if(istype(I, /obj/item/reagent_containers/food) && !istype(I, /obj/item/reagent_containers/food/drinks))
			playsound(src, pick('sound/machines/fryer/deep_fryer_1.ogg', 'sound/machines/fryer/deep_fryer_2.ogg'), 100, TRUE)
			var/obj/item/reagent_containers/food/grilled_item = I
			if(prob(80))
				return //To give the illusion that it's actually cooking omegalul.
			switch(power)
				if(20 to 39)
					grilled_item.name = "grilled [initial(grilled_item.name)]"
					grilled_item.desc = "[initial(I.desc)] It's been grilled over a nuclear reactor."
					if(!(grilled_item.foodtype & FRIED))
						grilled_item.foodtype |= FRIED
				if(40 to 70)
					grilled_item.name = "heavily grilled [initial(grilled_item.name)]"
					grilled_item.desc = "[initial(I.desc)] It's been heavily grilled through the magic of nuclear fission."
					if(!(grilled_item.foodtype & FRIED))
						grilled_item.foodtype |= FRIED
				if(70 to 95)
					grilled_item.name = "Three-Mile Nuclear-Grilled [initial(grilled_item.name)]"
					grilled_item.desc = "A [initial(grilled_item.name)]. It's been put on top of a nuclear reactor running at extreme power by some badass engineer."
					if(!(grilled_item.foodtype & FRIED))
						grilled_item.foodtype |= FRIED
				if(95 to INFINITY)
					grilled_item.name = "Ultimate Meltdown Grilled [initial(grilled_item.name)]"
					grilled_item.desc = "A [initial(grilled_item.name)]. A grill this perfect is a rare technique only known by a few engineers who know how to perform a 'controlled' meltdown whilst also having the time to throw food on a reactor. I'll bet it tastes amazing."
					if(!(grilled_item.foodtype & FRIED))
						grilled_item.foodtype |= FRIED


/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/has_fuel()
	return length(fuel_rods)

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/relay(var/sound, var/message=null, loop = FALSE, channel = null) //Sends a sound + text message to the crew of a ship
	for(var/mob/M in GLOB.player_list)
		if(M.z == z)
			if(!isinspace(M))
				if(sound)
					if(channel) //Doing this forbids overlapping of sounds
						SEND_SOUND(M, sound(sound, repeat = loop, wait = 0, volume = 70, channel = channel))
					else
						SEND_SOUND(M, sound(sound, repeat = loop, wait = 0, volume = 70))
				if(message)
					to_chat(M, message)

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/stop_relay(channel) //Stops all playing sounds for crewmen on N channel.
	for(var/mob/M in GLOB.player_list)
		if(M.z == z)
			M.stop_sound_channel(channel)

//Method to handle sound effects, reactor warnings, all that jazz.
/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/handle_alerts()
	var/alert = FALSE //If we have an alert condition, we'd best let people know.
	if(K <= 0 && temperature <= 0)
		shut_down()
	//First alert condition: Overheat
	if(temperature >= RBMK_TEMPERATURE_CRITICAL)
		alert = TRUE
		if(!has_hit_emergency)
			has_hit_emergency = TRUE
			investigate_log("Reactor reaching critical temperature at [temperature] C with desired criticality at [desired_k]", INVESTIGATE_SINGULO)
			message_admins("Reactor reaching critical temperature at [ADMIN_VERBOSEJMP(src)]")
		if(temperature >= RBMK_TEMPERATURE_MELTDOWN)
			var/temp_damage = min(temperature/100, initial(vessel_integrity)/40)	//40 seconds to meltdown from full integrity, worst-case. Bit less than blowout since it's harder to spike heat that much.
			vessel_integrity -= temp_damage
			if(vessel_integrity <= temp_damage)
				investigate_log("Reactor melted down at [temperature] C with desired criticality at [desired_k]", INVESTIGATE_SINGULO) //It wouldn't be able to tank another hit.
				meltdown() //Oops! All meltdown
				return
	else
		alert = FALSE
	if(temperature < -200) //That's as cold as I'm letting you get it, engineering.
		color = COLOR_CYAN
		temperature = -200
	else
		color = null
	//Second alert condition: Overpressurized (the more lethal one)
	if(pressure >= RBMK_PRESSURE_CRITICAL)
		alert = TRUE
		if(!has_hit_emergency)
			has_hit_emergency = TRUE
			investigate_log("Reactor reaching critical pressure at [pressure] PSI with desired criticality at [desired_k]", INVESTIGATE_SINGULO)
			message_admins("Reactor reaching critical pressure at [ADMIN_VERBOSEJMP(src)]")
		shake_animation(0.5)
		playsound(loc, 'sound/machines/clockcult/steam_whoosh.ogg', 100, TRUE)
		var/turf/T = get_turf(src)
		T.atmos_spawn_air("water_vapor=[pressure/100];TEMP=[CELSIUS_TO_KELVIN(temperature)]")
		var/pressure_damage = min(pressure/100, initial(vessel_integrity)/45)	//You get 45 seconds (if you had full integrity), worst-case. But hey, at least it can't be instantly nuked with a pipe-fire.. though it's still very difficult to save.
		vessel_integrity -= pressure_damage
		if(vessel_integrity <= pressure_damage) //It wouldn't be able to tank another hit.
			investigate_log("Reactor blowout at [pressure] PSI with desired criticality at [desired_k]", INVESTIGATE_SINGULO)
			blowout()
			return
	if(warning)
		if(!alert) //Congrats! You stopped the meltdown / blowout.
			stop_relay(CHANNEL_REACTOR_ALERT)
			warning = FALSE
			set_light(0)
			light_color = LIGHT_COLOR_CYAN
			set_light(10)
			has_hit_emergency = FALSE
	else
		if(!alert)
			return
		if(world.time < next_warning)
			return
		next_warning = world.time + 60 SECONDS //To avoid engis pissing people off when reaaaally trying to stop the meltdown or whatever.
		warning = TRUE //Start warning the crew of the imminent danger.
		relay('sound/effects/reactor/alarm.ogg', null, channel = CHANNEL_REACTOR_ALERT)
		set_light(0)
		light_color = LIGHT_COLOR_RED
		set_light(10)

//Failure condition 1: Meltdown. Achieved by having heat go over tolerances. This is less devastating because it's easier to achieve.
//Results: Engineering becomes unusable and your engine irreparable
/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/meltdown()
	set waitfor = FALSE
	SSair.atmos_machinery -= src //Annd we're now just a useless brick.
	slagged = TRUE
	color = null
	update_icon()
	STOP_PROCESSING(SSmachines, src)
	icon_state = "reactor_slagged"
	AddComponent(/datum/component/radioactive, 15000 , src, 0)
	var/obj/effect/landmark/nuclear_waste_spawner/NSW = new /obj/effect/landmark/nuclear_waste_spawner/strong(get_turf(src))
	relay('sound/effects/reactor/meltdown.ogg', "<span class='userdanger'>You hear a horrible metallic hissing.</span>")
	stop_relay(CHANNEL_REACTOR_ALERT)
	NSW.fire() //This will take out engineering for a decent amount of time as they have to clean up the sludge.
	for(var/obj/machinery/power/apc/apc in GLOB.apcs_list)
		if((apc.z == z) && prob(70))
			apc.overload_lighting()
	var/datum/gas_mixture/coolant_input = COOLANT_INPUT_GATE
	var/datum/gas_mixture/moderator_input = MODERATOR_INPUT_GATE
	var/datum/gas_mixture/coolant_output = COOLANT_OUTPUT_GATE
	var/turf/T = get_turf(src)
	coolant_input.set_temperature(CELSIUS_TO_KELVIN(temperature)*2)
	moderator_input.set_temperature(CELSIUS_TO_KELVIN(temperature)*2)
	coolant_output.set_temperature(CELSIUS_TO_KELVIN(temperature)*2)
	T.assume_air(coolant_input)
	T.assume_air(moderator_input)
	T.assume_air(coolant_output)
	explosion(get_turf(src), 0, 5, 10, 20, TRUE, TRUE)
	empulse(get_turf(src), 25, 15)

//Failure condition 2: Blowout. Achieved by reactor going over-pressured. This is a round-ender because it requires more fuckery to achieve.
/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/blowout()
	explosion(get_turf(src), GLOB.MAX_EX_DEVESTATION_RANGE, GLOB.MAX_EX_HEAVY_RANGE, GLOB.MAX_EX_LIGHT_RANGE, GLOB.MAX_EX_FLASH_RANGE)
	meltdown() //Double kill.
	relay('sound/effects/reactor/explode.ogg')
	SSweather.run_weather("nuclear fallout")
	for(var/X in GLOB.landmarks_list)
		if(istype(X, /obj/effect/landmark/nuclear_waste_spawner))
			var/obj/effect/landmark/nuclear_waste_spawner/WS = X
			if(is_station_level(WS.z)) //Begin the SLUDGING
				WS.fire()

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/update_icon()
	icon_state = "reactor_off"
	switch(temperature)
		if(0 to 200)
			icon_state = "reactor_on"
		if(200 to RBMK_TEMPERATURE_OPERATING)
			icon_state = "reactor_hot"
		if(RBMK_TEMPERATURE_OPERATING to 750)
			icon_state = "reactor_veryhot"
		if(750 to RBMK_TEMPERATURE_CRITICAL) //Point of no return.
			icon_state = "reactor_overheat"
		if(RBMK_TEMPERATURE_CRITICAL to INFINITY)
			icon_state = "reactor_meltdown"
	if(!has_fuel())
		icon_state = "reactor_off"
	if(slagged)
		icon_state = "reactor_slagged"


//Startup, shutdown

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/start_up()
	START_PROCESSING(SSmachines, src)
	desired_k = 1
	set_light(10)
	var/startup_sound = pick('sound/effects/reactor/startup.ogg', 'sound/effects/reactor/startup2.ogg')
	playsound(loc, startup_sound, 100)
	if(!powernet)
		message_admins("No powernet for the Nuclear Reactor! Trying to add.")
		connect_to_network()
		if(!powernet)
			message_admins("Powernet add fail. This reactor will never produce power.")

//Shuts off the fuel rods, ambience, etc. Keep in mind that your temperature may still go up!
/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/shut_down()
	STOP_PROCESSING(SSmachines, src)
	set_light(0)
	K = 0
	desired_k = 0
	temperature = 0
	update_icon()

/obj/item/fuel_rod/Initialize()
	.=..()
	AddComponent(/datum/component/radioactive, 350 , src)

//Controlling the reactor.

/obj/machinery/computer/reactor
	name = "Reactor control console"
	desc = "A computer which monitors and controls a reactor"
	light_color = "#55BA55"
	light_power = 1
	light_range = 3
	icon_state = "oldcomp"
	icon_screen = "oldcomp_broken"
	icon_keyboard = null
	var/obj/machinery/atmospherics/components/trinary/nuclear_reactor/reactor = null
	var/id = "default_reactor_for_lazy_mappers"
	var/next_stat_interval = 0
	var/list/psiData = list()
	var/list/powerData = list()
	var/list/tempInputData = list()
	var/list/tempOutputdata = list()

/obj/machinery/computer/reactor/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/reactor/LateInitialize()
	. = ..()
	link_to_reactor()

/obj/machinery/computer/reactor/process()
	psiData += (reactor) ? reactor.pressure : 0
	if(psiData.len > 100) //Only lets you track over a certain timeframe.
		psiData.Cut(1, 2)
	powerData += (reactor) ? reactor.power*10 : 0 //We scale up the figure for a consistent:tm: scale
	if(powerData.len > 100) //Only lets you track over a certain timeframe.
		powerData.Cut(1, 2)
	tempInputData += (reactor) ? reactor.last_coolant_temperature : 0 //We scale up the figure for a consistent:tm: scale
	if(tempInputData.len > 100) //Only lets you track over a certain timeframe.
		tempInputData.Cut(1, 2)
	tempOutputdata += (reactor) ? reactor.last_output_temperature : 0 //We scale up the figure for a consistent:tm: scale
	if(tempOutputdata.len > 100) //Only lets you track over a certain timeframe.
		tempOutputdata.Cut(1, 2)

/obj/machinery/computer/reactor/attack_hand(mob/living/user)
	. = ..()
	ui_interact(user)

/obj/machinery/computer/reactor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RbmkComputer")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/reactor/ui_act(action, params)
	if(..())
		return
	if(!reactor)
		return
	switch(action)
		if("input")
			var/input = text2num(params["target"])
			reactor.last_user = usr
			reactor.desired_k = clamp(input, 0, 3)
		if("eject")
			var/obj/item/fuel_rod/rod = locate(params["rodRef"])
			if(!rod)
				return
			playsound(src, pick('sound/effects/reactor/switch.ogg','sound/effects/reactor/switch2.ogg','sound/effects/reactor/switch3.ogg'), 100, FALSE)
			playsound(reactor, 'sound/effects/reactor/crane_1.wav', 100, FALSE)
			rod.forceMove(get_turf(reactor))
			reactor.fuel_rods -= rod

/obj/machinery/computer/reactor/ui_data(mob/user)
	var/list/data = list()
	data["control_rods"] = 0
	data["k"] = 0
	data["desiredK"] = 0
	if(reactor)
		data["k"] = reactor.K
		data["desiredK"] = reactor.desired_k
		data["control_rods"] = 100 - (reactor.desired_k / 3 * 100) //Rod insertion is extrapolated as a function of the percentage of K
		data["powerData"] = powerData
	data["psiData"] = psiData
	data["tempInputData"] = tempInputData
	data["tempOutputdata"] = tempOutputdata
	data["coolantInput"] = reactor ? reactor.last_coolant_temperature : 0
	data["coolantOutput"] = reactor ? reactor.last_output_temperature : 0
	data["power"] = reactor ? reactor.power : 0
	data["psi"] = reactor ? reactor.pressure : 0
	data["rods"] = list()
	if(reactor)
		for(var/obj/item/fuel_rod/rod in reactor.fuel_rods)
			data["rods"][REF(rod)] = list("name" = rod.name, "depletion" = rod.depletion)
	return data

/obj/machinery/computer/reactor/wrench_act(mob/living/user, obj/item/I)
	to_chat(user, "<span class='notice'>You start [anchored ? "un" : ""]securing [name]...</span>")
	if(I.use_tool(src, user, 40, volume=75))
		to_chat(user, "<span class='notice'>You [anchored ? "un" : ""]secure [name].</span>")
		setAnchored(!anchored)
		return TRUE
	return FALSE

/obj/machinery/computer/reactor/proc/link_to_reactor()
	for(var/obj/machinery/atmospherics/components/trinary/nuclear_reactor/asdf in GLOB.machines)
		if(asdf.id && asdf.id == id)
			reactor = asdf
			return TRUE
	return FALSE

#define FREQ_RBMK_CONTROL 1439.69

//Preset pumps for mappers. You can also set the id tags yourself.
/obj/machinery/atmospherics/components/binary/pump/rbmk_input
	id = "rbmk_input"
	frequency = FREQ_RBMK_CONTROL

/obj/machinery/atmospherics/components/binary/pump/rbmk_output
	id = "rbmk_output"
	frequency = FREQ_RBMK_CONTROL

/obj/machinery/atmospherics/components/binary/pump/rbmk_moderator
	id = "rbmk_moderator"
	frequency = FREQ_RBMK_CONTROL

/obj/machinery/computer/reactor/pump
	name = "Reactor inlet valve computer"
	desc = "A computer which controls valve settings on an advanced gas cooled reactor. Alt click it to remotely set pump pressure."
	icon_screen = "rbmk_input"
	id = "rbmk_input"
	var/datum/radio_frequency/radio_connection
	var/on = FALSE

/obj/machinery/computer/reactor/pump/AltClick(mob/user)
	. = ..()
	var/newPressure = input(user, "Set new output pressure (kPa)", "Remote pump control", null) as num
	if(!newPressure)
		return
	newPressure = clamp(newPressure, 0, MAX_OUTPUT_PRESSURE) //Number sanitization is not handled in the pumps themselves, only during their ui_act which this doesn't use.
	signal(on, newPressure)

/obj/machinery/computer/reactor/attack_robot(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/computer/reactor/attack_ai(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/computer/reactor/pump/attack_hand(mob/living/user)
	. = ..()
	if(!is_operational())
		return FALSE
	playsound(loc, pick('sound/effects/reactor/switch.ogg','sound/effects/reactor/switch2.ogg','sound/effects/reactor/switch3.ogg'), 100, FALSE)
	visible_message("<span class='notice'>[src]'s switch flips [on ? "off" : "on"].</span>")
	on = !on
	signal(on)

/obj/machinery/computer/reactor/pump/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	radio_connection = SSradio.add_object(src, FREQ_RBMK_CONTROL,filter=RADIO_ATMOSIA)

/obj/machinery/computer/reactor/pump/proc/signal(power, set_output_pressure=null)
	var/datum/signal/signal
	if(!set_output_pressure) //Yes this is stupid, but technically if you pass through "set_output_pressure" onto the signal, it'll always try and set its output pressure and yeahhh...
		signal = new(list(
			"tag" = id,
			"frequency" = FREQ_RBMK_CONTROL,
			"timestamp" = world.time,
			"power" = power,
			"sigtype" = "command"
		))
	else
		signal = new(list(
			"tag" = id,
			"frequency" = FREQ_RBMK_CONTROL,
			"timestamp" = world.time,
			"power" = power,
			"set_output_pressure" = set_output_pressure,
			"sigtype" = "command"
		))
	radio_connection.post_signal(src, signal, filter=RADIO_ATMOSIA)

//Preset subtypes for mappers
/obj/machinery/computer/reactor/pump/rbmk_input
	name = "Reactor inlet valve computer"
	icon_screen = "rbmk_input"
	id = "rbmk_input"

/obj/machinery/computer/reactor/pump/rbmk_output
	name = "Reactor output valve computer"
	icon_screen = "rbmk_output"
	id = "rbmk_output"

/obj/machinery/computer/reactor/pump/rbmk_moderator
	name = "Reactor moderator valve computer"
	icon_screen = "rbmk_moderator"
	id = "rbmk_moderator"

//Monitoring program.
/datum/computer_file/program/nuclear_monitor
	filename = "rbmkmonitor"
	filedesc = "Nuclear Reactor Monitoring"
	ui_header = "smmon_0.gif"
	program_icon_state = "smmon_0"
	extended_desc = "This program connects to specially calibrated sensors to provide information on the status of nuclear reactors."
	requires_ntnet = TRUE
	transfer_access = ACCESS_ENGINE
	//network_destination = "rbmk monitoring system" dont need anymore?
	size = 2
	tgui_id = "NtosRbmkStats"
	var/active = TRUE //Easy process throttle
	var/next_stat_interval = 0
	var/list/psiData = list()
	var/list/powerData = list()
	var/list/tempInputData = list()
	var/list/tempOutputdata = list()
	var/obj/machinery/atmospherics/components/trinary/nuclear_reactor/reactor //Our reactor.

/datum/computer_file/program/nuclear_monitor/process_tick()
	..()
	if(!reactor || !active)
		return FALSE
	var/stage = 0
	//This is dirty but i'm lazy wahoo!
	if(reactor.power > 0)
		stage = 1
	if(reactor.power >= 40)
		stage = 2
	if(reactor.temperature >= RBMK_TEMPERATURE_OPERATING)
		stage = 3
	if(reactor.temperature >= RBMK_TEMPERATURE_CRITICAL)
		stage = 4
	if(reactor.temperature >= RBMK_TEMPERATURE_MELTDOWN)
		stage = 5
		if(reactor.vessel_integrity <= 100) //Bye bye! GET OUT!
			stage = 6
	ui_header = "smmon_[stage].gif"
	program_icon_state = "smmon_[stage]"
	if(istype(computer))
		computer.update_icon()
	if(world.time >= next_stat_interval)
		next_stat_interval = world.time + 1 SECONDS //You only get a slow tick.
		psiData += (reactor) ? reactor.pressure : 0
		if(psiData.len > 100) //Only lets you track over a certain timeframe.
			psiData.Cut(1, 2)
		powerData += (reactor) ? reactor.power*10 : 0 //We scale up the figure for a consistent:tm: scale
		if(powerData.len > 100) //Only lets you track over a certain timeframe.
			powerData.Cut(1, 2)
		tempInputData += (reactor) ? reactor.last_coolant_temperature : 0 //We scale up the figure for a consistent:tm: scale
		if(tempInputData.len > 100) //Only lets you track over a certain timeframe.
			tempInputData.Cut(1, 2)
		tempOutputdata += (reactor) ? reactor.last_output_temperature : 0 //We scale up the figure for a consistent:tm: scale
		if(tempOutputdata.len > 100) //Only lets you track over a certain timeframe.
			tempOutputdata.Cut(1, 2)

/datum/computer_file/program/nuclear_monitor/run_program(mob/living/user)
	. = ..(user)
	//No reactor? Go find one then.
	if(!reactor)
		for(var/obj/machinery/atmospherics/components/trinary/nuclear_reactor/R in GLOB.machines)
			if(R.z == usr.z)
				reactor = R
				break
	active = TRUE

/datum/computer_file/program/nuclear_monitor/kill_program(forced = FALSE)
	active = FALSE
	..()

/datum/computer_file/program/nuclear_monitor/ui_data()
	var/list/data = get_header_data()
	data["powerData"] = powerData
	data["psiData"] = psiData
	data["tempInputData"] = tempInputData
	data["tempOutputdata"] = tempOutputdata
	data["coolantInput"] = reactor ? reactor.last_coolant_temperature : 0
	data["coolantOutput"] = reactor ? reactor.last_output_temperature : 0
	data["power"] = reactor ? reactor.power : 0
	data ["psi"] = reactor ? reactor.pressure : 0
	return data

/datum/computer_file/program/nuclear_monitor/ui_act(action, params)
	if(..())
		return TRUE

	switch(action)
		if("swap_reactor")
			var/list/choices = list()
			for(var/obj/machinery/atmospherics/components/trinary/nuclear_reactor/R in GLOB.machines)
				if(R.z != usr.z)
					continue
				choices += R
			reactor = input(usr, "What reactor do you wish to monitor?", "[src]", null) as null|anything in choices
			powerData = list()
			psiData = list()
			tempInputData = list()
			tempOutputdata = list()
			return TRUE

/obj/effect/decal/nuclear_waste
	name = "Plutonium sludge"
	desc = "A writhing pool of heavily irradiated, spent reactor fuel. You probably shouldn't step through this..."
	icon = 'icons/obj/machines/reactor_parts.dmi'
	icon_state = "nuclearwaste"
	alpha = 150
	light_color = LIGHT_COLOR_CYAN
	color = "#ff9eff"

/obj/effect/decal/nuclear_waste/Initialize()
	. = ..()
	for(var/obj/A in get_turf(src))
		if(istype(A, /obj/structure))
			qdel(src) //It is more processing efficient to do this here rather than when searching for available turfs.
	set_light(3)
	AddComponent(/datum/component/radioactive, 1000, src, 0)

/obj/effect/decal/nuclear_waste/epicenter //The one that actually does the irradiating. This is to avoid every bit of sludge PROCESSING
	name = "Dense nuclear sludge"

/obj/effect/landmark/nuclear_waste_spawner //Clean way of spawning nuclear gunk after a reactor core meltdown.
	name = "Nuclear waste spawner"
	var/range = 15 //15 tile radius to spawn goop

/obj/effect/landmark/nuclear_waste_spawner/strong
	range = 30

/obj/effect/landmark/nuclear_waste_spawner/proc/fire()
	playsound(loc, 'sound/effects/gib_step.ogg', 100)
	new /obj/effect/decal/nuclear_waste/epicenter(get_turf(src))
	for(var/turf/open/floor in orange(range, get_turf(src)))
		if(prob(35)) //Scatter the sludge, don't smear it everywhere
			new /obj/effect/decal/nuclear_waste (floor)
	qdel(src)

/obj/effect/decal/nuclear_waste/epicenter/Initialize()
	. = ..()

/obj/effect/decal/nuclear_waste/Crossed(atom/movable/AM)
	. = ..()
	if(isliving(AM))
		var/mob/living/L = AM
		playsound(loc, 'sound/effects/gib_step.ogg', HAS_TRAIT(L, TRAIT_LIGHT_STEP) ? 20 : 50, 1)
	radiation_pulse(src, 500, 5) //MORE RADS

/obj/effect/decal/nuclear_waste/attackby(obj/item/tool, mob/user)
	if(tool.tool_behaviour == TOOL_SHOVEL)
		radiation_pulse(src, 1000, 5) //MORE RADS
		to_chat(user, "<span class='notice'>You start to clear [src]...</span>")
		if(tool.use_tool(src, user, 50, volume=100))
			to_chat(user, "<span class='notice'>You clear [src]. </span>")
			qdel(src)
			return
	. = ..()

/datum/weather/nuclear_fallout
	name = "nuclear fallout"
	desc = "Irradiated dust falls down everywhere."
	telegraph_duration = 50
	telegraph_message = "<span class='boldwarning'>The air suddenly becomes dusty..</span>"
	weather_message = "<span class='userdanger'><i>You feel a wave of hot ash fall down on you.</i></span>"
	weather_overlay = "light_ash"
	telegraph_overlay = "light_snow"
	weather_duration_lower = 600
	weather_duration_upper = 1500
	weather_color = "green"
	telegraph_sound = null
	weather_sound = 'sound/effects/reactor/falloutwind.ogg'
	end_duration = 100
	area_type = /area
	protected_areas = list(/area/maintenance, /area/ai_monitored/turret_protected/ai_upload, /area/ai_monitored/turret_protected/ai_upload_foyer,
	/area/ai_monitored/turret_protected/ai, /area/shuttle)
	target_trait = ZTRAIT_STATION
	end_message = "<span class='notice'>The ash stops falling.</span>"
	immunity_type = "rad"

/datum/weather/nuclear_fallout/weather_act(mob/living/L)
	L.rad_act(100)

/datum/weather/nuclear_fallout/telegraph()
	..()
	status_alarm(TRUE)

/datum/weather/nuclear_fallout/proc/status_alarm(active)	//Makes the status displays show the radiation warning for those who missed the announcement.
	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)
	if(!frequency)
		return

	var/datum/signal/signal = new
	if (active)
		signal.data["command"] = "alert"
		signal.data["picture_state"] = "radiation"
	else
		signal.data["command"] = "shuttle"

	var/atom/movable/virtualspeaker/virt = new(null)
	frequency.post_signal(virt, signal)

/datum/weather/nuclear_fallout/end()
	if(..())
		return
	status_alarm(FALSE)

/obj/item/sealant
	name = "Flexi seal"
	desc = "A neat spray can that can repair torn inflatable segments, and more!"
	icon = 'icons/obj/inflatable.dmi'
	icon_state = "sealant"
	w_class = 1

/area/engineering/main/reactor_core
	name = "Nuclear Reactor Core"

/area/engineering/main/reactor_control
	name = "Reactor Control Room"


//Procs shamelessly taken from machinery/power
/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/connect_to_network()
	var/turf/T = src.loc
	if(!T || !istype(T))
		return FALSE

	var/obj/structure/cable/C = T.get_cable_node() //check if we have a node cable on the machine turf, the first found is picked
	if(!C || !C.powernet)
		return FALSE

	C.powernet.add_machine(src)
	return TRUE

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/disconnect_from_network()
	if(!powernet)
		return FALSE
	powernet.remove_machine(src)
	return TRUE

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/add_avail(amount)
	if(powernet)
		powernet.newavail += amount
		return TRUE
	else
		return FALSE
