SUBSYSTEM_DEF(Yogs)
	name = "Yog Features"
	flags = SS_BACKGROUND
	init_order = -101 //last subsystem to initialize, and first to shut down

	var/list/mentortickets //less of a ticket, and more just a log of everything someone has mhelped, and the responses

/datum/controller/subsystem/Yogs/Initialize()
	mentortickets = list()
	GLOB.arcade_prize_pool[/obj/item/grenade/plastic/glitterbomb/pink] = 1
	GLOB.arcade_prize_pool[/obj/item/toy/plush/goatplushie/angry] = 2
	GLOB.arcade_prize_pool[/obj/item/stack/tile/ballpit] = 2
	return ..()

/datum/controller/subsystem/Yogs/fire(resumed = 0)
	return

