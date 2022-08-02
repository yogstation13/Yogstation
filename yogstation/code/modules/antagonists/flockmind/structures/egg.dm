/obj/structure/destructible/flock/egg
	name = "glowing egg"
	desc = "It looks like an... egg"
	flock_id = "Second-Stage Assembler"
	flock_desc = "Will soon hatch into a Flockdrone."
	max_integrity = 30
	var/when_emerge //Used for examine
	var/hatchin_time = 6 SECONDS

/obj/structure/destructible/flock/egg/Initialize()
	. = ..()
	addtimer(CALLBACK(src, .proc/hatch), hatchin_time)

/obj/structure/destructible/flock/egg/get_special_description(mob/user)
	. = ..()
	var/time_till_hatched = round((when_emerge - world.time)/10)
	. += span_swarmer("<span class='bold'>Time Untill Assembled:</span> [time_till_hatched] second[time_till_hatched == 1 ? "" : "s"]")

/obj/structure/destructible/flock/egg/proc/spawn_dude()
	return new /mob/living/simple_animal/hostile/flockdrone (loc)

/obj/structure/destructible/flock/egg/proc/hatch()
	visible_message(span_notice("[spawn_dude()] hatches from [src]!"))
	qdel(src)