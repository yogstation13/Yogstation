/obj/machinery/computer/department_reward/security
	name = "departmental research console (Security)"
	department_display = "Security"

/obj/machinery/computer/department_reward/security/Initialize(mapload)
	nodes_available = GLOB.security_nodes
	. = ..()
