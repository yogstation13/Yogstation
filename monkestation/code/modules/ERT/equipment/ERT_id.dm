// gonna just make the green and blue alert IDs. it's fine if they have all access on red and above i am guessing
// Ordering:
// ROLES
// *Generic
// *Commander
// *Medic
// *Security Officer
// *Engineer
// *Janitor
// *Chaplain
// *Clown
// OTHER

/datum/id_trim/centcom/ert/generic
	assignment = "Emergency Response Officer"

/datum/id_trim/centcom/ert/generic/New()
	. = ..()
	access = list(
		ACCESS_MAINT_TUNNELS,
		ACCESS_MEDICAL,
		ACCESS_BRIG_ENTRANCE,
		ACCESS_SECURITY,
		ACCESS_CENT_GENERAL,
		ACCESS_WEAPONS,
		ACCESS_CARGO,
		ACCESS_CONSTRUCTION,
		ACCESS_HYDROPONICS,
		ACCESS_MORGUE,
		ACCESS_SCIENCE,
		ACCESS_SERVICE,
		ACCESS_EXTERNAL_AIRLOCKS,
		ACCESS_RC_ANNOUNCE,
		ACCESS_AUX_BASE,
		ACCESS_BIT_DEN,
		ACCESS_MECH_MINING,
		ACCESS_MINING_STATION,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MINING,
		ACCESS_SHIPPING,
		)

/obj/item/card/id/advanced/centcom/ert/generic
	name = "\improper CentCom ID"
	desc = "An ERT ID card."
	registered_age = null
	registered_name = "Emergency Response Officer"
	trim = /datum/id_trim/centcom/ert/generic

/datum/id_trim/centcom/ert/generic/commander
	assignment = JOB_ERT_COMMANDER
	trim_state = "trim_ert_commander"
	sechud_icon_state = SECHUD_EMERGENCY_RESPONSE_TEAM_COMMANDER

/datum/id_trim/centcom/ert/generic/commander/New()
	..()
	access |= list(
		ACCESS_AI_UPLOAD,
		ACCESS_ALL_PERSONAL_LOCKERS,
		ACCESS_AUX_BASE,
		ACCESS_COMMAND,
		ACCESS_COURT,
		ACCESS_EVA,
		ACCESS_GATEWAY,
		ACCESS_KEYCARD_AUTH,
		ACCESS_TELEPORTER,
		ACCESS_BRIG,
		ACCESS_MECH_SECURITY,
		ACCESS_PERMABRIG,
		ACCESS_DETECTIVE,
		ACCESS_ARMORY,
		ACCESS_ENGINE_EQUIP,
	)

/obj/item/card/id/advanced/centcom/ert/generic/commander
	registered_name = JOB_ERT_COMMANDER
	trim = /datum/id_trim/centcom/ert/generic/commander

/datum/id_trim/centcom/ert/generic/medical
	assignment = JOB_ERT_MEDICAL_DOCTOR
	trim_state = "trim_medicaldoctor"
	subdepartment_color = COLOR_MEDICAL_BLUE
	sechud_icon_state = SECHUD_MEDICAL_RESPONSE_OFFICER

/datum/id_trim/centcom/ert/generic/medical/New()
	..()
	access |= list(
		ACCESS_PLUMBING,
		ACCESS_MECH_MEDICAL,
		ACCESS_PHARMACY,
		ACCESS_PSYCHOLOGY,
		ACCESS_SURGERY,
		ACCESS_VIROLOGY,
	)

/obj/item/card/id/advanced/centcom/ert/generic/medical
	registered_name = JOB_ERT_MEDICAL_DOCTOR
	trim = /datum/id_trim/centcom/ert/generic/medical

/datum/id_trim/centcom/ert/generic/security
	assignment = JOB_ERT_OFFICER
	trim_state = "trim_securityofficer"
	subdepartment_color = COLOR_SECURITY_RED
	sechud_icon_state = SECHUD_SECURITY_RESPONSE_OFFICER

/datum/id_trim/centcom/ert/generic/security/New()
	..()
	access |= list(
		ACCESS_BRIG,
		ACCESS_MECH_SECURITY,
		ACCESS_PERMABRIG,
		ACCESS_DETECTIVE,
	)

/obj/item/card/id/advanced/centcom/ert/generic/security
	registered_name = JOB_ERT_OFFICER
	trim = /datum/id_trim/centcom/ert/generic/security

/datum/id_trim/centcom/ert/generic/engineer
	assignment = JOB_ERT_ENGINEER
	trim_state = "trim_stationengineer"
	subdepartment_color = COLOR_ENGINEERING_ORANGE
	sechud_icon_state = SECHUD_ENGINEERING_RESPONSE_OFFICER

/datum/id_trim/centcom/ert/generic/engineer/New()
	..()
	access |= list(
		ACCESS_ATMOSPHERICS,
		ACCESS_ENGINEERING,
		ACCESS_ENGINE_EQUIP,
		ACCESS_MECH_ENGINE,
		ACCESS_MINISAT,
		ACCESS_TCOMMS,
		ACCESS_TCOMMS_ADMIN,
		ACCESS_TECH_STORAGE,
	)

/obj/item/card/id/advanced/centcom/ert/generic/engineer
	registered_name = JOB_ERT_ENGINEER
	trim = /datum/id_trim/centcom/ert/generic/engineer

/datum/id_trim/centcom/ert/generic/janitor
	assignment = JOB_ERT_JANITOR
	trim_state = "trim_janitor"
	subdepartment_color = COLOR_SERVICE_LIME
	sechud_icon_state = SECHUD_JANITORIAL_RESPONSE_OFFICER

/datum/id_trim/centcom/ert/generic/janitor/New()
	..()
	access |= list(
		ACCESS_JANITOR,
	)

/obj/item/card/id/advanced/centcom/ert/generic/janitor
	registered_name = JOB_ERT_JANITOR
	trim = /datum/id_trim/centcom/ert/generic/janitor

/datum/id_trim/centcom/ert/generic/chaplain
	assignment = JOB_ERT_CHAPLAIN
	trim_state = "trim_chaplain"
	subdepartment_color = "#58C800"
	sechud_icon_state = SECHUD_RELIGIOUS_RESPONSE_OFFICER

/datum/id_trim/centcom/ert/generic/chaplain/New()
	..()
	access |= list(
		ACCESS_CHAPEL_OFFICE,
		ACCESS_CREMATORIUM,
		ACCESS_THEATRE,
	)

/obj/item/card/id/advanced/centcom/ert/generic/chaplain
	registered_name = JOB_ERT_CHAPLAIN
	trim = /datum/id_trim/centcom/ert/generic/chaplain

/datum/id_trim/centcom/ert/generic/clown
	assignment = JOB_ERT_CLOWN
	trim_state = "trim_clown"
	subdepartment_color = COLOR_MAGENTA
	sechud_icon_state = SECHUD_ENTERTAINMENT_RESPONSE_OFFICER

/datum/id_trim/centcom/ert/generic/clown/New()
	..()
	access |= list(
		ACCESS_THEATRE,
	)

/obj/item/card/id/advanced/centcom/ert/generic/clown
	registered_name = JOB_ERT_CLOWN
	trim = /datum/id_trim/centcom/ert/generic/clown
