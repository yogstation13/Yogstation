//DOLPHIN PORT WOOOOOO
/datum/round_event_control/dolphin_migration
	name = "Dolphin Migration"
	typepath = /datum/round_event/dolphin_migration
	weight = 15
	earliest_start = 10 MINUTES
	max_occurrences = 6
	category = EVENT_CATEGORY_ENTITIES
	description = "Summons a school of dolphin."
	min_wizard_trigger_potency = 0
	max_wizard_trigger_potency = 2
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_SPACE, TAG_EXTERNAL)
	event_group = /datum/event_group/guests

/datum/round_event/dolphin_migration
	announce_when	= 3
	start_when = 50

/datum/round_event/dolphin_migration/setup()
	start_when = rand(40, 60)

/datum/round_event/dolphin_migration/announce()
	priority_announce("Unknown biological entities have been detected near [station_name()], please stand-by.", "Lifesign Alert")

/datum/round_event/dolphin_migration/start()
	for(var/obj/effect/landmark/carpspawn/C in GLOB.landmarks_list)
		if(prob(95))
			new /mob/living/simple_animal/hostile/retaliate/dolphin(C.loc)
		else
			new /mob/living/simple_animal/hostile/retaliate/dolphin/manatee(C.loc)



