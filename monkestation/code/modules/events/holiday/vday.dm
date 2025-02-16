// Valentine's Day events //
// why are you playing spessmens on valentine's day you wizard //

//Assoc list
// Key: Sender
// Value: Receiever
GLOBAL_LIST(valentine_mobs)

#define VALENTINE_FILE "valentines.json"

// valentine / candy heart distribution //

/datum/round_event_control/valentines
	name = "Valentines!"
	holidayID = VALENTINES
	typepath = /datum/round_event/valentines
	weight = -1 //forces it to be called, regardless of weight
	max_occurrences = 1
	earliest_start = 0 MINUTES
	category = EVENT_CATEGORY_HOLIDAY
	description = "Puts people on dates! They must protect each other. \
		Some dates will have third wheels, and any odd ones out will be given the role of 'heartbreaker'."
	/// If TRUE, any odd candidate out will be given the role of "heartbreaker" and will be tasked with ruining the dates.
	var/heartbreaker = TRUE
	/// Probability that any given pair will be given a third wheel candidate
	var/third_wheel_chance = 4

/datum/round_event/valentines/proc/forge_third_wheel(mob/living/sad_one, mob/living/date_one, mob/living/date_two)
	var/datum/antagonist/valentine/third_wheel/third_wheel = new()
	third_wheel.date = pick(date_one.mind, date_two.mind)
	sad_one.mind.special_role = "valentine"
	sad_one.mind.add_antag_datum(third_wheel)

/datum/round_event/valentines
	end_when = 300 // this is seconds

/datum/round_event/valentines/start()
	LAZYINITLIST(GLOB.valentine_mobs)
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(!is_valid_valentine(player))
			continue
		var/obj/item/paper/valentine/card = new(player.drop_location())
		var/static/list/slots = list(
			LOCATION_LPOCKET = ITEM_SLOT_LPOCKET,
			LOCATION_RPOCKET = ITEM_SLOT_RPOCKET,
			LOCATION_BACKPACK = ITEM_SLOT_BACKPACK,
			LOCATION_HANDS = ITEM_SLOT_HANDS
		)
		var/where = player.equip_in_one_of_slots(card, slots, FALSE) || "at your feet"
		to_chat(player, span_notice(span_slightly_larger("A message appears [where], it looks like it has space to write somebody's name on it!")))

/datum/round_event/valentines/end()
	// Remove all the date candidates, anyone who got a mutual date now has the antag datum
	LAZYNULL(GLOB.valentine_mobs)

	var/datum/round_event_control/valentines/controller = control
	if(!istype(controller))
		return

	var/list/candidates = list()
	for(var/mob/living/player in GLOB.player_list)
		if(!is_valid_valentine(player))
			continue
		candidates += player

	var/list/mob/living/candidates_pruned = SSpolling.poll_candidates(
		question = "Do you want a Valentine?",
		group = candidates,
		poll_time = 30 SECONDS,
		flash_window = FALSE,
		start_signed_up = TRUE,
		alert_pic = /obj/item/storage/fancy/heart_box,
		role_name_text = "Valentine",
		custom_response_messages = list(
			POLL_RESPONSE_SIGNUP = "You have signed up for a date!",
			POLL_RESPONSE_ALREADY_SIGNED = "You are already signed up for a date.",
			POLL_RESPONSE_NOT_SIGNED = "You aren't signed up for a date.",
			POLL_RESPONSE_TOO_LATE_TO_UNREGISTER = "It's too late to decide against going on a date.",
			POLL_RESPONSE_UNREGISTERED = "You decide against going on a date.",
		),
		chat_text_border_icon = /obj/item/storage/fancy/heart_box,
		show_candidate_amount = FALSE,
	)

	for(var/mob/living/second_check as anything in candidates_pruned)
		if(!is_valid_valentine(second_check))
			candidates_pruned -= second_check

	if(length(candidates_pruned) == 0)
		return
	if(length(candidates_pruned) == 1)
		to_chat(candidates_pruned[1], span_warning("You are the only one who wanted a Valentine..."))
		return

	while(length(candidates_pruned) >= 2)
		var/mob/living/date_one = pick_n_take(candidates_pruned)
		var/mob/living/date_two = pick_n_take(candidates_pruned)
		give_valentines_things(date_one)
		give_valentines_things(date_two)
		forge_valentines_objective(date_one, date_two)
		forge_valentines_objective(date_two, date_one)

		if((length(candidates_pruned) == 1 && !controller.heartbreaker) || (length(candidates_pruned) && prob(controller.third_wheel_chance)))
			var/mob/living/third_wheel = pick_n_take(candidates_pruned)
			give_valentines_things(third_wheel)
			forge_third_wheel(third_wheel, date_one, date_two)
			// Third wheel starts with a bouquet because that's funny
			var/third_wheel_bouquet = pick(typesof(/obj/item/bouquet))
			var/obj/item/bouquet = new third_wheel_bouquet(third_wheel.drop_location())
			third_wheel.put_in_hands(bouquet)

	if(controller.heartbreaker && length(candidates_pruned) == 1)
		candidates_pruned[1].mind.add_antag_datum(/datum/antagonist/heartbreaker)

