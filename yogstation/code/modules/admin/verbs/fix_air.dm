/client/proc/fix_air(var/turf/open/T in world)
	set name = "Fix Air"
	set category = "Admin"
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

/client/proc/fillspace()
	set category = "Special Verbs"
	set name = "Fill Space with floor"
	if(!holder)
		src << "Only administrators may use this command."
		return
	if(check_rights(R_ADMIN,1))
		var/area/location = usr.loc.loc
		if(istype(location,/area/space))
			return
		if(location.name != "Space")
			for(var/turf/open/space/S in location)
				S.ChangeTurf(/turf/open/floor/plating)
			for(var/turf/open/O in location)
				O.ChangeTurf(/turf/open/floor/plating)