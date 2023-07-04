/datum/team/cult
	name = "Cult"

	///The blood mark target
	var/atom/blood_target
	///Image of the blood mark target
	var/image/blood_target_image
	///Timer for the blood mark expiration
	var/blood_target_reset_timer

	///List of all bloodstone structures, not designated as anything special.
	var/list/obj/structure/destructible/cult/bloodstone/bloodstone_list = list()
	///The cult's designated anchor bloodstone.
	var/obj/structure/destructible/cult/bloodstone/anchor_bloodstone
	///Boolean on whether the bloodstones are on cooldown.
	var/bloodstone_cooldown = FALSE

	var/cult_vote_called = FALSE
	var/mob/living/cult_master
	var/reckoning_complete = FALSE
	var/cult_risen = FALSE
	var/cult_ascendent = FALSE

	var/cult_got_mulligan = FALSE
	var/cult_failed = FALSE
	///list of cultists just before summoning Narsie
	var/list/true_cultists = list()

/datum/team/cult/proc/check_size()
	if(cult_ascendent)
		return
	var/alive = 0
	var/cultplayers = 0
	for(var/I in GLOB.player_list)
		var/mob/M = I
		if(M.stat != DEAD)
			if(IS_CULTIST(M))
				++cultplayers
			else
				++alive
	var/ratio = cultplayers/alive
	if(ratio > CULT_RISEN && !cult_risen)
		for(var/datum/mind/B in members)
			if(B.current)
				SEND_SOUND(B.current, 'sound/hallucinations/i_see_you2.ogg')
				to_chat(B.current, span_cultlarge("The veil weakens as your cult grows, your eyes begin to glow..."))
				addtimer(CALLBACK(src, PROC_REF(rise), B.current), 20 SECONDS)
		cult_risen = TRUE

	if(ratio > CULT_ASCENDENT && !cult_ascendent)
		for(var/datum/mind/B in members)
			if(B.current)
				SEND_SOUND(B.current, 'sound/hallucinations/im_here1.ogg')
				to_chat(B.current, "<span class='cultlarge'>Your cult is ascendent and the red harvest approaches - you cannot hide your true nature for much longer!!")
				addtimer(CALLBACK(src, PROC_REF(ascend), B.current), 20 SECONDS)
		cult_ascendent = TRUE


/datum/team/cult/proc/rise(cultist)
	if(ishuman(cultist))
		var/mob/living/carbon/human/H = cultist
		H.eye_color = "f00"
		H.dna.update_ui_block(DNA_EYE_COLOR_BLOCK)
		ADD_TRAIT(H, CULT_EYES, CULT_TRAIT)
		H.updateappearance()

/datum/team/cult/proc/ascend(cultist)
	if(ishuman(cultist))
		var/mob/living/carbon/human/H = cultist
		new /obj/effect/temp_visual/cult/sparks(get_turf(H), H.dir)
		var/istate = pick("halo1","halo2","halo3","halo4","halo5","halo6")
		var/mutable_appearance/new_halo_overlay = mutable_appearance('icons/effects/32x64.dmi', istate, -HALO_LAYER)
		H.overlays_standing[HALO_LAYER] = new_halo_overlay
		H.apply_overlay(HALO_LAYER)

/datum/team/cult/proc/make_image(datum/objective/sacrifice/sac_objective)
	var/datum/job/job_of_sacrifice = sac_objective.target.assigned_role
	var/datum/preferences/prefs_of_sacrifice = sac_objective.target.current.client.prefs
	var/icon/reshape = get_flat_human_icon(null, job_of_sacrifice, prefs_of_sacrifice, list(SOUTH))
	reshape.Shift(SOUTH, 4)
	reshape.Shift(EAST, 1)
	reshape.Crop(7,4,26,31)
	reshape.Crop(-5,-3,26,30)
	sac_objective.sac_image = reshape

/datum/team/cult/proc/setup_objectives()
	var/datum/objective/sacrifice/sacrifice_objective = new
	sacrifice_objective.team = src
	sacrifice_objective.find_target()
	objectives += sacrifice_objective

	var/datum/objective/eldergod/summon_objective = new
	summon_objective.team = src
	objectives += summon_objective

