/datum/job/nanotrasen_representative
	title = JOB_NANOTRASEN_REPRESENTATIVE
	description = "Ensure company interests and Standard Operating Procedure is upheld onboard the station, and get out as soon as you can when it inevitably falls apart."
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD
	department_head = list("CentCom")
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "Central Command"
	req_admin_notify = 1
	minimal_player_age = 30
	exp_requirements = 3000
	exp_required_type = EXP_TYPE_CREW
	exp_required_type_department = EXP_TYPE_CENTRAL_COMMAND
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "NANOTRASEN_REPRESENTATIVE"

	allow_bureaucratic_error = FALSE
	allow_overflow = FALSE

	outfit = /datum/outfit/job/nanotrasen_representative
	plasmaman_outfit = /datum/outfit/plasmaman/centcom_official

	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_CMD

	liver_traits = list(TRAIT_PRETENDER_ROYAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_NANOTRASEN_REPRESENTATIVE
	bounty_types = CIV_JOB_BASIC
	departments_list = list(
		/datum/job_department/central_command,
		/datum/job_department/command,
		)

	family_heirlooms = list(/obj/item/pen/fountain, /obj/item/lighter, /obj/item/reagent_containers/cup/glass/flask)

	mail_goodies = list(
		/obj/item/pen/fountain = 30,
		/obj/item/food/moonfish_caviar = 25,
		/obj/item/clothing/mask/cigarette/cigar/havana = 20,
		/obj/item/storage/fancy/cigarettes/cigars/havana = 15,
		/obj/item/reagent_containers/cup/glass/bottle/champagne = 15,
		/obj/item/reagent_containers/cup/glass/bottle/champagne/cursed = 5,
	)
	exclusive_mail_goodies = TRUE
	rpg_title = "Diplomat"
	job_flags = STATION_JOB_FLAGS | JOB_BOLD_SELECT_TEXT | JOB_CANNOT_OPEN_SLOTS

	voice_of_god_power = 1.4 //Command staff has authority

	alt_titles = list(
		"Corporate Liaison",
		"Nanotrasen Fax Operater",
		"Nanotrasen Official",
		"Nanotrasen Informant",
	)
	job_tone = "incoming message"

/datum/outfit/job/nanotrasen_representative
	name = "Nanotrasen Representative"
	jobtype = /datum/job/nanotrasen_representative
	id = /obj/item/card/id/advanced/centcom
	id_trim = /datum/id_trim/job/nanotrasen_representative
	uniform = /obj/item/clothing/under/rank/centcom/nanotrasen_representative
	suit = /obj/item/clothing/suit/armor/vest/nanotrasen_representative
	head = /obj/item/clothing/head/hats/nanotrasen_representative
	backpack_contents = list(
		/obj/item/stamp/centcom = 1,
		/obj/item/melee/baton/telescopic = 1,
		/obj/item/folder/blue = 1,
	)
	belt = /obj/item/gun/energy/laser/plasmacore
	shoes = /obj/item/clothing/shoes/laceup
	l_pocket = /obj/item/pen/fountain
	r_pocket = /obj/item/modular_computer/pda/heads
	l_hand = /obj/item/storage/secure/briefcase/cash
	glasses = /obj/item/clothing/glasses/sunglasses
	ears = /obj/item/radio/headset/headset_cent
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/laceup

	chameleon_extras = list(
		/obj/item/gun/energy/laser/plasmacore,
		/obj/item/stamp/centcom,
		)

	implants = list(/obj/item/implant/mindshield)
	pda_slot = ITEM_SLOT_RPOCKET
	skillchips = list(
		/obj/item/skillchip/disk_verifier,
	)

/datum/id_trim/job/nanotrasen_representative
	assignment = "Nanotrasen Representative"
	trim_state = "trim_centcom"
	department_color = COLOR_CENTCOM_BLUE
	subdepartment_color = COLOR_CENTCOM_BLUE
	sechud_icon_state = SECHUD_CENTCOM
	minimal_access = list(
		ACCESS_BRIG_ENTRANCE,
		ACCESS_COMMAND,
		ACCESS_MAINT_TUNNELS,
		ACCESS_WEAPONS,
		ACCESS_CENT_GENERAL,
		ACCESS_CENT_LIVING,
		)
	extra_access = list(
		ACCESS_BAR,
		)
	template_access = list(
		)
	job = /datum/job/nanotrasen_representative

