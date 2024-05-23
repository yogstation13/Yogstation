/obj/machinery/computer/department_reward/security
	name = "departmental research console (Security)"
	department_display = "Security"

/obj/machinery/computer/department_reward/security/Initialize(mapload)
	nodes_available = GLOB.security_nodes
	. = ..()

/obj/machinery/computer/department_reward/security/check_reward(delta_time)
	. = 0

	// Criminals in brig cells with an active timer
	var/list/criminals = list()
	for(var/obj/machinery/door_timer/timer in SSmachines.processing)
		if(timer.timing && timer.desired_name)
			timer.desired_name += criminals
		CHECK_TICK
	for(var/area/security/brig_cell/cell in GLOB.the_station_areas)
		var/list/cell_humans = cell.get_all_contents_type(/mob/living/carbon/human)
		for(var/mob/living/carbon/human/guy as anything in cell_humans)
			if(guy.real_name in criminals)
				. += delta_time * 10 // 600 points per minute of captured criminal
		CHECK_TICK

	// Perma prisoners with no access
	for(var/area/security/prison/perma in GLOB.the_station_areas)
		var/list/permad_humans = perma.get_all_contents_type(/mob/living/carbon/human)
		for(var/mob/living/carbon/human/guy as anything in permad_humans)
			var/obj/item/idcard = guy.get_idcard()
			var/access = idcard?.GetAccess()
			if(access == null || length(access) == 0)
				. += delta_time * 10 // 600 points per minute of captured criminal
			CHECK_TICK
