/obj/structure/destructible/flock/collector
	name = "pulsing thing"
	desc = "A weird looking object."
	flock_id = "Collector"
	flock_desc = "Provides compute power based on the number of Flock floor tiles it is connected to."
	max_integrity = 60
	var/list/connected_to = list()
	var/maxrange = 5

/obj/structure/destructible/flock/collector/Initialize()
	. = ..()
	update_flocktiles_and_compute()

/obj/structure/destructible/flock/collector/proc/update_flocktiles_and_compute()
	connected_to = list()
	var/distance
	var/turf/open/floor/feather/floor 
	for(var/d in GLOB.cardinals)
		distance = 0
		floor = src.loc
		while(TRUE)
			floor = get_step(floor, d)
			if(!istype(floor)) 
				break
			if(floor.broken) 
				break
			if(distance >= maxrange) 
				break
			distance++
			connected_to |= floor
	change_compute_amount(max(0, length(connected_to)*5))
