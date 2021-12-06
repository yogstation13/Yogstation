#define PYLON_RANGE 4

/obj/item/pylon_spawner
	name = "deployable pylon"
	desc = "A compact pylon, use it in hand to prepare it for use."
	icon = 'icons/mob/infection/infection.dmi'
	icon_state = "dpylon"
	var/contained_pylon = /obj/structure/destructible/infection_pylon

/obj/item/pylon_spawner/attack_self(mob/user)
	to_chat(user, span_notice("You activate [src], and the pylon expands!"))
	new contained_pylon(get_turf(src))
	qdel(src)

/obj/item/pylon_spawner/charger
	name = "deployable charger pylon"
	contained_pylon = /obj/structure/destructible/infection_pylon/charger

/obj/item/pylon_spawner/turret
	name = "deployable disruptor pylon"
	contained_pylon = /obj/structure/destructible/infection_pylon/turret

/obj/structure/destructible/infection_pylon
	name = "generic pylon"
	desc = "it does stuff"
	anchored = FALSE
	icon = 'icons/mob/infection/infection.dmi'
	icon_state = "pylon"
	var/unanchored_icon = "pylon" //icon for when this structure is unanchored

/obj/structure/destructible/infection_pylon/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)
	update_anchored()

/obj/structure/destructible/infection_pylon/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/structure/destructible/infection_pylon/attackby(obj/item/I, mob/user, params)
	var/success = default_unfasten_wrench(user, I, 8 SECONDS)
	if(success == SUCCESSFUL_UNFASTEN)
		update_anchored(user)
		return TRUE
	if(success == FAILED_UNFASTEN)
		return TRUE
	return ..()

/obj/structure/destructible/infection_pylon/can_be_unfasten_wrench(mob/user, silent)
	if(!anchored)
		for(var/obj/structure/destructible/infection_pylon/P in orange(PYLON_RANGE, src))
			if(P.anchored)
				if(!silent)
					to_chat(user, span_warning("A safety light flashes on the side of [src], placing two of these this close would prevent either from drawing their power."))
				return FAILED_UNFASTEN
	return SUCCESSFUL_UNFASTEN

/obj/structure/destructible/infection_pylon/proc/update_anchored()
	if(anchored)
		icon_state = initial(icon_state)
	else
		icon_state = unanchored_icon

/obj/structure/destructible/infection_pylon/charger
	name = "node pylon"
	desc = "A pylon that draws power directly from bluespace and distributes it to nearby weaponry."
	icon_state = "powerpylon"

/obj/structure/destructible/infection_pylon/charger/process()
	if(!anchored)
		return
	for(var/atom/movable/AM in range(PYLON_RANGE/2, src)) //halved range for "balance" and to prevent stacking
		for(var/obj/item/stock_parts/cell/C in AM.GetAllContents())
			var/newcharge = min(C.charge+0.05*C.maxcharge, C.maxcharge) //5% per process, about the same amount as a leveled cell charger
			if(C.charge < newcharge)
				C.charge = newcharge
				if(isobj(C.loc))
					var/obj/O = C.loc
					O.update_icon() //update power meters and such
					Beam(AM, icon_state = "medbeam", time = 2 SECONDS)
				C.update_icon()

/obj/structure/destructible/infection_pylon/turret
	name = "disruptor pylon"
	desc = "A pylon that charges the nearby area with a weak bluespace field, tearing apart nearby infected creep."
	icon_state = "defensepylon"
	var/list/effected_types = list(/obj/structure/infection/normal, /obj/structure/infection/shield)

/obj/structure/destructible/infection_pylon/turret/process()
	if(!anchored)
		return
	var/damage_successful = FALSE
	for(var/obj/structure/infection/I in view(PYLON_RANGE, src)) //works off view to make it harder to block off with walls
		if(is_type_in_list(I, effected_types))
			I.take_damage(15, BURN)
			damage_successful = TRUE
	if(damage_successful)
		flick("defensepylonattack", src)
