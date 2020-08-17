/obj/machinery/computer/holodeck/perma
	holodeck_type = /area/holodeck/perma
	var/disallowed_programs = list(/area/holodeck/rec_center/kobayashi, /area/holodeck/rec_center/firingrange, /area/holodeck/rec_center/medical)

/obj/machinery/computer/holodeck/perma/generate_program_list()
	..()
	for(var/typelist in program_cache)
		if (typelist["type"] in disallowed_programs)
			LAZYADD(emag_programs, list(typelist))
			LAZYREMOVE(program_cache, list(typelist))