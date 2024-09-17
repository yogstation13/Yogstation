/datum/job/hos
	title = "Divisional Lead"
	description = "Command the civil protection team, ensure the safety of the administrator and labor lead, take over for the District Administrator if necessary."
	orbit_icon = "user-shield"
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD|DEADMIN_POSITION_SECURITY|DEADMIN_POSITION_CRITICAL
	department_head = list("District Administrator")
	head_announce = list(RADIO_CHANNEL_SECURITY)
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the district administrator, overwatch"
	req_admin_notify = 1
	minimal_player_age = 14
	exp_requirements = 0
	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_SECURITY

	outfit = /datum/outfit/job/hos
	mind_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	added_access = list(ACCESS_CAPTAIN, ACCESS_AI_MASTER)
	base_access = list(ACCESS_COMMAND, ACCESS_SECURITY, ACCESS_HOS, ACCESS_SEC_BASIC,
					ACCESS_BRIG, ACCESS_ARMORY, ACCESS_DETECTIVE, ACCESS_BRIG_PHYS,
					ACCESS_WEAPONS_PERMIT, ACCESS_LAWYER, ACCESS_MECH_SECURITY,
					ACCESS_MORGUE, ACCESS_MEDICAL, ACCESS_SURGERY, ACCESS_PARAMEDIC,
					ACCESS_ENGINEERING, ACCESS_ATMOSPHERICS, ACCESS_CONSTRUCTION, ACCESS_AUX_BASE,
					ACCESS_EXTERNAL_AIRLOCKS, ACCESS_SCIENCE, ACCESS_TOXINS, ACCESS_EXPERIMENTATION,
					ACCESS_XENOBIOLOGY, ACCESS_ROBOTICS, ACCESS_AI_SAT, ACCESS_CARGO,
					ACCESS_CARGO_BAY, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MAINT_TUNNELS,
					ACCESS_EVA, ACCESS_PERSONAL_LOCKERS, ACCESS_VAULT, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH)

	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_SEC

	display_order = JOB_DISPLAY_ORDER_HEAD_OF_SECURITY
	minimal_character_age = 28 //You need some experience on your belt and a little gruffiness; you're still a foot soldier, not quite a tactician commander back at base

	departments_list = list(
		/datum/job_department/security,
		/datum/job_department/command,
	)

	minimal_lightup_areas = list(
		/area/crew_quarters/heads/hos,
		/area/security/detectives_office,
		/area/security/warden
	)
	
	smells_like = "deadly authority"

/datum/job/hos/after_spawn(mob/living/carbon/human/H, mob/M)
	. = ..()
	H.faction += "combine"

/datum/outfit/job/hos
	name = "Divisional Lead"
	jobtype = /datum/job/hos

	id_type = /obj/item/card/id/silver

	ears = /obj/item/radio/headset/civilprotection/divisional
	uniform = /obj/item/clothing/under/combine/civilprotection/divisionallead
	gloves = /obj/item/clothing/gloves/color/black
	suit = /obj/item/clothing/suit/armor/civilprotection
	suit_store = /obj/item/gun/ballistic/revolver/coltpython
	shoes = /obj/item/clothing/shoes/jackboots
	glasses = /obj/item/clothing/glasses/hud/security/civilprotection

	mask = /obj/item/clothing/mask/gas/civilprotection
	belt = /obj/item/storage/belt/civilprotection/divisionleadfull

	implants = list(/obj/item/implant/mindshield, /obj/item/implant/biosig_ert)


/datum/outfit/job/hos/hardsuit
	name = "Divisional Lead (Hardsuit)"

	mask = /obj/item/clothing/mask/gas/sechailer
	suit = /obj/item/clothing/suit/space/hardsuit/security/hos
	suit_store = /obj/item/tank/internals/oxygen
	backpack_contents = list(/obj/item/melee/baton/loaded=1, /obj/item/gun/energy/e_gun=1)

