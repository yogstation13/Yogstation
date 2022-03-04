/datum/game_mode
	var/list/datum/mind/bloodsuckers = list()
	var/list/datum/mind/vassals = list() // List of minds that have been turned into Vassals.
	var/list/datum/mind/monsterhunter = list() // List of all Monster Hunters
	var/obj/effect/sunlight/bloodsucker_sunlight // Sunlight Timer. Created on first Bloodsucker assign. Destroyed on last removed Bloodsucker.
	// The antags you're allowed to be if turning Vassal:
	var/list/vassal_allowed_antags = list(/datum/antagonist/brother, /datum/antagonist/traitor, /datum/antagonist/traitor/internal_affairs, /datum/antagonist/nukeop/lone, // Regular ops are bonded by team
		/datum/antagonist/fugitive, /datum/antagonist/fugitive_hunter, /datum/antagonist/gang, /datum/antagonist/rev,
		/datum/antagonist/pirate, /datum/antagonist/ert, /datum/antagonist/abductee, /datum/antagonist/valentine
		)

/proc/AmBloodsucker(mob/living/M, falseIfInDisguise = FALSE)
	if(!M.mind)
		return FALSE
	if(!M.mind.has_antag_datum(/datum/antagonist/bloodsucker))
		return FALSE
	return TRUE

/datum/game_mode/bloodsucker
	name = "bloodsucker"
	config_tag = "bloodsucker"
	report_type = "Bloodsucker"
	antag_flag = ROLE_BLOODSUCKER
	false_report_weight = 10
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Captain", "Head of Personnel", "Head of Security", "Research Director", "Chief Engineer", "Chief Medical Officer", "Quartermaster", "Warden", "Security Officer", "Detective", "Brig Physician", "Deputy",)
	required_players = 0
	required_enemies = 1
	recommended_enemies = 4
	reroll_friendly = 1
	round_ends_with_antag_death = FALSE

	announce_span = "greem"
	announce_text = "Filthy, bloodsucking vampires are crawling around disguised as crewmembers!\n\
	<span class='danger'>Bloodsuckers</span>: Claim a coffin and grow strength, turn the crew into your slaves.\n\
	<span class='notice'>Crew</span>: Put an end to the undead menace and resist their brainwashing!"

/datum/game_mode/bloodsucker/pre_setup()

	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

	recommended_enemies = clamp(round(num_players()/10), 1, 6);

	for(var/i = 0, i < recommended_enemies, i++)
		if(!antag_candidates.len)
			break
		var/datum/mind/bloodsucker = pick(antag_candidates)
		// Can we even BE a bloodsucker?
		//if(can_make_bloodsucker(bloodsucker, display_warning=FALSE))
		bloodsuckers += bloodsucker
		bloodsucker.restricted_roles = restricted_jobs
		log_game("[bloodsucker.key] (ckey) has been selected as a Bloodsucker.")
		antag_candidates.Remove(bloodsucker) // Apparently you can also write antag_candidates -= bloodsucker

	// Do we have enough vamps to continue?
	return bloodsuckers.len >= required_enemies

/datum/game_mode/bloodsucker/post_setup()
	// Vamps
	for(var/datum/mind/bloodsucker in bloodsuckers)
		if(!make_bloodsucker(bloodsucker))
			bloodsuckers -= bloodsucker
	..()

/// Init Sunlight, called from datum_bloodsucker.on_gain(), in case game mode isn't even Bloodsucker
/datum/game_mode/proc/check_start_sunlight()
	// Already Sunlight (and not about to cancel)
	if(istype(bloodsucker_sunlight))
		return
	bloodsucker_sunlight = new()

/// End Sun (If you're the last)
/datum/game_mode/proc/check_cancel_sunlight()
	// No Sunlight
	if(!istype(bloodsucker_sunlight))
		return
	if(bloodsuckers.len <= 0)
		qdel(bloodsucker_sunlight)
		bloodsucker_sunlight = null

/datum/game_mode/proc/is_daylight()
	return istype(bloodsucker_sunlight) && bloodsucker_sunlight.amDay

/datum/game_mode/bloodsucker/generate_report()
	return "There's been a report of the undead roaming around the sector, especially those that display Vampiric abilities.\
			They've displayed the ability to disguise themselves as anyone and brainwash the minds of people they capture alive.\
			Please take care of the crew and their health, as it is impossible to tell if one is lurking in the darkness behind."

