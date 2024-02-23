/* In this file:
 *
 * Plating
 * Airless
 * Airless plating
 * Engine floor
 * Foam plating
 */

/turf/open/floor/plating
	name = "plating"
	icon_state = "plating"
	overfloor_placed = FALSE
	underfloor_accessibility = UNDERFLOOR_INTERACTABLE
	baseturfs = /turf/baseturf_bottom
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

	FASTDMM_PROP(\
		pipe_astar_cost = 1\
	)
	//Can this plating have reinforced floors placed ontop of it
	var/attachment_holes = TRUE

	//Used for upgrading this into R-Plating
	var/upgradable = TRUE

	/// If true, will allow tiles to replace us if the tile [wants to] [/obj/item/stack/tile/var/replace_plating].
	/// And if our baseturfs are compatible.
	/// See [/obj/item/stack/tile/proc/place_tile].
	var/allow_replacement = TRUE

/turf/open/floor/plating/broken_states()
	return list("damaged1", "damaged2", "damaged4")

/turf/open/floor/plating/burnt_states()
	return list("floorscorched1", "floorscorched2")

/turf/open/floor/plating/examine(mob/user)
	. = ..()
	if(broken || burnt)
		. += span_notice("It looks like the dents could be <i>welded</i> smooth.")
		return
	if(attachment_holes)
		. += span_notice("There are a few attachment holes for a new <i>tile</i>, reinforcement <i>sheets</i> or catwalk <i>rods</i>.")
	else
		. += span_notice("You might be able to build ontop of it with some <i>tiles</i>...")

/turf/open/floor/plating/attackby(obj/item/C, mob/user, params)
	if(..())
		return
	if(istype(C, /obj/item/stack/rods) && attachment_holes)
		if(broken || burnt)
			to_chat(user, span_warning("Repair the plating first!"))
			return
		if(locate(/obj/structure/lattice/catwalk/over, src))
			return
		if (istype(C, /obj/item/stack/rods))
			var/obj/item/stack/rods/R = C
			if (R.use(2))
				to_chat(user, span_notice("You lay down the catwalk."))
				playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
				new /obj/structure/lattice/catwalk/over(src)
				return
	if(istype(C, /obj/item/stack/sheet/metal) && attachment_holes)
		if(broken || burnt)
			to_chat(user, span_warning("Repair the plating first!"))
			return
		var/obj/item/stack/sheet/metal/R = C
		if (R.get_amount() < 1)
			to_chat(user, span_warning("You need one sheet to make a reinforced floor!"))
			return
		else
			to_chat(user, span_notice("You begin reinforcing the floor..."))
			if(do_after(user, 3 SECONDS, src))
				if (R.get_amount() >= 1 && !istype(src, /turf/open/floor/engine))
					place_on_top(/turf/open/floor/engine, flags = CHANGETURF_INHERIT_AIR)
					playsound(src, 'sound/items/deconstruct.ogg', 80, 1)
					R.use(1)
					to_chat(user, span_notice("You reinforce the floor."))
				return
	else if(istype(C, /obj/item/stack/tile) && !locate(/obj/structure/lattice/catwalk, src))
		if(!broken && !burnt)
			for(var/obj/O in src)
				for(var/M in O.buckled_mobs)
					to_chat(user, span_warning("Someone is buckled to \the [O]! Unbuckle [M] to move \him out of the way."))
					return
			var/obj/item/stack/tile/W = C
			if(!W.use(1))
				return
			var/turf/open/floor/T = place_on_top(W.turf_type, flags = CHANGETURF_INHERIT_AIR)
			if(istype(W, /obj/item/stack/tile/light)) //TODO: get rid of this ugly check somehow
				var/obj/item/stack/tile/light/L = W
				var/turf/open/floor/light/F = T
				F.state = L.state
			playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
		else
			to_chat(user, span_warning("This section is too damaged to support a tile! Use a welder to fix the damage."))

/turf/open/floor/plating/welder_act(mob/living/user, obj/item/I)
	if((broken || burnt) && I.use_tool(src, user, 0, volume=80))
		to_chat(user, span_danger("You fix some dents on the broken plating."))
		icon_state = icon_plating
		burnt = FALSE
		broken = FALSE

	return TRUE

/turf/open/floor/plating/rust_heretic_act()
	if(prob(70))
		new /obj/effect/glowing_rune(src)
	ChangeTurf(/turf/open/floor/plating/rust)

/turf/open/floor/plating/make_plating()
	return

/turf/open/floor/plating/broken
	icon_state = "platingdmg1"
	broken = TRUE

/turf/open/floor/plating/broken/two
	icon_state = "platingdmg2"

/turf/open/floor/plating/broken/three
	icon_state = "platingdmg3"

/turf/open/floor/plating/burnt
	icon_state = "panelscorched"
	burnt = TRUE

/turf/open/floor/plating/foam
	name = "metal foam plating"
	desc = "Thin, fragile flooring created with metal foam."
	icon_state = "foam_plating"

/turf/open/floor/plating/foam/burn_tile()
	return //jetfuel can't melt steel foam

/turf/open/floor/plating/foam/break_tile()
	return //jetfuel can't break steel foam...

/turf/open/floor/plating/foam/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/tile/plasteel))
		var/obj/item/stack/tile/plasteel/P = I
		if(P.use(1))
			var/obj/L = locate(/obj/structure/lattice) in src
			if(L)
				qdel(L)
			to_chat(user, span_notice("You reinforce the foamed plating with tiling."))
			playsound(src, 'sound/weapons/Genhit.ogg', 50, TRUE)
			ChangeTurf(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
	else
		playsound(src, 'sound/weapons/tap.ogg', 100, TRUE) //The attack sound is muffled by the foam itself
		user.changeNext_move(CLICK_CD_MELEE)
		user.do_attack_animation(src)
		if(prob(I.force * 20 - 25))
			user.visible_message(span_danger("[user] smashes through [src]!"), \
							span_danger("You smash through [src] with [I]!"))
			ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
		else
			to_chat(user, span_danger("You hit [src], to no effect!"))

/turf/open/floor/plating/foam/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.construction_mode == RCD_FLOORWALL)
		return list("mode" = RCD_FLOORWALL, "delay" = 0, "cost" = 1)

/turf/open/floor/plating/foam/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	if(passed_mode == RCD_FLOORWALL)
		to_chat(user, span_notice("You build a floor."))
		ChangeTurf(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
		return TRUE
	return FALSE

/turf/open/floor/plating/foam/ex_act()
	..()
	ScrapeAway(flags = CHANGETURF_INHERIT_AIR)

/turf/open/floor/plating/foam/tool_act(mob/living/user, obj/item/I, tool_type)
	return

/turf/open/floor/plating/can_have_cabling()
	if(locate(/obj/structure/lattice/catwalk, src))
		return FALSE
	return TRUE
///not an actual turf its used just for rcd ui purposes
/turf/open/floor/plating/rcd
	name = "Floor/Wall"
	icon = 'icons/mob/radial.dmi'
	icon_state = "wallfloor"
