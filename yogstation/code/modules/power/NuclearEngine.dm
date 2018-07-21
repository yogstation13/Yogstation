#define FUELHATCH_OPEN 2
#define WASTEHATCH_OPEN 4

//NOTES!
/*
According to players, the average usage is 160 KW, or 160,000 watts. So that's the lowest target to hit. Right now it hits around 4000 watts
*/

/obj/machinery/power/NuclearReactor
	name = "Nuclear Reactor Core"
	desc = "The core part of a primitive nuclear reactor. The new Nt-STE-VENS linup uses bluespace induction techniques to get more neutrons out of whatever fuel you put in by accelerating them to the speed of light."
	icon = 'icons/obj/reactor.dmi'
	icon_state = "reactor"
	critical_machine = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	var/datum/nuclearreaction/react = new //J!nx here with another reaction video
	var/Heat = 0 //how hot are we as a percent, so up to 100
	var/Efficiency = 0 //Efficiency is how quickly you chew through fuel, but it also affects heat produced, so you want a midpoint
	var/HeatRate = 0
	var/Power = 0
	var/Time = 0
	var/state //Bitflag for tracking states
	var/obj/effect/reactoroverlay/fuelhatch/fuel = new
	var/obj/effect/reactoroverlay/wastehatch/waste = new
	var/obj/effect/reactoroverlay/monitor/monitor = new
	var/emagged = FALSE
	var/input_power_multiplier = 1 //For upgrading it with new parts
	var/obj/machinery/atmospherics/components/binary/pump/nuclear/inlet
	var/obj/machinery/atmospherics/components/binary/pump/nuclear/outlet


//COOL STUFF: PIPES AIR CONTAINER: AIRS | AIR TEMPERATURE VAR: TEMPERATURE (K) aim for 1000 for turbines!
//var/newrpm = ((compressor.gas_contained.temperature) * compressor.gas_contained.total_moles())/4



/obj/effect/reactoroverlay
	name = "reactor component"
	desc = "why are you seeing this"
	icon = 'icons/obj/reactor.dmi'
	icon_state = "hatch-closed"

/obj/effect/reactoroverlay/fuelhatch
	icon_state = "hatch-closed"

/obj/effect/reactoroverlay/wastehatch
	icon_state = "wastehatch-closed"

/obj/effect/reactoroverlay/monitor
	icon_state = "monitor-off"

/obj/machinery/power/NuclearReactor/CtrlClick(mob/user)
	if(state & FUELHATCH_OPEN)
		state &= ~FUELHATCH_OPEN //Bitflags! We add the OPPOSITE of fuelhatch open to "state", in other words, inverting it, if the hatch is open, this closes it
		playsound(loc, 'sound/effects/bin_close.ogg',50,1)
		to_chat(user,"You shut the fuel hatch")
	else
		state |= FUELHATCH_OPEN
		playsound(loc, 'sound/effects/bin_open.ogg',50,1)
		to_chat(user,"You open the fuel hatch")
	UpdateIcon()

/obj/machinery/power/NuclearReactor/AltClick(mob/user)
	if(state & WASTEHATCH_OPEN)
		state &= ~WASTEHATCH_OPEN //Bitflags! We add the OPPOSITE of wastehatch open to "state", in other words, inverting it, if the hatch is open, this closes it
		playsound(loc, 'sound/effects/bin_close.ogg',50,1)
		to_chat(user,"You shut the access hatch")
	else
		state |= WASTEHATCH_OPEN
		playsound(loc, 'sound/effects/bin_open.ogg',50,1)
		to_chat(user,"You open the access hatch")
	UpdateIcon()

