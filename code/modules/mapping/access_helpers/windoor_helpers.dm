/obj/effect/mapping_helpers/windoor/access
	icon_state = "windoor_access"

// These are mutually exclusive; can't have req_any and req_all
/obj/effect/mapping_helpers/windoor/access/any/payload(obj/machinery/door/window/windoor)
	if(windoor.req_access != null)
		log_mapping("[src] access helper at [AREACOORD(src)] tried to set req_one_access, but req_access was already set!")
	else
		var/list/access_list = get_access()
		windoor.req_one_access += access_list

/obj/effect/mapping_helpers/windoor/access/all/payload(obj/machinery/door/window/windoor)
	if(windoor.req_one_access != null)
		log_mapping("[src] access helper at [AREACOORD(src)] tried to set req_one_access, but req_access was already set!")
	else
		var/list/access_list = get_access()
		windoor.req_access += access_list

/obj/effect/mapping_helpers/windoor/access/proc/get_access()
	var/list/access = list()
	return access


//// HELPERS START - PLEASE KEEP EVERYTHING IN THE SAME ORDER AS IN ACCESS.DM THANKS

/// REQ ANY ///
// Applies onto req_one_access (only requires ONE of the given accesses to open)

//---  COMMAND  ---//

/obj/effect/mapping_helpers/windoor/access/any/command
	icon_state = "windoor_access_com"

/obj/effect/mapping_helpers/windoor/access/any/command/general/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_COMMAND
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/command/ai_master/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_AI_MASTER
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/command/ai_sat/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_AI_SAT
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/command/teleporter/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_TELEPORTER
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/command/eva/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_EVA
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/command/vault/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_VAULT
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/command/captain/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CAPTAIN
	return access_list


//---  SECURITY  ---//

/obj/effect/mapping_helpers/windoor/access/any/security
	icon_state = "windoor_access_sec"

/obj/effect/mapping_helpers/windoor/access/any/security/general/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_SECURITY
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/security/basic/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_SEC_BASIC
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/security/brig/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_BRIG
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/security/armory/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_ARMORY
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/security/detective/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_DETECTIVE
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/security/brig_phys/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_BRIG_PHYS
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/security/hos/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_HOS
	return access_list


//---  ENGINEERING  ---//

/obj/effect/mapping_helpers/windoor/access/any/engineering
	icon_state = "windoor_access_eng"

/obj/effect/mapping_helpers/windoor/access/any/engineering/general/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_ENGINEERING
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/engineering/atmos/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_ATMOSPHERICS
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/engineering/maintenance/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_MAINT_TUNNELS
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/engineering/external/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_EXTERNAL_AIRLOCKS
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/engineering/equipment/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_ENGINE_EQUIP
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/engineering/construction/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CONSTRUCTION
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/engineering/tech_storage/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_TECH_STORAGE
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/engineering/secure_tech/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_SECURE_TECH
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/engineering/tcomms/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_TCOMMS
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/engineering/aux_base/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_AUX_BASE
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/engineering/ce/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CE
	return access_list


//---  MEDICAL  ---//

/obj/effect/mapping_helpers/windoor/access/any/medical
	icon_state = "windoor_access_med"

/obj/effect/mapping_helpers/windoor/access/any/medical/general/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_MEDICAL
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/medical/surgery/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_SURGERY
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/medical/paramedic/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_PARAMEDIC
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/medical/morgue/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_MORGUE
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/medical/chemistry/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CHEMISTRY

/obj/effect/mapping_helpers/windoor/access/any/medical/cloning/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CLONING
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/medical/virology/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_VIROLOGY
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/medical/psychology/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_PSYCHOLOGY
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/medical/cmo/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CMO
	return access_list


//---  SUPPLY  ---//

/obj/effect/mapping_helpers/windoor/access/any/supply
	icon_state = "windoor_access_sup"

/obj/effect/mapping_helpers/windoor/access/any/supply/general/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CARGO
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/supply/cargo_bay/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CARGO_BAY
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/supply/mining/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_MINING
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/supply/mining_station/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_MINING_STATION
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/supply/qm/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_QM
	return access_list


//---  SCIENCE  ---//

/obj/effect/mapping_helpers/windoor/access/any/science
	icon_state = "windoor_access_sci"

/obj/effect/mapping_helpers/windoor/access/any/science/general/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_SCIENCE
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/science/research/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_RESEARCH
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/science/toxins/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_TOXINS
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/science/toxins_storage/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_TOXINS_STORAGE
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/science/experimentation/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_EXPERIMENTATION
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/science/genetics/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_GENETICS
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/science/robotics/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_ROBOTICS
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/science/xenobio/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_XENOBIOLOGY
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/science/rnd_servers/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_RND_SERVERS
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/science/rd/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_RD
	return access_list


