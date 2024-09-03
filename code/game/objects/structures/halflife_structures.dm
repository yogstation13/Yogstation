// From Mojave Sun

/obj/structure/halflife/street_sign
	name = "\improper street sign"
	desc = "sign street is the other way."
	icon = 'icons/obj/halflife/street_signs.dmi'
	anchored = TRUE
	density = TRUE
	layer = ABOVE_MOB_LAYER
	max_integrity = 500
	projectile_passchance = 95

/obj/structure/halflife/street_sign/stop
	desc = "You would stop at this sign if there were any vehicles left on the roads for you to drive."
	icon_state = "stop"

/obj/structure/halflife/street_sign/turning
	desc = "No turning around now. A good lesson for life."
	icon_state = "noturn"

/obj/structure/halflife/street_sign/parking
	desc = "No pee allowed here?"
	icon_state = "noparking"

/obj/structure/halflife/street_sign/street
	desc = "A street sign. Interesting."
	icon_state = "street"

/obj/structure/halflife/street_sign/one_way
	desc = "It seems the road ahead is one way."
	icon_state = "direction"

/obj/structure/halflife/street_sign/bus
	desc = "You'll be waiting here a very long time if you want a bus."
	icon_state = "busstop"

/obj/structure/halflife/street_sign/railroad
	desc = "I suppose the combine still run trains around."
	icon_state = "railcrossing"

/obj/structure/halflife/street_sign/only_direction
	desc = "It's telling you to only go this way."
	icon_state = "onlydir"

/obj/structure/halflife/street_sign/speed
	desc = "The combine usually ignore these signs, anyways."
	icon_state = "speed"

/obj/structure/halflife/street_sign/warnings
	desc = "Looks like there are traffic lights nearby, presumably."
	icon_state = "warnings"

/obj/structure/halflife/street_sign/turn
	desc = "It's pointing a direction with arrows on it. Cool."
	icon_state = "turn"

/obj/machinery/power/halflife/streetlamp
	name = "\improper street lamp"
	desc = "A pre-war street lamp, what more is there to say?"
	icon = 'icons/obj/halflife/streetpoles.dmi'
	icon_state = "streetlight"
	anchored = TRUE
	density = TRUE
	layer = ABOVE_ALL_MOB_LAYER
	plane = ABOVE_GAME_PLANE
	max_integrity = 2000
	pixel_x = -32
	pixel_y = 8
	resistance_flags = INDESTRUCTIBLE

/obj/machinery/power/halflife/streetlamp/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(locate(/obj/machinery/power/halflife/streetlamp) in get_turf(mover))
		return TRUE
	else if(istype(mover, /obj/projectile))
		if(!anchored)
			return TRUE
		var/obj/projectile/proj = mover
		if(proj.firer && Adjacent(proj.firer))
			return TRUE
		if(prob(75)) // These things are pretty thin
			return TRUE
		return FALSE

/obj/machinery/power/halflife/streetlamp
	name = "\improper street lamp"
	desc = "It doesn't seem functional anymore."
	icon_state = "streetlight"

/obj/machinery/power/halflife/streetlamp/corner
	name = "\improper street lamp"
	icon_state = "streetlightcorner"

/obj/machinery/power/halflife/streetlamp/double
	name = "\improper street lamp"
	icon_state = "streetlightduo"

/obj/machinery/power/halflife/trafficlight
	name = "\improper traffic light"
	desc = "The combine tend to ignore these anyways."
	icon = 'icons/obj/halflife/streetpoles.dmi'
	anchored = TRUE
	max_integrity = 2000
	pixel_x = -32
	icon_state = "trafficlightright"
	resistance_flags = INDESTRUCTIBLE

/obj/machinery/power/halflife/trafficlight/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(locate(/obj/machinery/power/halflife/trafficlight) in get_turf(mover))
		return TRUE
	else if(istype(mover, /obj/projectile))
		if(!anchored)
			return TRUE
		var/obj/projectile/proj = mover
		if(proj.firer && Adjacent(proj.firer))
			return TRUE
		if(prob(75)) // These things are pretty thin
			return TRUE
		return FALSE

/obj/machinery/power/halflife/trafficlight/alt
	icon_state = "trafficlightleft"

//Ladders

/obj/structure/ladder/halflife
	name = "ladder"
	desc = "A questionable metal ladder. There's got to be stairs around, right?"
	icon = 'icons/obj/halflife/ladders.dmi'
	icon_state = "ladder01"
	resistance_flags = INDESTRUCTIBLE
	travel_time = 2 SECONDS