/obj/machinery/power/NuclearReactor/proc/UpdateIcon()
	cut_overlays()
	waste.icon_state = "wastehatch-closed"
	fuel.icon_state = "hatch-closed"
	if(state & FUELHATCH_OPEN)
		fuel.icon_state = "hatch-open"
	if(state & WASTEHATCH_OPEN)
		waste.icon_state = "wastehatch-open"
	if(Heat >= 100)
		monitor.icon_state = "monitor-low"
	if(Heat > 500)
		monitor.icon_state = "monitor-med"
	if(Heat > 1000)
		monitor.icon_state = "monitor-high"
	if(Heat > 2000) //At this stage. Worry. A lot.
		monitor.icon_state = "monitor-warning"
		if(prob(5))
			playsound(loc,'sound/misc/bloblarm.ogg',50)
	add_overlay(waste)
	add_overlay(fuel)
	add_overlay(monitor)

/obj/machinery/power/NuclearReactor/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/twohanded/required/FuelRod))
		if(state & FUELHATCH_OPEN)
			to_chat(user, "You slot [I] into [src]!")
			I.forceMove(src)
			react.FRS += I
		else
			to_chat(user, "Open the fuel hatch first!")
	if(istype(I, /obj/item/twohanded/required/ControlRod))
		to_chat(user, "You slot [I] into [src]!")
		I.forceMove(src)
		react.CRS += I

/obj/machinery/power/NuclearReactor/attack_hand(mob/user)
	if(state & WASTEHATCH_OPEN)
		var/obj/C = input(user, "Remove what?", "Reactor Control Hatch") as null|obj in contents
		C.forceMove(get_turf(user))
		to_chat(user, "You carefully slide [C] out of [src]")
		if(prob(20))
			radiation_pulse(src, 5)
	else
		start()

/obj/machinery/power/NuclearReactor/Initialize()
	. = ..()
	react.reactor = src
	UpdateIcon()
	state |= FUELHATCH_OPEN
	state |= WASTEHATCH_OPEN
	connect_to_network()
	inlet = new(src.loc)
	var/obj/dummy = new(src.loc) //Handle placing pipes properly
	dummy.alpha = 0
	inlet.name = "[src] gas inlet port"
	inlet.dir = NORTH
	dummy.y += 1 //1 tile above the inlet
	var/obj/machinery/atmospherics/pipe/nuclear/S = new(dummy.loc) //Place a pipe above the inlet
	S.name = "[src] gas transfer pipe"
	S.dir = NORTH
	dummy.y += 1
	outlet = new(dummy.loc) //Put the outlet behind the whole reactor sprite, so people can actually access it
	outlet.dir = NORTH //Face right
	qdel(dummy)

/obj/machinery/power/NuclearReactor/proc/CheckPipes() //In case your pipes blow up
	outlet = null
	inlet = null
	var/obj/dummy = new(loc)
	dummy.alpha = 0
	for(var/B in loc)
		if(!istype(B, /obj/machinery/atmospherics/components/binary))
			return
		inlet = B
		break
	dummy.y += 2
	for(var/A in dummy.loc)
		if(!istype(A, /obj/machinery/atmospherics/components/binary))
			return
		outlet = A
		break
	qdel(dummy)
	say("Success! Inlet pump registered as [inlet], outlet pump registered as [outlet]")

/obj/machinery/power/NuclearReactor/Destroy()
	disconnect_from_network()
	. = ..()

/obj/machinery/power/NuclearReactor/proc/start()
	if(!powernet)
		connect_to_network()
	if(state & FUELHATCH_OPEN || state & WASTEHATCH_OPEN)
		say("Warning! A hatch is still open! Please close it before trying this!")
		return
	say("Reaction started!")
	Heat += 1 //kickstart it
	START_PROCESSING(SSmachines,src)

/obj/machinery/power/NuclearReactor/process()
	UpdateIcon()
	ProcessAtmos()
	if(state & FUELHATCH_OPEN || state & WASTEHATCH_OPEN)
		if(!emagged)
			radiation_pulse(src, Heat/2) //You fucked up kid
			stop()
			return
	Time ++
	react.ConsumeFuel()
	Heat = GetHeat()
	//Efficiency = GetEfficiency() gonna play round with this temporarily
	HeatRate += GetHeatIncreaseCoeff()
	Heat += HeatRate
	if(Heat >0)
		Power = GetPower()
	say("Heat: [Heat]")
	say("Efficiency: [Efficiency]")
	if(Heat <= 0)
		stop()
		return

