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

/client/proc/fix_air_z(var/turf/open/T in world)
	set name = "Fix Air, Z-level"
	set category = "Misc.Unused"
	set desc = "Fixes air on the entire z-level, warning, laggy and temporarily disables atmos"

	if(!holder)
		to_chat(src, "Only administrators may use this command.", confidential=TRUE)
		return
	if(!check_rights(R_ADMIN,1))
		return
	message_admins("[key_name_admin(usr)] fixed air on zlevel [T.z]")
	log_game("[key_name_admin(usr)] fixed airon zlevel [T.z]")

	var/atmos_enabled = SSair.can_fire
	if(atmos_enabled)
		message_admins("Disabling atmospherics to fix air on zlevel")
		SSair.can_fire = FALSE

	for(var/x = 1; x <= world.maxx; x++)
		for(var/y = 1; y <= world.maxy; y++)
			var/turf/open/F = locate(x, y, T.z)
			if(F.blocks_air)
			//skip walls
				continue
			F.air.parse_gas_string(F.initial_gas_mix)
			F.update_visuals()
			CHECK_TICK 

	if(atmos_enabled)
		message_admins("Re-enabling atmospherics, air on zlevel fixed")
		SSair.can_fire = atmos_enabled
