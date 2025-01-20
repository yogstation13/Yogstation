/datum/job/barber
	title = JOB_LATEJOIN_BARBER
	description = "Cut hair, spread gossip, judge folks poor fashion taste."
	department_head = list(JOB_HEAD_OF_PERSONNEL)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = SUPERVISOR_HOP
	config_tag = "BARBER"
	exp_granted_type = EXP_TYPE_SERVICE

	outfit = /datum/outfit/job/barber
	plasmaman_outfit = /datum/outfit/plasmaman/bar

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SRV

	display_order = JOB_DISPLAY_ORDER_BARBER
	departments_list = list(
		/datum/job_department/late,
		)

	mail_goodies = list(
		/obj/item/reagent_containers/spray/barbers_aid = 100,
		/obj/item/clothing/head/hair_tie = 50,
		/obj/item/reagent_containers/spray/baldium = 10, //good way to get valid'd
		/obj/item/dyespray = 20,
		/obj/item/lipstick/quantum = 1,
		/obj/item/reagent_containers/spray/super_barbers_aid = 1,
	)

	family_heirlooms = list(/obj/item/hairbrush/comb)
	rpg_title = "Scissorhands"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

/datum/outfit/job/barber
	name = "Barber"
	jobtype = /datum/job/barber

	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/barber
	uniform = /obj/item/clothing/under/rank/civilian/lawyer/purpsuit
	suit = /obj/item/clothing/suit/toggle/lawyer/purple
	backpack_contents = list(
		/obj/item/razor = 1,
		/obj/item/reagent_containers/spray/quantum_hair_dye = 1,
		/obj/item/reagent_containers/cup/rag = 1,
		)
	belt = /obj/item/modular_computer/pda/barber
	ears = /obj/item/radio/headset/headset_srv
	shoes = /obj/item/clothing/shoes/laceup
	l_pocket =/obj/item/scissors

	box = /obj/item/storage/box/survival


