/mob/living/basic/pet/potty
	name = "\proper craig the potted plant"
	desc = "A potted plant."

	icon = 'monkestation/code/modules/botany/icons/potty.dmi'
	icon_state = "potty"
	icon_living = "potty_living"
	icon_dead = "potty_dead"

	dexterous = TRUE
	held_items = list(null, null)

	ai_controller = /datum/ai_controller/basic_controller/craig

	/// Instructions you can give to dogs
	var/static/list/pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/craig_harvest,
		/datum/pet_command/free,
		/datum/pet_command/good_boy/dog,
		/datum/pet_command/follow/dog,
		/datum/pet_command/point_targeting/attack/dog,
		/datum/pet_command/point_targeting/fetch,
		/datum/pet_command/play_dead,
	)

/mob/living/basic/pet/potty/Initialize(mapload)
	..()
	AddComponent(/datum/component/item_receiver, list(/obj/item/reagent_containers/cup/watering_can), "happily takes")
	AddComponent(/datum/component/plant_tray_overlay, icon, null, null, null, null, null, null, 3, 8)
	AddComponent(/datum/component/plant_growing)
	AddComponent(/datum/component/obeys_commands, pet_commands)
	AddComponent(/datum/component/emotion_buffer)
	AddComponent(/datum/component/friendship_container, list(FRIENDSHIP_HATED = -100, FRIENDSHIP_DISLIKED = -50, FRIENDSHIP_STRANGER = 0, FRIENDSHIP_NEUTRAL = 1, FRIENDSHIP_ACQUAINTANCES = 3, FRIENDSHIP_FRIEND = 5, FRIENDSHIP_BESTFRIEND = 10), FRIENDSHIP_FRIEND)
	AddComponent(/datum/component/basic_inhands)
	AddElement(/datum/element/waddling)

	SEND_SIGNAL(src, COMSIG_TOGGLE_BIOBOOST)

	return INITIALIZE_HINT_LATELOAD

/mob/living/basic/pet/potty/LateInitialize()
	for(var/obj/item/reagent_containers/cup/watering_can/can in range(1, src))
		if(pick_up_watering_can(can))
			break

/mob/living/basic/pet/potty/Destroy()
	drop_all_held_items()
	return ..()

/mob/living/basic/pet/potty/death(gibbed)
	drop_all_held_items()
	return ..()

/mob/living/basic/pet/potty/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	face_atom(target)
	if (!ignore_cooldown)
		changeNext_move(melee_attack_cooldown)
	if(SEND_SIGNAL(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, target, Adjacent(target), modifiers) & COMPONENT_HOSTILE_NO_ATTACK)
		return FALSE //but more importantly return before attack_animal called
	var/result
	if(held_items[active_hand_index])
		var/obj/item/W = get_active_held_item()
		result = W.melee_attack_chain(src, target)
		SEND_SIGNAL(src, COMSIG_HOSTILE_POST_ATTACKINGTARGET, target, result)
		return result
	result = target.attack_basic_mob(src, modifiers)
	SEND_SIGNAL(src, COMSIG_HOSTILE_POST_ATTACKINGTARGET, target, result)
	return result

/*
/mob/living/basic/pet/potty/attackby(obj/item/thing, mob/user, params)
	// no forcing it into the hands of a sentient craig
	if(QDELETED(client) && istype(thing, /obj/item/reagent_containers/cup/watering_can))
		if(user.temporarilyRemoveItemFromInventory(thing) && !pick_up_watering_can(thing, user))
			user.put_in_hands(thing)
		return TRUE
	return ..()
*/

/mob/living/basic/pet/potty/proc/pick_up_watering_can(obj/item/reagent_containers/cup/watering_can/can, mob/living/feedback)
	// make sure it's actually a watering can, and that its not deleted
	if(!istype(can) || QDELING(can) || stat == DEAD)
		return FALSE
	// check if we're already holding a watering can
	var/obj/item/held_can = is_holding_item_of_type(/obj/item/reagent_containers/cup/watering_can)
	if(held_can)
		var/holding_advanced = istype(held_can, /obj/item/reagent_containers/cup/watering_can/advanced)
		var/giving_advanced = istype(can, /obj/item/reagent_containers/cup/watering_can/advanced)
		if(holding_advanced || !giving_advanced)
			if(feedback)
				balloon_alert(feedback, "already has watering can!")
			return FALSE
		else
			// we can hand craig an advanced can and they'll switch it out if their current can isn't advanced
			dropItemToGround(held_can)
	// make sure our hands aren't full
	if(!length(get_empty_held_indexes()))
		if(feedback)
			balloon_alert(feedback, "hands full!")
		return FALSE
	can.forceMove(src)
	// just make SURE we pick up the can - drop it back to the floor if we somehow fail
	if(!put_in_hands(can))
		if(feedback)
			balloon_alert(feedback, "couldn't pick up!")
		can.forceMove(drop_location())
		return FALSE
	// remove all non-water reagents from the can
	for(var/datum/reagent/reagent in can.reagents.reagent_list)
		if(reagent.type == /datum/reagent/water)
			continue
		can.reagents.remove_reagent(reagent.type, reagent.volume)
	if(feedback)
		balloon_alert(feedback, "took watering can")
	return TRUE

/mob/living/basic/pet/potty/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	. = ..()
	if(. && proximity_flag)
		pick_up_watering_can(attack_target)

// craig's living icons are movement states, so we gotta ensure icon2html handles that properly
/mob/living/basic/pet/potty/get_examine_string(mob/user, thats = FALSE)
	var/is_icon_moving = (icon_state == initial(icon_state) || icon_state == initial(icon_living))
	return "[icon2html(src, user, moving = is_icon_moving)] [thats ? "That's " : ""][get_examine_name(user)]"

/datum/pet_command/craig_harvest
	command_name = "Shake"
	command_desc = "Command your pet to stay idle in this location."
	radial_icon = 'icons/obj/objects.dmi'
	radial_icon_state = "dogbed"
	speech_commands = list("shake", "harvest")
	command_feedback = "shakes"

/datum/pet_command/craig_harvest/execute_action(datum/ai_controller/controller)
	var/mob/living/pawn = controller.pawn
	pawn.Shake(2, 2, 3 SECONDS)
	SEND_SIGNAL(pawn, COMSIG_TRY_HARVEST_SEEDS, pawn)
	return SUBTREE_RETURN_FINISH_PLANNING // This cancels further AI planning

/datum/ai_controller/basic_controller/craig
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_WEEDLEVEL_THRESHOLD = 3,
		BB_WATERLEVEL_THRESHOLD = 90,
	)

	ai_movement = /datum/ai_movement/jps
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/find_and_hunt_target/watering_can,
		/datum/ai_planning_subtree/find_and_hunt_target/fill_watercan,
		/datum/ai_planning_subtree/find_and_hunt_target/treat_hydroplants,
	)
