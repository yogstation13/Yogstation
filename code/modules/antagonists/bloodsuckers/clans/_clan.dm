/**
 * Bloodsucker clans
 *
 * Handles everything related to clans.
 * the entire idea of datumizing this came to me in a dream.
 */
/datum/bloodsucker_clan
	///The bloodsucker datum that owns this clan. Use this over 'source', because while it's the same thing, this is more consistent (and used for deletion).
	var/datum/antagonist/bloodsucker/bloodsuckerdatum
	///The name of the clan we're in.
	var/name = CLAN_CAITIFF
	///Description of what the clan is, given when joining and through your antag UI.
	var/description = "The Caitiff is as basic as you can get with Bloodsuckers. \n\
		Entirely Clan-less, they are blissfully unaware of who they really are. \n\
		No additional abilities is gained, nothing is lost, if you want a plain Bloodsucker, this is it. \n\
		The Favorite Vassal will gain the Brawn ability, to help in combat."
	///Whether the clan can be joined by players. FALSE for flavortext-only clans.
	var/joinable_clan = TRUE
	///Description shown when trying to join the clan.
	var/join_description = "The default, Classic Bloodsucker."

	///The icon of the radial icon to join this clan.
	var/join_icon = 'icons/mob/bloodsucker_clan_icons.dmi'
	///Same as join_icon, but the state
	var/join_icon_state = "caitiff"

	var/max_vassals = 1

	///The clan objective that is required to greentext.
	var/datum/objective/clan_objective
	
	///The clan's manipulation specialty. for the sake of crafting
	var/control_type = BLOODSUCKER_CONTROL_BLOOD
	///How we will drink blood using Feed.
	var/blood_drink_type = BLOODSUCKER_DRINK_NORMAL

	///Abilities our clan will start with. Granted to the owning bloodsucker on initialization
	var/list/datum/bloodsucker_power/starting_abilities = list()
	///Abilities the bloodsucker has learned
	var/list/datum/bloodsucker_power/learned_abilities = list()

//////////////////////////////////////////////////////////////////////////
//------------------------New clan is created---------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/bloodsucker_clan/New(datum/antagonist/bloodsucker/owner_datum)
	. = ..()
	src.bloodsuckerdatum = owner_datum

	RegisterSignal(bloodsuckerdatum, COMSIG_BLOODSUCKER_ON_LIFETICK, PROC_REF(handle_clan_life))
	RegisterSignal(bloodsuckerdatum, BLOODSUCKER_TRIGGER_FRENZY, PROC_REF(handle_clan_frenzy))
	//RegisterSignal(bloodsuckerdatum, BLOODSUCKER_RANK_UP, PROC_REF(on_spend_rank))

	// RegisterSignal(bloodsuckerdatum, BLOODSUCKER_PRE_MAKE_FAVORITE, PROC_REF(on_offer_favorite))
	// RegisterSignal(bloodsuckerdatum, BLOODSUCKER_MAKE_FAVORITE, PROC_REF(on_favorite_vassal))

	RegisterSignal(bloodsuckerdatum, BLOODSUCKER_MADE_VASSAL, PROC_REF(on_vassal_made))
	RegisterSignal(bloodsuckerdatum, BLOODSUCKER_FINAL_DEATH, PROC_REF(on_final_death))

	give_clan_objective()

//////////////////////////////////////////////////////////////////////////
//---------------------------Clan is destroyed--------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/bloodsucker_clan/Destroy(force)
	UnregisterSignal(bloodsuckerdatum, list(
		COMSIG_BLOODSUCKER_ON_LIFETICK,
		BLOODSUCKER_TRIGGER_FRENZY,
		BLOODSUCKER_RANK_UP,
		// BLOODSUCKER_PRE_MAKE_FAVORITE,
		// BLOODSUCKER_MAKE_FAVORITE,
		BLOODSUCKER_MADE_VASSAL,
		BLOODSUCKER_FINAL_DEATH,
	))
	remove_clan_objective()
	bloodsuckerdatum = null
	return ..()

/datum/bloodsucker_clan/proc/give_clan_objective()
	if(isnull(clan_objective))
		return
	clan_objective = new clan_objective()
	clan_objective.objective_name = "Clan Objective"
	clan_objective.owner = bloodsuckerdatum.owner
	bloodsuckerdatum.objectives += clan_objective
	bloodsuckerdatum.owner.announce_objectives()

/datum/bloodsucker_clan/proc/remove_clan_objective()
	bloodsuckerdatum.objectives -= clan_objective
	QDEL_NULL(clan_objective)
	bloodsuckerdatum.owner.announce_objectives()


//////////////////////////////////////////////////////////////////////////
//----------------------------Ability handler---------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/bloodsucker_clan/proc/get_purchasable_abilities()
	var/list/datum/bloodsucker_power/available_abilities = list()
	for(var/datum/bloodsucker_power/ability as anything in GLOB.all_bloodsucker_powers)
		if(locate(ability.type) in learned_abilities)
			continue
		if(!(name in ability.clans_purchasable))
			continue
		available_abilities += ability
	return available_abilities

/datum/bloodsucker_clan/proc/gain_power(atom/source, datum/bloodsucker_power/power_typepath, silent = FALSE)
	var/owner = bloodsuckerdatum.owner
	if(!ispath(power_typepath))
		CRASH("[owner] tried to gain [power_typepath] which is not a valid darkspawn ability")
	if(locate(power_typepath) in learned_abilities)
		return

	var/datum/bloodsucker_power/new_power = new power_typepath()
	if((name in new_power.clans_purchasable) && new_power.on_purchase(owner, silent))
		learned_abilities += new_power
	else
		qdel(new_power)