/obj/structure/ladder/halflife/upwards
	icon_state = "ladder10"

/obj/structure/ladder/halflife/travel(going_up, mob/user, is_ghost, obj/structure/ladder/ladder)
	if(!is_ghost)
		ladder.add_fingerprint(user)
		if(!do_after(user, travel_time, target = src))
			return
		/*playsound(user, pick('mojave/sound/halflifeeffects/ladder1.ogg',
							'mojave/sound/halflifeeffects/ladder2.ogg',
							'mojave/sound/halflifeeffects/ladder3.ogg',
							'mojave/sound/halflifeeffects/ladder4.ogg'), 60) */

	var/turf/target = get_turf(ladder)
	user.zMove(target = target, z_move_flags = ZMOVE_CHECK_PULLEDBY|ZMOVE_ALLOW_BUCKLED|ZMOVE_INCLUDE_PULLED)
	ladder.use(user) //reopening ladder radial menu ahead

// TG code edit to add a check for blocked ladders //

/obj/structure/ladder/halflife/use(mob/user, is_ghost=FALSE)
	if (!is_ghost && !in_range(src, user))
		return

	if(obstructed)
		to_chat(user, span_warning("It's blocked, you'll have to find a way to change that."))
		return

	var/list/tool_list = list()
	if (up)
		tool_list["Up"] = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = NORTH)
	if (down)
		tool_list["Down"] = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = SOUTH)
	if (!length(tool_list))
		to_chat(user, span_warning("[src] doesn't seem to lead anywhere!"))
		return

	var/result = show_radial_menu(user, src, tool_list, custom_check = CALLBACK(src, PROC_REF(check_menu), user, is_ghost), require_near = !is_ghost, tooltips = TRUE)
	if (!is_ghost && !in_range(src, user))
		return  // nice try
	switch(result)
		if("Up")
			if(up.obstructed)
				to_chat(user, span_warning("[src] is obstructed!"))
				return
			else
				travel(TRUE, user, is_ghost, up)
		if("Down")
			travel(FALSE, user, is_ghost, down)
		if("Cancel")
			return

	if(!is_ghost)
		add_fingerprint(user)

///////////////////// MANHOLE COVER /////////////////////////

/obj/structure/ladder/halflife/manhole
	name = "manhole"
	desc = "A manhole ladder, you could probably push the cover off from here, or try dragging it back on."
	travel_time = 2 SECONDS
	pixel_y = 7
	icon_state = "manhole_closed"

/obj/structure/ladder/halflife/manhole/upwards
	icon_state = "ladder10"

/obj/structure/ladder/halflife/manhole/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Use <b>RIGHT-CLICK</b> on [src] to open or close it.</span>"

