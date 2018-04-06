/client/proc/fix_air(var/turf/open/T in world)
	set name = "Fix Air"
	set category = "Admin"
	set desc = "Fixes air in specified radius."

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
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
			if(istype(F, /turf/open/floor/plasteel/airless) || istype(F, /turf/open/floor/engine/vacuum) || istype(F, /turf/open/floor/plating/airless) || istype(F, /turf/open/floor/engine/n2o) || istype(F, /turf/open/floor/mech_bay_recharge_floor/airless) || istype(F, /turf/open/floor/engine/airless))
			//skip some special turf types
				continue
			if(istype(F.loc, /area/science/server) || istype(F.loc, /area/tcommsat/server))
			//skip superchilled rooms
				continue
			if(istype(F, /turf/open/floor/engine) && istype(F.loc, /area/engine/atmos))
			//skip atmos tanks
				continue
			GM.parse_gas_string(F.initial_gas_mix)
			F.copy_air(GM)
			F.update_visuals()