/datum/round_event/valentines/announce(fake)
	priority_announce("It's Valentine's Day! Give a valentine to that special someone! You've all received complimentary Valentine's cards to send to your potential dates! \
	Anyone who doesn't pick their date will be given a chance to be assigned one shortly.", sound = SSstation.announcer.get_rand_alert_sound())

/obj/item/paper/valentine
	name = "valentine"
	desc = "A Valentine's card! Wonder what it says..."
	icon = 'icons/obj/toys/playing_cards.dmi'
	icon_state = "sc_Ace of Hearts_syndicate" // shut up // bye felicia
	show_written_words = FALSE
	var/used = FALSE
	var/datum/action/item_action/valentine/write_action

/obj/item/paper/valentine/Initialize(mapload)
	default_raw_text = pick_list(VALENTINE_FILE, "valentines") || "A generic message of love or whatever."
	if(!mapload)
		write_action = add_item_action(/datum/action/item_action/valentine)
	return ..()

/obj/item/paper/valentine/examine(mob/user)
	. = ..()
	if(write_action)
		. += span_boldnotice("You could perhaps send this valentine's card to someone!")

/obj/item/paper/valentine/proc/mark_as_used()
	used = TRUE
	remove_item_action(write_action)

/obj/item/paper/valentine/ui_action_click(mob/user, actiontype)
	if(user.mind?.has_antag_datum(/datum/antagonist/valentine))
		to_chat(user, span_warning("You already have a valentine!"))
		return
	if(isnull(GLOB.valentine_mobs))
		to_chat(user, span_warning("You feel regret... It's too late now."))
		mark_as_used()
		return
	if(used)
		return
	var/turf/user_turf = get_turf(user)
	if(!user_turf)
		to_chat(user, span_warning("You stop and look around for a moment. Where the hell are you?"))
		return
	var/list/mob_names = list()
	for(var/mob/living/carbon/human/candidate in GLOB.player_list)
		if(candidate == user || !is_valid_valentine(candidate))
			continue
		// if their jobs have the same faction, we shouldn't really care about z-levels (to avoid issues with miners and explorers)
		if(user.mind?.assigned_role?.faction != candidate.mind?.assigned_role?.faction)
			var/turf/candidate_turf = get_turf(candidate)
			if(!candidate_turf)
				continue
			if(!are_zs_connected(user_turf, candidate_turf))
				continue
		mob_names["[candidate.mind.name || candidate.real_name]"] = candidate
	if(!length(mob_names))
		to_chat(user, span_warning("There's no one for you to love..."))
		return
	// Pick names
	var/picked_name = tgui_input_list(user, "Who are you sending it to?", "Valentines Card", mob_names)
	var/mob/living/carbon/human/picked_human = mob_names[picked_name]
	if(!ishuman(picked_human) || !is_valid_valentine(picked_human))
		to_chat(user, span_notice("Nothing happens... I don't think it worked."))
		return
	if(isnull(GLOB.valentine_mobs))
		to_chat(user, span_warning("You feel regret... It's too late now."))
		mark_as_used()
		return
	if(used)
		to_chat(user, span_warning("The card has already been used!"))
		return
	to_chat(user, span_notice("The card vanishes out of your hand! Lets hope [picked_human.p_they()] got it..."))
	GLOB.valentine_mobs[user] = picked_human
	if(GLOB.valentine_mobs[picked_human] == user)
		// they picked each other, so now they get to go on a date
		forge_valentines_objective(user, picked_human)
		forge_valentines_objective(picked_human, user)
		give_valentines_things(user)
		give_valentines_things(picked_human)
	// Create a new card to prevent exploiting
	var/obj/item/paper/valentine/new_card = copy(/obj/item/paper/valentine, picked_human.drop_location())
	new_card.name = "valentines card from [user.mind.name || user.real_name]"
	new_card.desc = "A Valentine's card! It is addressed to [picked_name]."
	new_card.mark_as_used()
	var/static/list/slots = list(
		LOCATION_BACKPACK = ITEM_SLOT_BACKPACK,
		LOCATION_LPOCKET = ITEM_SLOT_LPOCKET,
		LOCATION_RPOCKET = ITEM_SLOT_RPOCKET,
	)
	var/where = picked_human.equip_in_one_of_slots(new_card, slots, FALSE)
	if(!where)
		if(picked_human.put_in_inactive_hand(new_card)) // only try to put in inactive hand to prevent potential exploits with blocking someone from punching mid-fight or something
			where = "in your hand"
		else
			where = "at your feet"
	to_chat(picked_human, span_notice(span_slightly_larger("A magical card suddenly appears [where]!")))
	qdel(src)

