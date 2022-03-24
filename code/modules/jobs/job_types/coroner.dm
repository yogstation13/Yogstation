/datum/job/coroner
	title = "Coroner"
	flag = CORONER
    department_head = list("Chief Medical Officer")
	department_flag = MEDSCI
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"
    exp_requirements = 120
    exp_type = EXP_TYPE_CREW
    alt_titles = list("Pathologist", "Medical Examiner", "Mortician")

	outfit = /datum/outfit/job/coroner

    access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_GENETICS, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS, ACCESS_CLONING)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MED

    display_order = JOB_DISPLAY_ORDER_CORONER

/datum/outfit/job/coroner
	name = "Coroner"
	jobtype = /datum/job/coroner

    ears = /obj/item/radio/headset/headset_med
	uniform = /obj/item/clothing/under/rank/medical/mortician
    shoes = /obj/item/clothing/shoes/white
	suit = /obj/item/clothing/suit/storage/labcoat/mortician
	l_hand = /obj/item/clipboard
    suit_store = /obj/item/flashlight/pen
    backpack_contents = list(
		/obj/item/clothing/head/surgery/black = 1,
		/obj/item/autopsy_scanner = 1,
		/obj/item/reagent_scanner = 1,
		/obj/item/storage/box/bodybags = 1
        )

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel_med
	dufflebag = /obj/item/storage/backpack/duffel/medical
