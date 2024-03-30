/datum/antagonist/bloodsucker
	name = "\improper Bloodsucker"
	show_in_antagpanel = TRUE
	roundend_category = "bloodsuckers"
	antagpanel_category = "Bloodsucker"
	job_rank = ROLE_BLOODSUCKER
	antag_hud_name = "bloodsucker"
	show_to_ghosts = TRUE
	show_name_in_check_antagonists = TRUE
	can_coexist_with_others = FALSE
	ui_name = "AntagInfoBloodsucker"
	preview_outfit = /datum/outfit/bloodsucker_outfit

	// TIMERS //
	///Timer between alerts for Burn messages
	COOLDOWN_DECLARE(static/bloodsucker_spam_sol_burn)
	///Timer between alerts for Healing messages
	COOLDOWN_DECLARE(static/bloodsucker_spam_healing)

	///Used for assigning your name
	var/bloodsucker_name
	///Used for assigning your title
	var/bloodsucker_title
	///Used for assigning your reputation
	var/bloodsucker_reputation

	///Amount of Humanity lost
	var/humanity_lost = 0
	///Have we been broken the Masquerade?
	var/broke_masquerade = FALSE
	///How many Masquerade Infractions do we have?
	var/masquerade_infractions = 0
	///If we are currently in a Frenzy
	var/frenzied = FALSE
	///If we have a task assigned
	var/has_task = FALSE
	///How many times have we used a blood altar
	var/altar_uses = 0

	///ALL Powers currently owned
	var/list/datum/action/cooldown/bloodsucker/powers = list()
	///Frenzy Grab Martial art given to Bloodsuckers in a Frenzy
	var/datum/martial_art/frenzygrab/frenzygrab = new
	///How many clan points you have -> Used in clans in order to assert certain limits // Upgrades and stuff
	var/clanpoints = 0
	///How much progress have you done on your clan
	var/clanprogress = 0

	///Vassals under my control. Periodically remove the dead ones.
	var/list/datum/antagonist/vassal/vassals = list()
	///Special vassals I own, to not have double of the same type.
	var/list/datum/antagonist/vassal/special_vassals = list()

	var/bloodsucker_level
	var/bloodsucker_level_unspent = 1
	var/passive_blood_drain = -0.1
	var/additional_regen
	var/bloodsucker_regen_rate = 0.3
	/// How much blood we have, starting off at default blood levels.
	var/bloodsucker_blood_volume = BLOOD_VOLUME_GENERIC
	/// How much blood we can have at once, increases per level.
	var/max_blood_volume = 600

	var/datum/bloodsucker_clan/my_clan

	// Used for Bloodsucker Objectives
	var/area/bloodsucker_lair_area
	var/obj/structure/closet/crate/coffin
	var/total_blood_drank = 0
	var/frenzy_blood_drank = 0
	var/task_heart_required = 0
	var/task_blood_required = 0
	var/task_blood_drank = 0
	var/frenzies = 0
	///Blood display HUD
	var/atom/movable/screen/bloodsucker/blood_counter/blood_display
	///Vampire level display HUD
	var/atom/movable/screen/bloodsucker/rank_counter/vamprank_display
	///Sunlight timer HUD
	var/atom/movable/screen/bloodsucker/sunlight_counter/sunlight_display

	/// Static typecache of all bloodsucker powers.
	var/static/list/all_bloodsucker_powers = typecacheof(/datum/action/cooldown/bloodsucker, TRUE)
	/// Antagonists that cannot be Vassalized no matter what
	var/static/list/vassal_banned_antags = list(
		/datum/antagonist/bloodsucker,
		/datum/antagonist/monsterhunter,
	)
	///Default Bloodsucker traits
	var/static/list/bloodsucker_traits = list(
		TRAIT_NOBREATH,
		TRAIT_SLEEPIMMUNE,
		TRAIT_NOCRITDAMAGE,
		TRAIT_RESISTCOLD,
		TRAIT_RADIMMUNE,
		TRAIT_GENELESS,
		TRAIT_STABLEHEART,
		TRAIT_NOSOFTCRIT,
		TRAIT_NOHARDCRIT,
		TRAIT_AGEUSIA,
		TRAIT_NOPULSE,
		TRAIT_COLDBLOODED,
		TRAIT_VIRUSIMMUNE,
		TRAIT_TOXIMMUNE,
		TRAIT_HARDLY_WOUNDED,
		TRAIT_RESISTDAMAGESLOWDOWN,
	)

/**
 * Apply innate effects is everything given to the mob
 * When a body is tranferred, this is called on the new mob
 * while on_gain is called ONCE per ANTAG, this is called ONCE per BODY.
 */