/obj/machinery/power/NuclearReactor/proc/ProcessAtmos()
	for(var/datum/gas_mixture/S in inlet.airs)
		S.temperature += Heat
		say("WATER VAPOUR TEMPERATURE: [S.temperature]")

/obj/machinery/power/NuclearReactor/proc/stop()
	if(Heat <= 0)
		STOP_PROCESSING(SSmachines,src)
		Time = 0
		Heat = 0
		HeatRate = 0

/obj/machinery/power/NuclearReactor/proc/GetPower(var/C = 2) //C is changeable for balance as you see fit. You can also change input power modifier.
	return Heat^C * Efficiency * C

/obj/machinery/power/NuclearReactor/proc/GetHeat()
	return HeatRate*Time

/obj/machinery/power/NuclearReactor/proc/GetHeatIncreaseCoeff(var/C = 1) //Where C is how strong the reaction is
	return react.GetFuelAmounts()*C //So let's pretend we have 2 CRs and 6 FRs, 2 CRs subtracts 2 heat from this tick, but the FRs add 10 more, so you get +10 heat per tick. Heat is good for the reactor, but too much = the big boom boom

//As we know from physics class, efficiency is helped by cooling it down, so at this point in the reaction your efficiency will be helped by some nice n2, for now we'll simulate n2 with vars.
/obj/machinery/power/NuclearReactor/proc/GetEfficiency(var/temp = 1,var/amt = 1) //As a percent
	return (1/temp) * amt

/datum/nuclearreaction
	var/name = "nuclear reaction"
	var/FuelAmt = 0 //How much fuel
	var/CombFuelPower = 0 //And combined, how strong are all our fuels
	var/list/obj/item/twohanded/required/ControlRod/CRS = list()
	var/list/obj/item/twohanded/required/FuelRod/FRS = list()
	var/DepletedAmt = 0 //How much of the uranium has been depleted, and thus acts like control rods?
	var/obj/machinery/power/NuclearReactor/reactor

/datum/nuclearreaction/proc/GetFuelAmounts()
	var/AmtSubtract
	for(var/obj/item/twohanded/required/ControlRod/CR in CRS)
		if(!istype(CR,/obj/item/twohanded/required/ControlRod))
			return
		AmtSubtract += CR.ControlPower
	var/AmtAdd
	for(var/obj/item/twohanded/required/FuelRod/FR in FRS)
		if(!istype(FR,/obj/item/twohanded/required/FuelRod))
			return
		AmtAdd += FR.FuelPower
	return AmtAdd - AmtSubtract //IE, AmtSubtract with one CR = 1, AmtAdd with 2 Uranium = 4, so resultant reaction power is 3, which also means a heat spike

/datum/nuclearreaction/proc/ConsumeFuel()
	for(var/obj/item/twohanded/required/FuelRod/FR in FRS)
		if(FR.loc != reactor || !FR in reactor.contents)
			FRS -= FR
		if(!istype(FR,/obj/item/twohanded/required/FuelRod))
			return
		if(FR.integrity <= 0) //That rod's spent, make it into DU
			reactor.say("[FR] died!")
			DepletedAmt ++
			qdel(FR)
			FRS -= FR
			FR = null
			var/obj/item/twohanded/required/FuelRod/depleted/spent = new
			FRS += spent
			spent.forceMove(reactor)
			return
		if(!istype(FR, /obj/item/twohanded/required/FuelRod/depleted)) //Depleted rods don't deplete further, they just interrupt heat
			FR.integrity -= 10 - reactor.Efficiency/10 // Eg, 100/10 = 10, so integrity -= 0 aka no health lost, 25 = 2.5, so 8.5 health lost, so keep that efficiency up!
	for(var/obj/item/twohanded/required/ControlRod/CR in CRS)
		if(!istype(CR,/obj/item/twohanded/required/ControlRod))
			return
		if(CR.integrity <= 10) //CR is spent!
			qdel(CR)
			reactor.say("[CR] died!")
		CR.integrity -= 10 - reactor.Efficiency/10

