/datum/job/janitor
	title = "Vortigaunt Slave"
	description = "Obey the combine, clean up messes."
	orbit_icon = "broom"
	department_head = list("Labor Lead")
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "everybody"

	outfit = /datum/outfit/job/vortigaunt_slave


	paycheck = PAYCHECK_ZERO
	paycheck_department = ACCOUNT_SRV

	display_order = JOB_DISPLAY_ORDER_JANITOR

	departments_list = list(
		/datum/job_department/service,
	)

	smells_like = "bleach"

/datum/outfit/job/vortigaunt_slave
	name = "Vortigaunt Slave"
	jobtype = /datum/job/janitor

	neck = /obj/item/clothing/neck/anti_magic_collar
	ears = /obj/item/radio/headset //so they can hear orders given to them
	id_type = null
	uniform = null
	shoes = null

/datum/job/janitor/after_spawn(mob/living/carbon/human/H, mob/M)
	. = ..()
	H.set_species(/datum/species/vortigaunt)
