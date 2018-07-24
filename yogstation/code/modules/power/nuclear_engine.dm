#define FUELHATCH_OPEN 2
#define WASTEHATCH_OPEN 4
#define LOW_HEAT 100
#define MEDIUM_HEAT 200
#define HIGH_HEAT 500
#define CRITICAL_HEAT 800
#define MELTDOWN 1000

//NOTES!
/*
According to players, the average usage is 160 KW, or 160,000 watts. So that's the lowest target to hit. Right now it hits around 4000 watts
*/

/obj/machinery/power/NuclearReactor
	name = "Nuclear Reactor Core"
	desc = "A massive nuclear reactor with an inbuilt cooling spire, two access hatches, and a large port for attaching atmos pipes to, <I>Alt Click</I> the reactor to open its access port for removal of objects, and <B>CTRL Click</B> the reactor to open / close its fuel port, you can also use a wrench to detect any pipes you've put under it. The Nt-STE-VENS series of reactors are a testament to the old saying 'If it ain't broke, don't fix it'"
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
	var/obj/machinery/atmospherics/components/binary/pump/nuclear/outlet
	var/WarningSoundCooldown = 460 //51 seconds long, and process() is quite slow, so this works
	var/SavedWarningTime = 0 //For cooldowns
	var/WarningSound = 'yogstation/sound/effects/CoreOverheating.ogg'
	var/MeltDownSound = 'yogstation/sound/effects/Meltdown.ogg'
	var/ReactorInoperable = FALSE
	density = TRUE
//	var/CoreHealth = 1000 //This gets chipped away when you run it above its temperature tolerance

/obj/machinery/power/NuclearReactor/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='warning'>Its heat readout reads: [Heat] K, its maximum tolerance limit is [CRITICAL_HEAT] K.</span>")


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
		to_chat(user,"You shut the fuel hatch.")
	else
		state |= FUELHATCH_OPEN
		playsound(loc, 'sound/effects/bin_open.ogg',50,1)
		to_chat(user,"You open the fuel hatch.")
	UpdateIcon()

/obj/machinery/power/NuclearReactor/AltClick(mob/user)
	if(state & WASTEHATCH_OPEN)
		state &= ~WASTEHATCH_OPEN //Bitflags! We add the OPPOSITE of wastehatch open to "state", in other words, inverting it, if the hatch is open, this closes it
		playsound(loc, 'sound/effects/bin_close.ogg',50,1)
		to_chat(user,"You shut the access hatch.")
	else
		state |= WASTEHATCH_OPEN
		playsound(loc, 'sound/effects/bin_open.ogg',50,1)
		to_chat(user,"You open the access hatch.")
	UpdateIcon()

/obj/machinery/power/NuclearReactor/proc/UpdateIcon()
	cut_overlays()
	waste.icon_state = "wastehatch-closed"
	fuel.icon_state = "hatch-closed"
	if(state & FUELHATCH_OPEN)
		fuel.icon_state = "hatch-open"
	if(state & WASTEHATCH_OPEN)
		waste.icon_state = "wastehatch-open"
	if(Heat >= LOW_HEAT)
		monitor.icon_state = "monitor-low"
	if(Heat > MEDIUM_HEAT)
		monitor.icon_state = "monitor-med"
	if(Heat > HIGH_HEAT)
		monitor.icon_state = "monitor-high"
	if(Heat > CRITICAL_HEAT) //At this stage. Worry. A lot.
		monitor.icon_state = "monitor-warning"
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
	if(istype(I, /obj/item/wrench))
		CheckPipes()

/obj/machinery/power/NuclearReactor/attack_hand(mob/user)
	if(!ReactorInoperable)
		if(state & WASTEHATCH_OPEN)
			var/obj/C = input(user, "Remove what?", "Reactor Control Hatch") as null|obj in contents
			C.forceMove(get_turf(user))
			to_chat(user, "You carefully slide [C] out of [src]")
			if(istype(C,/obj/item/twohanded/required/FuelRod))
				react.FRS -= C
			if(istype(C,/obj/item/twohanded/required/ControlRod))
				react.CRS -= C
			if(prob(20))
				radiation_pulse(src, 5, 10)
		else
			start()
	else
		radiation_pulse(src, 100, 20)

