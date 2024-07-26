/obj/effect/mapping_helpers/airlock/access
	layer = DOOR_HELPER_LAYER
	icon_state = "access_helper"

// These are mutually exclusive; can't have req_any and req_all
/obj/effect/mapping_helpers/airlock/access/any/payload(obj/machinery/door/airlock/airlock)
	if(airlock.req_access != null)
		log_mapping("[src] at [AREACOORD(src)] tried to set req_one_access, but req_access was already set!")
	else
		var/list/access_list = get_access()
		airlock.req_one_access += access_list

/obj/effect/mapping_helpers/airlock/access/all/payload(obj/machinery/door/airlock/airlock)
	if(airlock.req_one_access != null)
		log_mapping("[src] at [AREACOORD(src)] tried to set req_one_access, but req_access was already set!")
	else
		var/list/access_list = get_access()
		airlock.req_access += access_list


//// HELPERS START - PLEASE KEEP THESE IN THE SAME ORDER AS IN ACCESS.DM THANKS
/// REQ ANY ///
// Applies onto req_one_access_txt (only requires ONE of the given accesses to open)

//---  COMMAND  ---//

/obj/effect/mapping_helpers/airlock/access/any/command
	icon_state = "access_helper_com"

/obj/effect/mapping_helpers/airlock/access/any/command/general/Initialize()
	. = ..()
	access_list += ACCESS_COMMAND

/obj/effect/mapping_helpers/airlock/access/any/command/ai_upload/Initialize()
	. = ..()
	access_list += ACCESS_AI_UPLOAD

/obj/effect/mapping_helpers/airlock/access/any/command/ai_sat/Initialize()
	. = ..()
	access_list += ACCESS_AI_SAT

/obj/effect/mapping_helpers/airlock/access/any/command/teleporter/Initialize()
	. = ..()
	access_list += ACCESS_TELEPORTER

/obj/effect/mapping_helpers/airlock/access/any/command/eva/Initialize()
	. = ..()
	access_list += ACCESS_EVA

/obj/effect/mapping_helpers/airlock/access/any/command/vault/Initialize()
	. = ..()
	access_list += ACCESS_VAULT

/obj/effect/mapping_helpers/airlock/access/any/command/hop/Initialize()
	. = ..()
	access_list += ACCESS_HOP

/obj/effect/mapping_helpers/airlock/access/any/command/captain/Initialize()
	. = ..()
	access_list += ACCESS_CAPTAIN


//---  SECURITY  ---//

/obj/effect/mapping_helpers/airlock/access/any/security
	icon_state = "access_helper_sec"

/obj/effect/mapping_helpers/airlock/access/any/security/general/Initialize()
	. = ..()
	access_list += ACCESS_SECURITY

/obj/effect/mapping_helpers/airlock/access/any/security/entrance/Initialize()
	. = ..()
	access_list += ACCESS_SEC_BASIC

/obj/effect/mapping_helpers/airlock/access/any/security/brig/Initialize()
	. = ..()
	access_list += ACCESS_BRIG

/obj/effect/mapping_helpers/airlock/access/any/security/armory/Initialize()
	. = ..()
	access_list += ACCESS_ARMORY

/obj/effect/mapping_helpers/airlock/access/any/security/court/Initialize()
	. = ..()
	access_list += ACCESS_DETECTIVE

/obj/effect/mapping_helpers/airlock/access/any/security/court/Initialize()
	. = ..()
	access_list += ACCESS_BRIG_PHYS

/obj/effect/mapping_helpers/airlock/access/any/security/hos/Initialize()
	. = ..()
	access_list += ACCESS_HOS


//---  ENGINEERING  ---//

/obj/effect/mapping_helpers/airlock/access/any/engineering
	icon_state = "access_helper_eng"

/obj/effect/mapping_helpers/airlock/access/any/engineering/general/Initialize()
	. = ..()
	access_list += ACCESS_ENGINEERING

/obj/effect/mapping_helpers/airlock/access/any/engineering/atmos/Initialize()
	. = ..()
	access_list += ACCESS_ATMOSPHERICS

/obj/effect/mapping_helpers/airlock/access/any/engineering/maintenance/Initialize()
	. = ..()
	access_list += ACCESS_MAINT_TUNNELS

/obj/effect/mapping_helpers/airlock/access/any/engineering/external/Initialize()
	. = ..()
	access_list += ACCESS_EXTERNAL_AIRLOCKS

