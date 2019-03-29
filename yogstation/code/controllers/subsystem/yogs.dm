#define ROUND_END_ANNOUNCEMENT_TIME 105 //the time at which the game will announce that the shuttle can be called, in minutes.
#define REBWOINK_TIME 50 // Number of seconds before unclaimed tickets bwoink again and yell about being unclaimed

SUBSYSTEM_DEF(Yogs)
	name = "Yog Features"
	flags = SS_BACKGROUND
	init_order = -101 //last subsystem to initialize, and first to shut down

	var/list/mentortickets //less of a ticket, and more just a log of everything someone has mhelped, and the responses
	var/endedshift = FALSE //whether or not we've announced that the shift can be ended
	var/last_rebwoink = 0 // Last time we bwoinked all admins about unclaimed tickets

/datum/controller/subsystem/Yogs/Initialize()
	mentortickets = list()
	GLOB.arcade_prize_pool[/obj/item/grenade/plastic/glitterbomb/pink] = 1
	GLOB.arcade_prize_pool[/obj/item/toy/plush/goatplushie/angry] = 2
	GLOB.arcade_prize_pool[/obj/item/stack/tile/ballpit] = 2
	return ..()

/datum/controller/subsystem/Yogs/fire(resumed = 0)
	if(world.time > (ROUND_END_ANNOUNCEMENT_TIME*600) && !endedshift)
		priority_announce("Crew, your shift has come to an end. \n You may call the shuttle whenever you find it appropriate.", "End of shift announcement", 'sound/ai/commandreport.ogg')
		endedshift = TRUE
	
	if(world.time - last_rebwoink > REBWOINK_TIME*10)
		last_rebwoink = world.time
		for(var/datum/admin_help/bwoink in GLOB.unclaimed_tickets)
			if(bwoink.check_owner())
				GLOB.unclaimed_tickets -= bwoink
	return