/obj/machinery/power/NuclearReactor/Initialize()
	. = ..()
	react.reactor = src
	UpdateIcon()
	state |= FUELHATCH_OPEN
	state |= WASTEHATCH_OPEN
	connect_to_network()
//	outlet = new(src.loc)
	outlet = locate(/obj/machinery/atmospherics/components/binary/pump) in get_step(src, NORTH)
	STOP_PROCESSING(SSmachines,src)

/obj/machinery/power/NuclearReactor/proc/CheckPipes() //In case your pipes blow up
	outlet = null
	outlet = locate(/obj/machinery/atmospherics/components/binary/pump) in get_step(src, NORTH)
	if(outlet)
		say("Success: Outlet pump registered as [outlet].")
		return TRUE
	else
		say("Error: No outlet pump could be found!")
		return FALSE

/obj/machinery/power/NuclearReactor/Destroy()
	disconnect_from_network()
	. = ..()

/obj/machinery/power/NuclearReactor/proc/start()
	if(!outlet)
		say("<span class='warning'>ERROR: No outlet found, please attach a standard atmospherics pump on the highlighted tile to the left! (one tile above the reactor)<span>")
	if(!powernet)
		connect_to_network()
	if(state & FUELHATCH_OPEN || state & WASTEHATCH_OPEN)
		say("<span class='warning'>Warning! A hatch is still open! Please close it before trying this!</span>")
		return
	say("Reaction started!")
	Heat += 1 //kickstart it
	START_PROCESSING(SSmachines,src)

/obj/machinery/power/NuclearReactor/process()
	if(ReactorInoperable)
		stop()
		return
	UpdateIcon()
	ProcessAtmos()
	CheckState()
	Time ++
	react.ConsumeFuel()
//	Heat = GetHeat()
	//Efficiency = GetEfficiency() gonna play round with this temporarily
	HeatRate = react.GetFuelAmounts()
	Heat -= react.GetCoolAmounts()
	if(HeatRate > 0)
		Heat += HeatRate
	if(Heat <= 0)
		stop()
		return

/obj/machinery/power/NuclearReactor/proc/MeltdownAnnounce() //Announce the meltdown to give them a chance to RUN
	stop()
	ReactorInoperable = TRUE
	priority_announce("Nuclear reactor status: CRITICAL Meltdown imminent! Evacuate engineering section IMMEDIATELY", "Nuclear Reactor Monitoring Subsystem",'sound/ai/attention.ogg')
	addtimer(CALLBACK(src, .proc/Meltdown), 410) //It's the final countdown
	for(var/mob/M in GLOB.player_list)
		if(M.z == z)
			M << null //Don't want to assault their eardrums
			M << MeltDownSound

/obj/machinery/power/NuclearReactor/proc/Meltdown() //qdel(station)
	explosion(get_turf(src),20,40,30, 100, ignorecap=TRUE)
	var/datum/round_event_control/radiation_storm/RS = new()
	RS.runEvent()
	fuel = null
	monitor = null
	waste = null
	cut_overlays()
	icon_state = "reactor-broken"
	for(var/turf/T in orange(src, 10))
		new /obj/effect/nuclearwaste(T)


/obj/machinery/power/NuclearReactor/proc/CheckState()
	if(state & FUELHATCH_OPEN || state & WASTEHATCH_OPEN)
		radiation_pulse(src, Heat, 40) //You fucked up kid
	if(Heat >= MELTDOWN) //Oh FUCK
		MeltdownAnnounce()
		return
	if(Heat >= CRITICAL_HEAT)
		radiation_pulse(src, Heat*2, 60)
		if(world.time >= SavedWarningTime + WarningSoundCooldown)
			SavedWarningTime = world.time
			for(var/mob/M in GLOB.player_list)
				if(M.z == z)
					M << WarningSound
		else
			return

