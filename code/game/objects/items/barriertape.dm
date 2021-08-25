//Define all tape types in policetape.dm
/obj/item/barrier_taperoll
	name = "barrier tape roll"
	icon = 'icons/obj/barriertape.dmi'
	icon_state = "rollstart"
	w_class = 2.0
	var/turf/start
	var/turf/end
	var/tape_type = /obj/item/barrier_tape
	var/icon_base
	var/placing = FALSE

/obj/item/barrier_tape
	name = "barrier tape"
	icon = 'icons/obj/barriertape.dmi'
	anchored = TRUE
	var/lifted = FALSE
	var/crumpled = FALSE
	var/icon_base
	var/tape_dir


/obj/item/barrier_taperoll/police
	name = "police tape"
	desc = "A roll of police tape used to block off crime scenes from the public."
	icon_state = "police_start"
	tape_type = /obj/item/barrier_tape/police
	icon_base = "police"

/obj/item/barrier_tape/police
	name = "police tape"
	desc = "A length of police tape.  Do not cross."
	req_access = list(ACCESS_SECURITY)
	icon_base = "police"

/obj/item/barrier_taperoll/engineering
	name = "engineering tape"
	desc = "A roll of engineering tape used to block off working areas from the public."
	icon_state = "engineering_start"
	tape_type = /obj/item/barrier_tape/engineering
	icon_base = "engineering"

/obj/item/barrier_tape/engineering
	name = "engineering tape"
	desc = "A length of engineering tape. Better not cross it."
	req_access = list(ACCESS_CONSTRUCTION)
	icon_base = "engineering"

/obj/item/barrier_taperoll/attack_self(mob/user as mob)
	if(!placing)
		start = get_turf(src)
		to_chat(usr, "<span class='notice'>You place the first end of the [src].</span>")
		icon_state = "[icon_base]_stop"
		placing = TRUE
	else
		placing = FALSE
		icon_state = "[icon_base]_start"
		end = get_turf(src)
		if(start.y != end.y && start.x != end.x || start.z != end.z)
			to_chat(usr, "<span class='notice'>[src] can only be laid horizontally or vertically.</span>")
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
			if(cur.density)
				can_place = FALSE
			else if (istype(cur, /turf/open/space))
				can_place = FALSE
			else
				for(var/obj/O in cur)
					if(!istype(O, /obj/item/barrier_tape) && O.density)
						can_place = FALSE
						break
			cur = get_step_towards(cur,end)
		if (!can_place)
			to_chat(usr, "<span class='warning'>You can't run \the [src] through that!</notice>")
			return

		cur = start
		var/tapetest = FALSE
		while (cur!=end)
			for(var/obj/item/barrier_tape/Ptest in cur)
				if(Ptest.tape_dir == dir)
					tapetest = TRUE
			if(!tapetest)
				var/obj/item/barrier_tape/P = new tape_type(cur)
				P.icon_state = "[P.icon_base]_[dir]"
				P.tape_dir = dir
			cur = get_step_towards(cur,end)
	//is_blocked_turf(var/turf/T)
		to_chat(usr, "<span class='notice'>You finish placing the [src].</span>")	//Git Test

/obj/item/barrier_taperoll/afterattack(var/atom/A, mob/user as mob, proximity)
	if (proximity && istype(A, /obj/machinery/door/airlock))
		var/turf/T = get_turf(A)
		var/obj/item/barrier_tape/P = new tape_type(T.x,T.y,T.z)
		P.loc = locate(T.x,T.y,T.z)
		P.icon_state = "[icon_base]_door"
		P.layer = 3.2
		to_chat(user, "<span class='notice'>You finish placing the [src].</span>")

/obj/item/barrier_tape/proc/crumple()
	if(!crumpled)
		crumpled = TRUE
		icon_state = "[icon_state]_c"
		name = "crumpled [name]"

/obj/item/barrier_tape/Cross(atom/movable/mover, turf/target)
	if(!lifted && ismob(mover))
		var/mob/M = mover
		add_fingerprint(M)
		if (!allowed(M))	//only select few learn art of not crumpling the tape
			to_chat(M, "<span class='warning'>You are not supposed to go past [src]...</span>")
			crumple()
	return ..(mover)

/obj/item/barrier_tape/attackby(obj/item/W as obj, mob/user as mob)
	breaktape(W, user)

/obj/item/barrier_tape/attack_hand(mob/user as mob)
	if (user.a_intent == "help" && allowed(user))
		user.visible_message("<span class='notice'>[user] lifts [src], allowing passage.</span>")
		crumple()
		lifted = TRUE
		sleep(20 SECONDS)
		lifted = FALSE
	else
		breaktape(null, user)



/obj/item/barrier_tape/proc/breaktape(obj/item/W as obj, mob/user as mob)
	if(user.a_intent == INTENT_HELP && W && !W.is_sharp() && allowed(user))
		to_chat(user, "<span class='warning'>You can't break the [src] with that!</span>")
		return
	user.visible_message("<span class='notice'>[user] breaks the [src]!</span>")

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
			for (var/obj/item/barrier_tape/P in cur)
				if(P.tape_dir == tape_dir)
					N = FALSE
					qdel(P)
			cur = get_step(cur,dir[i])

	qdel(src)
	return


