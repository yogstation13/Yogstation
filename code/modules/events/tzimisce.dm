/datum/round_event_control/tzimisce/bloodsucker
	name = "Spawn Tzimisce - Bloodsucker"
	max_occurrences = 1
	weight = 5
	typepath = /datum/round_event/ghost_role/tzimisce/bloodsucker
	max_occurrences = 2
	min_players = 25
	earliest_start = 30 MINUTES
	gamemode_whitelist = list("bloodsucker","traitorsucker")

/datum/round_event/ghost_role/tzimisce/bloodsucker
	fakeable = FALSE
	var/cancel_me = TRUE

/datum/round_event/ghost_role/tzimisce/bloodsucker/start()
	for(var/mob/living/carbon/human/all_players in GLOB.player_list)
		if(IS_BLOODSUCKER(all_players) || IS_MONSTERHUNTER(all_players))
			message_admins("BLOODSUCKER NOTICE: Tzimisces have found a valid Target.")
			cancel_me = FALSE
			break
	if(cancel_me)
		kill()
		return

/datum/round_event_control/tzimisce
	name = "Spawn Tzimisce"
	typepath = /datum/round_event/ghost_role/tzimisce
	max_occurrences = 1
	min_players = 25
	earliest_start = 45 MINUTES

/datum/round_event/ghost_role/tzimisce
	var/success_spawn = 0
	minimum_required = 1
	role_name = "Tzimisce"
	fakeable = FALSE

/datum/round_event/ghost_role/tzimisce/kill()
	if(!success_spawn && control)
		control.occurrences--
	return ..()

/datum/round_event/ghost_role/tzimisce/spawn_role()
	//selecting a spawn_loc
	if(!SSjob.latejoin_trackers.len)
		return MAP_ERROR

	//selecting a candidate player
	var/list/candidates = get_candidates(ROLE_BLOODSUCKER, null, ROLE_BLOODSUCKER)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected_candidate = pick_n_take(candidates)
	var/key = selected_candidate.key

	var/datum/mind/Mind = create_tzimisce_mind(key)
	Mind.active = TRUE

	var/mob/living/carbon/human/tzimisce = spawn_event_tzimisce()
	Mind.transfer_to(tzimisce)
	Mind.add_antag_datum(/datum/antagonist/bloodsucker)
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = tzimisce.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	bloodsuckerdatum.bloodsucker_level_unspent += round(world.time / (15 MINUTES), 1)
	bloodsuckerdatum.AssignClanAndBane(tzimisce = TRUE)

	spawned_mobs += tzimisce
	message_admins("[ADMIN_LOOKUPFLW(tzimisce)] has been made into a tzimisce bloodsucker an event.")
	log_game("[key_name(tzimisce)] was spawned as a tzimisce bloodsucker by an event.")
	var/datum/job/jobdatum = SSjob.GetJob(pick("Assistant", "Botanist", "Station Engineer", "Medical Doctor", "Scientist", "Cargo Technician", "Cook"))
	set_antag_hud(tzimisce, "tzimisce")
	if(SSshuttle.arrivals)
		SSshuttle.arrivals.QueueAnnounce(tzimisce, jobdatum.title)
	Mind.assigned_role = jobdatum.title //sets up the manifest properly
	jobdatum.equip(tzimisce)
	var/obj/item/card/id/id = tzimisce.get_item_by_slot(SLOT_WEAR_ID)
	id.assignment = jobdatum.title
	id.originalassignment = jobdatum.title
	id.update_label()
	GLOB.data_core.manifest_inject(tzimisce, force = TRUE)
	tzimisce.update_move_intent_slowdown() //prevents you from going super duper fast
	return SUCCESSFUL_SPAWN


/datum/round_event/ghost_role/tzimisce/proc/spawn_event_tzimisce()
	var/mob/living/carbon/human/new_tzimisce = new()
	SSjob.SendToLateJoin(new_tzimisce)
	var/datum/preferences/A = new() //Randomize appearance.
	A.copy_to(new_tzimisce)
	new_tzimisce.dna.update_dna_identity()
	return new_tzimisce

/datum/round_event/ghost_role/tzimisce/proc/create_tzimisce_mind(key)
	var/datum/mind/Mind = new /datum/mind(key)
	Mind.special_role = ROLE_BLOODSUCKER
	return Mind
