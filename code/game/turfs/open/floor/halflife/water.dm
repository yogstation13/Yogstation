/turf/open/water
	name = "water"
	desc = "Water."
	icon = 'icons/turf/water.dmi'
	baseturfs = /turf/open/water
	footstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	clawfootstep = FOOTSTEP_WATER
	heavyfootstep = FOOTSTEP_WATER


#define TURF_LAYER_WATER 2
#define TURF_LAYER_MOB_WATER 1.95
#define TURF_LAYER_WATER_UNDER 1.94
#define TURF_LAYER_WATER_BASE 1.93

#define iswater(A) (istype(A, /turf/open/halflife/water))

/turf/open/halflife/water
	name = "water"
	desc = "Cold dirty water."
	icon = 'icons/turf/water.dmi'
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_CARPET_ROYAL_BLUE)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_ROYAL_BLUE)
	baseturfs = /turf/open/halflife/water
	footstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	clawfootstep = FOOTSTEP_WATER
	heavyfootstep = FOOTSTEP_WATER
	plane = FLOOR_PLANE
	layer = TURF_LAYER_WATER_BASE
	slowdown = 0.5
	light_power = 0.25 //water is reflective, or has glowing contaminants inside of it...
	light_range = 0.25
	light_color = "#0486b9" 
	// What type of water it'll give you when you fill a container from it.
	var/dispensedreagent = /datum/reagent/water/unpurified
	var/next_splash = 1
	var/atom/watereffect = /obj/effect/overlay/halflife/water/medium
	var/atom/watertop = /obj/effect/overlay/halflife/water/top/medium
	var/depth = 0
	var/coldness = -100
	var/z_to_change = 0 //absolutely terrible, but im desperate