/datum/team/cult/proc/get_sacrifice_target(allow_convertable = TRUE)
	var/list/target_candidates = list()
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(player.mind && !player.mind.has_antag_datum(/datum/antagonist/cult) && !is_convertable_to_cult(player) && player.stat != DEAD)
			// The chaplain gets triple relative weighting
			if (player.mind.holy_role)
				target_candidates[player.mind] = 3
			else
				target_candidates[player.mind] = 1

	if(target_candidates.len == 0 && allow_convertable)
		message_admins("Cult Sacrifice: Could not find unconvertible target, checking for convertible target.")
		for(var/mob/living/carbon/human/player in GLOB.player_list)
			if(player.mind && !player.mind.has_antag_datum(/datum/antagonist/cult) && player.stat != DEAD)
				target_candidates[player.mind] = 1

	if(target_candidates.len != 0)
		return pickweight(target_candidates)
	else
		return null

// Checks if the current sacrifice target is still valid and gives the cult
// their mulligan target if it isn't.  If the cult's mulligan target also fails,
// returns FALSE; in that case, the round should end immediately.
/datum/team/cult/proc/check_sacrifice_status()
	var/datum/objective/sacrifice/sac_objective = locate() in objectives
	if (!sac_objective)
		message_admins("A cult somehow doesn't have a sacrifice objective at all, causing the round to end.")
		return FALSE

	// The point of this function is to detect and gracefully recover from the
	// case that the target has their body destroyed completely without it being
	// sacrificed.  Thus, if the target has their body or was sacrificed, no
	// problem.
	if (sac_objective.sacced)
		return TRUE

	var/mob/living/carbon/human/body = sac_objective.target.current
	if (istype(body))
		return TRUE

	var/old_target = sac_objective.target
	if (!cult_got_mulligan)
		// If the cult was on its first sacrifice target, try to generate a new
		// target that can't be converted.
		var/datum/mind/new_target = get_sacrifice_target(FALSE)
		if (new_target != null) // If no valid targets exist, no mulligan
			cult_got_mulligan = TRUE

			sac_objective.target = new_target
			sac_objective.update_explanation_text()

			var/datum/job/sacjob = SSjob.GetJob(sac_objective.target.assigned_role)
			var/datum/preferences/sacface = sac_objective.target.current.client.prefs
			var/icon/reshape = get_flat_human_icon(null, sacjob, sacface, list(SOUTH))
			reshape.Shift(SOUTH, 4)
			reshape.Shift(EAST, 1)
			reshape.Crop(7,4,26,31)
			reshape.Crop(-5,-3,26,30)

			// Updates on its own every tick
			sac_objective.sac_image = reshape

			var/list/adjectives = list("sniveling", "cowardly", "worthless", "loyalist", "unhygenic")
			var/list/nouns = list("dog", "maggot", "ant", "cow", "clown")
			var/adjective = pick(adjectives)
			var/noun = pick(nouns)
			for (var/datum/mind/M in members)
				to_chat(M.current, span_cultlarge("The Geometer is displeased with your failure to sacrifice the [adjective] [noun] [old_target]."))

				// Handle the case where the new target is jobless
				var/job = new_target.current.job
				if (job == null)
					job = "disgusting NEET"
				to_chat(M.current, "<span class='cultlarge'>You will be given one more chance to serve by sacrificing the [job], [new_target].")
				to_chat(M.current, span_narsiesmall("Do not fail me again."))

			return TRUE
	// At this point, the cultists have squandered their mulligan and the round is over.
	for (var/datum/mind/M in members)
		to_chat(M.current, span_narsiesmall("I will not be worshipped by failures."))
		// Nar'sie is sick of your crap
		M.current.reagents.add_reagent(/datum/reagent/toxin/heparin, 100)
		M.current.reagents.add_reagent(/datum/reagent/toxin/initropidril, 100)
	cult_failed = TRUE
	return FALSE

