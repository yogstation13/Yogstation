/datum/round_event_control/antagonist/solo/nuclear_operative
	name = "Nuclear Assault"
	tags = list(TAG_DESTRUCTIVE, TAG_COMBAT, TAG_TEAM_ANTAG, TAG_EXTERNAL)
	antag_flag = ROLE_OPERATIVE
	antag_datum = /datum/antagonist/nukeop
	typepath = /datum/round_event/antagonist/solo/nuclear_operative
	shared_occurence_type = SHARED_HIGH_THREAT
	max_occurrences = 1
	restricted_roles = list(
		JOB_AI,
		JOB_CAPTAIN,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_CYBORG,
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_RESEARCH_DIRECTOR,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
		JOB_BRIG_PHYSICIAN,
	)
	base_antags = 2
	maximum_antags = 5
	enemy_roles = list(
		JOB_AI,
		JOB_CYBORG,
		JOB_CAPTAIN,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
	)
	required_enemies = 3
	min_players = 20
	roundstart = TRUE
	title_icon = "nukeops"
	earliest_start = 0 SECONDS
	weight = 4

/datum/round_event/antagonist/solo/nuclear_operative
	end_when = 60000
	excute_round_end_reports = TRUE
	var/static/datum/team/nuclear/nuke_team
	var/set_leader = FALSE
	var/required_role = ROLE_OPERATIVE
	var/datum/mind/most_experienced
	var/boss_type = /datum/antagonist/nukeop/leader

/datum/round_event/antagonist/solo/nuclear_operative/add_datum_to_mind(datum/mind/antag_mind)
	if(most_experienced == antag_mind)
		return

	var/mob/living/current_mob = antag_mind.current
	SSjob.FreeRole(antag_mind.assigned_role)
	var/list/items = current_mob.get_equipped_items(TRUE)
	current_mob.unequip_everything()
	for(var/obj/item/item as anything in items)
		qdel(item)

	if(!most_experienced)
		most_experienced = get_most_experienced(setup_minds, required_role)

	if(!most_experienced)
		most_experienced = antag_mind

	if(!set_leader)
		set_leader = TRUE
		if(antag_mind != most_experienced)
			var/mob/living/leader_mob = most_experienced.current
			SSjob.FreeRole(most_experienced.assigned_role)
			var/list/leader_items = leader_mob.get_equipped_items(TRUE)
			leader_mob.unequip_everything()
			for(var/obj/item/item as anything in leader_items)
				qdel(item)
		most_experienced.special_role = required_role
		most_experienced.assigned_role = required_role
		var/datum/antagonist/nukeop/leader/leader_antag_datum = most_experienced.add_antag_datum(boss_type)
		nuke_team = leader_antag_datum.nuke_team

	if(antag_mind == most_experienced)
		return

	antag_mind.special_role = required_role
	antag_mind.assigned_role = required_role

	var/datum/antagonist/nukeop/new_op = new antag_datum()
	antag_mind.add_antag_datum(new_op)


