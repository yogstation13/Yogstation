
/datum/species/proc/drain_power_from(mob/living/carbon/human/H, atom/A)
	if(!istype(H) || !A)
		return

	if(!A.can_consume_power_from(H))
		return
	
	if(get_dist(H, A) > 1)
		to_chat(H, span_warning("[A] is too far away to initiate CONSUME protocol!"))
		return
	
	if(draining)
		to_chat(H, span_info("CONSUME protocols can only be used on one object at any single time."))
		return

	draining = TRUE

	var/siemens_coefficient = 1

	if(H.reagents.has_reagent("teslium"))
		siemens_coefficient *= 1.5

	if(!istype(H.getorganslot(ORGAN_SLOT_STOMACH), /obj/item/organ/stomach/cell))
		to_chat(H, span_info("CONSUME protocol failed - missing internal power supply."))
		draining = FALSE
		return

	if(H.nutrition >= NUTRITION_LEVEL_FAT - 25) //just to prevent spam a bit
		to_chat(H, span_notice("CONSUME protocol reports no need for additional power at this time."))
		draining = FALSE
		return

	var/blocked = H.getarmor(H.held_index_to_hand(H.active_hand_index), ELECTRIC)
	siemens_coefficient *= (100 - blocked) / 100
	if(blocked >= 100)
		to_chat(H, span_info("NOTICE: [H.gloves] prevent electrical contact - CONSUME protocol aborted."))
		draining = FALSE
		return
	else if(blocked > 0)
		to_chat(H, span_info("NOTICE: [H.gloves] are interfering with electrical contact - advise removal before activating CONSUME protocol."))

	. = COMSIG_MOB_CANCEL_CLICKON

	H.face_atom(A)
	H.visible_message(span_warning("[H] starts placing their hands on [A]..."), span_warning("You start placing your hands on [A]..."))
	if(!do_after(H, HAS_TRAIT(H, TRAIT_VORACIOUS)? 1.5 SECONDS : 2 SECONDS, A))
		to_chat(H, span_info("CONSUME protocol aborted."))
		draining = FALSE
		return

	to_chat(H, span_info("Extracutaneous implants detect viable power source. Initiating CONSUME protocol."))

	var/done = FALSE
	var/baseDrain = 150 * siemens_coefficient
	var/cycle = 0

	var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
	spark_system.attach(A)
	spark_system.set_up(5, 0, A)

	while(!done)
		cycle++

		if (do_after(H, HAS_TRAIT(H, TRAIT_VORACIOUS)? 0.4 SECONDS : 0.5 SECONDS, A))
			var/can_drain = A.can_consume_power_from(H)
			if(!can_drain || istext(can_drain))
				if(istext(can_drain))
					to_chat(H, can_drain)
				done = TRUE

			else
				playsound(A.loc, "sparks", 50, 1)
				if(prob(75))
					spark_system.start()
          
				var/drained = A.consume_power_from(baseDrain, H)
				if(drained < baseDrain)
					to_chat(H, span_info("[A]'s power has been depleted, CONSUME protocol halted."))
					done = TRUE

				drained *= ELECTRICITY_TO_NUTRIMENT_FACTOR //loss of efficiency

				if(H.nutrition + drained > NUTRITION_LEVEL_FAT)
					drained = clamp(NUTRITION_LEVEL_FAT - H.nutrition, 0, NUTRITION_LEVEL_FAT)
				
				if(!H.adjust_nutrition(drained))
					to_chat(H, span_info("CONSUME protocol failed - unable to recharge internal power supply."))
					return

				if(!done)
					if(H.nutrition >= NUTRITION_LEVEL_FAT)
						to_chat(H, span_info("CONSUME protocol complete. Physical nourishment refreshed."))
						done = TRUE
					else if(!(cycle % 4))
						var/nutperc = round((H.nutrition / NUTRITION_LEVEL_FAT) * 100)
						to_chat(H, span_info("CONSUME protocol continues. Current satiety level: [nutperc]%."))
		else
			done = TRUE
	qdel(spark_system)
	draining = FALSE
	return

/atom/proc/can_consume_power_from(mob/user)
	return FALSE //if a string is returned, it will evaluate as false and be output to the person draining.

/atom/proc/consume_power_from(amount, mob/user)
	return FALSE //return the amount that was drained.

#define MIN_DRAINABLE_POWER 10

//IPC lol, lmao
/mob/living/carbon/human/can_consume_power_from(mob/user)
	if(src == user) //stop that
		return
	return HAS_TRAIT(src, TRAIT_POWERHUNGRY)

