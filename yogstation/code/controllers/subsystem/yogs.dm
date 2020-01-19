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
	
	//PRIZEPOOL MODIFIER THING
	GLOB.arcade_prize_pool[/obj/item/grenade/plastic/glitterbomb/pink] = 1
	GLOB.arcade_prize_pool[/obj/item/toy/plush/goatplushie/angry] = 2
	GLOB.arcade_prize_pool[/obj/item/toy/plush/goatplushie/angry/realgoat] = 2
	GLOB.arcade_prize_pool[/obj/item/stack/tile/ballpit] = 2
	
	//MULTI-PORTAL HANDLER
	var/list/enters = list()
	var/list/exits_by_id = list()
	for(var/obj/effect/portal/permanent/one_way/multi/portal in GLOB.portals)
		if(portal.is_entry) // If an entry portal
			enters += portal
		else
			if(!exits_by_id[portal.id])
				exits_by_id[portal.id] = list()
			exits_by_id[portal.id] += get_turf(portal)
			qdel(portal)
	for(var/obj/effect/portal/permanent/one_way/multi/portal in enters)
		if(exits_by_id[portal.id])
			portal.linked_targets = exits_by_id[portal.id]

	return ..()

/datum/controller/subsystem/Yogs/fire(resumed = 0)
	//END OF SHIFT ANNOUNCER
	if(world.time > (ROUND_END_ANNOUNCEMENT_TIME*600) && !endedshift && !(EMERGENCY_AT_LEAST_DOCKED))
		priority_announce("Crew, your shift has come to an end. \n You may call the shuttle whenever you find it appropriate.", "End of shift announcement", 'sound/ai/commandreport.ogg')
		endedshift = TRUE
	
	//UNCLAIMED TICKET BWOINKER
	if(world.time - last_rebwoink > REBWOINK_TIME*10)
		last_rebwoink = world.time
		for(var/datum/admin_help/bwoink in GLOB.unclaimed_tickets)
			if(bwoink.check_owner())
				GLOB.unclaimed_tickets -= bwoink
	return