//---  SERVICE  ---//
/obj/effect/mapping_helpers/windoor/access/any/service
	icon_state = "windoor_access_serv"

/obj/effect/mapping_helpers/windoor/access/any/service/general/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_SERVICE
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/service/theatre/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_THEATRE
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/service/chapel_office/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CHAPEL_OFFICE
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/service/crematorium/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CREMATORIUM
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/service/library/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_LIBRARY
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/service/bar/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_BAR
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/service/kitchen/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_KITCHEN
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/service/hydroponics/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_HYDROPONICS
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/service/janitor/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_JANITOR
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/service/lawyer/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_LAWYER
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/service/clerk/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CLERK
	return access_list

/obj/effect/mapping_helpers/windoor/access/any/service/hop/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_HOP
	return access_list


/// REQ ALL ///
// Applies onto req_access (requires ALL of the given accesses to open)
// Note: If a door only has one access req, - always - use this type

//---  COMMAND  ---//

/obj/effect/mapping_helpers/windoor/access/all/command
	icon_state = "windoor_access_com"

/obj/effect/mapping_helpers/windoor/access/all/command/general/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_COMMAND
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/command/ai_master/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_AI_MASTER
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/command/ai_sat/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_AI_SAT
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/command/teleporter/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_TELEPORTER
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/command/eva/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_EVA
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/command/vault/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_VAULT
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/command/captain/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CAPTAIN
	return access_list


//---  SECURITY  ---//

/obj/effect/mapping_helpers/windoor/access/all/security
	icon_state = "windoor_access_sec"

/obj/effect/mapping_helpers/windoor/access/all/security/general/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_SECURITY
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/security/basic/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_SEC_BASIC
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/security/brig/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_BRIG
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/security/armory/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_ARMORY
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/security/detective/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_DETECTIVE
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/security/brig_phys/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_BRIG_PHYS
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/security/hos/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_HOS
	return access_list


//---  ENGINEERING  ---//

/obj/effect/mapping_helpers/windoor/access/all/engineering
	icon_state = "windoor_access_eng"

/obj/effect/mapping_helpers/windoor/access/all/engineering/general/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_ENGINEERING
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/engineering/atmos/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_ATMOSPHERICS
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/engineering/maintenance/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_MAINT_TUNNELS
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/engineering/external/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_EXTERNAL_AIRLOCKS
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/engineering/equipment/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_ENGINE_EQUIP
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/engineering/construction/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CONSTRUCTION
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/engineering/tech_storage/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_TECH_STORAGE
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/engineering/secure_tech/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_SECURE_TECH
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/engineering/tcomms/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_TCOMMS
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/engineering/aux_base/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_AUX_BASE
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/engineering/ce/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CE
	return access_list


//---  MEDICAL  ---//

/obj/effect/mapping_helpers/windoor/access/all/medical
	icon_state = "windoor_access_med"

/obj/effect/mapping_helpers/windoor/access/all/medical/general/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_MEDICAL
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/medical/surgery/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_SURGERY
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/medical/paramedic/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_PARAMEDIC
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/medical/morgue/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_MORGUE
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/medical/chemistry/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CHEMISTRY
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/medical/cloning/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CLONING
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/medical/virology/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_VIROLOGY
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/medical/psychology/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_PSYCHOLOGY
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/medical/cmo/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CMO
	return access_list


//---  SUPPLY  ---//

/obj/effect/mapping_helpers/windoor/access/all/supply
	icon_state = "windoor_access_sup"

/obj/effect/mapping_helpers/windoor/access/all/supply/general/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CARGO
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/supply/cargo_bay/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CARGO_BAY
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/supply/mining/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_MINING
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/supply/mining_station/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_MINING_STATION
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/supply/qm/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_QM
	return access_list


//---  SCIENCE  ---//

/obj/effect/mapping_helpers/windoor/access/all/science
	icon_state = "windoor_access_sci"

/obj/effect/mapping_helpers/windoor/access/all/science/general/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_SCIENCE
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/science/research/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_RESEARCH
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/science/toxins/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_TOXINS
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/science/toxins_storage/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_TOXINS_STORAGE
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/science/experimentation/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_EXPERIMENTATION
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/science/genetics/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_GENETICS
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/science/robotics/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_ROBOTICS
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/science/xenobio/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_XENOBIOLOGY
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/science/rnd_servers/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_RND_SERVERS
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/science/rd/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_RD
	return access_list


