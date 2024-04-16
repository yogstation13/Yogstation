#define VASSAL_SCAN_MIN_DISTANCE 5
#define VASSAL_SCAN_MAX_DISTANCE 500
/// 2s update time.
#define VASSAL_SCAN_PING_TIME 2 SECONDS

/datum/antagonist/vassal
	name = "\improper Vassal"
	roundend_category = "vassals"
	antagpanel_category = "Bloodsucker"
	job_rank = ROLE_BLOODSUCKER
	antag_hud_name = "vassal"
	show_in_roundend = FALSE

	/// The Master Bloodsucker's antag datum.
	var/datum/antagonist/bloodsucker/master
	var/datum/game_mode/blooodsucker
	/// List of all Purchased Powers, like Bloodsuckers.
	var/list/datum/action/powers = list()
	///Whether this vassal is already a special type of Vassal.
	var/special_type = FALSE
	///Description of what this Vassal does.
	var/vassal_description

/datum/antagonist/vassal/antag_panel_data()
	return "Master : [master.owner.name]"

/datum/antagonist/vassal/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current
	current_mob.apply_status_effect(/datum/status_effect/agent_pinpointer/vassal_edition)
	add_team_hud(current_mob)

/datum/antagonist/vassal/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current
	current_mob.remove_status_effect(/datum/status_effect/agent_pinpointer/vassal_edition)

/datum/antagonist/vassal/add_team_hud(mob/target)
	QDEL_NULL(team_hud_ref)

	team_hud_ref = WEAKREF(target.add_alt_appearance(
		/datum/atom_hud/alternate_appearance/basic/has_antagonist,
		"antag_team_hud_[REF(src)]",
		hud_image_on(target),
	))

	var/datum/atom_hud/alternate_appearance/basic/has_antagonist/hud = team_hud_ref.resolve()

	var/list/mob/living/mob_list = list()
	mob_list += master.owner.current
	for(var/datum/antagonist/vassal/vassal as anything in master.vassals)
		mob_list += vassal.owner.current

	for (var/datum/atom_hud/alternate_appearance/basic/has_antagonist/antag_hud as anything in GLOB.has_antagonist_huds)
		if(!(antag_hud.target in mob_list))
			continue
		antag_hud.show_to(target)
		hud.show_to(antag_hud.target)

/datum/antagonist/vassal/proc/on_examine(datum/source, mob/examiner, examine_text)
	SIGNAL_HANDLER

	if(!iscarbon(source))
		return
	var/vassal_examine = return_vassal_examine(examiner)
	examine_text += vassal_examine

