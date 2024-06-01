GLOBAL_LIST_EMPTY(active_door_timers)
GLOBAL_LIST_EMPTY(brig_cell_areas)
GLOBAL_LIST_EMPTY(perma_prison_areas)

/obj/machinery/computer/department_reward/security
	name = "departmental research console (Security)"
	desc = "A primitive version of the famous R&D console used to unlock department-relevant research. This one is powered by incarcerated criminals."
	department_display = "Security"
	circuit = /obj/item/circuitboard/computer/department_reward/security

/obj/machinery/computer/department_reward/security/Initialize(mapload)
	nodes_available = GLOB.security_nodes
	. = ..()

/obj/machinery/computer/department_reward/security/check_reward(delta_time)
	. = 0

	// Criminals in brig cells with an active timer
	var/list/criminal_names = list()
	for(var/obj/machinery/door_timer/timer in GLOB.active_door_timers)
		if(!timer.desired_name)
			continue
		criminal_names += timer.desired_name

	for(var/area/security/brig_cell/cell_area in GLOB.brig_cell_areas)
		for(var/mob/living/carbon/human/guy in cell_area)
			if(!(guy.real_name in criminal_names))
				continue
			if(guy.stat != CONSCIOUS)
				continue
			if(!guy.mind || !(guy.mind.assigned_role in GLOB.crew_positions))
				continue
			criminals -= guy.real_name
			. += delta_time * 2.1 // 126 points per minute of captured criminal
		CHECK_TICK

	// Perma prisoners with no access
	for(var/area/security/prison/perma in GLOB.perma_prison_areas)
		var/list/permad_humans = perma.get_all_contents_type(/mob/living/carbon/human)
		for(var/mob/living/carbon/human/guy as anything in permad_humans)
			var/obj/item/idcard = guy.get_idcard()
			var/access = idcard?.GetAccess()
			if(access == null || length(access) == 0 && guy.stat == CONSCIOUS && (guy.mind?.assigned_role in GLOB.crew_positions))
				. += delta_time * 2.1 // 126 points per minute of captured criminal
			CHECK_TICK