/obj/item/twohanded/required/ControlRod
	name = "Carbon Control Rod"
	desc = "A huge rod of carbon used for nuclear reactors."
	icon = 'icons/obj/ControlRod.dmi'
	icon_state = "carbonrod"
	var/integrity = 1000 //As rods become worn, they are damaged.
	max_integrity = 1000
	var/obj/machinery/power/NuclearReactor/reactor
	var/ControlPower = 0.4 // 1 Rod of this will halve the power of 1 uranium fuel rod

/obj/item/twohanded/required/FuelRod
	name = "Uranium Fuel Rod"
	desc = "A huge stick of uranium to be inserted into a nuclear reactor"
	icon = 'icons/obj/ControlRod.dmi'
	icon_state = "uraniumrod"
	var/integrity = 1000//As rods become worn, they are damaged.
	max_integrity = 1000
	var/obj/machinery/power/NuclearReactor/reactor
	var/FuelPower = 0.7 //How strong is this fuel rod? higher = more heat produced

/obj/item/twohanded/required/Plasma
	name = "Plasma Fuel Rod"
	desc = "A huge stick of plasma to be inserted into a nuclear reactor. It has a small label haphazardly stuck to it: WARNING, UNCONTROLLED USE OF THIS WILL OVERHEAT REACTOR. USE AT OWN RISK!"
	icon = 'icons/obj/ControlRod.dmi' //This isn't a question of if it fucks your setup up... It's when.
	icon_state = "plasmarod"
	var/integrity = 1000//As rods become worn, they are damaged.
	max_integrity = 1000
	var/obj/machinery/power/NuclearReactor/reactor
	var/FuelPower = 7 //How strong is this fuel rod? higher = more heat produced

/obj/item/twohanded/required/FuelRod/depleted
	name = "Depleted Fuel Rod"
	desc = "A depleted stick of uranium, please dispose of safely!"
	icon_state = "depletedrod"
	FuelPower = -2


#undef FUELHATCH_OPEN
#undef WASTEHATCH_OPEN

/obj/machinery/atmospherics/pipe/nuclear
	icon = 'icons/obj/atmospherics/pipes/nuclear.dmi'
	name = "pipe manifold"
	desc = "A huge pipe that carries water to and from a nuclear reactor, it has ports to connect it to standard pipes on each end and you could probably climb over it."
	icon_state = "intact"
	dir = SOUTH
	initialize_directions = SOUTH|NORTH
	pipe_flags = PIPING_CARDINAL_AUTONORMALIZE
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER
	anchored = TRUE
	density = TRUE //Can't just walk over these massive pipes

	device_type = BINARY

	construction_type = null

/obj/machinery/atmospherics/pipe/nuclear/SetInitDirections()
	normalize_cardinal_directions()
	if(dir in GLOB.diagonals)
		initialize_directions = dir
	switch(dir)
		if(NORTH,SOUTH)
			initialize_directions = SOUTH|NORTH
		if(EAST,WEST)
			initialize_directions = EAST|WEST

/obj/machinery/atmospherics/components/binary/pump/nuclear
	icon = 'icons/obj/atmospherics/pipes/nuclear.dmi'
	name = "large gas pump"
	desc = "A huge pump"

	can_unwrench = TRUE

	construction_type = null
	pipe_state = "pump"


/obj/machinery/power/compressor/nuclear
	name = "industrial grade reactor compressor"
	icon = 'icons/obj/atmospherics/pipes/nuclear.dmi'
	desc = "A high grade compressor fitted with a precooler stage, allowing for much more efficient usage of hot gasses pumped out from a reactor."

/obj/machinery/power/turbine/nuclear
	name = "industrial grade gas turbine generator"
	desc = "A gas turbine used for backup power generation."
	icon = 'icons/obj/atmospherics/pipes/nuclear.dmi'
	desc = "A high grade turbine engine, no expense has been spared on this unit, which has been modified with bluespace technology, allowing for its turbines to spin in multiple dimensions simultaneously, producing sufficient power to power an entire station."
	productivity = 6