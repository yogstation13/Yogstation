/obj/item/extinguisher/attack_self(mob/user)
	..()
	if(safety)
		reagents.flags = AMOUNT_VISIBLE
	else
		reagents.flags = OPENCONTAINER

/obj/item/extinguisher/attackby(obj/O, mob/user)
	if(istype(O, /obj/item/reagent_containers))
		if(safety)
			to_chat(user, "<span class='warning'>You need to take off the safety before you can refill the [src]!</span>")
			return
	else
		..()

/obj/item/extinguisher/attack_obj(obj/O, mob/living/user)
	if(attempt_refill_yogs(O, user))
		refilling = TRUE
		return FALSE
	else
		return ..()

/obj/item/extinguisher/proc/attempt_refill_yogs(atom/target, mob/user)
	if(istype(target, /obj/structure/reagent_dispensers) && target.Adjacent(user))
		var/safety_save = safety
		safety = TRUE
		if(reagents.total_volume == reagents.maximum_volume)
			to_chat(user, "<span class='warning'>\The [src] is already full!</span>")
			safety = safety_save
			return 1
		var/obj/structure/reagent_dispensers/watertank/W = target
		var/transferred = W.reagents.trans_to(src, max_water)
		if(transferred > 0)
			to_chat(user, "<span class='notice'>\The [src] has been refilled by [transferred] units.</span>")
			playsound(src.loc, 'sound/effects/refill.ogg', 50, 1, -6)
			for(var/datum/reagent/water/R in reagents.reagent_list)
				R.cooling_temperature = cooling_power
		else
			to_chat(user, "<span class='warning'>\The [W] is empty!</span>")
		safety = safety_save
		return 1
	else
		return 0

/obj/item/extinguisher/suicide_act(mob/living/carbon/user)
	if (!safety && (reagents.total_volume >= 1))
		user.visible_message("<span class='suicide'>[user] puts the nozzle to [user.p_their()] mouth. It looks like [user.p_theyre()] trying to extinguish the spark of life!</span>")
		afterattack(user,user)
		return OXYLOSS
	else if (safety && (reagents.total_volume >= 1))
		user.visible_message("<span class='warning'>[user] puts the nozzle to [user.p_their()] mouth... The safety's still on!</span>")
		return SHAME
	else
		user.visible_message("<span class='warning'>[user] puts the nozzle to [user.p_their()] mouth... [src] is empty!</span>")
		return SHAME
