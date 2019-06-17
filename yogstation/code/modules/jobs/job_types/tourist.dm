/datum/job/tourist
	title = "Tourist"
	flag = TOUR
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = -1
	spawn_positions = 0
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	access = list()
	minimal_access = list()

	outfit = /datum/outfit/job/tourist
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_CIV
	display_order = JOB_DISPLAY_ORDER_TOURIST

/datum/outfit/job/tourist
	name = "Tourist"
	jobtype = /datum/job/tourist

	uniform = /obj/item/clothing/under/yogs/tourist
	shoes = /obj/item/clothing/shoes/sneakers/black
	ears = /obj/item/radio/headset
	belt = /obj/item/pda
	backpack_contents = list(/obj/item/camera_film, /obj/item/stack/spacecash/c20, /obj/item/stack/spacecash/c20, /obj/item/stack/spacecash/c20)
	r_hand =  /obj/item/camera
	l_pocket = /obj/item/camera_film
	r_pocket = /obj/item/camera_film