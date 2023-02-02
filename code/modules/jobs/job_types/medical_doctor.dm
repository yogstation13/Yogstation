/datum/job/doctor
	title = "Medical Doctor"
	description = "Save lives, run around the station looking for victims, \
		scan everyone in sight"
	flag = DOCTOR
	orbit_icon = "staff-snake"
	department_head = list("Chief Medical Officer")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 5
	spawn_positions = 3
	supervisors = "the chief medical officer"
	selection_color = "#d4ebf2"
	exp_requirements = 180
	exp_type = EXP_TYPE_CREW
	alt_titles = list("Physician", "Surgeon", "Nurse", "Medical Resident", "Attending Physician", "General Practitioner")

	outfit = /datum/outfit/job/doctor

	added_access = list(ACCESS_CHEMISTRY, ACCESS_GENETICS)
	base_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CLONING, ACCESS_MECH_MEDICAL, ACCESS_MINERAL_STOREROOM)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MED

	display_order = JOB_DISPLAY_ORDER_MEDICAL_DOCTOR
	minimal_character_age = 26 //Barely acceptable considering the theoretically absurd knowledge they have, but fine

	departments_list = list(
		/datum/job_department/medical,
	)

	changed_maps = list("EclipseStation", "OmegaStation")

	mail_goodies = list(
		/obj/item/healthanalyzer/advanced = 15,
		/obj/item/scalpel/advanced = 6,
		/obj/item/retractor/advanced = 6,
		/obj/item/cautery/advanced = 6,
		/obj/item/reagent_containers/autoinjector/medipen = 6,
		/obj/effect/spawner/lootdrop/organ_spawner = 5
		///obj/effect/spawner/random/medical/memeorgans = 1
	)

	smells_like = "a hospital"

/datum/job/doctor/proc/EclipseStationChanges()
	total_positions = 6
	spawn_positions = 5

/datum/job/doctor/proc/OmegaStationChanges()
	selection_color = "#ffffff"
	total_positions = 3
	spawn_positions = 3
	added_access = list()
	base_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS)
	supervisors = "the captain and the head of personnel"

/datum/outfit/job/doctor
	name = "Medical Doctor"
	jobtype = /datum/job/doctor
	ears = /obj/item/radio/headset/headset_med
	pda_type = /obj/item/modular_computer/tablet/pda/preset/medical
	uniform = /obj/item/clothing/under/rank/medical
	uniform_skirt = /obj/item/clothing/under/rank/medical/skirt
	shoes = /obj/item/clothing/shoes/sneakers/white
	suit =  /obj/item/clothing/suit/toggle/labcoat/md
	l_hand = /obj/item/storage/firstaid/medical
	suit_store = /obj/item/flashlight/pen
	gloves = /obj/item/clothing/gloves/color/latex/nitrile
	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med
	chameleon_extras = /obj/item/gun/syringe
/datum/outfit/job/doctor/dead
	name = "Medical Doctor"
	jobtype = /datum/job/doctor
	ears = /obj/item/radio/headset/headset_med
	uniform = /obj/item/clothing/under/rank/medical
	shoes = /obj/item/clothing/shoes/sneakers/white
	suit =  /obj/item/clothing/suit/toggle/labcoat/md
	l_hand = /obj/item/storage/firstaid/medical
	suit_store = /obj/item/flashlight/pen
	gloves = /obj/item/clothing/gloves/color/latex/nitrile
	pda_type = /obj/item/pda/medical