/datum/bloodsucker_clan/proc/full_refund()
	for(var/i in learned_abilities)
		lose_power(i, TRUE)

/datum/bloodsucker_clan/proc/lose_power(datum/bloodsucker_power/power, refund = FALSE)
	if(!locate(power) in learned_abilities)
		CRASH("[bloodsuckerdatum.owner] tried to lose [power] which they haven't learned")
	
	learned_abilities -= power
	power.remove(refund)


/**
 * Called when a Bloodsucker enters Final Death
 * args:
 * source - the Bloodsucker exiting Torpor
 */
/datum/bloodsucker_clan/proc/on_final_death(datum/antagonist/bloodsucker/source)
	SIGNAL_HANDLER
	return FALSE

/**
 * Called during Bloodsucker's LifeTick
 * args:
 * bloodsuckerdatum - the antagonist datum of the Bloodsucker running this.
 */
/datum/bloodsucker_clan/proc/handle_clan_life(datum/antagonist/bloodsucker/source)
	SIGNAL_HANDLER


/**
 * Called during Bloodsucker's LifeTick
 * args:
 * bloodsuckerdatum - the antagonist datum of the Bloodsucker running this.
 */
/datum/bloodsucker_clan/proc/handle_clan_frenzy(datum/antagonist/bloodsucker/source)
	SIGNAL_HANDLER

/**
 * Called when a Bloodsucker successfully Vassalizes someone.
 * args:
 * bloodsuckerdatum - the antagonist datum of the Bloodsucker running this.
 */
/datum/bloodsucker_clan/proc/on_vassal_made(datum/antagonist/bloodsucker/source, mob/living/user, mob/living/target)
	SIGNAL_HANDLER
	user.playsound_local(null, 'sound/effects/explosion_distant.ogg', 40, TRUE)
	target.playsound_local(null, 'sound/effects/singlebeat.ogg', 40, TRUE)
	target.do_jitter_animation(15)
	INVOKE_ASYNC(target, TYPE_PROC_REF(/mob, emote), "laugh")


/**
 * Called when we are trying to turn someone into a Favorite Vassal
 * args:
 * bloodsuckerdatum - the antagonist datum of the Bloodsucker performing this.
 * vassaldatum - the antagonist datum of the Vassal being offered up.
 */
// /datum/bloodsucker_clan/proc/on_offer_favorite(datum/antagonist/bloodsucker/source, datum/antagonist/vassal/vassaldatum)
// 	SIGNAL_HANDLER

// 	INVOKE_ASYNC(src, PROC_REF(offer_favorite), bloodsuckerdatum, vassaldatum)

// /datum/bloodsucker_clan/proc/offer_favorite(datum/antagonist/bloodsucker/source, datum/antagonist/vassal/vassaldatum)
// 	if(vassaldatum.special_type)
// 		to_chat(bloodsuckerdatum.owner.current, span_notice("This Vassal was already assigned a special position."))
// 		return FALSE
// 	if(!vassaldatum.owner.can_make_special(creator = bloodsuckerdatum.owner))
// 		to_chat(bloodsuckerdatum.owner.current, span_notice("This Vassal is unable to gain a Special rank due to innate features."))
// 		return FALSE

// 	var/list/options = list()
// 	var/list/radial_display = list()
// 	for(var/datum/antagonist/vassal/vassaldatums as anything in subtypesof(/datum/antagonist/vassal))
// 		if(bloodsuckerdatum.special_vassals[initial(vassaldatums.special_type)])
// 			continue
// 		options[initial(vassaldatums.name)] = vassaldatums

// 		var/datum/radial_menu_choice/option = new
// 		option.image = image(icon = initial(vassaldatums.hud_icon), icon_state = initial(vassaldatums.antag_hud_name))
// 		option.info = "[initial(vassaldatums.name)] - [span_boldnotice(initial(vassaldatums.vassal_description))]"
// 		radial_display[initial(vassaldatums.name)] = option

// 	if(!options.len)
// 		return

// 	to_chat(bloodsuckerdatum.owner.current, span_notice("You can change who this Vassal is, who are they to you?"))
// 	var/vassal_response = show_radial_menu(bloodsuckerdatum.owner.current, vassaldatum.owner.current, radial_display)
// 	if(!vassal_response)
// 		return
// 	vassal_response = options[vassal_response]
// 	if(QDELETED(src) || QDELETED(bloodsuckerdatum.owner.current) || QDELETED(vassaldatum.owner.current))
// 		return FALSE
// 	vassaldatum.make_special(vassal_response)
// 	bloodsuckerdatum.bloodsucker_blood_volume -= 150

// /**
//  * Called when we are successfully turn a Vassal into a Favorite Vassal
//  * args:
//  * bloodsuckerdatum - antagonist datum of the Bloodsucker who turned them into a Vassal.
//  * vassaldatum - the antagonist datum of the Vassal being offered up.
//  */
// /datum/bloodsucker_clan/proc/on_favorite_vassal(datum/antagonist/bloodsucker/source, datum/antagonist/vassal/vassaldatum)
// 	SIGNAL_HANDLER
// 	//vassaldatum.BuyPower(new /datum/action/cooldown/bloodsucker/targeted/brawn)
