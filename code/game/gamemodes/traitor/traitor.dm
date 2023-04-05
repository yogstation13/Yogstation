/datum/game_mode
	var/traitor_name = "traitor"
	var/list/datum/mind/traitors = list()

	var/datum/mind/exchange_red
	var/datum/mind/exchange_blue

/datum/game_mode/traitor
	name = "traitor"
	config_tag = "traitor"
	report_type = "traitor"
	antag_flag = ROLE_TRAITOR
	false_report_weight = 20 //Reports of traitors are pretty common.
	restricted_jobs = list("Cyborg")//They are part of the AI if he is traitor so are they, they use to get double chances
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Chief Engineer", "Chief Medical Officer", "Research Director", "Brig Physician") //YOGS -  added the hop and brig physician
	required_players = 0
	required_enemies = 1
	recommended_enemies = 4
	reroll_friendly = 1
	enemy_minimum_age = 0
	title_icon = "traitor"

	announce_span = "danger"
	announce_text = "There are Syndicate agents on the station!\n\
	<span class='danger'>Traitors</span>: Accomplish your objectives.\n\
	<span class='notice'>Crew</span>: Do not let the traitors succeed!"

	var/list/datum/mind/pre_traitors = list()
	var/traitors_possible = 4 //hard limit on traitors if scaling is turned off
	var/num_modifier = 0 // Used for gamemodes, that are a child of traitor, that need more than the usual.
	var/antag_datum = /datum/antagonist/traitor //what type of antag to create
	var/traitors_required = TRUE //Will allow no traitors

/datum/game_mode/traitor/proc/get_traitor_cap() //Only used after the game has started and jobs are assigned.

	var/command_count = 0
	var/security_count = 0
	var/medical_count = 0
	var/engineering_count = 0
	var/cyborg_count = 0
	var/other_count = 0

	var/has_warden = FALSE
	var/has_captain = FALSE
	var/has_head_of_security = FALSE
	var/has_ai = FALSE

	for(var/mob/living/carbon/human/player in GLOB.carbon_list)
		if(player.stat == DEAD) //Don't count dead.
			continue
		if(!player.mind) //Don't count non-players.
			continue

		//This is where the fun begins.
		var/assigned_role = player.mind.assigned_role
		if(assigned_role == "Warden")
			has_warden = TRUE
			continue
		if(assigned_role == "Captain")
			has_captain = TRUE
			continue
		if(assigned_role == "Head of Security")
			has_head_of_security = TRUE
			continue
		if(assigned_role == "AI")
			has_ai = TRUE
			continue
		if(assigned_role == "Cyborg")
			cyborg_count++
			continue

		//Assign roles.
		if(assigned_role in GLOB.command_positions)
			command_count++
			continue
		if(assigned_role in GLOB.medical_positions)
			medical_count++
			continue
		if(assigned_role in GLOB.security_positions)
			security_count++
			continue
		if(assigned_role in GLOB.engineering_positions)
			engineering_count++
			continue
		if(assigned_role in GLOB.science_positions)
			other_count++
			continue
		if(assigned_role in GLOB.supply_positions)
			other_count++
			continue
		if(assigned_role in GLOB.civilian_positions)
			other_count++
			continue

	var/has_leadership = has_head_of_security || (has_warden && (has_captain || command_count >= 3))

	//Cyborgs typically fill lacking departments.
	if(cyborg_count > 0 && engineering_count < 3)
		var/cyborgs_to_add = min(cyborg_count*0.25,3-engineering_count)
		engineering_count += cyborgs_to_add
		cyborg_count -= cyborgs_to_add
	if(cyborg_count > 0 && medical_count < 3)
		var/cyborgs_to_add = min(cyborg_count*0.25,3-medical_count)
		medical_count += cyborgs_to_add
		cyborg_count -= cyborgs_to_add
	if(cyborg_count > 0 && security_count < 3)
		var/cyborgs_to_add = min(cyborg_count*0.25,3-security_count)
		security_count += cyborgs_to_add
		cyborg_count -= cyborgs_to_add

	//"Uhhhh we have no sec. Anyone want to be a deputy?"
	if(has_leadership && security_count < 3)
		var/crew_to_add = min(other_count*0.05,3-security_count)
		security_count += crew_to_add
		other_count -= crew_to_add

	//This is where we actually calculate the number.
	var/final_calculation = security_count*0.75 //0.75 traitors for every sec officer.

	//Sec is better with a medical team. (25%)
	if(medical_count >= 3) //Sec is useless without medics.
		final_calculation *= 1.25

	//Sec is better with door openers. (5% to 20%)
	if(has_ai)
		final_calculation *= 1.2 //;AI OPEN
	else if(cyborg_count >= 1)
		final_calculation *= 1.10 //;BORG OPEN
	else if(command_count >= 2 || has_captain || engineering_count >= 3)
		final_calculation *= 1.05 //;SOMEONE OPEN PLEASE

	var/tsc = CONFIG_GET(number/traitor_scaling_coeff)

	return min(round(final_calculation), round(GLOB.joined_player_list.len / (tsc * 2)) + 2 + num_modifier, round(GLOB.joined_player_list.len / tsc) + num_modifier)


