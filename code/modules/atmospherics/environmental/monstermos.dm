#define MONSTERMOS_TURF_LIMIT 75

/turf/open
	var/last_eq_cycle
	var/eq_mole_delta = 0
	var/list/eq_transfer_dirs
	var/turf/open/curr_eq_transfer_turf
	var/curr_eq_transfer_amount
	var/eq_fast_done = FALSE
	var/eq_distance_score = 0

/turf/open/proc/adjust_eq_movement(turf/open/other, amount = 0)
	if(!other)
		return
	if(!eq_transfer_dirs)
		eq_transfer_dirs = list()
	if(!eq_transfer_dirs[other])
		eq_transfer_dirs[other] = amount
	else
		eq_transfer_dirs[other] += amount
	if(other != src)
		if(!other.eq_transfer_dirs)
			other.eq_transfer_dirs = list()
		if(!other.eq_transfer_dirs[src])
			other.eq_transfer_dirs[src] = -amount
		else
			other.eq_transfer_dirs[src] -= amount

/turf/open/proc/finalize_eq()
	var/list/transfer_dirs = eq_transfer_dirs
	if(!transfer_dirs)
		return
	eq_transfer_dirs = null // null it out to prevent infinite recursion.
	var/planet_transfer_amount = transfer_dirs[src] || 0
	var/list/cached_gases = air.gases
	var/sum
	if(planet_transfer_amount > 0)
		TOTAL_MOLES(cached_gases, sum)
		if(sum < planet_transfer_amount)
			finalize_eq_neighbors(transfer_dirs)
		remove_air(planet_transfer_amount)

	if(planet_transfer_amount < 0) // succ gases from above.
		var/datum/gas_mixture/G = new
		G.copy_from_turf(src)
		var/list/planet_gases = G.gases
		var/planet_sum
		TOTAL_MOLES(planet_gases, planet_sum)
		if(planet_sum > 0) // oi you cant just suck gases from turfs with no air.
			var/multiplier = -planet_transfer_amount / planet_sum
			for(var/id in planet_gases)
				planet_gases[id][MOLES] *= multiplier
			assume_air(G)

	for(var/t in transfer_dirs)
		if(t == src)
			continue
		var/amount = transfer_dirs[t]
		var/turf/open/T = t
		if(amount > 0)
			// gas push time baby
			// but first gotta make sure we got enough gas for that.
			TOTAL_MOLES(cached_gases, sum)
			if(sum < amount)
				finalize_eq_neighbors(transfer_dirs)
			if(T.eq_transfer_dirs)
				T.eq_transfer_dirs -= src
			// air.transfer_to(T.return_air(), amount) // push them gases.
			//update_visuals()
			//T.update_visuals()
			T.assume_air(remove_air(amount))
			consider_pressure_difference(T, amount)

/turf/open/proc/finalize_eq_neighbors(list/transfer_dirs)
	for(var/t in transfer_dirs)
		if(t == src)
			continue
		var/amount = transfer_dirs[t]
		if(amount < 0)
			var/turf/open/T = t
			T.finalize_eq() // just a bit of recursion if necessary.

