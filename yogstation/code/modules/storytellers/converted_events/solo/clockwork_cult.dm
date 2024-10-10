/datum/round_event_control/antagonist/solo/clockcult
	name = "Clock Cult"
	tags = list(TAG_SPOOKY, TAG_DESTRUCTIVE, TAG_COMBAT, TAG_TEAM_ANTAG, TAG_EXTERNAL, TAG_MAGICAL)
	antag_flag = ROLE_SERVANT_OF_RATVAR
	antag_datum = /datum/antagonist/clockcult
	typepath = /datum/round_event/antagonist/solo/clockcult
	restricted_roles = list(
		JOB_AI,
		JOB_CAPTAIN,
		JOB_CHAPLAIN,
		JOB_CYBORG,
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
		JOB_BRIG_PHYSICIAN,
	)
	enemy_roles = list(
		JOB_CAPTAIN,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
		JOB_CHAPLAIN,
	)
	required_enemies = 3
	base_antags = 3
	maximum_antags = 4
	min_players = 25
	roundstart = TRUE
	title_icon = "clockcult"
	earliest_start = 0 SECONDS
	weight = 4
	shared_occurence_type = SHARED_HIGH_THREAT
	max_occurrences = 1

/datum/round_event/antagonist/solo/clockcult
	end_when = 60000
	var/list/spread_out_spawns
	var/ark_time

/datum/round_event/antagonist/solo/clockcult/setup()
	. = ..()
	var/list/cog_spawns = GLOB.servant_spawns_scarabs.Copy()
	for(var/turf/T in cog_spawns)
		new /obj/item/clockwork/construct_chassis/cogscarab(T)

	ark_time = 20 + round((SSgamemode.get_correct_popcount() / 5)) //In minutes, how long the Ark will wait before activation
	ark_time = min(ark_time, 35) //35 minute maximum for the activation timer
	var/obj/structure/destructible/clockwork/massive/celestial_gateway/G = GLOB.ark_of_the_clockwork_justiciar //that's a mouthful
	G.final_countdown(ark_time)


/datum/round_event/antagonist/solo/clockcult/add_datum_to_mind(datum/mind/antag_mind)
	if(!LAZYLEN(spread_out_spawns))
		spread_out_spawns = GLOB.servant_spawns.Copy()

	var/mob/living/L = antag_mind.current
	if(!L)
		return

	antag_mind.special_role = ROLE_SERVANT_OF_RATVAR
	antag_mind.assigned_role = ROLE_SERVANT_OF_RATVAR
	
	var/turf/T = pick_n_take(spread_out_spawns)

	L.forceMove(T)
	SSgamemode.greet_servant(L, ark_time)
	SSgamemode.equip_servant(L)
	add_servant_of_ratvar(L, TRUE)
	GLOB.data_core.manifest_inject(L)