/obj/machinery/power/NuclearReactor/proc/ProcessAtmos()
	for(var/datum/gas_mixture/S in outlet.airs)
		if(S.temperature <= 20000) //A small nerf to avoid ambient temperatures in the room reaching 2000 degrees
			var/num = Heat
			if(num <= 0)
				num = 0
			S.temperature += num

/obj/machinery/power/NuclearReactor/proc/stop()
	STOP_PROCESSING(SSmachines,src)
	Heat = 0
	HeatRate = 0

//obj/machinery/power/NuclearReactor/proc/GetHeat()
//	return HeatRate*Time

/obj/machinery/power/NuclearReactor/proc/GetHeatIncreaseCoeff() //Where C is how strong the reaction is
	return react.GetFuelAmounts() //So let's pretend we have 2 CRs and 6 FRs, 2 CRs subtracts 2 heat from this tick, but the FRs add 10 more, so you get +10 heat per tick. Heat is good for the reactor, but too much = the big boom boom

//As we know from physics class, efficiency is helped by cooling it down, so at this point in the reaction your efficiency will be helped by some nice n2, for now we'll simulate n2 with vars.
/obj/machinery/power/NuclearReactor/proc/GetEfficiency(var/temp = 1,var/amt = 1) //As a percent
	return (1/temp) * amt

/datum/nuclearreaction
	var/name = "nuclear reaction"
	var/list/obj/item/twohanded/required/ControlRod/CRS = list()
	var/list/obj/item/twohanded/required/FuelRod/FRS = list()
	var/obj/machinery/power/NuclearReactor/reactor

/datum/nuclearreaction/proc/GetCoolAmounts()
	var/AmtSubtract
	var/frum = 0
	for(var/obj/item/twohanded/required/ControlRod/CR in CRS)
		if(!istype(CR,/obj/item/twohanded/required/ControlRod))
			return
		AmtSubtract += CR.ControlPower
	for(var/obj/item/twohanded/required/FuelRod/FR in FRS)
		if(!istype(FR,/obj/item/twohanded/required/FuelRod))
			return
		AmtSubtract += FR.FuelPenalty
		frum ++
	if(!frum || frum <=0) //No fuel? Drain that heat fast lad
		AmtSubtract += 2
	if(AmtSubtract <= 0)
		AmtSubtract = 0
	return AmtSubtract


/datum/nuclearreaction/proc/GetFuelAmounts()
	var/AmtAdd
	for(var/obj/item/twohanded/required/FuelRod/FR in FRS)
		if(!istype(FR,/obj/item/twohanded/required/FuelRod))
			return
		AmtAdd += FR.FuelPower
	var/final = AmtAdd
	return final //IE, AmtSubtract with one CR = 1, AmtAdd with 2 Uranium = 4, so resultant reaction power is 3, which also means a heat spike

/datum/nuclearreaction/proc/ConsumeFuel()
	for(var/obj/item/twohanded/required/FuelRod/FR in FRS)
		if(FR.loc != reactor || !FR in reactor.contents)
			FRS -= FR
		if(!istype(FR,/obj/item/twohanded/required/FuelRod))
			return
		if(FR.integrity <= 0) //That rod's spent, make it into DU
			reactor.say("<span class='warning'>[FR] has been depleted.<span>")
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
		if(CR.loc != reactor || !CR in reactor.contents)
			CRS -= CR
		if(!istype(CR,/obj/item/twohanded/required/ControlRod))
			return
		if(CR.integrity <= 10) //CR is spent!
			qdel(CR)
			reactor.say("<span class='warning'>[CR] has worn out.<span>")
		CR.integrity -= 10 - reactor.Efficiency/10

