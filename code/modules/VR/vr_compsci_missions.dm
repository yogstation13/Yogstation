#define VR_SPAWNER(_id, _outfit) \
	/obj/effect/landmark/vr_spawn/vr_mission/##_id { \
		id = #_id; \
		vr_outfit = #_outfit; \
	}; \


GLOBAL_LIST_EMPTY(compsci_flags)

#define MINE_FLAG "mine"

/datum/compsci_mission
	var/name
	var/desc
	var/id
	var/completion_item
	var/tags

	var/delete_completion_item = FALSE

/datum/compsci_mission/proc/complete()
	return

/datum/outfit/vr/mission


/obj/effect/landmark/vr_spawn/vr_mission
	var/id = "debug_mission"
	vr_outfit = /datum/outfit/vr/mission

/obj/effect/landmark/vr_spawn/vr_mission/Initialize(mapload)
	. = ..()
	LAZYADD(GLOB.compsci_mission_markers[id], src)
	LAZYREMOVE(GLOB.vr_spawnpoints[vr_category], src)

/obj/effect/landmark/vr_spawn/vr_mission/Destroy()
	LAZYREMOVE(GLOB.compsci_mission_markers[id], src)
	return ..()

//ACTUAL MISSIONS START HERE


/datum/compsci_mission/scientist_raid
	name = "Unknown Small Research Station"
	desc = "A recurring distress beacon has been detected from a nearby unidentified research station."
	id = "scientist_raid"
	completion_item = /obj/item/ai_cpu/organic

VR_SPAWNER(scientist_raid, /datum/outfit/vr/mission)

/datum/compsci_mission/combat_robot_factory
	name = "Abandoned Robot Factory"
	desc = "The records for an old abandoned robot factory have been lost. You've been sent to remake the report."
	id = "combat_robot_factory"
	completion_item = /obj/item/ai_cpu/self_aware

VR_SPAWNER(combat_robot_factory, /datum/outfit/vr/mission)

/datum/compsci_mission/abandoned_mine
	name = "Abandoned Mine"
	desc = "The records for an old abandoned robot factory have been lost. You've been sent to remake the report."
	id = "abandoned_mine"
	completion_item = /obj/item/paper/fluff/awaymissions/mine_coordinates
	delete_completion_item = TRUE

/datum/compsci_mission/abandoned_mine/complete()
	. = ..()
	GLOB.compsci_flags[MINE_FLAG] = TRUE 

VR_SPAWNER(abandoned_mine, /datum/outfit/vr/mission)