/obj/effect/mapping_helpers/airlock/access/any/engineering/equipment/Initialize()
	. = ..()
	access_list += ACCESS_ENGINE_EQUIP

/obj/effect/mapping_helpers/airlock/access/any/engineering/construction/Initialize()
	. = ..()
	access_list += ACCESS_CONSTRUCTION

/obj/effect/mapping_helpers/airlock/access/any/engineering/tech_storage/Initialize()
	. = ..()
	access_list += ACCESS_TECH_STORAGE

/obj/effect/mapping_helpers/airlock/access/any/engineering/secure_tech/Initialize()
	. = ..()
	access_list += ACCESS_SECURE_TECH

/obj/effect/mapping_helpers/airlock/access/any/engineering/tcomms/Initialize()
	. = ..()
	access_list += ACCESS_TCOMMS

/obj/effect/mapping_helpers/airlock/access/any/engineering/aux_base/Initialize()
	. = ..()
	access_list += ACCESS_AUX_BASE

/obj/effect/mapping_helpers/airlock/access/any/engineering/ce/Initialize()
	. = ..()
	access_list += ACCESS_CE


//---  MEDICAL  ---//

/obj/effect/mapping_helpers/airlock/access/any/medical
	icon_state = "access_helper_med"

/obj/effect/mapping_helpers/airlock/access/any/medical/general/Initialize()
	. = ..()
	access_list += ACCESS_MEDICAL

/obj/effect/mapping_helpers/airlock/access/any/medical/surgery/Initialize()
	. = ..()
	access_list += ACCESS_SURGERY

/obj/effect/mapping_helpers/airlock/access/any/medical/paramedic/Initialize()
	. = ..()
	access_list += ACCESS_PARAMEDIC

/obj/effect/mapping_helpers/airlock/access/any/medical/morgue/Initialize()
	. = ..()
	access_list += ACCESS_MORGUE

/obj/effect/mapping_helpers/airlock/access/any/medical/chemistry/Initialize()
	. = ..()
	access_list += ACCESS_CHEMISTRY

/obj/effect/mapping_helpers/airlock/access/any/medical/cloning/Initialize()
	. = ..()
	access_list += ACCESS_CLONING

/obj/effect/mapping_helpers/airlock/access/any/medical/virology/Initialize()
	. = ..()
	access_list += ACCESS_VIROLOGY

/obj/effect/mapping_helpers/airlock/access/any/medical/psychology/Initialize()
	. = ..()
	access_list += ACCESS_PSYCHOLOGY

/obj/effect/mapping_helpers/airlock/access/any/medical/cmo/Initialize()
	. = ..()
	access_list += ACCESS_CMO


//---  SUPPLY  ---//

/obj/effect/mapping_helpers/airlock/access/any/supply
	icon_state = "access_helper_sup"

/obj/effect/mapping_helpers/airlock/access/any/supply/general/Initialize()
	. = ..()
	access_list += ACCESS_CARGO

/obj/effect/mapping_helpers/airlock/access/any/supply/cargo_bay/Initialize()
	. = ..()
	access_list += ACCESS_CARGO_BAY

/obj/effect/mapping_helpers/airlock/access/any/supply/mining/Initialize()
	. = ..()
	access_list += ACCESS_MINING

/obj/effect/mapping_helpers/airlock/access/any/supply/mining_station/Initialize()
	. = ..()
	access_list += ACCESS_MINING_STATION

/obj/effect/mapping_helpers/airlock/access/any/supply/materials/Initialize()
	. = ..()
	access_list += ACCESS_MATERIALS

/obj/effect/mapping_helpers/airlock/access/any/supply/qm/Initialize()
	. = ..()
	access_list += ACCESS_QM


//---  SCIENCE  ---//

/obj/effect/mapping_helpers/airlock/access/any/science
	icon_state = "access_helper_sci"

/obj/effect/mapping_helpers/airlock/access/any/science/general/Initialize()
	. = ..()
	access_list += ACCESS_SCIENCE

/obj/effect/mapping_helpers/airlock/access/any/science/research/Initialize()
	. = ..()
	access_list += ACCESS_RESEARCH

/obj/effect/mapping_helpers/airlock/access/any/science/toxins/Initialize()
	. = ..()
	access_list += ACCESS_TOXINS