// This proc has a worst-case running time of about O(n^2), but this is
// is really rare. Otherwise you get more like O(n*log(n)) (there's a sort in there), or if you get lucky its faster.
/proc/equalize_pressure_in_zone(turf/open/starting_point, cyclenum)
	// okay I lied in the proc name it equalizes moles not pressure. Pressure is impossible.
	// wanna know why? well let's say you have two turfs. One of them is 101.375 kPA and the other is 101.375 kPa.
	// When they mix what's the pressure gonna be, before any reactions occur? If you guessed 1483.62 kPa you'd be right,
	// because one of them is 101.375 kPa of hyper-noblium at 1700K temperature, and the other is 101.375 kPa of nitrogen at 43.15K temperature,
	// and that's just the way the math works out in SS13. And there's no reactions going on - hyper-noblium stops all reactions from happening.
	// I'm pretty sure real gases don't work this way. Oh yeah this property can be used to make bombs too I guess so thats neat

	if(!istype(starting_point) || starting_point.last_eq_cycle >= cyclenum)
		return // if we've alrady done it then piss off.

	// first gotta figure out if it's even necessary
	var/starting_moles
	var/list/starting_gases = starting_point.air.gases
	var/run_monstermos = FALSE
	TOTAL_MOLES(starting_gases, starting_moles)
	for(var/t in starting_point.atmos_adjacent_turfs)
		var/turf/open/T = t;
		var/list/comparison_gases = T.air.gases
		var/comparison_moles
		TOTAL_MOLES(comparison_gases, comparison_moles)
		if(abs(comparison_moles - starting_moles) > MINIMUM_MOLES_DELTA_TO_MOVE)
			run_monstermos = TRUE
			break
	if(!run_monstermos) // if theres no need dont bother
		starting_point.last_eq_cycle = cyclenum
		return

	if(starting_point.planetary_atmos)
		return // nah, let's not lag the server trying to process lavaland please.

	// it has been deemed necessary. Now to figure out which turfs are involved.

	var/total_moles
	var/list/turfs = list()
	turfs[starting_point] = 1
	var/list/planet_turfs = list()
	for(var/i = 1; i <= turfs.len; i++) // turfs.len changes so this is necessary
		var/turf/open/T = turfs[i]
		T.eq_mole_delta = 0
		T.eq_transfer_dirs = list()
		T.eq_distance_score = i
		if(i < MONSTERMOS_TURF_LIMIT)
			var/turf_moles
			var/list/cached_gases = T.air.gases
			TOTAL_MOLES(cached_gases, turf_moles)
			T.eq_mole_delta = turf_moles
			T.eq_fast_done = FALSE
			if(T.planetary_atmos)
				planet_turfs += T
				continue
			total_moles += turf_moles
		for(var/t2 in T.atmos_adjacent_turfs)
			var/turf/open/T2 = t2
			turfs[T2] = 1
			if(istype(T2, /turf/open/space))
				// Uh oh! looks like someone opened an airlock to space! TIME TO SUCK ALL THE AIR OUT!!!
				// NOT ONE OF YOU IS GONNA SURVIVE THIS
				// (I just made explosions less laggy, you're welcome)
				explosively_depressurize(T, cyclenum)
				return
		CHECK_TICK
	if(turfs.len >= MONSTERMOS_TURF_LIMIT)
		turfs.Cut(MONSTERMOS_TURF_LIMIT)
	var/average_moles = total_moles / (turfs.len - planet_turfs.len)
	var/list/giver_turfs = list()
	var/list/taker_turfs = list()
	for(var/t in turfs)
		var/turf/open/T = t
		T.last_eq_cycle = cyclenum
		T.eq_mole_delta -= average_moles
		if(T.planetary_atmos)
			continue
		if(T.eq_mole_delta > 0)
			giver_turfs += T
		else if(T.eq_mole_delta < 0)
			taker_turfs += T

	var/log_n = log(2, turfs.len)
	if(giver_turfs.len > log_n && taker_turfs.len > log_n) // optimization - try to spread gases using an O(nlogn) algorithm that has a chance of not working first to avoid O(n^2)
		// even if it fails, it will speed up the next part
		var/list/eligible_adj = list()
		sortTim(turfs, /proc/cmp_monstermos_pushorder)
		for(var/t in turfs)
			var/turf/open/T = t
			T.eq_fast_done = TRUE
			if(T.eq_mole_delta > 0)
				eligible_adj.Cut()
				for(var/t2 in T.atmos_adjacent_turfs)
					var/turf/open/T2 = t2
					if(T2.eq_fast_done)
						continue
					eligible_adj += T2
				if(eligible_adj.len <= 0)
					continue // Oof we've painted ourselves into a corner. Bad luck. Next part will handle this.
				var/moles_to_move = T.eq_mole_delta / eligible_adj.len
				for(var/t2 in eligible_adj)
					var/turf/open/T2 = t2
					T.adjust_eq_movement(T2, moles_to_move)
					T.eq_mole_delta -= moles_to_move
					T2.eq_mole_delta += moles_to_move
				CHECK_TICK
		giver_turfs.Cut() // we need to recaclculate those now
		taker_turfs.Cut()
		for(var/t in turfs)
			var/turf/open/T = t
			if(T.planetary_atmos)
				continue
			if(T.eq_mole_delta > 0)
				giver_turfs += T
			else if(T.eq_mole_delta < 0)
				taker_turfs += T

	// alright this is the part that can become O(n^2).
	if(giver_turfs.len < taker_turfs.len) // as an optimization, we choose one of two methods based on which list is smaller. We really want to avoid O(n^2) if we can.
		for(var/g in giver_turfs)
			var/turf/open/giver = g
			giver.curr_eq_transfer_turf = giver
			giver.curr_eq_transfer_amount = 0
			var/list/queue = list()
			queue[giver] = TRUE
			for(var/i = 1; i <= queue.len; i++)
				if(giver.eq_mole_delta <= 0)
					break // we're done here now. Let's not do more work than we need.
				var/turf/open/T = queue[i]
				for(var/t2 in T.atmos_adjacent_turfs)
					if(giver.eq_mole_delta <= 0)
						break // we're done here now. Let's not do more work than we need.
					var/turf/open/T2 = t2
					if(T2.planetary_atmos)
						continue
					if(queue[T2])
						continue
					queue[T2] = 1
					T2.curr_eq_transfer_turf = T
					T2.curr_eq_transfer_amount = 0
					if(T2.eq_mole_delta < 0)
						// this turf needs gas. Let's give it to 'em.
						if(-T2.eq_mole_delta > giver.eq_mole_delta)
							// we don't have enough gas
							T2.curr_eq_transfer_amount -= giver.eq_mole_delta
							T2.eq_mole_delta += giver.eq_mole_delta
							giver.eq_mole_delta = 0
						else
							// we have enough gas.
							T2.curr_eq_transfer_amount += T2.eq_mole_delta
							giver.eq_mole_delta += T2.eq_mole_delta
							T2.eq_mole_delta = 0
			for(var/i = queue.len; i > 0; i--) // putting this loop here helps make it O(n^2) over O(n^3) I nearly put this in the previous loop that would have been really really slow and bad.
				var/turf/open/T = queue[i]
				if(T.curr_eq_transfer_amount && T.curr_eq_transfer_turf != T)
					T.adjust_eq_movement(T.curr_eq_transfer_turf, T.curr_eq_transfer_amount)
					T.curr_eq_transfer_turf.curr_eq_transfer_amount += T.curr_eq_transfer_amount
					T.curr_eq_transfer_amount = 0
			CHECK_TICK
	else
		for(var/t in taker_turfs)
			var/turf/open/taker = t
			taker.curr_eq_transfer_turf = taker
			taker.curr_eq_transfer_amount = 0
			var/list/queue = list()
			queue[taker] = TRUE
			for(var/i = 1; i <= queue.len; i++)
				if(taker.eq_mole_delta >= 0)
					break // we're done here now. Let's not do more work than we need.
				var/turf/open/T = queue[i]
				for(var/t2 in T.atmos_adjacent_turfs)
					if(taker.eq_mole_delta >= 0)
						break // we're done here now. Let's not do more work than we need.
					var/turf/open/T2 = t2
					if(T2.planetary_atmos)
						continue
					if(queue[T2])
						continue
					queue[T2] = 1
					T2.curr_eq_transfer_turf = T
					T2.curr_eq_transfer_amount = 0
					if(T2.eq_mole_delta > 0)
						// this turf has gas we can succ. Time to succ.
						if(T2.eq_mole_delta > -taker.eq_mole_delta)
							// they have enough gas
							T2.curr_eq_transfer_amount -= taker.eq_mole_delta
							T2.eq_mole_delta += taker.eq_mole_delta
							taker.eq_mole_delta = 0
						else
							// they don't have enough gas.
							T2.curr_eq_transfer_amount += T2.eq_mole_delta
							taker.eq_mole_delta += T2.eq_mole_delta
							T2.eq_mole_delta = 0
			for(var/i = queue.len; i > 0; i--)
				var/turf/open/T = queue[i]
				if(T.curr_eq_transfer_amount && T.curr_eq_transfer_turf != T)
					T.adjust_eq_movement(T.curr_eq_transfer_turf, T.curr_eq_transfer_amount)
					T.curr_eq_transfer_turf.curr_eq_transfer_amount += T.curr_eq_transfer_amount
					T.curr_eq_transfer_amount = 0
			CHECK_TICK

	if(planet_turfs.len) // now handle planet turfs
		var/turf/open/sample = planet_turfs[1] // we're gonna assume all the planet turfs are the same.
		var/datum/gas_mixture/G = new
		G.copy_from_turf(sample)
		var/list/planet_gases = G.gases
		var/planet_sum
		TOTAL_MOLES(planet_gases, planet_sum)
		var/target_delta = planet_sum - average_moles

		var/list/progression_order = list()
		for(var/t in planet_turfs)
			var/turf/open/T = t
			progression_order[T] = 1
			T.curr_eq_transfer_turf = T
		// now build a map of where the path to planet turf is for each tile.
		for(var/i = 1; i <= progression_order.len; i++)
			var/turf/open/T = progression_order[i]
			for(var/t2 in T.atmos_adjacent_turfs)
				if(!turfs[t2]) continue
				if(progression_order[t2])
					continue
				var/turf/open/T2 = t2
				if(T2.planetary_atmos)
					continue
				T2.curr_eq_transfer_turf = T
				progression_order[T2] = 1
		// apply airflow to turfs
		for(var/i = progression_order.len; i > 0; i--)
			var/turf/open/T = progression_order[i]
			var/turf/open/T2 = T.curr_eq_transfer_turf
			var/airflow = T.eq_mole_delta - target_delta
			T.adjust_eq_movement(T2, airflow)
			if(T != T2)
				T2.eq_mole_delta += airflow
			T.eq_mole_delta = target_delta

	for(var/t in turfs)
		var/turf/open/T = t
		T.finalize_eq()
	for(var/t in turfs)
		var/turf/open/T = t
		// make sure there's actually a difference - remember, we just equalized like all the pressure.
		// it's very likely there's no significant difference in the gases, and we don't want to fuck around with
		// expensive list operations afterwards.
		for(var/t2 in T.atmos_adjacent_turfs)
			var/turf/open/T2 = t2
			if(T.air.compare(T2.air))
				SSair.add_to_active(T)
				break

