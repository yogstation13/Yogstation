/datum/job/geneticist
	title = "Geneticist"
	description = "Alter genomes, turn monkeys into humans (and vice-versa), and make DNA backups."
	orbit_icon = "dna"
	department_head = list("Chief Medical Officer", "Research Director")
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the chief medical officer and research director"
	exp_type = EXP_TYPE_CREW
	exp_requirements = 60
	alt_titles = list("DNA Mechanic", "Bioengineer", "Junior Geneticist", "Gene Splicer", "Mutation Specialist")

	outfit = /datum/outfit/job/geneticist

	added_access = list(ACCESS_CHEMISTRY, ACCESS_RESEARCH)
	base_access = list(ACCESS_MEDICAL, ACCESS_SCIENCE, ACCESS_GENETICS, ACCESS_CLONING, ACCESS_MORGUE, ACCESS_MECH_MEDICAL)

	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MED

	display_order = JOB_DISPLAY_ORDER_GENETICIST
	minimal_character_age = 24 //Genetics would likely require more education than your average position due to the sheer number of alien physiologies and experimental nature of the field

	base_skills = list(
		SKILL_PHYSIOLOGY = EXP_LOW,
		SKILL_MECHANICAL = EXP_NONE,
		SKILL_TECHNICAL = EXP_NONE,
		SKILL_SCIENCE = EXP_HIGH,
		SKILL_FITNESS = EXP_NONE,
	)
	skill_points = 2

	departments_list = list(
		/datum/job_department/medical,
	)

	mail_goodies = list(
		/obj/item/storage/box/monkeycubes = 10,
		/obj/item/reagent_containers/pill/mutadone = 10,
		/obj/item/reagent_containers/glass/bottle/mutagen = 5,
		/obj/item/dnainjector/elvismut = 1
	)
	
	lightup_areas = list(
		/area/medical/surgery,
		/area/medical/virology,
		/area/medical/chemistry
	)
	minimal_lightup_areas = list(/area/medical/morgue, /area/medical/genetics)

	smells_like = "monkey hair"

/datum/outfit/job/geneticist
	name = "Geneticist"
	jobtype = /datum/job/geneticist

	pda_type = /obj/item/modular_computer/tablet/pda/preset/geneticist

	ears = /obj/item/radio/headset/headset_medsci
	uniform = /obj/item/clothing/under/rank/rnd/geneticist
	uniform_skirt = /obj/item/clothing/under/rank/rnd/geneticist/skirt
	shoes = /obj/item/clothing/shoes/sneakers/white
	suit =  /obj/item/clothing/suit/toggle/labcoat/genetics
	suit_store =  /obj/item/flashlight/pen
	l_pocket = /obj/item/sequence_scanner

	backpack = /obj/item/storage/backpack/genetics
	satchel = /obj/item/storage/backpack/satchel/gen
	duffelbag = /obj/item/storage/backpack/duffelbag/med