/datum/game_mode/traitor/pre_setup()

	if(num_players() <= lowpop_amount)
		if(!prob((2*1.14**num_players())-2)) //exponential equation, chance of restriction goes up as pop goes down.
			protected_jobs += GLOB.command_positions

	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

	if(CONFIG_GET(flag/protect_AI_from_traitor))
		restricted_jobs += "AI"

	var/num_traitors = 1

	var/tsc = CONFIG_GET(number/traitor_scaling_coeff)
	if(tsc)
		num_traitors = max(1, min(round(num_players() / (tsc * 2)) + 2 + num_modifier, round(num_players() / tsc) + num_modifier))
	else
		num_traitors = max(1, min(num_players(), traitors_possible))

	num_traitors = min(3,num_traitors) //Limit to 3 on the setup. More traitors will be spawned later if needed.

	for(var/j = 0, j < num_traitors, j++)
		if (!antag_candidates.len)
			break
		var/datum/mind/traitor = antag_pick(antag_candidates)
		pre_traitors += traitor
		traitor.special_role = traitor_name
		traitor.restricted_roles = restricted_jobs
		//log_game("[key_name(traitor)] has been selected as a [traitor_name]") | yogs - redundant
		antag_candidates.Remove(traitor)

	var/enough_tators = !traitors_required || pre_traitors.len > 0

	if(!enough_tators)
		setup_error = "Not enough traitor candidates"
		return FALSE
	else
		return TRUE


/datum/game_mode/traitor/post_setup()
	for(var/datum/mind/traitor in pre_traitors)
		addtimer(CALLBACK(src, /datum/game_mode/traitor.proc/add_traitor_delayed, traitor), rand(3 MINUTES, (5 MINUTES + 10 SECONDS)))

	if(!exchange_blue)
		exchange_blue = -1 //Block latejoiners from getting exchange objectives
	..()

	//We're not actually ready until all traitors are assigned.
	gamemode_ready = FALSE
	addtimer(VARSET_CALLBACK(src, gamemode_ready, TRUE), (5 MINUTES + 11 SECONDS))
	return TRUE

/datum/game_mode/traitor/make_antag_chance(mob/living/carbon/human/character) //Assigns traitor to latejoiners
	var/traitorcap = get_traitor_cap() //Yogstation change: Changed traitor cap.
	var/cur_traitors = SSticker.mode.traitors.len
	// [SANITY] Uh oh! Somehow the pre_traitors aren't in the traitors list! Add them!
	if(SSticker.mode.traitors.len < pre_traitors.len)
		cur_traitors += pre_traitors.len
	if(cur_traitors < traitorcap) //Yogstation change. Removes weird/confusing/near useless prob()
		if(antag_flag in character.client.prefs.be_special)
			if(!is_banned_from(character.ckey, list(ROLE_TRAITOR, ROLE_SYNDICATE)) && !QDELETED(character))
				if(age_check(character.client))
					if(!(character.job in restricted_jobs))
						add_latejoin_traitor(character.mind)

/datum/game_mode/traitor/proc/add_traitor_delayed(datum/mind/traitor)
	if(!traitor || !traitor.current || !traitor.current.client || (traitor.current.stat != CONSCIOUS) || istype(traitor.current.loc, /obj/machinery/cryopod))
		create_new_traitor()
		return
	var/datum/antagonist/traitor/new_antag = new antag_datum()
	traitor.add_antag_datum(new_antag)

/datum/game_mode/traitor/proc/create_new_traitor()
	var/list/potential_candidates = list()
	for(var/mob/living/carbon/human/applicant in GLOB.player_list)
		if(!applicant.client)
			continue
		if(!applicant.mind)
			continue
		if(!applicant.stat != CONSCIOUS)
			continue
		if(applicant.mind.assigned_role in protected_jobs)
			continue
		if(applicant.mind.assigned_role in restricted_jobs)
			continue
		if(!(applicant.mind.assigned_role in GLOB.command_positions + GLOB.engineering_positions + GLOB.medical_positions + GLOB.science_positions + GLOB.supply_positions + GLOB.civilian_positions + GLOB.security_positions + list("AI", "Cyborg")))
			continue
		if(applicant.mind.quiet_round)
			continue
		if(HAS_TRAIT(applicant, TRAIT_MINDSHIELD))
			continue
		if(is_banned_from(applicant.ckey, list(antag_flag, ROLE_SYNDICATE)))
			continue
		if(!(antag_flag in applicant.client.prefs.be_special))
			continue
		if(!age_check(applicant.client))
			continue
		potential_candidates += applicant
	if(!potential_candidates.len)
		message_admins("Failed to find new antag after original one left! Check the antag balance please.")
		return
	var/mob/living/carbon/human/picked = pick(potential_candidates)
	if(!picked || !picked.client)
		return
	var/datum/antagonist/traitor/new_antag = new antag_datum()
	picked.mind.add_antag_datum(new_antag)
	picked.mind.special_role = traitor_name

/datum/game_mode/traitor/proc/add_latejoin_traitor(datum/mind/character)
	var/datum/antagonist/traitor/new_antag = new antag_datum()
	character.add_antag_datum(new_antag)

/datum/game_mode/traitor/generate_report()
	return "Although more specific threats are commonplace, you should always remain vigilant for Syndicate agents aboard your station. Syndicate communications have implied that many \
		Nanotrasen employees are Syndicate agents with hidden memories that may be activated at a moment's notice, so it's possible that these agents might not even know their positions."

/datum/game_mode/traitor/generate_credit_text()
	var/list/round_credits = list()
	var/len_before_addition

	round_credits += "<center><h1>The [syndicate_name()] Spies:</h1>"
	len_before_addition = round_credits.len
	for(var/datum/mind/traitor in traitors)
		round_credits += "<center><h2>[traitor.name] as a [syndicate_name()] traitor</h2>"
	if(len_before_addition == round_credits.len)
		round_credits += list("<center><h2>The traitors have concealed their treachery!</h2>", "<center><h2>We couldn't locate them!</h2>")
	round_credits += "<br>"

	round_credits += ..()
	return round_credits