/datum/antagonist/bloodsucker/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current
	RegisterSignal(current_mob, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(current_mob, COMSIG_LIVING_LIFE, PROC_REF(LifeTick))
	RegisterSignal(current_mob, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	handle_clown_mutation(current_mob, mob_override ? null : "As a vampiric clown, you are no longer a danger to yourself. Your clownish nature has been subdued by your thirst for blood.")
	add_team_hud(current_mob)

	if(current_mob.hud_used)
		on_hud_created()
	else
		RegisterSignal(current_mob, COMSIG_MOB_HUD_CREATED, PROC_REF(on_hud_created))
#ifdef BLOODSUCKER_TESTING
	var/turf/user_loc = get_turf(current_mob)
	new /obj/structure/closet/crate/coffin(user_loc)
	new /obj/structure/bloodsucker/vassalrack(user_loc)
#endif

/**
 * Remove innate effects is everything given to the mob
 * When a body is tranferred, this is called on the new mob
 * while on_removal is called ONCE per ANTAG, this is called ONCE per BODY.
 */

/datum/antagonist/bloodsucker/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current
	UnregisterSignal(current_mob, list(COMSIG_LIVING_LIFE, COMSIG_ATOM_EXAMINE, COMSIG_LIVING_DEATH))

	if(current_mob.hud_used)
		var/datum/hud/hud_used = current_mob.hud_used

		hud_used.infodisplay -= blood_display
		hud_used.infodisplay -= vamprank_display
		hud_used.infodisplay -= sunlight_display

		QDEL_NULL(blood_display)
		QDEL_NULL(vamprank_display)
		QDEL_NULL(sunlight_display)

/datum/antagonist/bloodsucker/proc/on_hud_created(datum/source)
	SIGNAL_HANDLER

	var/datum/hud/bloodsucker_hud = owner.current.hud_used

	blood_display = new /atom/movable/screen/bloodsucker/blood_counter(bloodsucker_hud)
	bloodsucker_hud.infodisplay += blood_display

	vamprank_display = new /atom/movable/screen/bloodsucker/rank_counter(bloodsucker_hud)
	bloodsucker_hud.infodisplay += vamprank_display

	sunlight_display = new /atom/movable/screen/bloodsucker/sunlight_counter(bloodsucker_hud)
	bloodsucker_hud.infodisplay += sunlight_display

	INVOKE_ASYNC(bloodsucker_hud, TYPE_PROC_REF(/datum/hud/, show_hud), bloodsucker_hud.hud_version)

/datum/antagonist/bloodsucker/get_admin_commands()
	. = ..()
	.["Give Level"] = CALLBACK(src, PROC_REF(RankUp))
	if(bloodsucker_level_unspent >= 1)
		.["Remove Level"] = CALLBACK(src, PROC_REF(RankDown))

	if(broke_masquerade)
		.["Fix Masquerade"] = CALLBACK(src, PROC_REF(fix_masquerade))
	else
		.["Break Masquerade"] = CALLBACK(src, PROC_REF(break_masquerade))

	if(!my_clan)
		.["Force Clan"] = CALLBACK(src, PROC_REF(force_clan))

/datum/antagonist/bloodsucker/proc/force_clan(mob/admin)
	if(my_clan)	
		return

	var/list/clans = list()
	for(var/datum/bloodsucker_clan/all_clans as anything in typesof(/datum/bloodsucker_clan))
		if(initial(all_clans.joinable_clan))
			clans |= all_clans
	clans |= "vvv Not regularly joinable vvv"
	clans |= typesof(/datum/bloodsucker_clan)
		
	var/chosen = tgui_input_list(admin, "Select which clan to force on the target.", "Select Clan", clans)
	if(!chosen || !ispath(chosen, /datum/bloodsucker_clan))
		return
	
	if(QDELETED(src) || QDELETED(owner.current))
		return
	if(my_clan)
		to_chat(admin, span_warning("error, clan already picked"))
		return

	my_clan = new chosen(src)
	owner.announce_objectives()

///Called when you get the antag datum, called only ONCE per antagonist.
/datum/antagonist/bloodsucker/on_gain()
	RegisterSignal(SSsunlight, COMSIG_SOL_RANKUP_BLOODSUCKERS, PROC_REF(sol_rank_up))
	RegisterSignal(SSsunlight, COMSIG_SOL_NEAR_START, PROC_REF(sol_near_start))
	RegisterSignal(SSsunlight, COMSIG_SOL_END, PROC_REF(on_sol_end))
	RegisterSignal(SSsunlight, COMSIG_SOL_RISE_TICK, PROC_REF(handle_sol))
	RegisterSignal(SSsunlight, COMSIG_SOL_WARNING_GIVEN, PROC_REF(give_warning))

	if(IS_FAVORITE_VASSAL(owner.current)) // Vassals shouldnt be getting the same benefits as Bloodsuckers.
		bloodsucker_level_unspent = 0
		show_in_roundend = FALSE
	else
		// Start Sunlight if first Bloodsucker
		check_start_sunlight()
		// Name and Titles
		SelectFirstName()
		SelectTitle(am_fledgling = TRUE)
		SelectReputation(am_fledgling = TRUE)
		// Objectives
		forge_bloodsucker_objectives()

	. = ..()
	// Assign Powers
	give_starting_powers()
	assign_starting_stats()

/// Called by the remove_antag_datum() and remove_all_antag_datums() mind procs for the antag datum to handle its own removal and deletion.
/datum/antagonist/bloodsucker/on_removal()
	/// End Sunlight? (if last Vamp)
	UnregisterSignal(SSsunlight, list(COMSIG_SOL_RANKUP_BLOODSUCKERS, COMSIG_SOL_NEAR_START, COMSIG_SOL_END, COMSIG_SOL_RISE_TICK, COMSIG_SOL_WARNING_GIVEN))
	clear_powers_and_stats()
	check_cancel_sunlight() //check if sunlight should end
	return ..()

/datum/antagonist/bloodsucker/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	if(istype(new_body, /mob/living/simple_animal/hostile/bloodsucker) || istype(old_body, /mob/living/simple_animal/hostile/bloodsucker))
		return
	for(var/datum/action/cooldown/bloodsucker/all_powers as anything in powers)
		all_powers.Remove(old_body)
		all_powers.Grant(new_body)
	var/old_punchdamagelow
	var/old_punchdamagehigh
	var/old_punchstunthreshold
	var/old_species_punchdamagelow
	var/old_species_punchdamagehigh
	var/old_species_punchstunthreshold
	if(ishuman(old_body))
		var/mob/living/carbon/human/old_user = old_body
		var/datum/species/old_species = old_user.dna.species
		old_species.species_traits -= DRINKSBLOOD
		//Keep track of what they were
		old_punchdamagelow = old_species.punchdamagelow
		old_punchdamagehigh = old_species.punchdamagehigh
		old_punchstunthreshold = old_species.punchstunthreshold
		//Then reset them
		old_species.punchdamagelow = initial(old_species.punchdamagelow)
		old_species.punchdamagehigh = initial(old_species.punchdamagehigh)
		old_species.punchstunthreshold = initial(old_species.punchstunthreshold)
		//Then save the new, old, original species values so we can use them in the next part. This is starting to get convoluted.
		old_species_punchdamagelow = old_species.punchdamagelow
		old_species_punchdamagehigh = old_species.punchdamagehigh
		old_species_punchstunthreshold = old_species.punchstunthreshold
	if(ishuman(new_body))
		var/mob/living/carbon/human/new_user = new_body
		var/datum/species/new_species = new_user.dna.species
		new_species.species_traits += DRINKSBLOOD
		//Adjust new species punch damage
		new_species.punchdamagelow += (old_punchdamagelow - old_species_punchdamagelow)			//Takes whatever DIFFERENCE you had between your punch damage and that of the baseline species
		new_species.punchdamagehigh += (old_punchdamagehigh - old_species_punchdamagehigh)		//and adds it to your new species, thus preserving whatever bonuses you got
		new_species.punchstunthreshold += (old_punchstunthreshold - old_species_punchstunthreshold)

	//Give Bloodsucker Traits
	if(old_body)
		old_body.remove_traits(bloodsucker_traits, BLOODSUCKER_TRAIT)
	new_body.add_traits(bloodsucker_traits, BLOODSUCKER_TRAIT)


/datum/antagonist/bloodsucker/greet()
	. = ..()
	var/fullname = return_full_name(TRUE)
	to_chat(owner, span_userdanger("You are [fullname], a strain of vampire known as a Bloodsucker!"))
	owner.announce_objectives()
	if(bloodsucker_level_unspent >= 2)
		to_chat(owner, span_announce("As a latejoiner, you have [bloodsucker_level_unspent] bonus Ranks, entering your claimed coffin allows you to spend a Rank."))
	owner.current.playsound_local(null, 'sound/ambience/antag/bloodsuckeralert.ogg', 100, FALSE, pressure_affected = FALSE)
	antag_memory += "Although you were born a mortal, in undeath you earned the name <b>[fullname]</b>.<br>"

/datum/antagonist/bloodsucker/farewell()
	to_chat(owner.current, span_userdanger("<FONT size = 3>With a snap, your curse has ended. You are no longer a Bloodsucker. You live once more!</FONT>"))
	// Refill with Blood so they don't instantly die.
	if(ishuman(owner.current))
		var/mob/living/carbon/user = owner.current
		if(!LAZYFIND(user.dna.species.species_traits, NOBLOOD))
			owner.current.blood_volume = max(owner.current.blood_volume, BLOOD_VOLUME_NORMAL(owner.current))

// Called when using admin tools to give antag status, admin spawned bloodsuckers don't get turned human if plasmaman.
/datum/antagonist/bloodsucker/admin_add(datum/mind/new_owner, mob/admin)
	var/levels = input("How many unspent Ranks would you like [new_owner] to have?","Bloodsucker Rank", bloodsucker_level_unspent) as null | num
	var/msg = " made [key_name_admin(new_owner)] into \a [name]"
	if(levels > 1)
		bloodsucker_level_unspent = levels
		msg += " with [levels] extra unspent Ranks."
	message_admins("[key_name_admin(usr)][msg]")
	log_admin("[key_name(usr)][msg]")
	new_owner.add_antag_datum(src)

/datum/antagonist/bloodsucker/ui_data(mob/user)
	var/list/data = list()

	data["in_clan"] = !!my_clan
	var/list/clan_data = list()
	if(my_clan)
		clan_data["clan_name"] = my_clan.name
		clan_data["clan_description"] = my_clan.description
		clan_data["clan_icon"] = my_clan.join_icon_state

	data["clan"] += list(clan_data)

	return data

/datum/antagonist/bloodsucker/ui_static_data(mob/user)
	var/list/data = list()
	//we don't need to update this that much.
	for(var/datum/action/cooldown/bloodsucker/power as anything in powers)
		var/list/power_data = list()

		power_data["power_name"] = power.name
		power_data["power_explanation"] = power.power_explanation
		power_data["power_icon"] = power.button_icon_state

		data["power"] += list(power_data)

	return data + ..()

/datum/antagonist/bloodsucker/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/bloodsucker_icons),
	)