//---  SERVICE  ---//
/obj/effect/mapping_helpers/windoor/access/all/service
	icon_state = "windoor_access_serv"

/obj/effect/mapping_helpers/windoor/access/all/service/general/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_SERVICE
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/service/theatre/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_THEATRE
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/service/chapel_office/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CHAPEL_OFFICE
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/service/crematorium/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CREMATORIUM
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/service/library/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_LIBRARY
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/service/bar/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_BAR
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/service/kitchen/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_KITCHEN
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/service/hydroponics/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_HYDROPONICS
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/service/janitor/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_JANITOR
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/service/lawyer/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_LAWYER
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/service/clerk/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_CLERK
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/service/hop/get_access()
	var/list/access_list = ..()
	access_list += ACCESS_HOP
	return access_list


//---  RUINS  ---//
// Only giving req all to non-station helpers to cut down on bloat, feel free to add req any in the future if needed

/obj/effect/mapping_helpers/windoor/access/all/ruins
	icon_state = "windoor_access_ruin"

/obj/effect/mapping_helpers/windoor/access/all/ruins/general/get_access()
	var/list/access_list = ..()
	access_list += list(ACCESS_RUINS_GENERAL)
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/ruins/command/get_access()
	var/list/access_list = ..()
	access_list += list(ACCESS_RUINS_COMMAND)
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/ruins/security/get_access()
	var/list/access_list = ..()
	access_list += list(ACCESS_RUINS_SECURITY)
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/ruins/engineering/get_access()
	var/list/access_list = ..()
	access_list += list(ACCESS_RUINS_ENGINEERING)
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/ruins/medical/get_access()
	var/list/access_list = ..()
	access_list += list(ACCESS_RUINS_MEDICAL)
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/ruins/supply/get_access()
	var/list/access_list = ..()
	access_list += list(ACCESS_RUINS_SUPPLY)
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/ruins/science/get_access()
	var/list/access_list = ..()
	access_list += list(ACCESS_RUINS_SCIENCE)
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/ruins/maintenance/get_access()
	var/list/access_list = ..()
	access_list += list(ACCESS_RUINS_MAINTENANCE)
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/ruins/generic1/get_access()
	var/list/access_list = ..()
	access_list += list(ACCESS_RUINS_GENERIC1)
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/ruins/generic2/get_access()
	var/list/access_list = ..()
	access_list += list(ACCESS_RUINS_GENERIC2)
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/ruins/generic3/get_access()
	var/list/access_list = ..()
	access_list += list(ACCESS_RUINS_GENERIC3)
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/ruins/generic4/get_access()
	var/list/access_list = ..()
	access_list += list(ACCESS_RUINS_GENERIC4)
	return access_list


//---  ADMIN  ---//

/obj/effect/mapping_helpers/windoor/access/all/admin
	icon_state = "windoor_access_adm"

/obj/effect/mapping_helpers/windoor/access/all/admin/general/get_access()
	var/list/access_list = ..()
	access_list += list(ACCESS_CENT_GENERAL)
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/admin/thunderdome/get_access()
	var/list/access_list = ..()
	access_list += list(ACCESS_CENT_THUNDER)
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/admin/medical/get_access()
	var/list/access_list = ..()
	access_list += list(ACCESS_CENT_MEDICAL)
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/admin/living/get_access()
	var/list/access_list = ..()
	access_list += list(ACCESS_CENT_LIVING)
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/admin/storage/get_access()
	var/list/access_list = ..()
	access_list += list(ACCESS_CENT_STORAGE)
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/admin/teleporter/get_access()
	var/list/access_list = ..()
	access_list += list(ACCESS_CENT_TELEPORTER)
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/admin/captain/get_access()
	var/list/access_list = ..()
	access_list += list(ACCESS_CENT_CAPTAIN)
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/admin/bar/get_access()
	var/list/access_list = ..()
	access_list += list(ACCESS_CENT_BAR)
	return access_list


//---  SYNDICATE  ---//

/obj/effect/mapping_helpers/windoor/access/all/syndicate
	icon_state = "windoor_access_syn"

/obj/effect/mapping_helpers/windoor/access/all/syndicate/general/get_access()
	var/list/access_list = ..()
	access_list += list(ACCESS_SYNDICATE)
	return access_list

/obj/effect/mapping_helpers/windoor/access/all/syndicate/leader/get_access()
	var/list/access_list = ..()
	access_list += list(ACCESS_SYNDICATE_LEADER)
	return access_list
