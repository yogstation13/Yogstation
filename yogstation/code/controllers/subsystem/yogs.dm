#define ROUND_END_ANNOUNCEMENT_TIME 105 //the time at which the game will announce that the shuttle can be called, in minutes.

SUBSYSTEM_DEF(Yogs)
	name = "Yog Features"
	flags = SS_BACKGROUND
	init_order = -101 //last subsystem to initialize, and first to shut down

	var/list/mentortickets //less of a ticket, and more just a log of everything someone has mhelped, and the responses
	var/endedshift = FALSE //whether or not we've announced that the shift can be ended

/datum/controller/subsystem/Yogs/Initialize()
	mentortickets = list()
	GLOB.arcade_prize_pool[/obj/item/grenade/plastic/glitterbomb/pink] = 1
	GLOB.arcade_prize_pool[/obj/item/toy/plush/goatplushie/angry] = 2
	GLOB.arcade_prize_pool[/obj/item/stack/tile/ballpit] = 2
	return ..()

/datum/controller/subsystem/Yogs/fire(resumed = 0)
	if(world.time > ROUND_END_ANNOUNCEMENT_TIME && !endedshift)
		priority_announce("Crew, your shift has come to an end. \n You may call the shuttle whenever you find it appropriate.", "End of shift announcement", 'sound/ai/commandreport.ogg')
	return