/obj/item/twohanded/required/ControlRod
	name = "Carbon Control Rod"
	desc = "A huge rod of carbon used for nuclear reactors. It is inert."
	icon = 'icons/obj/control_rod.dmi'
	icon_state = "carbonrod"
	var/integrity = 10000 //As rods become worn, they are damaged.
	max_integrity = 10000
	var/obj/machinery/power/NuclearReactor/reactor
	var/ControlPower = 4.8 // 1 Rod of this will cockblock 1 fuel rod

/obj/item/twohanded/required/FuelRod
	name = "Uranium Fuel Rod"
	desc = "A huge stick of uranium to be inserted into a nuclear reactor, its casing is in tact, mitigating most of its radioactive output"
	icon = 'icons/obj/control_rod.dmi'
	icon_state = "uraniumrod"
	var/integrity = 10000//As rods become worn, they are damaged.
	max_integrity = 10000
	var/obj/machinery/power/NuclearReactor/reactor
	var/FuelPower = 5 //How strong is this fuel rod? higher = more heat produced
	var/radiation_strength = 10
	var/FuelPenalty = 0

/obj/item/twohanded/required/FuelRod/attack_hand(mob/user)
	radiation_pulse(src,radiation_strength, 2)
	. = ..()

/obj/item/twohanded/required/FuelRod/plasma
	name = "Plasma Fuel Rod"
	desc = "A huge stick of plasma to be inserted into a nuclear reactor. It has a small label haphazardly stuck to it: WARNING, UNCONTROLLED USE OF THIS WILL OVERHEAT REACTOR. USE AT OWN RISK!" //This isn't a question of if it fucks your setup... It's when.
	icon_state = "plasmarod"
	integrity = 1000//As rods become worn, they are damaged.
	max_integrity = 1000
	FuelPower = 15 //How strong is this fuel rod? higher = more heat produced
	radiation_strength = 0

/obj/item/twohanded/required/FuelRod/depleted
	name = "Depleted Fuel Rod"
	desc = "A depleted stick of uranium, its casing is damaged and worn. You should dispose of this quickly."
	icon_state = "depletedrod"
	FuelPower = 0
	FuelPenalty = 2
	radiation_strength = 30

/obj/effect/nuclearwaste
	name = "nuclear waste"
	desc = "A highly radioactive pool of sludge; the remains of a nuclear reactor that went critical."
	icon = 'icons/obj/atmospherics/pipes/nuclear.dmi'
	icon_state = "nuclearwaste"

/obj/effect/nuclearwaste/attackby() //You need to contain it
	return 0

/obj/effect/nuclearwaste/Initialize()
	START_PROCESSING(SSobj,src)

/obj/effect/nuclearwaste/process()
	radiation_pulse(src, 500, 50)

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
//	density = TRUE //Can't just walk over these massive pipes
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

/obj/machinery/atmospherics/pipe/manifold4w/nuclear
	icon = 'icons/obj/atmospherics/pipes/nuclear.dmi'
	icon_state = "manifold4w"
	name = "4-way pipe manifold"
	desc = "A manifold composed of large pipes."
	layer = GAS_PIPE_VISIBLE_LAYER
	anchored = TRUE
	level = PIPE_VISIBLE_LEVEL
//	density = TRUE //Can't just walk over these massive pipes

/obj/machinery/atmospherics/pipe/manifold4w/nuclear/update_icon()
	return

/obj/machinery/atmospherics/pipe/manifold/general/visible/nuclear/update_icon()
	return

/obj/machinery/atmospherics/pipe/manifold/general/visible/nuclear
	icon = 'icons/obj/atmospherics/pipes/nuclear.dmi'
	name = "pipe manifold"
	desc = "A manifold composed of large pipes."
	pipe_state = "manifold"


#undef FUELHATCH_OPEN
#undef WASTEHATCH_OPEN
#undef LOW_HEAT
#undef MEDIUM_HEAT
#undef HIGH_HEAT
#undef CRITICAL_HEAT
#undef MELTDOWN