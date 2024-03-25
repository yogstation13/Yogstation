/datum/job/chemist
	title = "Chemist"
	description = "Supply the doctors with chemicals, make medicine, as well as \
		less likable substances in the comfort of a fully reinforced room."
	orbit_icon = "prescription-bottle"
	department_head = list("Chief Medical Officer")
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the chief medical officer"
	exp_type = EXP_TYPE_CREW
	exp_requirements = 120
	exp_type_department = EXP_TYPE_MEDICAL

	alt_titles = list("Pharmacist", "Chemical Analyst", "Chemistry Lab Technician", "Chemical Specialist", "Druggist") // Yes Druggist is a real thing.

	outfit = /datum/outfit/job/chemist

	added_access = list(ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_GENETICS, ACCESS_CLONING)
	base_access = list(ACCESS_MEDICAL, ACCESS_CHEMISTRY, ACCESS_MECH_MEDICAL, ACCESS_MINERAL_STOREROOM)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MED

	display_order = JOB_DISPLAY_ORDER_CHEMIST
	minimal_character_age = 24 //A lot of experimental drugs plus understanding the facilitation and purpose of several subtances; what treats what and how to safely manufacture it

	departments_list = list(
		/datum/job_department/medical,
	)

	mail_goodies = list(
		/obj/item/reagent_containers/glass/bottle/flash_powder = 15,
		/obj/item/reagent_containers/glass/beaker/meta = 15,
		/obj/item/reagent_containers/glass/beaker/large/lemoline = 10,
		/obj/item/storage/pill_bottle/gummies/floorbear = 1,
		/obj/item/paper/secretrecipe = 1
	)

	lightup_areas = list(
		/area/medical/surgery,
		/area/medical/virology,
		/area/medical/genetics
	)
	minimal_lightup_areas = list(
		/area/medical/morgue,
		/area/medical/chemistry
	)

	smells_like = "chemicals"

/datum/outfit/job/chemist
	name = "Chemist"
	jobtype = /datum/job/chemist

	pda_type = /obj/item/modular_computer/tablet/pda/preset/medical/chem

	glasses = /obj/item/clothing/glasses/science
	ears = /obj/item/radio/headset/headset_med
	uniform = /obj/item/clothing/under/rank/chemist
	uniform_skirt = /obj/item/clothing/under/rank/chemist/skirt
	shoes = /obj/item/clothing/shoes/sneakers/white
	suit =  /obj/item/clothing/suit/toggle/labcoat/chemist
	backpack = /obj/item/storage/backpack/chemistry
	satchel = /obj/item/storage/backpack/satchel/chem
	duffelbag = /obj/item/storage/backpack/duffelbag/med

	chameleon_extras = /obj/item/gun/syringe