/datum/antagonist/bloodsucker/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("join_clan")
			assign_clan_and_bane()
			ui?.send_full_update(force = TRUE)
			return

/datum/antagonist/bloodsucker/roundend_report()
	var/list/report = list()

	// Vamp name
	report += "<br>[span_header("<b>\[[return_full_name(TRUE)]\]</b>")]</span>"
	report += printplayer(owner)
	if(my_clan)
		report += "They were part of the <b>[my_clan.name]</b>!"

	// Default Report
	var/objectives_complete = TRUE
	var/optional_objectives_complete = TRUE
	if(objectives.len)
		report += printobjectives(objectives)
		for(var/datum/objective/objective in objectives)
			if(objective.objective_name == "Optional Objective")
				if(!objective.check_completion())
					optional_objectives_complete = FALSE
				continue
			if(!objective.check_completion())
				objectives_complete = FALSE
				break

	// Now list their vassals
	if(vassals.len)
		report += span_header("Their Vassals were...")
		for(var/datum/antagonist/vassal/all_vassals as anything in vassals)
			if(!all_vassals.owner)
				continue
			var/list/vassal_report = list()
			vassal_report += "<b>[all_vassals.owner.name]</b>"

			if(all_vassals.owner.assigned_role)
				vassal_report += " the [all_vassals.owner.assigned_role]"
			if(IS_FAVORITE_VASSAL(all_vassals.owner.current))
				vassal_report += " and was the <b>Favorite Vassal</b>"
			else if(IS_REVENGE_VASSAL(all_vassals.owner.current))
				vassal_report += " and was the <b>Revenge Vassal</b>"
			report += vassal_report.Join()

	if(!LAZYLEN(objectives) || objectives_complete && optional_objectives_complete)
		report += span_greentext(span_big("The [name] was successful!"))
	else if(objectives_complete && !optional_objectives_complete)
		report += span_marooned("The [name] survived, but has not made a name for [owner.current.p_them()]self...")
	else
		report += span_redtext(span_big("The [name] has failed!"))
	report += get_flavor(objectives_complete, optional_objectives_complete)

	return report.Join("<br>")

