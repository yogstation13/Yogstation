/area/proc/copy_contents_to(area/A , platingRequired = 0, nerf_weapons = 0 )
	//Takes: Area. Optional: If it should copy to areas that don't have plating
	//Returns: Nothing.
	//Notes: Attempts to move the contents of one area to another area.
	//       Movement based on lower left corner. Tiles that do not fit
	//		 into the new area will not be moved.

	if(!A || !src)
		return 0

	var/list/turfs_src = get_area_turfs(src.type)
	var/list/turfs_trg = get_area_turfs(A.type)

	var/src_min_x = 99999
	var/src_min_y = 99999
	var/list/refined_src = new/list()

	for (var/turf/T in turfs_src)
		src_min_x = min(src_min_x,T.x)
		src_min_y = min(src_min_y,T.y)
	for (var/turf/T in turfs_src)
		refined_src[T] = "[T.x - src_min_x].[T.y - src_min_y]"

	var/trg_min_x = 99999
	var/trg_min_y = 99999
	var/list/refined_trg = new/list()

	for (var/turf/T in turfs_trg)
		trg_min_x = min(trg_min_x,T.x)
		trg_min_y = min(trg_min_y,T.y)
	for (var/turf/T in turfs_trg)
		refined_trg["[T.x - trg_min_x].[T.y - trg_min_y]"] = T

	var/list/toupdate = new/list()

	var/copiedobjs = list()

	for (var/turf/T in refined_src)
		var/coordstring = refined_src[T]
		var/turf/B = refined_trg[coordstring]
		if(!istype(B))
			continue

		if(platingRequired)
			if(isspaceturf(B))
				continue

		var/old_dir1 = T.dir
		var/old_icon_state1 = T.icon_state
		var/old_icon1 = T.icon

		B = B.ChangeTurf(T.type)
		B.setDir(old_dir1)
		B.icon = old_icon1
		B.icon_state = old_icon_state1

		for(var/obj/O in T)
			var/obj/O2 = duplicate_object(O, spawning_location = B, nerf=nerf_weapons, holoitem=TRUE)
			if(!O2)
				continue
			copiedobjs += O2.get_all_contents()

		for(var/mob/M in T)
			if(iscameramob(M))
				continue // If we need to check for more mobs, I'll add a variable
			var/mob/SM = duplicate_object(M, spawning_location = B, holoitem=TRUE)
			copiedobjs += SM.get_all_contents()

		for(var/V in T.vars - GLOB.duplicate_forbidden_vars)
			if(V == "air" && SSair.initialized)
				var/turf/open/O1 = B
				var/turf/open/O2 = T
				O1.air.copy_from(O2.return_air())
				continue
			B.vars[V] = T.vars[V]
		toupdate += B

	if(toupdate.len)
		for(var/turf/T1 in toupdate)
			T1.immediate_calculate_adjacent_turfs()

	return copiedobjs