/obj/effect/mapping_helpers/airlock/access/any/science/toxins_storage/Initialize()
	. = ..()
	access_list += ACCESS_TOXINS_STORAGE

/obj/effect/mapping_helpers/airlock/access/any/science/experimentation/Initialize()
	. = ..()
	access_list += ACCESS_EXPERIMENTATION

/obj/effect/mapping_helpers/airlock/access/any/science/genetics/Initialize()
	. = ..()
	access_list += ACCESS_GENETICS

/obj/effect/mapping_helpers/airlock/access/any/science/robotics/Initialize()
	. = ..()
	access_list += ACCESS_ROBOTICS

/obj/effect/mapping_helpers/airlock/access/any/science/xenobio/Initialize()
	. = ..()
	access_list += ACCESS_XENOBIOLOGY

/obj/effect/mapping_helpers/airlock/access/any/science/rnd_servers/Initialize()
	. = ..()
	access_list += ACCESS_RND_SERVERS

/obj/effect/mapping_helpers/airlock/access/any/science/rd/Initialize()
	. = ..()
	access_list += ACCESS_RD


//---  SERVICE  ---//
/obj/effect/mapping_helpers/airlock/access/any/service
	icon_state = "access_helper_serv"

/obj/effect/mapping_helpers/airlock/access/any/service/general/Initialize()
	. = ..()
	access_list += ACCESS_SERVICE

/obj/effect/mapping_helpers/airlock/access/any/service/theatre/Initialize()
	. = ..()
	access_list += ACCESS_THEATRE

/obj/effect/mapping_helpers/airlock/access/any/service/chapel_office/Initialize()
	. = ..()
	access_list += ACCESS_CHAPEL_OFFICE

/obj/effect/mapping_helpers/airlock/access/any/service/crematorium/Initialize()
	. = ..()
	access_list += ACCESS_CREMATORIUM

/obj/effect/mapping_helpers/airlock/access/any/service/library/Initialize()
	. = ..()
	access_list += ACCESS_LIBRARY

/obj/effect/mapping_helpers/airlock/access/any/service/bar/Initialize()
	. = ..()
	access_list += ACCESS_BAR

/obj/effect/mapping_helpers/airlock/access/any/service/kitchen/Initialize()
	. = ..()
	access_list += ACCESS_KITCHEN

/obj/effect/mapping_helpers/airlock/access/any/service/hydroponics/Initialize()
	. = ..()
	access_list += ACCESS_HYDROPONICS

/obj/effect/mapping_helpers/airlock/access/any/service/janitor/Initialize()
	. = ..()
	access_list += ACCESS_JANITOR

/obj/effect/mapping_helpers/airlock/access/any/service/lawyer/Initialize()
	. = ..()
	access_list += ACCESS_LAWYER



/// REQ ALL ///
// Applies onto req_access_txt (requires ALL of the given accesses to open)

//---  COMMAND  ---//

/obj/effect/mapping_helpers/airlock/access/all/command
	icon_state = "access_helper_com"

/obj/effect/mapping_helpers/airlock/access/all/command/general/Initialize()
	. = ..()
	access_list += ACCESS_COMMAND

/obj/effect/mapping_helpers/airlock/access/all/command/ai_upload/Initialize()
	. = ..()
	access_list += ACCESS_AI_UPLOAD

/obj/effect/mapping_helpers/airlock/access/all/command/ai_sat/Initialize()
	. = ..()
	access_list += ACCESS_AI_SAT

/obj/effect/mapping_helpers/airlock/access/all/command/teleporter/Initialize()
	. = ..()
	access_list += ACCESS_TELEPORTER

/obj/effect/mapping_helpers/airlock/access/all/command/eva/Initialize()
	. = ..()
	access_list += ACCESS_EVA

/obj/effect/mapping_helpers/airlock/access/all/command/vault/Initialize()
	. = ..()
	access_list += ACCESS_VAULT

/obj/effect/mapping_helpers/airlock/access/all/command/hop/Initialize()
	. = ..()
	access_list += ACCESS_HOP

/obj/effect/mapping_helpers/airlock/access/all/command/captain/Initialize()
	. = ..()
	access_list += ACCESS_CAPTAIN


//---  SECURITY  ---//

/obj/effect/mapping_helpers/airlock/access/all/security
	icon_state = "access_helper_sec"

/obj/effect/mapping_helpers/airlock/access/all/security/general/Initialize()
	. = ..()
	access_list += ACCESS_SECURITY