/datum/round_event/antagonist/solo/nuclear_operative/round_end_report()
	var/result = nuke_team.get_result()
	switch(result)
		if(NUKE_RESULT_FLUKE)
			SSticker.mode_result = "loss - syndicate nuked - disk secured"
			SSticker.news_report = NUKE_SYNDICATE_BASE
		if(NUKE_RESULT_NUKE_WIN)
			SSticker.mode_result = "win - syndicate nuke"
			SSticker.news_report = STATION_DESTROYED_NUKE
		if(NUKE_RESULT_NOSURVIVORS)
			SSticker.mode_result = "halfwin - syndicate nuke - did not evacuate in time"
			SSticker.news_report = STATION_DESTROYED_NUKE
		if(NUKE_RESULT_WRONG_STATION)
			SSticker.mode_result = "halfwin - blew wrong station"
			SSticker.news_report = NUKE_MISS
		if(NUKE_RESULT_WRONG_STATION_DEAD)
			SSticker.mode_result = "halfwin - blew wrong station - did not evacuate in time"
			SSticker.news_report = NUKE_MISS
		if(NUKE_RESULT_CREW_WIN_SYNDIES_DEAD)
			SSticker.mode_result = "loss - evacuation - disk secured - syndi team dead"
			SSticker.news_report = OPERATIVES_KILLED
		if(NUKE_RESULT_CREW_WIN)
			SSticker.mode_result = "loss - evacuation - disk secured"
			SSticker.news_report = OPERATIVES_KILLED
		if(NUKE_RESULT_DISK_LOST)
			SSticker.mode_result = "halfwin - evacuation - disk not secured"
			SSticker.news_report = OPERATIVE_SKIRMISH
		if(NUKE_RESULT_DISK_STOLEN)
			SSticker.mode_result = "halfwin - detonation averted"
			SSticker.news_report = OPERATIVE_SKIRMISH
		else
			SSticker.mode_result = "halfwin - interrupted"
			SSticker.news_report = OPERATIVE_SKIRMISH



/datum/outfit/syndicate
	name = "Syndicate Operative - Basic"

	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	back = /obj/item/storage/backpack/fireproof
	ears = /obj/item/radio/headset/syndicate/alt
	l_pocket = /obj/item/pinpointer/nuke/syndicate
	id = /obj/item/card/id/syndicate
	belt = /obj/item/gun/ballistic/automatic/pistol
	box = /obj/item/storage/box/survival/syndie
	backpack_contents = list(/obj/item/kitchen/knife/combat/survival)

	var/tc = 25
	var/command_radio = FALSE
	var/uplink_type = /obj/item/uplink/nuclear


/datum/outfit/syndicate/leader
	name = "Syndicate Leader - Basic"
	id = /obj/item/card/id/syndicate/nuke_leader
	gloves = /obj/item/clothing/gloves/krav_maga/combatglovesplus
	r_hand = /obj/item/nuclear_challenge
	neck = /obj/item/clothing/neck/cloak/nukie
	command_radio = TRUE

/datum/outfit/syndicate/no_crystals
	name = "Syndicate Operative - Reinforcement"
	tc = 0

/datum/outfit/syndicate/post_equip(mob/living/carbon/human/H)
	var/obj/item/radio/R = H.ears
	R.set_frequency(FREQ_SYNDICATE)
	R.freqlock = TRUE
	if(command_radio)
		R.command = TRUE

	if(ispath(uplink_type, /obj/item/uplink/nuclear) || tc) // /obj/item/uplink/nuclear understands 0 tc
		var/obj/item/U = new uplink_type(H, H.key, tc)
		H.equip_to_slot_or_del(U, ITEM_SLOT_BACKPACK)

	var/obj/item/implant/biosig_gorlex/B = new/obj/item/implant/biosig_gorlex(H) // Biosignaller won't trigger if it's put below the explosive implant.
	B.implant(H)
	var/obj/item/implant/weapons_auth/W = new/obj/item/implant/weapons_auth(H)
	W.implant(H)
	var/obj/item/implant/explosive/E = new/obj/item/implant/explosive(H)
	E.implant(H)
	H.faction |= ROLE_ANTAG
	H.update_icons()

/datum/outfit/syndicate/full
	name = "Syndicate Operative - Full Kit"

	glasses = /obj/item/clothing/glasses/night
	mask = /obj/item/clothing/mask/gas/syndicate
	suit = /obj/item/clothing/suit/space/hardsuit/syndi
	r_pocket = /obj/item/tank/internals/emergency_oxygen/engi
	internals_slot = ITEM_SLOT_RPOCKET
	belt = /obj/item/storage/belt/military
	r_hand = /obj/item/gun/ballistic/shotgun/bulldog
	backpack_contents = list(/obj/item/tank/jetpack/oxygen/harness=1,\
		/obj/item/gun/ballistic/automatic/pistol=1,\
		/obj/item/kitchen/knife/combat/survival)
