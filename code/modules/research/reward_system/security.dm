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
	var/list/criminals = list()
	for(var/obj/machinery/door_timer/timer in SSmachines.processing)
		if(timer.timing && timer.desired_name)
			criminals += timer.desired_name
		CHECK_TICK
	for(var/area/security/brig_cell/cell in GLOB.areas)
		var/list/cell_humans = cell.get_all_contents_type(/mob/living/carbon/human)
		for(var/mob/living/carbon/human/guy as anything in cell_humans)
			if(guy.real_name in criminals && guy.stat == CONSCIOUS && (guy.mind?.assigned_role in GLOB.crew_positions))
				. += delta_time * 2.1 // 126 points per minute of captured criminal
		CHECK_TICK

	// Perma prisoners with no access
	for(var/area/security/prison/perma in GLOB.areas)
		var/list/permad_humans = perma.get_all_contents_type(/mob/living/carbon/human)
		for(var/mob/living/carbon/human/guy as anything in permad_humans)
			var/obj/item/idcard = guy.get_idcard()
			var/access = idcard?.GetAccess()
			if(access == null || length(access) == 0 && guy.stat == CONSCIOUS && (guy.mind?.assigned_role in GLOB.crew_positions))
				. += delta_time * 2.1 // 126 points per minute of captured criminal
			CHECK_TICK