/datum/antagonist/vassal/on_gain()
	RegisterSignal(owner.current, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(SSsunlight, COMSIG_SOL_WARNING_GIVEN, PROC_REF(give_warning))
	if(owner.current && HAS_TRAIT(owner.current, TRAIT_MINDSHIELD))
		for(var/obj/item/implant/mindshield/L in owner.current)
			if(L)
				qdel(L)
	/// Enslave them to their Master
	if(!master || !istype(master, master))
		return
	if(special_type)
		if(!master.special_vassals[special_type])
			master.special_vassals[special_type] = list()
		master.special_vassals[special_type] |= src
	master.vassals |= src
	owner.enslave_mind_to_creator(master.owner.current)
	owner.current.log_message("has been vassalized by [master.owner.current]!", LOG_ATTACK, color="#960000")
	/// Give Recuperate Power
	BuyPower(new /datum/action/cooldown/bloodsucker/recuperate)
	/// Give Objectives
	var/datum/objective/vassal_objective/vassal_objective = new
	vassal_objective.owner = owner
	objectives += vassal_objective
	/// Give Vampire Language & Hud
	owner.current.grant_all_languages(FALSE, FALSE, TRUE)
	owner.current.grant_language(/datum/language/vampiric)
	. = ..()

/datum/antagonist/vassal/on_removal()
	UnregisterSignal(owner.current, COMSIG_ATOM_EXAMINE)
	UnregisterSignal(SSsunlight, COMSIG_SOL_WARNING_GIVEN)
	//Free them from their Master
	if(master && master.owner)
		if(special_type && master.special_vassals[special_type])
			master.special_vassals[special_type] -= src
		master.vassals -= src
		owner.enslaved_to = null
	for(var/all_status_traits in owner.current._status_traits)
		REMOVE_TRAIT(owner.current, all_status_traits, BLOODSUCKER_TRAIT)
	//Remove Recuperate Power
	while(powers.len)
		var/datum/action/cooldown/bloodsucker/power = pick(powers)
		powers -= power
		power.Remove(owner.current)
	//Remove Language & Hud
	owner.current.remove_language(/datum/language/vampiric)
	return ..()

/datum/antagonist/vassal/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	for(var/datum/action/cooldown/bloodsucker/all_powers as anything in powers)
		all_powers.Remove(old_body)
		all_powers.Grant(new_body)

/datum/antagonist/vassal/proc/add_objective(datum/objective/added_objective)
	objectives += added_objective

/datum/antagonist/vassal/greet()
	. = ..()
	if(silent)
		return
	to_chat(owner, span_userdanger("You are now the mortal servant of [master.owner.current], a Bloodsucker!"))
	to_chat(owner, span_boldannounce("The power of [master.owner.current.p_their()] immortal blood compels you to obey [master.owner.current.p_them()] in all things, even offering your own life to prolong theirs.\n\
		You are not required to obey any other Bloodsucker, for only [master.owner.current] is your master. The laws of Nanotrasen do not apply to you now; only your vampiric master's word must be obeyed."))
	owner.current.playsound_local(null, 'sound/magic/mutate.ogg', 100, FALSE, pressure_affected = FALSE)
	antag_memory += "You have been vassalized, becoming the mortal servant of <b>[master.owner.current]</b>, a bloodsucking vampire!<br>"
	/// Message told to your Master.
	to_chat(master.owner, span_userdanger("[owner.current] has become addicted to your immortal blood. [owner.current.p_they(TRUE)] [owner.current.p_are()] now your undying servant!"))
	master.owner.current.playsound_local(null, 'sound/magic/mutate.ogg', 100, FALSE, pressure_affected = FALSE)

/datum/antagonist/vassal/farewell()
	if(silent)
		return
	owner.current.visible_message(
		span_deconversion_message("[owner.current]'s eyes dart feverishly from side to side, and then stop. [owner.current.p_they(TRUE)] seem[owner.current.p_s()] calm, \
		like [owner.current.p_they()] [owner.current.p_have()] regained some lost part of [owner.current.p_them()]self."),
	)
	to_chat(owner, span_deconversion_message("With a snap, you are no longer enslaved to [master.owner]! You breathe in heavily, having regained your free will."))
	owner.current.playsound_local(null, 'sound/magic/mutate.ogg', 100, FALSE, pressure_affected = FALSE)
	/// Message told to your (former) Master.
	if(master && master.owner)
		to_chat(master.owner, span_cultbold("You feel the bond with your vassal [owner.current] has somehow been broken!"))

/datum/antagonist/vassal/admin_add(datum/mind/new_owner, mob/admin)
	var/list/datum/mind/possible_vampires = list()
	for(var/datum/antagonist/bloodsucker/bloodsuckerdatums in GLOB.antagonists)
		var/datum/mind/vamp = bloodsuckerdatums.owner
		if(!vamp)
			continue
		if(!vamp.current)
			continue
		if(vamp.current.stat == DEAD)
			continue
		possible_vampires += vamp
	if(!length(possible_vampires))
		message_admins("[key_name_admin(usr)] tried vassalizing [key_name_admin(new_owner)], but there were no bloodsuckers!")
		return
	var/datum/mind/choice = input("Which bloodsucker should this vassal belong to?", "Bloodsucker") in possible_vampires
	if(!choice)
		return
	log_admin("[key_name_admin(usr)] turned [key_name_admin(new_owner)] into a vassal of [key_name_admin(choice)]!")
	var/datum/antagonist/bloodsucker/vampire = choice.has_antag_datum(/datum/antagonist/bloodsucker)
	master = vampire
	new_owner.add_antag_datum(src)
	to_chat(choice, span_notice("Through divine intervention, you've gained a new vassal!"))

/datum/antagonist/vassal/proc/toreador_levelup_mesmerize() //Don't need stupid args
	for(var/datum/action/cooldown/bloodsucker/targeted/mesmerize/mesmerize_power in powers)
		if(!istype(mesmerize_power))
			continue
		mesmerize_power.level_current = max(master.bloodsucker_level, 1)

/// If we weren't created by a bloodsucker, then we cannot be a vassal (assigned from antag panel)
/datum/antagonist/vassal/can_be_owned(datum/mind/new_owner)
	if(!master)
		return FALSE
	return ..()

/// When a Bloodsucker gets FinalDeath, all Vassals are freed - This is a Bloodsucker proc, not a Vassal one.
/datum/antagonist/bloodsucker/proc/free_all_vassals()
	for(var/datum/antagonist/vassal/all_vassals in vassals)
		// Skip over any Bloodsucker Vassals, they're too far gone to have all their stuff taken away from them
		if(all_vassals.owner.has_antag_datum(/datum/antagonist/bloodsucker))
			all_vassals.owner.current.remove_status_effect(/datum/status_effect/agent_pinpointer/vassal_edition)
			continue
		remove_vassal(all_vassals.owner)
		if(all_vassals.special_type == REVENGE_VASSAL)
			continue
		all_vassals.owner.add_antag_datum(/datum/antagonist/ex_vassal)
		all_vassals.owner.remove_antag_datum(/datum/antagonist/vassal)

/// Called by FreeAllVassals()
/datum/antagonist/bloodsucker/proc/remove_vassal(datum/mind/vassal)
	vassal.remove_antag_datum(/datum/antagonist/vassal)

/// Used when your Master teaches you a new Power.
/datum/antagonist/vassal/proc/BuyPower(datum/action/cooldown/bloodsucker/power)
	powers += power
	power.Grant(owner.current)

/datum/antagonist/vassal/proc/LevelUpPowers()
	for(var/datum/action/cooldown/bloodsucker/power in powers)
		power.level_current++

/// Called when we are made into the Favorite Vassal
/datum/antagonist/vassal/proc/make_special(datum/antagonist/vassal/vassal_type)
	//store what we need
	var/datum/mind/vassal_owner = owner
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = master

	//remove our antag datum
	silent = TRUE
	vassal_owner.remove_antag_datum(/datum/antagonist/vassal)

	//give our new one
	var/datum/antagonist/vassal/vassaldatum = new vassal_type(vassal_owner)
	vassaldatum.master = bloodsuckerdatum
	vassaldatum.silent = TRUE
	vassal_owner.add_antag_datum(vassaldatum)
	vassaldatum.silent = FALSE

	//send alerts of completion
	to_chat(master, span_danger("You have turned [vassal_owner.current] into your [vassaldatum.name]! They will no longer be deconverted upon Mindshielding!"))
	to_chat(vassal_owner, span_notice("As Blood drips over your body, you feel closer to your Master... You are now the Favorite Vassal!"))
	vassal_owner.current.playsound_local(null, 'sound/magic/mutate.ogg', 75, FALSE, pressure_affected = FALSE)

/**
 *	# Vassal Pinpointer
 *
 *	Pinpointer that points to their Master's location at all times.
 *	Unlike the Monster hunter one, this one is permanently active, and has no power needed to activate it.
 */

/atom/movable/screen/alert/status_effect/agent_pinpointer/vassal_edition
	name = "Blood Bond"
	desc = "You always know where your master is."

/datum/status_effect/agent_pinpointer/vassal_edition
	id = "agent_pinpointer"
	alert_type = /atom/movable/screen/alert/status_effect/agent_pinpointer/vassal_edition
	minimum_range = VASSAL_SCAN_MIN_DISTANCE
	tick_interval = VASSAL_SCAN_PING_TIME
	duration = -1
	range_fuzz_factor = 0

/datum/status_effect/agent_pinpointer/vassal_edition/on_creation(mob/living/new_owner, ...)
	..()
	var/datum/antagonist/vassal/antag_datum = new_owner.mind.has_antag_datum(/datum/antagonist/vassal)
	scan_target = antag_datum?.master?.owner?.current

/datum/status_effect/agent_pinpointer/vassal_edition/scan_for_target()
	return

/datum/status_effect/agent_pinpointer/vassal_edition/Destroy()
	if(scan_target)
		to_chat(owner, span_notice("You've lost your master's trail."))
	return ..()

#define BLOOD_TIMER_REQUIREMENT (10 MINUTES)
#define BLOOD_TIMER_HALWAY (BLOOD_TIMER_REQUIREMENT / 2)

/datum/antagonist/ex_vassal
	name = "\improper Ex-Vassal"
	roundend_category = "vassals"
	antagpanel_category = "Bloodsucker"
	job_rank = ROLE_BLOODSUCKER
	antag_hud_name = "vassal_grey"
	show_in_roundend = FALSE
	show_in_antagpanel = FALSE
	silent = TRUE
	ui_name = FALSE
	hud_icon = 'yogstation/icons/mob/hud.dmi'

	///The revenge vassal that brought us into the fold.
	var/datum/antagonist/vassal/revenge/revenge_vassal
	///Timer we have to live
	COOLDOWN_DECLARE(blood_timer)

/datum/antagonist/ex_vassal/on_gain()
	. = ..()
	RegisterSignal(owner.current, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/antagonist/ex_vassal/on_removal()
	if(revenge_vassal)
		revenge_vassal.ex_vassals -= src
		revenge_vassal = null
	blood_timer = null
	return ..()

/datum/antagonist/ex_vassal/proc/on_examine(datum/source, mob/examiner, examine_text)
	SIGNAL_HANDLER

	var/datum/antagonist/vassal/revenge/vassaldatum = examiner.mind.has_antag_datum(/datum/antagonist/vassal/revenge)
	if(vassaldatum && !revenge_vassal)
		examine_text += span_notice("[owner.current] is an ex-vassal!")

/datum/antagonist/ex_vassal/add_team_hud(mob/target)
	QDEL_NULL(team_hud_ref)

	team_hud_ref = WEAKREF(target.add_alt_appearance(
		/datum/atom_hud/alternate_appearance/basic/has_antagonist,
		"antag_team_hud_[REF(src)]",
		hud_image_on(target),
	))

	var/datum/atom_hud/alternate_appearance/basic/has_antagonist/hud = team_hud_ref.resolve()

	var/list/mob/living/mob_list = list()
	mob_list += revenge_vassal.owner.current
	for(var/datum/antagonist/ex_vassal/former_vassals as anything in revenge_vassal.ex_vassals)
		mob_list += former_vassals.owner.current

	for (var/datum/atom_hud/alternate_appearance/basic/has_antagonist/antag_hud as anything in GLOB.has_antagonist_huds)
		if(!(antag_hud.target in mob_list))
			continue
		antag_hud.show_to(target)
		hud.show_to(antag_hud.target)

/**
 * Fold return
 *
 * Called when a Revenge bloodsucker gets a vassal back into the fold.
 */
/datum/antagonist/ex_vassal/proc/return_to_fold(datum/antagonist/vassal/revenge/mike_ehrmantraut)
	revenge_vassal = mike_ehrmantraut
	mike_ehrmantraut.ex_vassals += src
	COOLDOWN_START(src, blood_timer, BLOOD_TIMER_REQUIREMENT)

	RegisterSignal(src, COMSIG_LIVING_LIFE, PROC_REF(on_life))

/datum/antagonist/ex_vassal/proc/on_life(datum/source, delta_time, times_fired)
	SIGNAL_HANDLER

	if(COOLDOWN_TIMELEFT(src, blood_timer) <= BLOOD_TIMER_HALWAY + 2 && COOLDOWN_TIMELEFT(src, blood_timer) >= BLOOD_TIMER_HALWAY - 2) //just about halfway
		to_chat(owner.current, span_cultbold("You need new blood from your Master!"))
	if(!COOLDOWN_FINISHED(src, blood_timer))
		return
	to_chat(owner.current, span_cultbold("You are out of blood!"))
	to_chat(revenge_vassal.owner.current, span_cultbold("[owner.current] has ran out of blood and is no longer in the fold!"))
	owner.remove_antag_datum(/datum/antagonist/ex_vassal)

/datum/antagonist/vassal/proc/give_warning(atom/source, danger_level, vampire_warning_message, vassal_warning_message)
	SIGNAL_HANDLER
	if(vassal_warning_message)
		to_chat(owner, vassal_warning_message)

/**
 * Returns a Vassals's examine strings.
 * Args:
 * viewer - The person examining.
 */

/datum/antagonist/vassal/proc/return_vassal_examine(mob/living/viewer)
	if(!viewer.mind || !iscarbon(owner.current))
		return FALSE
	var/mob/living/carbon/carbon_current = owner.current
	// Target must be a Vassal
	// Default String
	var/returnString = "\[<span class='warning'>"
	var/returnIcon = ""
	// Vassals and Bloodsuckers recognize eachother, while Monster Hunters can see Vassals.
	if(!IS_BLOODSUCKER(viewer) && !IS_VASSAL(viewer) && !IS_MONSTERHUNTER(viewer))
		return FALSE
	// Am I Viewer's Vassal?
	if(master.owner == viewer.mind)
		returnString += "This [carbon_current.dna.species.name] bears YOUR mark!"
		returnIcon = "[icon2html('icons/mob/vampiric.dmi', world, "vassal")]"
	// Am I someone ELSE'S Vassal?
	else if(IS_BLOODSUCKER(viewer) || IS_MONSTERHUNTER(viewer))
		returnString += "This [carbon_current.dna.species.name] bears the mark of <span class='boldwarning'>[master.return_full_name()][master.broke_masquerade ? " who has broken the Masquerade" : ""]</span>"
		returnIcon = "[icon2html('icons/mob/vampiric.dmi', world, "vassal_grey")]"
	// Are you serving the same master as I am?
	else if(viewer.mind.has_antag_datum(/datum/antagonist/vassal) in master.vassals)
		returnString += "[p_they(TRUE)] bears the mark of your Master"
		returnIcon = "[icon2html('icons/mob/vampiric.dmi', world, "vassal")]"
	// You serve a different Master than I do.
	else
		returnString += "[p_they(TRUE)] bears the mark of another Bloodsucker"
		returnIcon = "[icon2html('icons/mob/vampiric.dmi', world, "vassal_grey")]"

	returnString += "</span>\]" // \n"  Don't need spacers. Using . += "" in examine.dm does this on its own.
	return returnIcon + returnString


/datum/objective/vassal_objective
	name = "vassal objective"
	explanation_text = "Help your Master with whatever is requested of you."
	martyr_compatible = TRUE

/datum/objective/vassal_objective/check_completion()
	var/datum/antagonist/vassal/antag_datum = owner.has_antag_datum(/datum/antagonist/vassal)
	return antag_datum.master?.owner?.current?.stat != DEAD

/**
 * 
 * Bloodsucker Blood
 *
 * Artificially made, this must be fed to ex-vassals to keep them on their high.
 */
/datum/reagent/blood/bloodsucker
	name = "Blood two" //real

/datum/reagent/blood/bloodsucker/reaction_mob(mob/living/exposed_mob, methods, reac_volume, show_message, permeability)
	var/datum/antagonist/ex_vassal/former_vassal = exposed_mob.mind.has_antag_datum(/datum/antagonist/ex_vassal)
	if(former_vassal)
		to_chat(exposed_mob, span_cult("You feel the blood restore you... You feel safe."))
		COOLDOWN_RESET(former_vassal, blood_timer)
		COOLDOWN_START(former_vassal, blood_timer, BLOOD_TIMER_REQUIREMENT)
	return ..()

#undef BLOOD_TIMER_REQUIREMENT
#undef BLOOD_TIMER_HALWAY
