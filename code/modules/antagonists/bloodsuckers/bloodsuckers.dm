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
	count_towards_antag_cap = TRUE

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
	///If we are currently in a Frenzy
	var/frenzied = FALSE
	///If we have a task assigned
	var/has_task = FALSE
	///How many times have we used a blood altar
	var/altar_uses = 0

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
		TRAIT_RESISTDAMAGESLOWDOWN
	)

////////////////////////////////////////////////////////////////////////////////////
//--------------------------------------Gain--------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
///Called when you get the antag datum, called only ONCE per antagonist.
/datum/antagonist/bloodsucker/on_gain()
	RegisterSignal(SSsunlight, COMSIG_SOL_RANKUP_BLOODSUCKERS, PROC_REF(sol_rank_up))
	RegisterSignal(SSsunlight, COMSIG_SOL_NEAR_START, PROC_REF(sol_near_start))
	RegisterSignal(SSsunlight, COMSIG_SOL_END, PROC_REF(on_sol_end))
	RegisterSignal(SSsunlight, COMSIG_SOL_RISE_TICK, PROC_REF(handle_sol))
	RegisterSignal(SSsunlight, COMSIG_SOL_WARNING_GIVEN, PROC_REF(give_warning))

	RegisterSignal(owner, COMSIG_MIND_CHECK_ANTAG_RESOURCE, PROC_REF(has_blood))
	RegisterSignal(owner, COMSIG_MIND_SPEND_ANTAG_RESOURCE, PROC_REF(use_blood))

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
	ADD_TRAIT(current_mob, TRAIT_UNHOLY, type)

	if(current_mob.hud_used)
		on_hud_created()
	else
		RegisterSignal(current_mob, COMSIG_MOB_HUD_CREATED, PROC_REF(on_hud_created))
#ifdef BLOODSUCKER_TESTING
	var/turf/user_loc = get_turf(current_mob)
	new /obj/structure/closet/crate/coffin(user_loc)
	new /obj/structure/bloodsucker/vassalrack(user_loc)
#endif


////////////////////////////////////////////////////////////////////////////////////
//----------------------------------Hud Handling----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
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

////////////////////////////////////////////////////////////////////////////////////
//------------------------------------Removal-------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/// Called by the remove_antag_datum() and remove_all_antag_datums() mind procs for the antag datum to handle its own removal and deletion.
/datum/antagonist/bloodsucker/on_removal()
	/// End Sunlight? (if last Vamp)
	UnregisterSignal(SSsunlight, list(COMSIG_SOL_RANKUP_BLOODSUCKERS, COMSIG_SOL_NEAR_START, COMSIG_SOL_END, COMSIG_SOL_RISE_TICK, COMSIG_SOL_WARNING_GIVEN))
	UnregisterSignal(owner, list(COMSIG_MIND_CHECK_ANTAG_RESOURCE, COMSIG_MIND_SPEND_ANTAG_RESOURCE))
	clear_powers_and_stats()
	check_cancel_sunlight() //check if sunlight should end
	return ..()

/**
 * Remove innate effects is everything given to the mob
 * When a body is tranferred, this is called on the new mob
 * while on_removal is called ONCE per ANTAG, this is called ONCE per BODY.
 */

/datum/antagonist/bloodsucker/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current
	UnregisterSignal(current_mob, list(COMSIG_LIVING_LIFE, COMSIG_ATOM_EXAMINE, COMSIG_LIVING_DEATH))
	REMOVE_TRAIT(current_mob, TRAIT_UNHOLY, type)

	if(current_mob.hud_used)
		var/datum/hud/hud_used = current_mob.hud_used

		hud_used.infodisplay -= blood_display
		hud_used.infodisplay -= vamprank_display
		hud_used.infodisplay -= sunlight_display

		QDEL_NULL(blood_display)
		QDEL_NULL(vamprank_display)
		QDEL_NULL(sunlight_display)

////////////////////////////////////////////////////////////////////////////////////
//------------------------------Greet and farewell--------------------------------//
////////////////////////////////////////////////////////////////////////////////////
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

////////////////////////////////////////////////////////////////////////////////////
//-----------------------------------Ability use----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/bloodsucker/proc/has_blood(datum/mind, flag = ANTAG_RESOURCE_BLOODSUCKER, amt)
	SIGNAL_HANDLER
	if(flag != ANTAG_RESOURCE_BLOODSUCKER)
		return FALSE
	return bloodsucker_blood_volume >= amt