/// Evaluates the conditions of the bloodsucker at the end of each round to pick a flavor message to add
/datum/antagonist/bloodsucker/proc/get_flavor(objectives_complete, optional_objectives_complete)
	var/list/flavor = list()
	var/flavor_message
	var/alive = owner?.current?.stat != DEAD //Technically not necessary because of Final Death objective?
	var/escaped = ((owner.current.onCentCom() || owner.current.onSyndieBase()) && alive)
	flavor += "<div><font color='#6d6dff'>Epilogue: </font>"
	var/message_color = "#ef2f3c"
	//i used pick() in case anyone wants to add more messages as time goes on
	if(objectives_complete && optional_objectives_complete && broke_masquerade && escaped)
		//finish all objectives, break masquerade, evac
		flavor_message += pick(list(
			"What matters of the Masquerade to you? Let it crumble into dust as your tyranny whips forward to dine on more stations. \
			News of your butchering exploits will quickly spread, and you know what will encompass the minds of mortals and undead alike. Fear."
		))
		message_color = "#008000"
	else if(objectives_complete && optional_objectives_complete && broke_masquerade && alive)
		//finish all objectives, break masquerade, don't evac
		flavor_message += pick(list(
			"Blood still pumps in your veins as you lay stranded on the station. No doubt the wake of chaos left in your path will attract danger, but greater power than you've ever felt courses through your body. \
			Let the Camarilla and the witchers come. You will be waiting."
		))
		message_color = "#008000"
	else if(objectives_complete && optional_objectives_complete && !broke_masquerade && escaped)
		//finish all objectives, don't break masquerade, escape
		flavor_message += pick(list(
			"You step off the spacecraft with a mark of pride at a superbly completed mission. Upon arriving back at CentCom, an unassuming assistant palms you an invitation stamped with the Camarilla seal. \
			High society awaits: a delicacy you have earned."
		))
		message_color = "#008000"
	else if(objectives_complete && optional_objectives_complete && !broke_masquerade && alive)
		//finish all objectives, don't break masquerade, don't escape
		flavor_message += pick(list(
			"This station has become your own slice of paradise. Your mission completed, you turn on the others who were stranded, ripe for your purposes. \
			Who knows? If they prove to elevate your power enough, perhaps a new bloodline might be founded here."
		))
		message_color = "#008000"
	else if(objectives_complete && !optional_objectives_complete && broke_masquerade && escaped)
		//finish primary objectives only, break masquerade, escape
		flavor_message += pick(list(
			"Your mission accomplished, you step off the spacecraft, feeling the mark of exile on your neck. Your allies gone, your veins thrum with a singular purpose: survival."
		))
		message_color = "#517fff"
	else if(objectives_complete && !optional_objectives_complete && broke_masquerade && alive)
		//finish primary objectives only, break masquerade, don't escape
		flavor_message += pick(list(
			"You survived, but you broke the Masquerade, your blood-stained presence clear and your power limited. No doubt death in the form of claw or stake hails its approach. Perhaps it's time to understand the cattles' fascinations with the suns."
		))
	else if(objectives_complete && !optional_objectives_complete && !broke_masquerade && escaped)
		//finish primary objectives only, don't break masquerade, escape
		flavor_message += pick(list(
			"A low profile has always suited you best, conspiring enough to satiate the clan and keep your head low. It's not luxorious living, though death is a less kind alternative. On to the next station."
		))
		message_color = "#517fff"
	else if(objectives_complete && !optional_objectives_complete && !broke_masquerade && alive)
		//finish primary objectives only, don't break masquerade, don't escape
		flavor_message += pick(list(
			"You completed your mission and kept your identity free of heresy, though your mark here is not strong enough to lay a claim. Best stow away when the next shuttle comes around."
		))
		message_color = "#517fff"
	else
		//perish or just fuck up and fail your primary objectives
		flavor_message += pick(list(
			"Thus ends the story of [return_full_name(TRUE)]. No doubt future generations will look back on your legacy and reflect on the lessons of the past. If they remember you at all."
		))
	flavor += "<font color=[message_color]>[flavor_message]</font></div>"
	return "<div>[flavor.Join("<br>")]</div>"