/proc/cmp_monstermos_pushorder(turf/open/A, turf/open/B)
	if(A.eq_mole_delta != B.eq_mole_delta)
		return B.eq_mole_delta - A.eq_mole_delta
	/*var/a_len = A.atmos_adjacent_turfs?.len || 0
	var/b_len = B.atmos_adjacent_turfs?.len || 0
	if(a_len != b_len)
		if(A.eq_mole_delta > 0)
			return a_len - b_len
		else
			return b_len - a_len*/ // hm I think this might actually be counterproductive
	if(A.eq_mole_delta > 0)
		return B.eq_distance_score - A.eq_distance_score
	else
		return A.eq_distance_score - B.eq_distance_score

/proc/explosively_depressurize(turf/open/starting_point, cyclenum)
	var/total_gases_deleted = 0
	// this is where all the air is immediately vented into space. Right now. Immediately.
	var/list/turfs = list()
	turfs[starting_point] = 1
	var/list/space_turfs = list() // this is where we keep all the space turfs so that our wallslam hell is realistic
	// start by figuring out which turfs are actually affected
	var/warned_about_planet_atmos = FALSE
	for(var/i = 1; i <= turfs.len; i++)
		CHECK_TICK
		var/turf/open/T = turfs[i]
		T.last_eq_cycle = cyclenum
		T.pressure_direction = 0
		if(T.planetary_atmos)
			// planet atmos > space
			if(!warned_about_planet_atmos)
				message_admins("Space turf(s) at [ADMIN_VERBOSEJMP(starting_point)] is connected to planetary turf(s) at [ADMIN_VERBOSEJMP(T)]!")
				log_game("Space turf(s) at [AREACOORD(starting_point)] is connected to planetary turf(s) at [AREACOORD(T)]!")
				warned_about_planet_atmos = TRUE
			continue
		if(istype(T, /turf/open/space))
			space_turfs += T
			T.pressure_specific_target = T
		else
			for(var/t2 in T.atmos_adjacent_turfs)
				var/turf/open/T2 = t2
				var/reconsider_adj = FALSE
				for(var/obj/machinery/door/firedoor/FD in T2)
					if((FD.flags_1 & ON_BORDER_1) && get_dir(T2, T) != FD.dir)
						continue
					FD.emergency_pressure_stop()
					reconsider_adj = TRUE
				for(var/obj/machinery/door/firedoor/FD in T)
					if((FD.flags_1 & ON_BORDER_1) && get_dir(T, T2) != FD.dir)
						continue
					FD.emergency_pressure_stop()
					reconsider_adj = TRUE
				if(reconsider_adj)
					T2.ImmediateCalculateAdjacentTurfs() // We want those firelocks closed yesterday.
					if(T2 in T.atmos_adjacent_turfs)
						turfs[T2] = 1
				else
					turfs[T2] = 1
	if(warned_about_planet_atmos)
		return // planet atmos > space

	var/list/progression_order = list()
	for(var/T in space_turfs)
		progression_order[T] = 1
	// now build a map of where the path to space is for each tile.
	for(var/i = 1; i <= progression_order.len; i++)
		CHECK_TICK
		var/turf/open/T = progression_order[i]
		for(var/t2 in T.atmos_adjacent_turfs)
			if(!turfs[t2]) continue
			if(progression_order[t2])
				continue
			if(istype(t2, /turf/open/space))
				continue
			var/turf/open/T2 = t2
			T2.pressure_direction = get_dir(T2, T)
			T2.pressure_difference = 0
			T2.pressure_specific_target = T.pressure_specific_target
			progression_order[T2] = 1
	// apply pressure differences to turfs
	for(var/i = progression_order.len; i > 0; i--)
		CHECK_TICK
		var/turf/open/T = progression_order[i]
		if(T.pressure_direction == 0)
			continue
		SSair.high_pressure_delta |= T
		var/turf/open/T2 = get_step_multiz(T, T.pressure_direction)
		if(!istype(T2))
			continue
		var/list/cached_gases = T.air.gases
		var/sum
		TOTAL_MOLES(cached_gases, sum)
		total_gases_deleted += sum
		T.pressure_difference += sum // our pressure gets applied to our tile
		T2.pressure_difference += T.pressure_difference // then our tile gets propogated to the next tile.
		if(!T2.pressure_direction)
			T2.pressure_direction = T.pressure_direction // extend wallslam hell into space a bit, that way you're not totally safe from WALLSLAM HELL when in space.
		cached_gases.Cut() // oh yeah its now vacuum I guess too, that's pretty important I think.
		T.update_visuals() // yeah removing the plasma overlay is probably important.
		if(istype(T, /turf/open/floor) && sum > 20 && prob(CLAMP(sum / 10, 0, 30)))
			var/turf/open/floor/F = T
			F.remove_tile()

	if((total_gases_deleted / turfs.len) > 20 && turfs.len > 10) // logging I guess
		if(SSticker.current_state != GAME_STATE_FINISHED && SSair.log_explosive_decompression)
			message_admins("Explosive decompression occured at [ADMIN_VERBOSEJMP(starting_point)], sucking [total_gases_deleted] moles of air into space.")
		log_game("Explosive decompression occured at [AREACOORD(starting_point)], sucking [total_gases_deleted] moles of air into space.")
