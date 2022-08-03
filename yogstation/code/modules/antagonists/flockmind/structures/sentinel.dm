/obj/structure/destructible/flock/sentinel
	name = "glowing pylon"
	desc = "A glowing pylon of sorts, faint sparks are jumping inside of it."
	flock_id = "Sentinel"
	flock_desc = "A charged pylon, capable of sending disorienting arcs of electricity at enemies."
	max_integrity = 80
	var/charge_status = FALSE
	//Charge percentage
	var/charge = 0
	var/charge_per_tick = 4
	var/range = 4
	var/powered = FALSE
	var/online_compute_cost = -20

/obj/structure/destructible/flock/sentinel/Initialize()
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/obj/structure/destructible/flock/sentinel/process()
	var/datum/team/flock/flock = get_flock_team()
	if(charge < 100)
		if(flock.get_compute() < online_compute_cost) //We can't afford to charge if no compute(
			return 
		if(compute_provided != online_compute_cost)
			change_compute_amount(online_compute_cost)
		charge += charge_per_tick
		return
	if(compute_provided != 0)
		change_compute_amount(0)
	var/list/targets = acquire_nearby_targets()
	if(!targets.len)
		return
	var/mob/living/L = pick(targets)
	if(!L)
		return
	tesla_zap(L, range, 6000, TESLA_MOB_DAMAGE)
	charge = 0
	
/obj/structure/destructible/flock/sentinel/proc/acquire_nearby_targets()
	. = list()
	for(var/mob/living/L in viewers(range, src)) //Doesn't attack the blind
		if(L.stat || L.IsStun() || L.IsParalyzed()) //yogs: changes mobility flag to IsStun so people have to taze themselves to ignore warden attacks
			continue
		if(isflockdrone(L))
			continue 
		else if(isrevenant(L))
			var/mob/living/simple_animal/revenant/R = L
			if(R.stasis) //Don't target any revenants that are respawning
				continue
		else if(!L.mind)
			continue
		. += L