/turf/open/halflife/water/attackby(obj/item/W, mob/user, params)
	. = ..()

	if(istype(W, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/container = W
		if(container.is_refillable())
			if(!container.reagents.holder_full())
				container.reagents.add_reagent(dispensedreagent, min(container.volume - container.reagents.total_volume, container.amount_per_transfer_from_this))
				to_chat(user, span_notice("You fill [container] from [src]."))
				return TRUE
			to_chat(user, span_notice("\The [container] is full."))
			return FALSE

/turf/open/halflife/water/can_have_cabling()
	return

/turf/open/halflife/water/deep
	name = "deep water"
	desc = "Cold dirty water, it looks pretty deep."
	icon_state = "water_deep"
	baseturfs = /turf/open/halflife/water/deep
	watereffect = /obj/effect/overlay/halflife/water/deep
	watertop = /obj/effect/overlay/halflife/water/top/deep
	depth = 3

/turf/open/halflife/water/medium
	icon_state = "water_medium"
	baseturfs = /turf/open/halflife/water/medium
	watereffect = /obj/effect/overlay/halflife/water/medium
	watertop = /obj/effect/overlay/halflife/water/top/medium
	depth = 2

/turf/open/halflife/water/shallow
	icon_state = "water_shallow"
	baseturfs = /turf/open/halflife/water/shallow
	watereffect = /obj/effect/overlay/halflife/water/shallow
	watertop = /obj/effect/overlay/halflife/water/top/shallow
	depth = 1

/turf/open/halflife/water/Initialize()
	. = ..()
	new watereffect(src)
	new watertop(src)
	if(z == 2)
		z_to_change = -100

/obj/effect/overlay/halflife/water
	name = "water"
	icon = 'icons/turf/water.dmi'
	density = FALSE
	mouse_opacity = 0
	layer = TURF_LAYER_WATER
	plane = FLOOR_PLANE
	anchored = TRUE

/obj/effect/overlay/halflife/water/deep
	icon_state = "water_deep_bottom"

/obj/effect/overlay/halflife/water/medium
	icon_state = "water_medium_bottom"

/obj/effect/overlay/halflife/water/shallow
	icon_state = "water_shallow_bottom"

/obj/effect/overlay/halflife/water/top
	layer = TURF_LAYER_WATER_UNDER

/obj/effect/overlay/halflife/water/top/deep
	icon_state = "water_deep_top"

/obj/effect/overlay/halflife/water/top/medium
	icon_state = "water_medium_top"

/obj/effect/overlay/halflife/water/top/shallow
	icon_state = "water_shallow_top"

/mob/living
	var/swimming = FALSE

/turf/open/halflife/water/MouseDrop_T(mob/living/M, mob/living/user)
	if(!M.swimming) //can't put yourself up if you are not swimming
		return ..()
	switch(depth)
		if(3)
			if(user == M)
				M.visible_message("<span class='notice'>[user] is getting out the deep water", \
								"<span class='notice'>You start getting out of the deep water.</span>")
				if(do_mob(user, M, 20))
					M.swimming = FALSE
					M.forceMove(src)
					to_chat(user, "<span class='notice'>You get out of the deep water.</span>")
			else
				user.visible_message("<span class='notice'>[M] is being dragged out the water by [user].</span>", \
								"<span class='notice'>You start getting [M] out of the deep water.")
				if(do_mob(user, M, 20))
					M.swimming = FALSE
					M.forceMove(src)
					to_chat(user, "<span class='notice'>You get [M] out of the deep water.</span>")
					return
		else
			return

/turf/open/halflife/water/MouseDrop_T(mob/living/M, mob/living/user)
	if(user.stat || user.body_position == LYING_DOWN || !Adjacent(user) || !M.Adjacent(user)|| !iscarbon(M))
		return
	if(M.swimming) //can't lower yourself again
		return
	else
		switch(depth)
			if(3)
				if(user == M)
					M.visible_message("<span class='notice'>[user] is descending in the deep water", \
									"<span class='notice'>You start lowering yourself in the deep water.</span>")
					if(do_mob(user, M, 20))
						M.swimming = TRUE
						addtimer(CALLBACK(src, PROC_REF(transfer_mob_layer), M), 0.2 SECONDS)
						M.forceMove(src)
						to_chat(user, "<span class='notice'>You lower yourself in the deep water.</span>")
						//M.adjust_bodytemperature(coldness)
						//M.Jitter(20)
				else
					user.visible_message("<span class='notice'>[M] is being put in the deep water by [user].</span>", \
									"<span class='notice'>You start lowering [M] in the deep water.")
					if(do_mob(user, M, 20))
						M.swimming = TRUE
						addtimer(CALLBACK(src, PROC_REF(transfer_mob_layer), M), 0.2 SECONDS)
						M.forceMove(src)
						to_chat(user, "<span class='notice'>You lower [M] in the deep water.</span>")
						//M.adjust_bodytemperature(coldness)
						//M.Jitter(20)
						return
			else
				return

/turf/open/halflife/water/Exited(atom/movable/gone, direction)
	..()
	if(isliving(gone))
		var/mob/living/M = gone
		if(!iswater(get_step(src, direction)))
			M.swimming = FALSE
			M.layer = initial(M.layer)
			M.plane = (initial(M.plane) + z_to_change) //absolutely terrible, but im desperate

/turf/open/halflife/water/Entered(atom/A, turf/OL)
	..()
	for(var/obj/structure/lattice/catwalk/C in get_turf(A))
		return

	if(isliving(A))
		var/mob/living/M = A
		var/mob/living/carbon/H = M
		addtimer(CALLBACK(src, PROC_REF(transfer_mob_layer), M), 0.2 SECONDS)
		if(!(M.swimming))
			switch(depth)
				if(3)
					H.wash(CLEAN_WASH)
					if(iscarbon(M) && H.wear_mask && H.wear_mask.flags_cover & MASKCOVERSMOUTH)
						H.visible_message("<span class='danger'>[H] falls in the water!</span>",
											"<span class='userdanger'>You fall in the water!</span>")
						playsound(src, 'sound/halflifesounds/halflifeeffects/splash.ogg', 60, 1, 1)
						H.Knockdown(20)
						H.swimming = TRUE
						//M.adjust_bodytemperature(coldness)
						return
					else
						H.dropItemToGround(H.get_active_held_item())
						H.adjustOxyLoss(5)
						H.emote("cough")
						H.visible_message("<span class='danger'>[H] falls in and takes a drink!</span>",
											"<span class='userdanger'>You fall in and swallow some water!</span>")
						playsound(src, 'sound/halflifesounds/halflifeeffects/splash.ogg', 60, 1, 1)
						H.Knockdown(60)
						H.swimming = TRUE
						//M.adjust_bodytemperature(coldness)
				else
					H.swimming = TRUE
					//M.adjust_bodytemperature(coldness)
		if(H.body_position == LYING_DOWN)
			if(M.stat == DEAD)
				return
			switch(depth)
				if(3)
					H.visible_message("<span class='danger'>[H] flails in the water!</span>",
										"<span class='userdanger'>You're drowning!</span>")
					H.Knockdown(20)
					//M.adjust_bodytemperature(coldness)
					M.adjustStaminaLoss(20)
					M.adjustOxyLoss(10)
					M.adjustOrganLoss(ORGAN_SLOT_LUNGS, 20)
					playsound(src, 'sound/halflifesounds/halflifeeffects/drown.ogg', 30, 1, 1)
				if(2)
					H.visible_message("<span class='danger'>[H] flails in the shallow water!</span>",
										"<span class='userdanger'>You're drowning!</span>")
					H.Knockdown(10)
					//M.adjust_bodytemperature(coldness)
					M.adjustStaminaLoss(10)
					M.adjustOxyLoss(5)
					M.adjustOrganLoss(ORGAN_SLOT_LUNGS, 10)
					playsound(src, 'sound/halflifesounds/halflifeeffects/drown.ogg', 30, 1, 1)
		else //wading
			switch(depth)
				if(3)
					M.wash(CLEAN_WASH)
					//M.adjust_bodytemperature(coldness)
					//M.Jitter(20)
					M.adjustStaminaLoss(3)
				if(2)
					M.wash(CLEAN_WASH)
					//M.adjust_bodytemperature(coldness)
					//M.Jitter(20)
					M.adjustStaminaLoss(1)
				/*else
					M.adjust_bodytemperature(coldness)
					M.Jitter(20)*/
			return

/turf/open/halflife/water/proc/transfer_mob_layer(var/mob/living/carbon/M)
	if(iswater(get_turf(M)))
		M.layer = TURF_LAYER_MOB_WATER
		M.plane = (FLOOR_PLANE + z_to_change)
		M.update_icon(UPDATE_OVERLAYS)
	else
		return

/turf/open/halflife/water/sewer
	name = "sewer water"
	desc = "Murky and foul smelling water, if you could call it that."
	baseturfs = /turf/open/halflife/water/sewer
	dispensedreagent = /datum/reagent/water/dirty/sewer
	light_color = "#013b09" 


/turf/open/halflife/water/sewer/deep
	name = "deep water"
	desc = "Cold rancid sewer water, it looks pretty deep."
	icon_state = "sewer_deep"
	baseturfs = /turf/open/halflife/water/sewer/deep
	watereffect = /obj/effect/overlay/halflife/sewer/deep
	watertop = /obj/effect/overlay/halflife/sewer/top/deep
	depth = 3

/turf/open/halflife/water/sewer/medium
	icon_state = "sewer_medium"
	baseturfs = /turf/open/halflife/water/sewer/medium
	watereffect = /obj/effect/overlay/halflife/sewer/medium
	watertop = /obj/effect/overlay/halflife/sewer/top/medium
	depth = 2

/turf/open/halflife/water/sewer/shallow
	icon_state = "sewer_shallow"
	baseturfs = /turf/open/halflife/water/sewer/shallow
	watereffect = /obj/effect/overlay/halflife/sewer/shallow
	watertop = /obj/effect/overlay/halflife/sewer/top/shallow
	depth = 1

/obj/effect/overlay/halflife/sewer
	name = "water"
	icon = 'icons/turf/water.dmi'
	density = FALSE
	mouse_opacity = 0
	layer = TURF_LAYER_WATER
	plane = FLOOR_PLANE
	anchored = TRUE

/obj/effect/overlay/halflife/sewer/deep
	icon_state = "sewer_deep_bottom"

/obj/effect/overlay/halflife/sewer/medium
	icon_state = "sewer_medium_bottom"

/obj/effect/overlay/halflife/sewer/shallow
	icon_state = "sewer_shallow_bottom"

/obj/effect/overlay/halflife/sewer/top
	layer = TURF_LAYER_WATER_UNDER

/obj/effect/overlay/halflife/sewer/top/deep
	icon_state = "sewer_deep_top"

/obj/effect/overlay/halflife/sewer/top/medium
	icon_state = "sewer_medium_top"

/obj/effect/overlay/halflife/sewer/top/shallow
	icon_state = "sewer_shallow_top"
