/mob/living/carbon/AltClickOn(atom/A)
	if(ispreternis(src))
		dna.species.spec_AltClickOn(A,src)
		return
	..()

/datum/species/preternis/spec_AltClickOn(atom/A,H)
	return species_drain_act(H, A)

/datum/species/preternis/proc/species_drain_act(mob/living/carbon/human/H, atom/A)
	if(!istype(H) || !A)
		return 0

	if(!A.can_consume_power_from())
		return 0 //if it returns text, we want it to continue so we can get the error message later.

	var/siemens_coefficient = 1

	if(H.reagents.has_reagent("teslium"))
		siemens_coefficient *= 1.5

	if (charge == PRETERNIS_LEVEL_FULL - 25)
		to_chat(H,"<span class='notice'>CONSUME protocol reports no need for additional power at this time.</span>")
		return 1

	if(H.gloves)
		if(H.gloves.siemens_coefficient == 0)
			to_chat(H,"<span class='info'>NOTICE: [H.gloves] prevent electrical contact - CONSUME protocol aborted.</span>")
			return 1
		else
			if(H.gloves.siemens_coefficient < 1)
				to_chat(H,"<span class='info'>NOTICE: [H.gloves] are interfering with electrical contact - advise removal before activating CONSUME protocol.</span>")
			siemens_coefficient *= H.gloves.siemens_coefficient

	H.face_atom(A)
	H.visible_message("<span class='warning'>[H] starts placing their hands on [A]...</span>", "<span class='warning'>You start placing your hands on [A]...</span>")
	if(!do_after(H, 20, target = A))
		to_chat(H,"<span class='info'>CONSUME protocol aborted.</span>")
		return 1

	to_chat(H,"<span class='info'>Extracutaneous implants detect viable power source. Initiating CONSUME protocol.</span>")

	var/done = 0
	var/drain = 150 * siemens_coefficient

	var/cycle = 0
	var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
	spark_system.attach(A)
	spark_system.set_up(5, 0, A)
	while(!done)
		cycle++
		var/nutritionIncrease = drain * ELECTRICITY_TO_NUTRIMENT_FACTOR

		if(charge + nutritionIncrease > PRETERNIS_LEVEL_FULL)
			nutritionIncrease = max(PRETERNIS_LEVEL_FULL - charge, 0) //if their nutrition goes up from some other source, this could be negative, which would cause bad things to happen.
			drain = nutritionIncrease/ELECTRICITY_TO_NUTRIMENT_FACTOR

		if (do_after(H,15, target = A))
			var/can_drain = A.can_consume_power_from()
			if(!can_drain || istext(can_drain))
				if(istext(can_drain))
					to_chat(H,can_drain)
				done = 1
			else
				playsound(A.loc, "sparks", 50, 1)
				if(prob(75))
					spark_system.start()
				var/drained = A.consume_power_from(drain)
				if(drained < drain)
					to_chat(H,"<span class='info'>[A]'s power has been depleted, CONSUME protocol halted.</span>")
					done = 1
				charge += drained * ELECTRICITY_TO_NUTRIMENT_FACTOR

				if(!done)
					if(charge > (PRETERNIS_LEVEL_FULL -1))
						to_chat(H,"<span class='info'>CONSUME protocol complete. Physical nourishment refreshed.</span>")
						done = 1
					else if(cycle % 4 == 0)
						var/nutperc = round((charge / PRETERNIS_LEVEL_FULL) * 100)
						to_chat(H,"<span class='info'>CONSUME protocol continues. Current satiety level: [nutperc]%.</span>")
		else
			done = 1
	qdel(spark_system)
	return 1

/atom/proc/can_consume_power_from()
	return 0 //if a string is returned, it will evaluate as false and be output to the person draining.

/atom/proc/consume_power_from(amount)
	return 0 //return the amount that was drained.

#define MIN_DRAINABLE_POWER 10

//CELL//
/obj/item/stock_parts/cell/can_consume_power_from()
	if(charge < MIN_DRAINABLE_POWER)
		return "<span class='info'>Power cell depleted, CONSUME protocol halted.</span>"
	return 1

/obj/item/stock_parts/cell/consume_power_from(amount)
	if((charge - amount) < MIN_DRAINABLE_POWER)
		amount = max(charge - MIN_DRAINABLE_POWER, 0)
	use(amount)
	return amount

//APC//
/obj/machinery/power/apc/can_consume_power_from()
	if(!cell)
		return "<span class='info'>APC cell absent, CONSUME protocol halted.</span>"
	if(stat & BROKEN)
		return "<span class='info'>APC is damaged, CONSUME protocol halted.</span>"
	if(!operating || shorted)
		return "<span class='info'>APC main breaker is off, CONSUME protocol halted.</span>"
	if(cell.charge < MIN_DRAINABLE_POWER)
		return "<span class='info'>APC cell depleted, CONSUME protocol halted.</span>"
	return 1

/obj/machinery/power/apc/consume_power_from(amount)
	if((cell.charge - amount) < MIN_DRAINABLE_POWER)
		amount = max(cell.charge - MIN_DRAINABLE_POWER, 0)
	cell.use(amount)
	if(charging == 2)
		charging = 0 //if we do not do this here, the APC can get stuck thinking it is fully charged.
	update()
	return amount

//SMES//
/obj/machinery/power/smes/can_consume_power_from()
	if(stat & BROKEN)
		return "<span class='info'>SMES is damaged, CONSUME protocol halted.</span>"
	if(!output_attempt)
		return "<span class='info'>SMES is not outputting power, CONSUME protocol halted.</span>"
	if(charge < MIN_DRAINABLE_POWER)
		return "<span class='info'>SMES cells depleted, CONSUME protocol halted.</span>"
	return 1

/obj/machinery/power/smes/consume_power_from(amount)
	if((charge - amount) < MIN_DRAINABLE_POWER)
		amount = max(charge - MIN_DRAINABLE_POWER, 0)
	charge -= amount
	return amount

//MECH//
/obj/mecha/can_consume_power_from()
	if(!cell)
		return "<span class='info'>Mech power cell absent, CONSUME protocol halted.</span>"
	if(cell.charge < MIN_DRAINABLE_POWER)
		return "<span class='info'>Mech power cell depleted, CONSUME protocol halted.</span>"
	return 1

/obj/mecha/consume_power_from(amount)
	occupant_message("<span class='danger'>Warning: Unauthorized access through sub-route 4, block H, detected.</span>")
	if((cell.charge - amount) < MIN_DRAINABLE_POWER)
		amount = max(cell.charge - MIN_DRAINABLE_POWER, 0)
	cell.use(amount)
	return amount

//BORG//
/mob/living/silicon/robot/can_consume_power_from()
	if(!cell)
		return "<span class='info'>Cyborg power cell absent, CONSUME protocol halted.</span>"
	if(cell.charge < MIN_DRAINABLE_POWER)
		return "<span class='info'>Cyborg power cell depleted, CONSUME protocol halted.</span>"
	return 1

/mob/living/silicon/robot/consume_power_from(amount)
	src << "<span class='danger'>Warning: Unauthorized access through sub-route 12, block C, detected.</span>"
	if((cell.charge - amount) < MIN_DRAINABLE_POWER)
		amount = max(cell.charge - MIN_DRAINABLE_POWER, 0)
	cell.use(amount)
	return amount

#undef MIN_DRAINABLE_POWER