/**
 *	# Vampire Clan
 *
 *	This is used for dealing with the Vampire Clan.
 *	This handles Sol for Bloodsuckers, making sure to not have several.
 *	None of this should appear in game, we are using it JUST for Sol. All Bloodsuckers should have their individual report.
 */

///Ranks the Bloodsucker up, called by Sol.
/datum/antagonist/bloodsucker/proc/sol_rank_up(atom/source)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(RankUp))

///Called when Sol is near starting.
/datum/antagonist/bloodsucker/proc/sol_near_start(atom/source)
	SIGNAL_HANDLER
	if(bloodsucker_lair_area && !(locate(/datum/action/cooldown/bloodsucker/gohome) in powers))
		BuyPower(new /datum/action/cooldown/bloodsucker/gohome)
	if(my_clan?.get_clan() == CLAN_GANGREL && !(locate(/datum/action/cooldown/bloodsucker/gangrel/transform) in powers))
		BuyPower(new /datum/action/cooldown/bloodsucker/gangrel/transform)

///Called when Sol first ends.
/datum/antagonist/bloodsucker/proc/on_sol_end(atom/source)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(check_end_torpor))
	for(var/datum/action/cooldown/bloodsucker/power in powers)
		if(istype(power, /datum/action/cooldown/bloodsucker/gohome))
			RemovePower(power)
	if(altar_uses)
		to_chat(owner, span_boldnotice("Your Altar uses have been reset!"))
		altar_uses = 0

/// Buying powers
/datum/antagonist/bloodsucker/proc/BuyPower(datum/action/cooldown/bloodsucker/power)
	for(var/datum/action/cooldown/bloodsucker/current_powers as anything in powers)
		if(current_powers.type == power.type)
			return FALSE
	powers += power
	power.Grant(owner.current)
	return TRUE

/datum/antagonist/bloodsucker/proc/RemovePower(datum/action/cooldown/bloodsucker/power)
	if(power.active)
		power.DeactivatePower()
	powers -= power
	power.Remove(owner.current)

