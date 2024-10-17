/datum/round_event_control/carp_migration
	name = "Carp Migration"
	typepath = /datum/round_event/carp_migration
	weight = 15
	min_players = 10
	earliest_start = 10 MINUTES
	max_occurrences = 2
	description = "Summons a school of space carp."
	min_wizard_trigger_potency = 0
	max_wizard_trigger_potency = 3
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_DESTRUCTIVE, TAG_COMBAT, TAG_SPACE, TAG_EXTERNAL, TAG_ALIEN)
	event_group = /datum/event_group/guests
	
/datum/round_event_control/carp_migration/New()
	. = ..()
	if(!HAS_TRAIT(SSstation, STATION_TRAIT_CARP_INFESTATION))
		return
	weight *= 3
	max_occurrences *= 2
	earliest_start *= 0.5

/datum/round_event/carp_migration
	announce_when	= 3
	start_when = 50
	var/carp_type = /mob/living/simple_animal/hostile/carp
	var/boss_type = /mob/living/simple_animal/hostile/carp/megacarp
	var/hasAnnounced = FALSE

/datum/round_event/carp_migration/setup()
	start_when = rand(40, 60)
	setup = TRUE

/datum/round_event/carp_migration/announce(fake)
	priority_announce("Unknown biological entities have been detected near [station_name()], please stand-by.", "Lifesign Alert")

/datum/round_event/carp_migration/start()
	var/mob/living/simple_animal/fish
	for(var/obj/effect/landmark/carpspawn/C in GLOB.landmarks_list)

		//yogs -- Gondola Day for some goddamn reason. Can't they just let go of Oak?
		if(prob(20) && SSgamemode.holidays && SSgamemode.holidays["Gondola Day"])
			fish = new /mob/living/simple_animal/pet/gondola(C.loc)
			continue
		//yogs end

		if(prob(95))
			fish = new carp_type(C.loc)
		else
			fish = new boss_type(C.loc)
			fishannounce(fish) //Prefer to announce the megacarps over the regular fishies
	fishannounce(fish)

/datum/round_event/carp_migration/proc/fishannounce(atom/fish)	
	if (!hasAnnounced)
		announce_to_ghosts(fish) //Only anounce the first fish
		hasAnnounced = TRUE

/**----------------------------------------------------------------
 * 
 * Dolphins
 * 
 */
/datum/round_event_control/carp_migration/dolphin
	name = "Dolphin Migration"
	typepath = /datum/round_event/carp_migration/dolphin
	max_occurrences = 6
	description = "Summons a school of dolphin."
	max_wizard_trigger_potency = 2
	tags = list(TAG_SPACE, TAG_EXTERNAL, TAG_POSITIVE)

/datum/round_event/carp_migration/dolphin
	carp_type = /mob/living/simple_animal/hostile/retaliate/dolphin
	boss_type = /mob/living/simple_animal/hostile/retaliate/dolphin/manatee