/datum/action/item_action/valentine
	name = "Write Valentine's Card"
	desc = "Write someone's name on the valentine's card and send it to them!"

/obj/item/food/candyheart
	name = "candy heart"
	icon = 'icons/obj/holiday/holiday_misc.dmi'
	icon_state = "candyheart"
	desc = "A heart-shaped candy that reads: "
	food_reagents = list(/datum/reagent/consumable/sugar = 2)
	junkiness = 5

/obj/item/food/candyheart/Initialize(mapload)
	. = ..()
	desc = pick(strings(VALENTINE_FILE, "candyhearts"))
	icon_state = pick("candyheart", "candyheart2", "candyheart3", "candyheart4")

/proc/is_valid_valentine(mob/living/target)
	if(QDELETED(target))
		return FALSE
	if(target.stat == DEAD)
		return FALSE
	if(isnull(target.mind))
		return FALSE
	if(istype(target.loc, /obj/machinery/cryopod))
		return FALSE
	if(HAS_TRAIT(target, TRAIT_TEMPORARY_BODY))
		return FALSE
	if(istype(target, /mob/living/carbon/human/ghost) || isdummy(target)) // these should never be valid targets anyways, but let's make 100% sure
		return FALSE
	if(target.onCentCom())
		return FALSE
	if(target.mind.has_antag_datum(/datum/antagonist/valentine))
		return FALSE
	return TRUE

/proc/forge_valentines_objective(mob/living/lover, mob/living/date)
	var/datum/antagonist/valentine/valentine = new
	valentine.date = date.mind
	lover.mind.special_role = "valentine"
	lover.mind.add_antag_datum(valentine) //These really should be teams but i can't be assed to incorporate third wheels right now

/proc/give_valentines_things(mob/living/target)
	/// Items to give to all valentines
	var/static/list/items_to_give_out = list(
		/obj/item/storage/fancy/heart_box,
		/obj/item/food/candyheart,
	)

	var/obj/item/storage/backpack/bag = locate() in target.contents
	if(QDELETED(bag))
		return

	var/atom/drop_loc = target.drop_location()
	for(var/thing_type in items_to_give_out)
		var/obj/item/thing = new thing_type(drop_loc)
		if(!bag.atom_storage.attempt_insert(thing, override = TRUE, force = STORAGE_SOFT_LOCKED))
			target.put_in_hands(thing)

#undef VALENTINE_FILE