/datum/game_mode/bloodsucker/make_antag_chance(mob/living/carbon/human/character) //Assigns changeling to latejoiners
	var/bloodsuckercap = min(round(GLOB.joined_player_list.len / (3 * 4)) + 2, round(GLOB.joined_player_list.len / 2))
	if(bloodsuckers.len >= bloodsuckercap) //Caps number of latejoin antagonists
		return
	if(bloodsuckers.len <= (bloodsuckercap - 2) || prob(100 - (3 * 2)))
		if(ROLE_BLOODSUCKER in character.client.prefs.be_special)
			if(!is_banned_from(character.ckey, list(ROLE_BLOODSUCKER, ROLE_SYNDICATE)) && !QDELETED(character))
				if(age_check(character.client))
					if(!(character.job in restricted_jobs))
						character.mind.make_bloodsucker()
						bloodsuckers += character.mind

//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////
//                                          //
//        ROUNDSTART BLOODSUCKER            //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/bloodsucker
	name = "Bloodsuckers"
	antag_flag = ROLE_BLOODSUCKER
	antag_datum = /datum/antagonist/bloodsucker
	protected_roles = list("Captain", "Head of Personnel", "Head of Security", "Research Director", "Chief Engineer", "Chief Medical Officer", "Curator", "Warden", "Security Officer", "Detective", "Brig Physician")
	restricted_roles = list("AI", "Cyborg")
	required_candidates = 1
	weight = 3
	cost = 10
	scaling_cost = 15
	requirements = list(70,70,60,50,40,20,20,10,10,10)
	antag_cap = list(1,1,1,1,1,2,2,2,2,3)

/datum/dynamic_ruleset/roundstart/bloodsucker/pre_execute()
	. = ..()
	var/num_bloodsuckers = antag_cap[indice_pop] * (scaled_times + 1)
	for (var/i = 1 to num_bloodsuckers)
		var/mob/M = pick_n_take(candidates)
		assigned += M.mind
		M.mind.restricted_roles = restricted_roles
		M.mind.special_role = ROLE_BLOODSUCKER
	return TRUE

/datum/dynamic_ruleset/roundstart/bloodsucker/execute()
	for(var/datum/mind/bloodsucker in assigned)
		var/datum/antagonist/bloodsucker/new_antag = new antag_datum()
		bloodsucker.add_antag_datum(new_antag)
	return TRUE

/*
 *	DON'T ADD DYNAMIC MIDROUNDS TO BLOODSUCKERS
 *	By the time they'll spawn, they'd have missed several Sol's, and Security would likely be geared up.
 *	-Willard
 */

//////////////////////////////////////////////////////////////////////////////

/// Creator is just here so we can display fail messages to whoever is turning us.
/datum/game_mode/proc/can_make_bloodsucker(datum/mind/bloodsucker, datum/mind/creator)
	// Species Must have a HEART (Sorry Plasmamen)
	var/mob/living/carbon/human/H = bloodsucker.current
	if(NOBLOOD in H.dna.species.species_traits)
		to_chat(creator, "<span class='danger'>[bloodsucker]'s DNA isn't compatible!</span>")
		return FALSE
	// Already a Non-Human Antag
	if(bloodsucker.has_antag_datum(/datum/antagonist/abductor) || bloodsucker.has_antag_datum(/datum/antagonist/changeling))
		return FALSE
	// Already a vamp
	if(bloodsucker.has_antag_datum(/datum/antagonist/bloodsucker))
		to_chat(creator, "<span class='danger'>[bloodsucker] is already a Bloodsucker!</span>")
		return FALSE
	return TRUE

/datum/game_mode/proc/can_make_vassal(mob/living/target, datum/mind/creator, display_warning = TRUE)//, check_antag_or_loyal=FALSE)
	// Not Correct Type: Abort
	if(!iscarbon(target) || !creator)
		return FALSE
	if(target.stat > UNCONSCIOUS)
		return FALSE
	// No Mind!
	if(!target.mind || !target.mind.key)
		if(display_warning)
			to_chat(creator, "<span class='danger'>[target] isn't self-aware enough to be made into a Vassal.</span>")
		return FALSE
	// Already MY Vassal
	var/datum/antagonist/vassal/V = target.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(istype(V) && V.master)
		if(V.master.owner == creator)
			if(display_warning)
				to_chat(creator, "<span class='danger'>[target] is already your loyal Vassal!</span>")
		else
			if(display_warning)
				to_chat(creator, "<span class='danger'>[target] is the loyal Vassal of another Bloodsucker!</span>")
		return FALSE
	// Already Antag or Loyal (Vamp Hunters count as antags)
	if(target.mind.enslaved_to || AmInvalidAntag(target.mind)) //!VassalCheckAntagValid(target.mind, check_antag_or_loyal)) // HAS_TRAIT(target, TRAIT_MINDSHIELD, "implant") ||
		if(display_warning)
			to_chat(creator, "<span class='danger'>[target] resists the power of your blood to dominate their mind!</span>")
		return FALSE
	return TRUE