/datum/antagonist/bloodsucker/proc/use_psi(datum/mind, list/resource_costs)
	SIGNAL_HANDLER
	if(!LAZYLEN(resource_costs))
		return
	var/amount = resource_costs[ANTAG_RESOURCE_BLOODSUCKER]
	if(!amount)
		return
	if(!has_blood(amt = amount))
		return
	bloodsucker_blood_volume -= amount
	update_hud()
	return TRUE
////////////////////////////////////////////////////////////////////////////////////
//--------------------------------Admin Tools-------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
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

/datum/antagonist/bloodsucker/get_admin_commands()
	. = ..()
	.["Give Level"] = CALLBACK(src, PROC_REF(RankUp))
	if(bloodsucker_level_unspent >= 1)
		.["Remove Level"] = CALLBACK(src, PROC_REF(RankDown))

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

/datum/antagonist/bloodsucker/proc/assign_clan_and_bane()
	if(my_clan)	
		return
	var/list/options = list()
	var/list/radial_display = list()
	for(var/datum/bloodsucker_clan/all_clans as anything in typesof(/datum/bloodsucker_clan))
		if(!initial(all_clans.joinable_clan)) //flavortext only
			continue
		options[initial(all_clans.name)] = all_clans
		var/datum/radial_menu_choice/option = new
		option.image = image(icon = initial(all_clans.join_icon), icon_state = initial(all_clans.join_icon_state))
		option.info = "[initial(all_clans.name)] - [span_boldnotice(initial(all_clans.join_description))]"
		radial_display[initial(all_clans.name)] = option

	var/chosen_clan = show_radial_menu(owner.current, owner.current, radial_display)
	chosen_clan = options[chosen_clan]
	if(QDELETED(src) || QDELETED(owner.current))
		return FALSE
	if(!chosen_clan)
		to_chat(owner, span_announce("You choose to remain ignorant, for now."))
		return
	my_clan = new chosen_clan(src)
	owner.announce_objectives()


////////////////////////////////////////////////////////////////////////////////////
//-------------------------------Bloodsucker UI-----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/bloodsucker/ui_static_data(mob/user)
	var/list/data = list()
	//we don't need to update this that much.
	// for(var/datum/action/cooldown/bloodsucker/power as anything in powers)
	// 	var/list/power_data = list()

	// 	power_data["power_name"] = power.name
	// 	power_data["power_explanation"] = power.power_explanation
	// 	power_data["power_icon"] = power.button_icon_state

	// 	data["power"] += list(power_data)

	return data + ..()

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

/datum/antagonist/bloodsucker/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("join_clan")
			assign_clan_and_bane()
			ui?.send_full_update(force = TRUE)
			return

/datum/antagonist/bloodsucker/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/bloodsucker_icons),
	)

////////////////////////////////////////////////////////////////////////////////////
//------------------------------Roundend report-----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
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

