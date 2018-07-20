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

/obj/machinery/power/NuclearReactor/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/twohanded/FuelRod))
		to_chat(user, "You slot [I] into [src]!")
		I.forceMove(src)
		react.FRS += I
	if(istype(I, /obj/item/twohanded/ControlRod))
		to_chat(user, "You slot [I] into [src]!")
		I.forceMove(src)
		react.CRS += I

/obj/machinery/power/NuclearReactor/Initialize()
	. = ..()
	react.reactor = src

/obj/machinery/power/NuclearReactor/proc/start()
	say("Reaction started!")
	Heat = 1
	START_PROCESSING(SSmachines,src)

/obj/machinery/power/NuclearReactor/process()
	if(Heat <= 0)
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
	say("Heat is now: [Heat]")
	say("Producing [Power] watts of electricity")
	say("I've been running for [Time] seconds")

/obj/machinery/power/NuclearReactor/proc/stop()
	say("I've stopped processing")
	STOP_PROCESSING(SSmachines,src)
	say("Heat: [Heat]")
	say("Efficiency: [Efficiency]")
	say("Heat is now: [Heat]")
	say("Producing [Power] watts of electricity")
	say("I ran for [Time] seconds")
	Time = 0
	Heat = 0
	Efficiency = 0
	HeatRate = 0

/obj/machinery/power/NuclearReactor/proc/GetPower(var/C) //Where C is the reaction coeff
	if(!C)
		C = 1
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
	var/list/obj/item/twohanded/ControlRod/CRS = list()
	var/list/obj/item/twohanded/FuelRod/FRS = list()
	var/DepletedAmt = 0 //How much of the uranium has been depleted, and thus acts like control rods?
	var/obj/machinery/power/NuclearReactor/reactor

/datum/nuclearreaction/proc/GetFuelAmounts()
	var/AmtSubtract
	for(var/obj/item/twohanded/ControlRod/CR in CRS)
		if(!istype(CR,/obj/item/twohanded/ControlRod))
			return
		AmtSubtract += CR.ControlPower
	var/AmtAdd
	for(var/obj/item/twohanded/FuelRod/FR in FRS)
		if(!istype(FR,/obj/item/twohanded/FuelRod))
			return
		AmtAdd += FR.FuelPower
	return AmtAdd - AmtSubtract //IE, AmtSubtract with one CR = 1, AmtAdd with 2 Uranium = 4, so resultant reaction power is 3, which also means a heat spike

/datum/nuclearreaction/proc/ConsumeFuel()
	for(var/obj/item/twohanded/FuelRod/FR in FRS)
		if(!istype(FR,/obj/item/twohanded/FuelRod))
			return
		if(FR.integrity <= 0) //That rod's spent, make it into DU
			reactor.say("[FR] died!")
			DepletedAmt ++
			qdel(FR)
			FRS -= FR
			FR = null
			var/obj/item/twohanded/FuelRod/depleted/spent = new
			FRS += spent
			spent.forceMove(reactor)
			return
		if(!istype(FR, /obj/item/twohanded/FuelRod/depleted)) //Depleted rods don't deplete further, they just interrupt heat
			FR.integrity -= 10 - reactor.Efficiency/10 // Eg, 100/10 = 10, so integrity -= 0 aka no health lost, 25 = 2.5, so 8.5 health lost, so keep that efficiency up!
	for(var/obj/item/twohanded/ControlRod/CR in CRS)
		if(!istype(CR,/obj/item/twohanded/ControlRod))
			return
		if(CR.integrity <= 10) //CR is spent!
			qdel(CR)
			reactor.say("[CR] died!")
		CR.integrity -= 10 - reactor.Efficiency/10

/obj/item/twohanded/ControlRod
	name = "Carbon Control Rod"
	desc = "A huge rod of carbon used for nuclear reactors."
	icon = 'icons/obj/ControlRod.dmi'
	icon_state = "carbonrod"
	var/integrity = 1000 //As rods become worn, they are damaged.
	max_integrity = 1000
	var/obj/machinery/power/NuclearReactor/reactor
	var/ControlPower = 1 // 1 Rod of this will halve the power of 1 uranium fuel rod

/obj/item/twohanded/FuelRod
	name = "Uranium Fuel Rod"
	desc = "A huge stick of uranium to be inserted into a nuclear reactor"
	icon = 'icons/obj/ControlRod.dmi'
	icon_state = "uraniumrod"
	var/integrity = 100//As rods become worn, they are damaged.
	max_integrity = 100
	var/obj/machinery/power/NuclearReactor/reactor
	var/FuelPower = 2 //How strong is this fuel rod? higher = more heat produced

/obj/item/twohanded/FuelRod/depleted
	name = "Depleted Fuel Rod"
	desc = "A depleted stick of uranium, please dispose of safely!"
	icon_state = "depletedrod"
	FuelPower = -1