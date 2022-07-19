/obj/item/barrier_taperoll
	name = "barrier tape roll"
	icon = 'icons/obj/barriertape.dmi'
	icon_state = "rollstart"
	w_class = WEIGHT_CLASS_SMALL
	var/turf/start
	var/turf/end
	var/tape_type = /obj/structure/barrier_tape
	var/icon_base
	var/placing = FALSE

/obj/structure/barrier_tape
	name = "barrier tape"
	icon = 'icons/obj/barriertape.dmi'
	anchored = TRUE
	density = TRUE
	var/lifted = FALSE
	var/crumpled = FALSE
	var/icon_base
	var/tape_dir

/obj/item/barrier_taperoll/police
	name = "police tape"
	desc = "A roll of police tape used to block off crime scenes from the public."
	icon_state = "police_start"
	tape_type = /obj/structure/barrier_tape/police
	icon_base = "police"

/obj/structure/barrier_tape/police
	name = "police tape"
	desc = "A length of police tape.  Do not cross."
	req_access = list(ACCESS_SECURITY)
	icon_base = "police"

/obj/item/barrier_taperoll/engineering
	name = "engineering tape"
	desc = "A roll of engineering tape used to block off working areas from the public."
	icon_state = "engineering_start"
	tape_type = /obj/structure/barrier_tape/engineering
	icon_base = "engineering"

/obj/structure/barrier_tape/engineering
	name = "engineering tape"
	desc = "A length of engineering tape. Better not cross it."
	req_access = list(ACCESS_CONSTRUCTION)
	icon_base = "engineering"

/obj/item/barrier_taperoll/attack_self(var/mob/user)
	if(!placing)
		start = get_turf(src)
		to_chat(usr, span_notice("You place the first end of the [src]."))
		icon_state = "[icon_base]_stop"
		placing = TRUE
	else
		placing = FALSE
		icon_state = "[icon_base]_start"
		end = get_turf(src)
		if(start.y != end.y && start.x != end.x || start.z != end.z)
			to_chat(usr, span_notice("[src] can only be laid horizontally or vertically."))
			return

		var/turf/cur = start
		var/dir
		if (start.x == end.x)
			var/d = end.y-start.y
			if(d) d = d/abs(d)
			end = get_turf(locate(end.x,end.y+d,end.z))
			dir = "v"
		else
			var/d = end.x-start.x
			if(d) d = d/abs(d)
			end = get_turf(locate(end.x+d,end.y,end.z))
			dir = "h"

		var/can_place = TRUE
		while (cur!=end && can_place)
			if(cur.density || istype(cur, /turf/open/space))
				can_place = FALSE
			else
				for(var/obj/O in cur)
					if(!istype(O, /obj/structure/barrier_tape) && O.density)
						can_place = FALSE
						break
			cur = get_step_towards(cur,end)
		if (!can_place)
			to_chat(usr, span_notice("You can't run \the [src] through that!"))
			return

		cur = start
		var/tapetest = FALSE
		while (cur!=end)
			for(var/obj/structure/barrier_tape/Ptest in cur)
				if(Ptest.tape_dir == dir)
					tapetest = TRUE
			if(!tapetest)
				var/obj/structure/barrier_tape/P = new tape_type(cur)
				P.icon_state = "[P.icon_base]_[dir]"
				P.tape_dir = dir
			cur = get_step_towards(cur,end)
	//is_blocked_turf(var/turf/T)
		to_chat(usr, span_notice("You finish placing the [src]."))	//Git Test

/obj/item/barrier_taperoll/afterattack(var/atom/A, var/mob/user, proximity)
	if (proximity && istype(A, /obj/machinery/door/airlock))
		var/turf/T = get_turf(A)
		var/obj/structure/barrier_tape/P = new tape_type(T.x,T.y,T.z)
		P.loc = locate(T.x,T.y,T.z)
		P.icon_state = "[icon_base]_door"
		P.layer = 3.2
		to_chat(user, span_notice("You finish placing the [src]."))

/obj/structure/barrier_tape/proc/crumple()
	if(!crumpled)
		crumpled = TRUE
		icon_state = "[icon_state]_c"
		name = "crumpled [name]"

/obj/structure/barrier_tape/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(.)
		return
	if(mover.pass_flags & (PASSGLASS|PASSTABLE|PASSGRILLE))
		return TRUE
	if(issilicon(mover))
		return TRUE
	if(iscarbon(mover))
		var/mob/living/carbon/C = mover
		if(C.stat)	// Lets not prevent dragging unconscious/dead people.
			return TRUE
		if(lifted == TRUE)
			return TRUE

/obj/structure/barrier_tape/Bumped(atom/movable/AM)
	. = ..()
	if(iscarbon(AM))
		add_fingerprint(AM)
		if(allowed(AM))
			to_chat(AM, span_notice("You lift [src] to pass under it"))
			lift_tape()
		if(lifted == FALSE)
			to_chat(AM, span_warning("You are not supposed to go past [src]... (You can break the tape with something sharp or lift the tape with HELP intent)"))

/obj/structure/barrier_tape/attackby(var/obj/item/W, var/mob/user)
	breaktape(W, user)

/obj/structure/barrier_tape/attack_hand(var/mob/user)
	if (user.a_intent == "help" )
		user.visible_message(span_notice("[user] lifts [src], allowing passage."))
		crumple()
		lift_tape()
	else
		breaktape(null, user)

/obj/structure/barrier_tape/proc/lift_tape()
	lifted = TRUE
	addtimer(VARSET_CALLBACK(src, lifted, FALSE), 2 SECONDS)

/obj/structure/barrier_tape/proc/breaktape(var/obj/item/W, var/mob/user)
	if(user.a_intent == INTENT_HELP && W && !W.is_sharp() && allowed(user))
		to_chat(user, span_warning("You can't break the [src] with that!"))
		return
	user.visible_message(span_notice("[user] breaks the [src]!"))
	playsound(src.loc, 'sound/items/poster_ripped.ogg', 100, 1)

	var/dir[2]
	if(tape_dir == "h")
		dir[1] = EAST
		dir[2] = WEST
	if(tape_dir == "v")
		dir[1] = NORTH
		dir[2] = SOUTH

	for(var/i=1;i<3;i++)
		var/N = FALSE
		var/turf/cur = get_step(src,dir[i])
		while(!N)
			N = TRUE
			for (var/obj/structure/barrier_tape/P in cur)
				if(P.tape_dir == tape_dir)
					N = FALSE
					qdel(P)
			cur = get_step(cur,dir[i])

	qdel(src)
	return