/datum/team/cult/proc/check_cult_victory()
	for(var/datum/objective/O in objectives)
		if(O.check_completion() == CULT_NARSIE_KILLED)
			return CULT_NARSIE_KILLED
		else if(!O.check_completion())
			return CULT_LOSS
	return CULT_VICTORY

/datum/team/cult/roundend_report()
	var/list/parts = list()

	var/victory = check_cult_victory()

	if(victory == CULT_NARSIE_KILLED) // Epic failure, you summoned your god and then someone killed it.
		parts += "<span class='redtext big'>Nar'sie has been killed! The cult will haunt the universe no longer!</span>"
	else if(victory)
		parts += "<span class='greentext big'>The cult has succeeded! Nar'Sie has snuffed out another torch in the void!</span>"
	else
		parts += "<span class='redtext big'>The staff managed to stop the cult! Dark words and heresy are no match for Nanotrasen's finest!</span>"

	if(objectives.len)
		parts += "<b>The cultists' objectives were:</b>"
		var/count = 1
		for(var/datum/objective/objective in objectives)
			if(objective.check_completion())
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] [span_greentext("Success!")]"
			else
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] [span_redtext("Fail.")]"
			count++

	if(members.len)
		parts += span_header("The cultists were:")
		if(length(true_cultists))
			parts += printplayerlist(true_cultists)
		else
			parts += printplayerlist(members)

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/team/cult/proc/is_sacrifice_target(datum/mind/mind)
	for(var/datum/objective/sacrifice/sac_objective in objectives)
		if(mind == sac_objective.target)
			return TRUE
	return FALSE

/datum/team/cult/is_gamemode_hero()
	return SSticker.mode.name == "cult"

/// Sets a blood target for the cult.
/datum/team/cult/proc/set_blood_target(atom/new_target, mob/marker, duration = 90 SECONDS)
	if(QDELETED(new_target))
		CRASH("A null or invalid target was passed to set_blood_target.")

	if(blood_target_reset_timer)
		return FALSE

	blood_target = new_target
	RegisterSignal(blood_target, COMSIG_PARENT_QDELETING, PROC_REF(unset_blood_target_and_timer))
	var/area/target_area = get_area(new_target)

	blood_target_image = image('icons/effects/mouse_pointers/cult_target.dmi', new_target, "glow", ABOVE_MOB_LAYER)
	blood_target_image.appearance_flags = RESET_COLOR
	blood_target_image.pixel_x = -new_target.pixel_x
	blood_target_image.pixel_y = -new_target.pixel_y

	for(var/datum/mind/cultist as anything in members)
		if(!cultist.current)
			continue
		if(cultist.current.stat == DEAD || !cultist.current.client)
			continue

		to_chat(cultist.current, span_bold(span_cultlarge("[marker] has marked [blood_target] in the [target_area.name] as the cult's top priority, get there immediately!")))
		SEND_SOUND(cultist.current, sound(pick('sound/hallucinations/over_here2.ogg','sound/hallucinations/over_here3.ogg'), 0, 1, 75))
		cultist.current.client.images += blood_target_image

	blood_target_reset_timer = addtimer(CALLBACK(src, PROC_REF(unset_blood_target)), duration, TIMER_STOPPABLE)
	return TRUE

/// Unsets out blood target, clearing the images from all the cultists.
/datum/team/cult/proc/unset_blood_target()
	blood_target_reset_timer = null

	for(var/datum/mind/cultist as anything in members)
		if(!cultist.current)
			continue
		if(cultist.current.stat == DEAD || !cultist.current.client)
			continue

		if(QDELETED(blood_target))
			to_chat(cultist.current, span_bold(span_cultlarge("The blood mark's target is lost!")))
		else
			to_chat(cultist.current, span_bold(span_cultlarge("The blood mark has expired!")))
		cultist.current.client.images -= blood_target_image

	UnregisterSignal(blood_target, COMSIG_PARENT_QDELETING)
	blood_target = null

	QDEL_NULL(blood_target_image)

/// Unsets our blood target when they get deleted.
/datum/team/cult/proc/unset_blood_target_and_timer(datum/source)
	SIGNAL_HANDLER

	deltimer(blood_target_reset_timer)
	unset_blood_target()