/// NOTE: This is a game_mode/proc, NOT a game_mode/bloodsucker/proc! We need to access this function despite the game mode.
/datum/game_mode/proc/make_bloodsucker(datum/mind/bloodsucker, datum/mind/creator = null)
	if(!can_make_bloodsucker(bloodsucker))
		return FALSE
	// Create Datum: Fledgling
	var/datum/antagonist/bloodsucker/A
	// [FLEDGLING]
	if(creator)
		A = new (bloodsucker)
		bloodsucker.add_antag_datum(A)
		// Log
		message_admins("[bloodsucker] has become a Bloodsucker, and was created by [creator].")
		log_admin("[bloodsucker] has become a Bloodsucker, and was created by [creator].")
	// [MASTER]
	else
		A = bloodsucker.add_antag_datum(/datum/antagonist/bloodsucker)
	return TRUE

/// Mind version
/datum/mind/proc/make_bloodsucker()
	var/datum/antagonist/bloodsucker/C = has_antag_datum(/datum/antagonist/bloodsucker)
	if(!C)
		C = add_antag_datum(/datum/antagonist/bloodsucker)
		special_role = ROLE_BLOODSUCKER
	return C

/datum/mind/proc/remove_bloodsucker()
	var/datum/antagonist/bloodsucker/C = has_antag_datum(/datum/antagonist/bloodsucker)
	if(C)
		remove_antag_datum(/datum/antagonist/bloodsucker)
		special_role = null

/datum/game_mode/proc/AmValidAntag(datum/mind/M)
	// No List?
	if(!islist(M.antag_datums) || M.antag_datums.len == 0)
		return FALSE
	// Am I NOT an invalid Antag? NOTE: We already excluded non-antags above. Don't worry about the "No List?" check in AmInvalidIntag()
	return !AmInvalidAntag(M)

/datum/game_mode/proc/AmInvalidAntag(datum/mind/M)
	// No List?
	if(!islist(M.antag_datums) || M.antag_datums.len == 0)
		return FALSE
	// Does even ONE antag appear in this mind that isn't in the list? Then FAIL!
	for(var/datum/antagonist/antag_datum in M.antag_datums)
		if(!(antag_datum.type in vassal_allowed_antags))  // vassal_allowed_antags is a list stored in the game mode, above.
			//message_admins("DEBUG VASSAL: Found Invalid: [antag_datum] // [antag_datum.type]")
			return TRUE
	//message_admins("DEBUG VASSAL: Valid Antags! (total of [M.antag_datums.len])")
	// WHEN YOU DELETE THE ABOVE: Remove the 3 second timer on converting the vassal too.
	return FALSE

/datum/game_mode/proc/make_vassal(var/mob/living/target, var/datum/mind/creator)
	if(!can_make_vassal(target, creator))
		return FALSE
	// Make Vassal
	var/datum/antagonist/vassal/V = new(target.mind)
	var/datum/antagonist/bloodsucker/B = creator.has_antag_datum(/datum/antagonist/bloodsucker)
	V.master = B
	target.mind.add_antag_datum(V, V.master.get_team())
	// Update Bloodsucker Title
	B.SelectTitle(am_fledgling = FALSE) // Only works if you have no title yet.
	// Log it
	message_admins("[target] has become a Vassal, and is enslaved to [creator].")
	log_admin("[target] has become a Vassal, and is enslaved to [creator].")
	return TRUE

/datum/game_mode/proc/update_bloodsucker_icons_added(datum/mind/bloodsucker)
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_BLOODSUCKER]
	hud.join_hud(bloodsucker.current)
	set_antag_hud(bloodsucker.current,((IS_BLOODSUCKER(bloodsucker.current)) ? "bloodsucker" : "vassal"))

/datum/game_mode/proc/update_bloodsucker_icons_removed(datum/mind/bloodsucker)
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_BLOODSUCKER]
	hud.leave_hud(bloodsucker.current)
	set_antag_hud(bloodsucker.current, null)

/datum/game_mode/bloodsucker/generate_credit_text()
	var/list/round_credits = list()
	var/len_before_addition

	round_credits += "<center><h1>The Bloodsuckers:</h1>"
	len_before_addition = round_credits.len
	for(var/datum/mind/bloodsucker in bloodsuckers)
		round_credits += "<center><h2>[bloodsucker.name] as a Bloodsucker</h2>"
	if(len_before_addition == round_credits.len)
		round_credits += list("<center><h2>The Bloodsuckers have vanished into the night!</h2>", "<center><h2>We couldn't locate them!</h2>")
	round_credits += "<br>"

	round_credits += ..()
	return round_credits