/obj/effect/landmark/start/yogs
	icon = 'yogstation/icons/mob/landmarks.dmi'

/obj/effect/landmark/start/yogs/mining_medic
	name = "Mining Medic"
	icon_state = "Mining Medic"

/obj/effect/landmark/start/yogs/signal_technician
	name = "Signal Technician"
	icon_state = "Signal Technician"

/obj/effect/landmark/start/yogs/clerk
	name = "Clerk"
	icon_state = "Clerk"

/obj/effect/landmark/start/yogs/paramedic
	name = "Paramedic"
	icon_state = "Paramedic"

/obj/effect/landmark/start/yogs/psychiatrist
	name = "Psychiatrist"
	icon_state = "Psychiatrist"

/obj/effect/landmark/start/yogs/tourist
	name = "Tourist"
	icon_state = "Tourist"

/obj/effect/landmark/event_spawn/proc/spawnroyale(drop = FALSE)
	if(drop)
		new /obj/effect/DPtarget(src, /obj/structure/closet/crate/royale, 0)
		priority_announce("[get_area(src)]")
	else
		return