/obj/effect/mapping_helpers/airlock/access/all/security/entrance/Initialize()
	. = ..()
	access_list += ACCESS_SEC_BASIC

/obj/effect/mapping_helpers/airlock/access/all/security/brig/Initialize()
	. = ..()
	access_list += ACCESS_BRIG

/obj/effect/mapping_helpers/airlock/access/all/security/armory/Initialize()
	. = ..()
	access_list += ACCESS_ARMORY

/obj/effect/mapping_helpers/airlock/access/all/security/court/Initialize()
	. = ..()
	access_list += ACCESS_DETECTIVE

/obj/effect/mapping_helpers/airlock/access/all/security/court/Initialize()
	. = ..()
	access_list += ACCESS_BRIG_PHYS

/obj/effect/mapping_helpers/airlock/access/all/security/hos/Initialize()
	. = ..()
	access_list += ACCESS_HOS


//---  ENGINEERING  ---//

/obj/effect/mapping_helpers/airlock/access/all/engineering
	icon_state = "access_helper_eng"

/obj/effect/mapping_helpers/airlock/access/all/engineering/general/Initialize()
	. = ..()
	access_list += ACCESS_ENGINEERING

/obj/effect/mapping_helpers/airlock/access/all/engineering/atmos/Initialize()
	. = ..()
	access_list += ACCESS_ATMOSPHERICS

/obj/effect/mapping_helpers/airlock/access/all/engineering/maintenance/Initialize()
	. = ..()
	access_list += ACCESS_MAINT_TUNNELS

/obj/effect/mapping_helpers/airlock/access/all/engineering/external/Initialize()
	. = ..()
	access_list += ACCESS_EXTERNAL_AIRLOCKS

/obj/effect/mapping_helpers/airlock/access/all/engineering/equipment/Initialize()
	. = ..()
	access_list += ACCESS_ENGINE_EQUIP

/obj/effect/mapping_helpers/airlock/access/all/engineering/construction/Initialize()
	. = ..()
	access_list += ACCESS_CONSTRUCTION

/obj/effect/mapping_helpers/airlock/access/all/engineering/tech_storage/Initialize()
	. = ..()
	access_list += ACCESS_TECH_STORAGE

/obj/effect/mapping_helpers/airlock/access/all/engineering/secure_tech/Initialize()
	. = ..()
	access_list += ACCESS_SECURE_TECH

/obj/effect/mapping_helpers/airlock/access/all/engineering/tcomms/Initialize()
	. = ..()
	access_list += ACCESS_TCOMMS

/obj/effect/mapping_helpers/airlock/access/all/engineering/aux_base/Initialize()
	. = ..()
	access_list += ACCESS_AUX_BASE

/obj/effect/mapping_helpers/airlock/access/all/engineering/ce/Initialize()
	. = ..()
	access_list += ACCESS_CE


//---  MEDICAL  ---//

/obj/effect/mapping_helpers/airlock/access/all/medical
	icon_state = "access_helper_med"

/obj/effect/mapping_helpers/airlock/access/all/medical/general/Initialize()
	. = ..()
	access_list += ACCESS_MEDICAL

/obj/effect/mapping_helpers/airlock/access/all/medical/surgery/Initialize()
	. = ..()
	access_list += ACCESS_SURGERY

/obj/effect/mapping_helpers/airlock/access/all/medical/paramedic/Initialize()
	. = ..()
	access_list += ACCESS_PARAMEDIC

/obj/effect/mapping_helpers/airlock/access/all/medical/morgue/Initialize()
	. = ..()
	access_list += ACCESS_MORGUE

/obj/effect/mapping_helpers/airlock/access/all/medical/chemistry/Initialize()
	. = ..()
	access_list += ACCESS_CHEMISTRY

/obj/effect/mapping_helpers/airlock/access/all/medical/cloning/Initialize()
	. = ..()
	access_list += ACCESS_CLONING

/obj/effect/mapping_helpers/airlock/access/all/medical/virology/Initialize()
	. = ..()
	access_list += ACCESS_VIROLOGY

/obj/effect/mapping_helpers/airlock/access/all/medical/psychology/Initialize()
	. = ..()
	access_list += ACCESS_PSYCHOLOGY

/obj/effect/mapping_helpers/airlock/access/all/medical/cmo/Initialize()
	. = ..()
	access_list += ACCESS_CMO


