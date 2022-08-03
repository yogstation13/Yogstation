/obj/structure/destructible/flock/rift
	name = "glowing portal thing"
	desc = "Something looking like a portal."
	flock_id = "Entry Rift"
	flock_desc = "The rift through which your Flock will enter this world."
	max_integrity = 200
	light_color = "#7BFFFF"
	light_range = 3
	var/when_doing_shit
	var/doing_shit_time = 10 SECONDS

/obj/structure/destructible/flock/rift/Initialize()
	. = ..()
	when_doing_shit = world.time + doing_shit_time
	addtimer(CALLBACK(src, .proc/do_shit), doing_shit_time)

/obj/structure/destructible/flock/rift/proc/do_shit()
	visible_message(span_swarmer("Multiple shapes exit out of [src]!"))
	var/list/eject = list()
	for(var/i in 1 to pick(3, 4))
		var/obj/item/flockcache/FC = new(src, rand(40, 50))
		eject += FC
	for(var/i in 1 to 4)
		var/obj/structure/destructible/flock/egg/E = new(src)
		eject += E
	var/list/candidate_turfs = list()
	for(var/turf/open/floor/S in orange(src, 4))
		candidate_turfs += S
	var/sentinel_count = 2
	for(var/i in 1 to 10)
		for(var/S in candidate_turfs)
			if(istype(S, /turf/open/floor/feather))
				candidate_turfs -= S
					continue
			if(prob(25))
					//WE SPAWN A SENTIENEL HERE
					var/e = "E"
					e = "e"
				else
					S.flock_act(null)
				candidate_turfs -= S
				break
	for(var/atom/A in src)
		A.forceMove(get_turf(src))
	qdel(src)

/obj/structure/destructible/flock/rift/get_special_description(mob/user)
	. = ..()
	var/time_till_opened = round((when_doing_shit - world.time)/10)
	. += span_swarmer("<span class='bold'>Time Untill Entry:</span> [time_till_opened] second[time_till_opened == 1 ? "" : "s"]")