/datum/antagonist/bloodsucker/proc/give_starting_powers()
	for(var/datum/action/cooldown/bloodsucker/all_powers as anything in all_bloodsucker_powers)
		if(!(initial(all_powers.purchase_flags) & BLOODSUCKER_DEFAULT_POWER))
			continue
		BuyPower(new all_powers)

/datum/antagonist/bloodsucker/proc/assign_starting_stats()
	// Traits: Species
	var/mob/living/carbon/human/user = owner.current
	if(ishuman(owner.current))
		var/datum/species/user_species = user.dna.species
		user_species.species_traits += DRINKSBLOOD
		user.dna?.remove_all_mutations()
		user_species.punchdamagelow += 1 //lowest possible punch damage - 0
		user_species.punchdamagehigh += 1 //highest possible punch damage - 9
		user_species.punchstunthreshold += 1	//To not change rng knockdowns
	/// Give Bloodsucker Traits
	owner.current.add_traits(bloodsucker_traits, BLOODSUCKER_TRAIT)
	/// No Skittish "People" allowed
	if(HAS_TRAIT(owner.current, TRAIT_SKITTISH))
		REMOVE_TRAIT(owner.current, TRAIT_SKITTISH, ROUNDSTART_TRAIT)
	// Tongue & Language
	owner.current.grant_all_languages(FALSE, FALSE, TRUE)
	owner.current.grant_language(/datum/language/vampiric)
	/// Clear Disabilities & Organs
	heal_vampire_organs()

/**
 * ##clear_power_and_stats()
 *
 * Removes all Bloodsucker related Powers/Stats changes, setting them back to pre-Bloodsucker
 * Order of steps and reason why:
 * Remove clan - Clans like Nosferatu give Powers on removal, we have to make sure this is given before removing Powers.
 * Powers - Remove all Powers, so things like Masquerade are off.
 * Species traits, Traits, MaxHealth, Language - Misc stuff, has no priority.
 * Organs - At the bottom to ensure everything that changes them has reverted themselves already.
 * Update Sight - Done after Eyes are regenerated.
 */
/datum/antagonist/bloodsucker/proc/clear_powers_and_stats()
	// Remove clan first
	if(my_clan)
		QDEL_NULL(my_clan)
	// Powers
	for(var/datum/action/cooldown/bloodsucker/all_powers as anything in powers)
		RemovePower(all_powers)
	/// Stats
	if(ishuman(owner.current))
		var/mob/living/carbon/human/human_user = owner.current
		var/datum/species/user_species = human_user.dna.species
		user_species.species_traits -= DRINKSBLOOD
		// Clown
		if(istype(human_user) && owner.assigned_role == "Clown")
			human_user.dna.add_mutation(CLOWNMUT)
	// Remove all bloodsucker traits
	owner.current.remove_traits(bloodsucker_traits, BLOODSUCKER_TRAIT)
	// Update Health
	owner.current.setMaxHealth(initial(owner.current.maxHealth))
	// Language
	owner.current.remove_language(/datum/language/vampiric)
	// Heart & Eyes
	var/mob/living/carbon/user = owner.current
	var/obj/item/organ/heart/newheart = owner.current.getorganslot(ORGAN_SLOT_HEART)
	if(newheart)
		newheart.beating = initial(newheart.beating)
	var/obj/item/organ/eyes/user_eyes = user.getorganslot(ORGAN_SLOT_EYES)
	if(user_eyes)
		user_eyes.flash_protect = initial(user_eyes.flash_protect)
		user_eyes.sight_flags = initial(user_eyes.sight_flags)
		user_eyes.color_cutoffs = initial(user_eyes.color_cutoffs)
	user.update_sight()

/datum/antagonist/bloodsucker/proc/give_masquerade_infraction()
	if(broke_masquerade)
		return
	masquerade_infractions++
	if(masquerade_infractions >= 3)
		break_masquerade()
	else
		to_chat(owner.current, span_cultbold("You violated the Masquerade! Break the Masquerade [3 - masquerade_infractions] more times and you will become a criminal to the Bloodsucker's Cause!"))


/datum/antagonist/bloodsucker/proc/RankUp()
	if(!owner || !owner.current || IS_FAVORITE_VASSAL(owner.current))
		return
	bloodsucker_level_unspent++
	if(!my_clan)
		to_chat(owner.current, span_notice("You have gained a rank. Join a Clan to spend it."))
		return
	passive_blood_drain -= 0.03 * bloodsucker_level //do something. It's here because if you are gaining points through other means you are doing good
	// Spend Rank Immediately?
	if(!istype(owner.current.loc, /obj/structure/closet/crate/coffin))
		to_chat(owner, span_notice("<EM>You have grown more ancient! Sleep in a coffin that you have claimed to thicken your blood and become more powerful.</EM>"))
		if(bloodsucker_level_unspent >= 2)
			to_chat(owner, span_announce("Bloodsucker Tip: If you cannot find or steal a coffin to use, you can build one from wood or metal."))
		return
	SpendRank()