////////////////////////////////////////////////////////////////////////////////////
//--------------------------------Credits flavour---------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/// Evaluates the conditions of the bloodsucker at the end of each round to pick a flavor message to add
/datum/antagonist/bloodsucker/proc/get_flavor(objectives_complete, optional_objectives_complete)
	var/list/flavor = list()
	var/flavor_message
	var/alive = owner?.current?.stat != DEAD //Technically not necessary because of Final Death objective?
	var/escaped = ((owner.current.onCentCom() || owner.current.onSyndieBase()) && alive)
	flavor += "<div><font color='#6d6dff'>Epilogue: </font>"
	var/message_color = "#ef2f3c"

	flavor_message += "flavour texts are a work in progress, stay tuned."
	// if(objectives_complete)
	// 	if(optional_objectives_complete)
	// 		message_color = "#008000"
	// 		if(broke_masquerade)
	// 			if(escaped)
	// 				flavor_message += pick(list(
	// 					"What matters of the Masquerade to you? Let it crumble into dust as your tyranny whips forward to dine on more stations. \
	// 					News of your butchering exploits will quickly spread, and you know what will encompass the minds of mortals and undead alike. Fear."
	// 				))
	// 			else if(alive)
	// 				flavor_message += pick(list(
	// 					"Blood still pumps in your veins as you lay stranded on the station. No doubt the wake of chaos left in your path will attract danger, but greater power than you've ever felt courses through your body. \
	// 					Let the Camarilla and the witchers come. You will be waiting."
	// 				))
	// 		else
	// 			if(escaped)
	// 				flavor_message += pick(list(
	// 					"You step off the spacecraft with a mark of pride at a superbly completed mission. Upon arriving back at CentCom, an unassuming assistant palms you an invitation stamped with the Camarilla seal. \
	// 					High society awaits: a delicacy you have earned."
	// 				))
	// 			else if(alive)
	// 				flavor_message += pick(list(
	// 					"This station has become your own slice of paradise. Your mission completed, you turn on the others who were stranded, ripe for your purposes. \
	// 					Who knows? If they prove to elevate your power enough, perhaps a new bloodline might be founded here."
	// 				))
	// 	else
	// 		message_color = "#517fff"
	// 		if(broke_masquerade)
	// 			if(escaped)
	// 				flavor_message += pick(list(
	// 					"Your mission accomplished, you step off the spacecraft, feeling the mark of exile on your neck. Your allies gone, your veins thrum with a singular purpose: survival."
	// 				))
	// 			else if(alive)
	// 				flavor_message += pick(list(
	// 					"You survived, but you broke the Masquerade, your blood-stained presence clear and your power limited. No doubt death in the form of claw or stake hails its approach. Perhaps it's time to understand the cattles' fascinations with the suns."
	// 				))
	// 		else
	// 			if(escaped)
	// 				flavor_message += pick(list(
	// 					"A low profile has always suited you best, conspiring enough to satiate the clan and keep your head low. It's not luxorious living, though death is a less kind alternative. On to the next station."
	// 				))
	// 			else if(alive)
	// 				flavor_message += pick(list(
	// 					"You completed your mission and kept your identity free of heresy, though your mark here is not strong enough to lay a claim. Best stow away when the next shuttle comes around."
	// 				))

	if(!message_color || (!alive && !escaped)) //perish or just fuck up and fail your primary objectives
		message_color = "#ef2f3c"
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
	// if(bloodsucker_lair_area && !(locate(/datum/action/cooldown/bloodsucker/gohome) in powers))
	// 	BuyPower(new /datum/action/cooldown/bloodsucker/gohome)
	// if(my_clan?.get_clan() == CLAN_GANGREL && !(locate(/datum/action/cooldown/bloodsucker/gangrel/transform) in powers))
	// 	BuyPower(new /datum/action/cooldown/bloodsucker/gangrel/transform)

///Called when Sol first ends.
/datum/antagonist/bloodsucker/proc/on_sol_end(atom/source)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(check_end_torpor))
	// for(var/datum/action/cooldown/bloodsucker/power in powers)
	// 	if(istype(power, /datum/action/cooldown/bloodsucker/gohome))
	// 		RemovePower(power)
	if(altar_uses)
		to_chat(owner, span_boldnotice("Your Altar uses have been reset!"))
		altar_uses = 0

/// Buying powers
// /datum/antagonist/bloodsucker/proc/BuyPower(datum/action/cooldown/bloodsucker/power)
// 	for(var/datum/action/cooldown/bloodsucker/current_powers as anything in powers)
// 		if(current_powers.type == power.type)
// 			return FALSE
// 	powers += power
// 	power.Grant(owner.current)
// 	return TRUE

// /datum/antagonist/bloodsucker/proc/RemovePower(datum/action/cooldown/bloodsucker/power)
// 	if(power.active)
// 		power.DeactivatePower()
// 	powers -= power
// 	power.Remove(owner.current)

// /datum/antagonist/bloodsucker/proc/give_starting_powers()
// 	for(var/datum/action/cooldown/bloodsucker/all_powers as anything in all_bloodsucker_powers)
// 		if(!(initial(all_powers.purchase_flags) & BLOODSUCKER_DEFAULT_POWER))
// 			continue
// 		BuyPower(new all_powers)


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


// /datum/asset/simple/bloodsucker_icons

// /datum/asset/simple/bloodsucker_icons/register()
// 	for(var/datum/bloodsucker_clan/clans as anything in typesof(/datum/bloodsucker_clan))
// 		if(!initial(clans.joinable_clan))
// 			continue
// 		add_bloodsucker_icon(initial(clans.join_icon), initial(clans.join_icon_state))

// 	for(var/datum/action/cooldown/bloodsucker/power as anything in subtypesof(/datum/action/cooldown/bloodsucker))
// 		add_bloodsucker_icon(initial(power.button_icon), initial(power.button_icon_state))

// 	return ..()

// /datum/asset/simple/bloodsucker_icons/proc/add_bloodsucker_icon(bloodsucker_icon, bloodsucker_icon_state)
// 	assets[sanitize_filename("bloodsucker.[bloodsucker_icon_state].png")] = icon(bloodsucker_icon, bloodsucker_icon_state)
