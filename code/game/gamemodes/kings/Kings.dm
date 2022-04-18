/datum/game_mode/kings
	name = "kings"
	config_tag = "kings"
	report_type = "Kings"
	antag_flag = ROLE_KING
	false_report_weight = 10
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list(
		"Captain", "Head of Personnel", "Head of Security",
		"Research Director", "Chief Engineer", "Chief Medical Officer", "Curator",
		"Warden", "Security Officer", "Detective", "Brig Physician",
	)
	required_players = 30
	required_enemies = 1
	recommended_enemies = 4
	reroll_friendly = 1
	round_ends_with_antag_death = FALSE

	announce_span = "green"
	announce_text = "Among the crew are some strange psychos who consider themselves kings!\n\
	<span class='danger'>Kings</span>: Capture areas of this station to gather followers and complete your tasks.\n\
	<span class='notice'>Crew</span>: Well... They are just mentally ill people, so you should just ignore them, riht? Perhaps, untill something wouldn't go wrong."

	///List of all Kings, used for assigning
	var/list/kings = list()

/datum/game_mode/kings/pre_setup()

	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

	recommended_enemies = clamp(round(num_players()/10), 1, 6);

	for(var/i = 0, i < recommended_enemies, i++)
		if(!antag_candidates.len)
			break
		var/datum/mind/king = pick(antag_candidates)
		// Can we even BE a king?
		if(!king.can_make_king(king))
			antag_candidates -= king
			continue
		kings += king
		king.restricted_roles = restricted_jobs
		log_game("[king.key] (ckey) has been selected as a King.")
		antag_candidates -= king// Apparently you can also write antag_candidates -= king

	// Do we have enough kings to continue?
	return kings.len >= required_enemies

/datum/game_mode/kings/post_setup()
	// kings
	for(var/datum/mind/king in kings)
		if(!king.make_king(king))
			kings -= king
	..()

/datum/game_mode/kings/generate_report()
	return "There's been a report of some crewmembers consider themself kings.\
			They've try to ''Conquer'' departaments, with unknown effect on it's members.\
			Please aproach them with caution, because we have information that they have some sort of bluespace powers."

/datum/game_mode/kings/make_antag_chance(mob/living/carbon/human/character)
	var/kingcap = min(round(GLOB.joined_player_list.len / (3 * 4)) + 2, round(GLOB.joined_player_list.len / 2))
	if(kings.len >= kingcap) //Caps number of latejoin antagonists
		return
	if(kings.len <= (kingcap - 2) || prob(100 - (3 * 2)))
		if(ROLE_KING in character.client.prefs.be_special)
			if(!is_banned_from(character.ckey, list(ROLE_KING, ROLE_SYNDICATE)) && !QDELETED(character))
				if(age_check(character.client))
					if(!(character.job in restricted_jobs))
						character.mind.make_king()
						kings += character.mind

/datum/game_mode/kings/generate_credit_text()
	var/list/round_credits = list()
	var/len_before_addition

	round_credits += "<center><h1>The Kingss:</h1>"
	len_before_addition = round_credits.len
	for(var/datum/mind/king in kings)
		round_credits += "<center><h2>[king.name] as a King</h2>"
	if(len_before_addition == round_credits.len)
		round_credits += list("<center><h2>The Kings have gone far away into they home kingdom!</h2>", "<center><h2>We couldn't locate them!</h2>")
	round_credits += "<br>"

	round_credits += ..()
	return round_credits