/obj/structure/ladder/halflife/manhole/attack_hand_secondary(mob/living/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return

	. = SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	var/obj/item/bodypart/arm = user.get_bodypart(user.active_hand_index % 2 ? BODY_ZONE_L_ARM : BODY_ZONE_R_ARM)

	if(!down && up.obstructed)
		if(do_after(user, 10 SECONDS, target = src, interaction_key = DOAFTER_SOURCE_LADDERBLOCKERS))
			up.icon_state = "manhole_open"
			up.desc = "An open manhole, it still stinks even after all these years. You could use a crowbar or your hands to slide the cover back on."
			up.obstructed = FALSE
			obstructed = FALSE
			to_chat(user, span_notice("You push up on the cover from below, and slide it off."))
			return

	if(!down && !up.obstructed)
		if(do_after(user, 10 SECONDS, target = src, interaction_key = DOAFTER_SOURCE_LADDERBLOCKERS))
			up.icon_state = "manhole_closed"
			up.desc = "A heavy stamped manhole. You could probably pry it up with a crowbar to access the lower town systems. Or, try using your hands..."
			up.obstructed = TRUE
			obstructed = TRUE
			to_chat(user, span_notice("You carefully drag and slide the cover back on from below."))
			return

	else
		if(obstructed)
			to_chat(user, span_warning("It's so heavy! Surely there's a better way of doing this."))
			if(do_after(user, 10 SECONDS, target = src, interaction_key = DOAFTER_SOURCE_LADDERBLOCKERS))
				obstructed = FALSE
				down.obstructed = FALSE
				icon_state = "manhole_open"
				desc = "An open manhole, it still stinks even after all these years. You could use a crowbar or your hands to slide the cover back on."
				to_chat(user, span_notice("With a lot of effort, you manage to finally get the cover off."))
				if(prob(10))
					to_chat(user, span_userdanger("MY ARM! THE PAIN!"))
					arm.force_wound_upwards(/datum/wound/blunt/moderate)
					arm.receive_damage(10)
		else
			if(do_after(user, 10 SECONDS, target = src, interaction_key = DOAFTER_SOURCE_LADDERBLOCKERS))
				obstructed = TRUE
				down.obstructed = TRUE
				icon_state = "manhole_closed"
				desc = "A heavy stamped manhole. You could probably pry it up with a crowbar to access the lower town systems. Or, try using your hands..."
				to_chat(user, span_notice("You carefully slide the cover back on the manhole."))


/obj/structure/ladder/halflife/manhole/crowbar_act(mob/living/user, obj/item/tool)
	if(down && obstructed)
		if(do_after(user, 4 SECONDS * tool.toolspeed, target = src, interaction_key = DOAFTER_SOURCE_LADDERBLOCKERS))
			obstructed = FALSE
			down.obstructed = FALSE
			icon_state = "manhole_open"
			desc = "An open manhole. You could use a crowbar or your hands to slide the cover back on."
			to_chat(user, span_notice("You wedge the crowbar in and pull the cover off the manhole."))
			return

	if(down && !obstructed)
		if(do_after(user, 4 SECONDS * tool.toolspeed, target = src, interaction_key = DOAFTER_SOURCE_LADDERBLOCKERS))
			obstructed = TRUE
			down.obstructed = TRUE
			icon_state = "manhole_closed"
			desc = "A heavy stamped manhole. You could probably pry it up with a crowbar to access the lower town systems. Or, try using your hands..."
			to_chat(user, span_notice("You hook the edge of the manhole cover with your crowbar and slide it back on."))
			return

/obj/structure/ladder/halflife/manhole/update_icon_state()
	. = ..()
	if(down)
		name = "manhole entry"
		desc = "A heavy stamped manhole. You could probably pry it up with a crowbar to access the lower town systems."
		icon_state = "manhole_closed"
		pixel_y = 7
		obstructed = TRUE
	else
		icon_state = "ladder10"

/obj/structure/bed/halflife
	name = "base class Mojave Sun bed"
	desc = "Scream at the coders if you see this."
	icon = 'icons/obj/halflife/beds.dmi'
	bolts = FALSE 

/obj/structure/bed/halflife/wrench_act(mob/living/user, obj/item/weapon)
	return

//bed//

/obj/structure/bed/halflife/bedframe
	name = "base class bedframe"
	desc = "Scream at the coders if you see this."

/obj/structure/bed/halflife/bedframe/wire
	name = "wireframe bed"
	desc = "A bed with a wire backing."
	icon_state = "wire_bed"

/obj/structure/bed/halflife/bedframe/metal
	name = "metal bed"
	desc = "A slatted metal bed."
	icon_state = "metal_bed"

/obj/structure/bed/halflife/bedframe/cot
	name = "cot"
	desc = "A cot. Still usable without a mattress."
	icon_state = "cot"

/obj/structure/bed/halflife/bedframe/wood
	name = "wood bed"
	desc = "A panel bed made from wood."
	icon_state = "wood_bed"

//mattress//

/obj/structure/bed/halflife/mattress
	name = "base class mattress"
	desc = "Scream at the coders if you see this."

/obj/structure/bed/halflife/mattress/dirty
	name = "mattress"
	desc = "Less of a mattress and more of a lump."
	icon_state = "dirty_mattress"

/obj/structure/bed/halflife/mattress/old
	name = "mattress"
	desc = "Mildly stained and better than most."
	icon_state = "old_mattress"

/obj/structure/bed/halflife/mattress/stained
	name = "mattress"
	desc = "No idea what these stains are."
	icon_state = "stained_mattress"

/obj/structure/bed/halflife/mattress/yellowed
	name = "mattress"
	desc = "This was white when someone bought it."
	icon_state = "yellowed_mattress"

/obj/structure/bed/halflife/mattress/filthy
	name = "mattress"
	desc = "Is that mold?"
	icon_state = "filthy_mattress"

/obj/structure/bed/halflife/mattress/stale
	name = "mattress"
	desc = "Relatively clean."
	icon_state = "stale_mattress"