/mob/living/carbon/human/consume_power_from(amount, mob/user)
	if((nutrition - amount) < NUTRITION_LEVEL_STARVING)
		amount = max(nutrition - NUTRITION_LEVEL_STARVING, 0)
	adjust_nutrition(-amount)
	return amount

//CELL//
/obj/item/stock_parts/cell/can_consume_power_from(mob/user)
	if(charge < MIN_DRAINABLE_POWER)
		return span_info("Power cell depleted, cannot consume power.")
	return TRUE

/obj/item/stock_parts/cell/consume_power_from(amount, mob/user)
	if((charge - amount) < MIN_DRAINABLE_POWER)
		amount = max(charge - MIN_DRAINABLE_POWER, 0)
	use(amount)
	return amount

//APC//
/obj/machinery/power/apc/can_consume_power_from(mob/user)
	if(stat & BROKEN)
		return span_info("APC is damaged, cannot consume power.")
	if(!operating || shorted)
		return span_info("APC main breaker is off, cannot consume power.")
	if(HAS_TRAIT(user, TRAIT_BOTTOMLESS_STOMACH))
		return TRUE
	if(!cell)
		return span_info("APC cell absent, cannot consume power.")
	if(cell.charge < MIN_DRAINABLE_POWER)
		return span_info("APC cell depleted, cannot consume power.")
	return TRUE

/obj/machinery/power/apc/consume_power_from(amount, mob/user)
	var/newamount = amount
	if((cell.charge - amount) < MIN_DRAINABLE_POWER)
		newamount = max(cell.charge - MIN_DRAINABLE_POWER, 0)
	cell.use(newamount)
	if(charging == 2)
		charging = 0 //if we do not do this here, the APC can get stuck thinking it is fully charged.
	update()

	if(newamount < amount && HAS_TRAIT(user, TRAIT_BOTTOMLESS_STOMACH))
		add_load(amount - newamount) //GIVE ME THAT EXTRA POWER
		newamount = amount
	return amount

//SMES//
/obj/machinery/power/smes/can_consume_power_from(mob/user)
	if(stat & BROKEN)
		return span_info("SMES is damaged, cannot consume power.")
	if(HAS_TRAIT(user, TRAIT_BOTTOMLESS_STOMACH))
		return TRUE
	if(!output_attempt)
		return span_info("SMES is not outputting power, cannot consume power.")
	if(charge < MIN_DRAINABLE_POWER)
		return span_info("SMES cells depleted, cannot consume power.")
	return TRUE

/obj/machinery/power/smes/consume_power_from(amount, mob/user)
	var/newamount = amount
	if((charge - amount) < MIN_DRAINABLE_POWER)
		newamount = max(charge - MIN_DRAINABLE_POWER, 0)
	charge -= newamount
	
	if(newamount < amount && HAS_TRAIT(user, TRAIT_BOTTOMLESS_STOMACH))
		add_load(amount - newamount) //GIVE ME THAT EXTRA POWER
		newamount = amount

	return newamount

//MECH//
/obj/mecha/can_consume_power_from(mob/user)
	if(!cell)
		return span_info("Mech power cell absent, cannot consume power.")
	if(cell.charge < MIN_DRAINABLE_POWER)
		return span_info("Mech power cell depleted, cannot consume power.")
	return TRUE

/obj/mecha/consume_power_from(amount, mob/user)
	occupant_message(span_danger("Warning: Unauthorized access through sub-route 4, block H, detected."))
	if((cell.charge - amount) < MIN_DRAINABLE_POWER)
		amount = max(cell.charge - MIN_DRAINABLE_POWER, 0)
	cell.use(amount)
	return amount

//BORG//
/mob/living/silicon/robot/can_consume_power_from(mob/user)
	if(!cell)
		return span_info("Cyborg power cell absent, cannot consume power.")
	if(cell.charge < MIN_DRAINABLE_POWER)
		return span_info("Cyborg power cell depleted, cannot consume power.")
	return TRUE

/mob/living/silicon/robot/consume_power_from(amount, mob/user)
	src << span_danger("Warning: Unauthorized access through sub-route 12, block C, detected.")
	if((cell.charge - amount) < MIN_DRAINABLE_POWER)
		amount = max(cell.charge - MIN_DRAINABLE_POWER, 0)
	cell.use(amount)
	return amount

#undef MIN_DRAINABLE_POWER