/datum/antagonist/bloodsucker/proc/RankDown()
	bloodsucker_level_unspent--

/datum/antagonist/bloodsucker/proc/remove_nondefault_powers(return_levels = FALSE)
	for(var/datum/action/cooldown/bloodsucker/power as anything in powers)
		if(istype(power, /datum/action/cooldown/bloodsucker/feed) || istype(power, /datum/action/cooldown/bloodsucker/masquerade) || istype(power, /datum/action/cooldown/bloodsucker/veil))
			continue
		RemovePower(power)
		if(return_levels)
			bloodsucker_level_unspent++

/datum/antagonist/bloodsucker/proc/LevelUpPowers()
	for(var/datum/action/cooldown/bloodsucker/power as anything in powers)
		power.level_current++
		power.UpdateDesc()

///Disables all powers, accounting for torpor
/datum/antagonist/bloodsucker/proc/DisableAllPowers(forced = FALSE)
	for(var/datum/action/cooldown/bloodsucker/power as anything in powers)
		if(forced || ((power.check_flags & BP_CANT_USE_IN_TORPOR) && HAS_TRAIT(owner.current, TRAIT_NODEATH)))
			if(power.active)
				power.DeactivatePower()

/datum/antagonist/bloodsucker/proc/SpendRank(mob/living/carbon/human/target, cost_rank = TRUE, blood_cost, ask = TRUE)
	if(!owner || !owner.current || !owner.current.client || (cost_rank && bloodsucker_level_unspent <= 0.5))
		return
	SEND_SIGNAL(src, BLOODSUCKER_RANK_UP, target, cost_rank, blood_cost, ask)

////////////////////////////////////////////////////////////////////////////////////////////////

/datum/antagonist/bloodsucker/proc/forge_bloodsucker_objectives()

	var/datum/objective/survive/bloodsucker/survive_objective = new
	survive_objective.owner = owner
	objectives += survive_objective

	var/datum/objective/bloodsucker_lair/lair_objective = new
	lair_objective.owner = owner
	objectives += lair_objective

	var/datum/objective/vassal/vassalize = new
	vassalize.owner = owner
	objectives += vassalize


/// Name shown on antag list
/datum/antagonist/bloodsucker/antag_listing_name()
	return ..() + "([return_full_name(TRUE)])"

/// Whatever interesting things happened to the antag admins should know about
/// Include additional information about antag in this part
/datum/antagonist/bloodsucker/antag_listing_status()
	if(owner && !considered_alive(owner))
		return "<font color=red>Final Death</font>"
	return ..()

/*
 *	# Bloodsucker Names
 *
 *	All Bloodsuckers get a name, and gets a better one when they hit Rank 4.
 */

/// Names
/datum/antagonist/bloodsucker/proc/SelectFirstName()
	if(owner.current.gender == MALE)
		bloodsucker_name = pick(
			"Desmond","Rudolph","Dracula","Vlad","Pyotr","Gregor",
			"Cristian","Christoff","Marcu","Andrei","Constantin",
			"Gheorghe","Grigore","Ilie","Iacob","Luca","Mihail","Pavel",
			"Vasile","Octavian","Sorin","Sveyn","Aurel","Alexe","Iustin",
			"Theodor","Dimitrie","Octav","Damien","Magnus","Caine","Abel", // Romanian/Ancient
			"Lucius","Gaius","Otho","Balbinus","Arcadius","Romanos","Alexios","Vitellius", // Latin
			"Melanthus","Teuthras","Orchamus","Amyntor","Axion", // Greek
			"Thoth","Thutmose","Osorkon,","Nofret","Minmotu","Khafra", // Egyptian
			"Dio",
		)
	else
		bloodsucker_name = pick(
			"Islana","Tyrra","Greganna","Pytra","Hilda",
			"Andra","Crina","Viorela","Viorica","Anemona",
			"Camelia","Narcisa","Sorina","Alessia","Sophia",
			"Gladda","Arcana","Morgan","Lasarra","Ioana","Elena",
			"Alina","Rodica","Teodora","Denisa","Mihaela",
			"Svetla","Stefania","Diyana","Kelssa","Lilith", // Romanian/Ancient
			"Alexia","Athanasia","Callista","Karena","Nephele","Scylla","Ursa", // Latin
			"Alcestis","Damaris","Elisavet","Khthonia","Teodora", // Greek
			"Nefret","Ankhesenpep", // Egyptian
		)