//---  SUPPLY  ---//

/obj/effect/mapping_helpers/airlock/access/all/supply
	icon_state = "access_helper_sup"

/obj/effect/mapping_helpers/airlock/access/all/supply/general/Initialize()
	. = ..()
	access_list += ACCESS_CARGO

/obj/effect/mapping_helpers/airlock/access/all/supply/cargo_bay/Initialize()
	. = ..()
	access_list += ACCESS_CARGO_BAY

/obj/effect/mapping_helpers/airlock/access/all/supply/mining/Initialize()
	. = ..()
	access_list += ACCESS_MINING

/obj/effect/mapping_helpers/airlock/access/all/supply/mining_station/Initialize()
	. = ..()
	access_list += ACCESS_MINING_STATION

/obj/effect/mapping_helpers/airlock/access/all/supply/materials/Initialize()
	. = ..()
	access_list += ACCESS_MATERIALS

/obj/effect/mapping_helpers/airlock/access/all/supply/qm/Initialize()
	. = ..()
	access_list += ACCESS_QM


//---  SCIENCE  ---//

/obj/effect/mapping_helpers/airlock/access/all/science
	icon_state = "access_helper_sci"

/obj/effect/mapping_helpers/airlock/access/all/science/general/Initialize()
	. = ..()
	access_list += ACCESS_SCIENCE

/obj/effect/mapping_helpers/airlock/access/all/science/research/Initialize()
	. = ..()
	access_list += ACCESS_RESEARCH

/obj/effect/mapping_helpers/airlock/access/all/science/toxins/Initialize()
	. = ..()
	access_list += ACCESS_TOXINS

/obj/effect/mapping_helpers/airlock/access/all/science/toxins_storage/Initialize()
	. = ..()
	access_list += ACCESS_TOXINS_STORAGE

/obj/effect/mapping_helpers/airlock/access/all/science/experimentation/Initialize()
	. = ..()
	access_list += ACCESS_EXPERIMENTATION

/obj/effect/mapping_helpers/airlock/access/all/science/genetics/Initialize()
	. = ..()
	access_list += ACCESS_GENETICS

/obj/effect/mapping_helpers/airlock/access/all/science/robotics/Initialize()
	. = ..()
	access_list += ACCESS_ROBOTICS

/obj/effect/mapping_helpers/airlock/access/all/science/xenobio/Initialize()
	. = ..()
	access_list += ACCESS_XENOBIOLOGY

/obj/effect/mapping_helpers/airlock/access/all/science/rnd_servers/Initialize()
	. = ..()
	access_list += ACCESS_RND_SERVERS

/obj/effect/mapping_helpers/airlock/access/all/science/rd/Initialize()
	. = ..()
	access_list += ACCESS_RD


//---  SERVICE  ---//
/obj/effect/mapping_helpers/airlock/access/all/service
	icon_state = "access_helper_serv"

/obj/effect/mapping_helpers/airlock/access/all/service/general/Initialize()
	. = ..()
	access_list += ACCESS_SERVICE

/obj/effect/mapping_helpers/airlock/access/all/service/theatre/Initialize()
	. = ..()
	access_list += ACCESS_THEATRE

/obj/effect/mapping_helpers/airlock/access/all/service/chapel_office/Initialize()
	. = ..()
	access_list += ACCESS_CHAPEL_OFFICE

/obj/effect/mapping_helpers/airlock/access/all/service/crematorium/Initialize()
	. = ..()
	access_list += ACCESS_CREMATORIUM

/obj/effect/mapping_helpers/airlock/access/all/service/library/Initialize()
	. = ..()
	access_list += ACCESS_LIBRARY

/obj/effect/mapping_helpers/airlock/access/all/service/bar/Initialize()
	. = ..()
	access_list += ACCESS_BAR

/obj/effect/mapping_helpers/airlock/access/all/service/kitchen/Initialize()
	. = ..()
	access_list += ACCESS_KITCHEN

/obj/effect/mapping_helpers/airlock/access/all/service/hydroponics/Initialize()
	. = ..()
	access_list += ACCESS_HYDROPONICS

/obj/effect/mapping_helpers/airlock/access/all/service/janitor/Initialize()
	. = ..()
	access_list += ACCESS_JANITOR

/obj/effect/mapping_helpers/airlock/access/all/service/lawyer/Initialize()
	. = ..()
	access_list += ACCESS_LAWYER
