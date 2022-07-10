/obj/machinery/power/stationarybike
	name = "stationary bike"
	desc = "Fifteen Million Merits"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "bicycle"
	density = TRUE
	anchored =  TRUE
	use_power = NO_POWER_USE
	can_buckle = 1
	buckle_lying = 0

	var/operating // On or off, also tracks what type of power being generated
	var/generating = 0 // Actual power being generated for the examine text
	var/power_exponent = 1000
	var/simple_power = 15 // Monkeys and other simple animals
	var/no_mind_power = 25 // Braindeads and Catatonics
	var/slave_power = 50 // Living, non-braindead, non-catatonic
	var/lifeweb // Emagged or not

/obj/machinery/power/stationarybike/examine(mob/user)
	. = ..()
	. +=span_notice("It is generating [generating]kw of power.")

/obj/machinery/power/stationarybike/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	lifeweb = 1
	to_chat(user, span_warning("You disabled safeties"))

/obj/machinery/power/stationarybike/wrench_act(mob/living/user, obj/item/I)
	if(!anchored && !isinspace())
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
		if(do_after(user, 2 SECONDS, src))
			connect_to_network()
			to_chat(user, span_notice("You secure [src] to the floor."))
			anchored  = TRUE
			playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
	else if(anchored)
		if(operating)
			to_chat(user, span_warning("You can't detach [src] from the floor while its moving!"))
			return TRUE
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
		if(do_after(user, 2 SECONDS, src))
			disconnect_from_network()
			to_chat(user, span_notice("You unsecure [src] from the floor."))
			anchored = FALSE
			playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
	return TRUE

/obj/machinery/power/stationarybike/crowbar_act(mob/living/user, obj/item/I)
	for(var/mob/living/BM in buckled_mobs)
		if(lifeweb)
			to_chat(user, span_notice("You forcefully yank the emergency brake."))
			unbuckle_mob(BM)
			check_buckled()
	return TRUE

/obj/machinery/power/stationarybike/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/power/stationarybike/attack_hand(mob/user)
	if(lifeweb)
		to_chat(user, span_danger("It's spinning too fast! You might hurt yourself if you try to get them off!"))
		return
	. = ..()

/obj/machinery/power/stationarybike/process()
	if(!operating)
		return
	if(operating)
		if(lifeweb)
			check_buckled()
			life_drain()
			add_avail((operating * power_exponent) * 1.5)
			generating = (operating * 1.5)
			return
		check_buckled()
		add_avail(operating * power_exponent)
		generating = (operating)

//BUCKLE HOOKS

/obj/machinery/power/stationarybike/user_unbuckle_mob(mob/living/buckled_mob,force = 0)
	operating = 0
	generating = 0
	. = ..()

/obj/machinery/power/stationarybike/user_buckle_mob(mob/living/M, mob/living/carbon/user)
	if(user.incapacitated() || !istype(user))
		return
	for(var/atom/movable/A in get_turf(src))
		if(A.density && (A != src && A != M))
			return
	M.forceMove(get_turf(src))
	..()
	playsound(src,'sound/mecha/mechmove01.ogg', 50, TRUE)
	check_buckled()

/obj/machinery/power/stationarybike/proc/check_buckled(mob/living)
	for(var/mob/living/BM in buckled_mobs)
		if(!BM || BM.stat == DEAD)
			operating = 0
			return
		else if(istype(BM,/mob/living/carbon/monkey) || istype(BM, /mob/living/simple_animal))
			operating = simple_power
		else if(istype(BM,/mob/living/carbon/human))
			if(!BM.mind)
				operating = no_mind_power
				return
			operating = slave_power

/obj/machinery/power/stationarybike/proc/life_drain(mob/living)
	for(var/mob/living/BM in buckled_mobs)
		BM.adjustBruteLoss(5)
		BM.Paralyze(30)