/datum/antagonist/bloodsucker/proc/SelectTitle(am_fledgling = 0, forced = FALSE)
	// Already have Title
	if(!forced && bloodsucker_title != null)
		return
	// Titles [Master]
	if(!am_fledgling)
		if(owner.current.gender == MALE)
			bloodsucker_title = pick ("Count","Baron","Viscount","Prince","Duke","Tzar","Dreadlord","Lord","Master")
		else
			bloodsucker_title = pick ("Countess","Baroness","Viscountess","Princess","Duchess","Tzarina","Dreadlady","Lady","Mistress")
		to_chat(owner, span_announce("You have earned a title! You are now known as <i>[return_full_name(TRUE)]</i>!"))
	// Titles [Fledgling]
	else
		bloodsucker_title = null

/datum/antagonist/bloodsucker/proc/SelectReputation(am_fledgling = FALSE, forced = FALSE)
	// Already have Reputation
	if(!forced && bloodsucker_reputation != null)
		return

	if(am_fledgling)
		bloodsucker_reputation = pick(
			"Crude","Callow","Unlearned","Neophyte","Novice","Unseasoned",
			"Fledgling","Young","Neonate","Scrapling","Untested","Unproven",
			"Unknown","Newly Risen","Born","Scavenger","Unknowing","Unspoiled",
			"Disgraced","Defrocked","Shamed","Meek","Timid","Broken","Fresh",
		)
	else if(owner.current.gender == MALE && prob(10))
		bloodsucker_reputation = pick("King of the Damned", "Blood King", "Emperor of Blades", "Sinlord", "God-King")
	else if(owner.current.gender == FEMALE && prob(10))
		bloodsucker_reputation = pick("Queen of the Damned", "Blood Queen", "Empress of Blades", "Sinlady", "God-Queen")
	else
		bloodsucker_reputation = pick(
			"Butcher","Blood Fiend","Crimson","Red","Black","Terror",
			"Nightman","Feared","Ravenous","Fiend","Malevolent","Wicked",
			"Ancient","Plaguebringer","Sinister","Forgotten","Wretched","Baleful",
			"Inqisitor","Harvester","Reviled","Robust","Betrayer","Destructor",
			"Damned","Accursed","Terrible","Vicious","Profane","Vile",
			"Depraved","Foul","Slayer","Manslayer","Sovereign","Slaughterer",
			"Forsaken","Mad","Dragon","Savage","Villainous","Nefarious",
			"Inquisitor","Marauder","Horrible","Immortal","Undying","Overlord",
			"Corrupt","Hellspawn","Tyrant","Sanguineous",
		)

	to_chat(owner, span_announce("You have earned a reputation! You are now known as <i>[return_full_name(TRUE)]</i>!"))


/datum/antagonist/bloodsucker/proc/AmFledgling()
	return !bloodsucker_title

/datum/antagonist/bloodsucker/proc/return_full_name(include_rep = FALSE)

	var/fullname
	// Name First
	fullname = (bloodsucker_name ? bloodsucker_name : owner.current.name)
	// Title
	if(bloodsucker_title)
		fullname = bloodsucker_title + " " + fullname
	// Rep
	if(include_rep && bloodsucker_reputation)
		fullname = fullname + " the " + bloodsucker_reputation

	return fullname

///When a Bloodsucker breaks the Masquerade, they get their HUD icon changed.
/datum/antagonist/bloodsucker/proc/break_masquerade()
	if(broke_masquerade)
		return
	owner.current.playsound_local(null, 'sound/effects/lunge_warn.ogg', 100, FALSE, pressure_affected = FALSE)
	to_chat(owner.current, span_cultboldtalic("You have broken the Masquerade!"))
	to_chat(owner.current, span_warning("Bloodsucker Tip: When you break the Masquerade, you become open for termination by fellow Bloodsuckers, and your Vassals are no longer completely loyal to you, as other Bloodsuckers can steal them for themselves!"))
	broke_masquerade = TRUE
	antag_hud_name = "masquerade_broken"
	add_team_hud(owner.current)
	SEND_GLOBAL_SIGNAL(COMSIG_BLOODSUCKER_BROKE_MASQUERADE)

///This is admin-only of reverting a broken masquerade.
/datum/antagonist/bloodsucker/proc/fix_masquerade()
	if(!broke_masquerade)
		return
	to_chat(owner.current, span_cultboldtalic("You have re-entered the Masquerade."))
	broke_masquerade = FALSE

/datum/antagonist/bloodsucker/get_preview_icon()
	var/icon/final_icon = render_preview_outfit(/datum/outfit/bloodsucker_outfit)
	final_icon.Blend(icon('icons/effects/blood.dmi', "uniformblood"), ICON_OVERLAY)

	return finish_preview_icon(final_icon)

/datum/outfit/bloodsucker_outfit
	name = "Bloodsucker outfit (Preview only)"
	suit = /obj/item/clothing/suit/dracula

/datum/outfit/bloodsucker_outfit/post_equip(mob/living/carbon/human/enrico, visualsOnly=FALSE)
	enrico.hair_style = "Undercut"
	enrico.hair_color = "FFF"
	enrico.skin_tone = "african2"

	enrico.update_body()
	enrico.update_hair()
