/client/proc/fix_air(var/turf/open/T in world)
	set name = "Fix Air"
	set category = "Misc.Unused"
	set desc = "Fixes air in specified radius."

	if(!holder)
		to_chat(src, "Only administrators may use this command.", confidential=TRUE)
		return
	if(check_rights(R_ADMIN,1))
		var/range=input("Enter range:","Num",2) as num
		message_admins("[key_name_admin(usr)] fixed air with range [range] in area [T.loc.name]")
		log_game("[key_name_admin(usr)] fixed air with range [range] in area [T.loc.name]")
		var/datum/gas_mixture/GM = new
		for(var/turf/open/F in range(range,T))
			if(F.blocks_air)
			//skip walls
				continue
			GM.parse_gas_string(F.initial_gas_mix)
			F.copy_air(GM)
			F.update_visuals()

/client/proc/fix_air_z()
	set name = "Fix Air on current Z-level"
	set category = "Misc.Unused"
	set desc = "Fixes air on the entire z-level, temporarily disables atmos"

	if(!holder)
		to_chat(src, "Only administrators may use this command.", confidential=TRUE)
		return
	if(!check_rights(R_ADMIN))
		return

	if(Master.current_runlevel < log(2, RUNLEVEL_GAME) + 1)
		to_chat(src, "This command may not be used before the game has started!", confidential=TRUE)
		message_admins("[src] has attempted to fix air before the game has started.")
		return

	if(alert("Do you want to reset air on the entire z level?", "Fix Air- Z level", "No", "Yes") != "Yes")
		return

	message_admins("[key_name_admin(usr)] fixed air on zlevel [mob.z]")
	log_game("[key_name_admin(usr)] fixed air on zlevel [mob.z]")

	var/z = mob.z
	for(var/x=1, x<=world.maxx, x++)
		for(var/y=1, y<=world.maxy, y++)
			//Not guarenteed to be an open turf, typecasted as an optimization, be careful how you use this variable
			var/turf/open/T = locate(x, y, z)
			//Not an early return to allow check_tick to do its thing
			//Verfied to be an open turf here
			if(!istype(T, /turf/open/space) && T.is_openturf && !T.blocks_air)
				T.air?.parse_gas_string(T.initial_gas_mix)
				T.update_visuals()
