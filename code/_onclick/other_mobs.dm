/*
	Humans:
	Adds an exception for gloves, to allow special glove types like the ninja ones.

	Otherwise pretty standard.
*/
/mob/living/carbon/human/UnarmedAttack(atom/A, proximity, modifiers)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		if(src == A)
			check_self_for_injuries()
		return
	if(HAS_TRAIT(A, TRAIT_NOINTERACT))
		to_chat(A, span_notice("You can't touch things!"))
		return

	if(!has_active_hand()) //can't attack without a hand.
		var/obj/item/bodypart/check_arm = get_active_hand()
		if(check_arm?.bodypart_disabled)
			to_chat(src, span_warning("Your [check_arm.name] is in no condition to be used."))
			return
		to_chat(src, span_notice("You look at your arm and sigh."))
		return

	// Special glove functions:
	// If the gloves do anything, have them return 1 to stop
	// normal attack_hand() here.
	var/obj/item/clothing/gloves/G = gloves // not typecast specifically enough in defines
	if(proximity && istype(G) && G.Touch(A, 1, modifiers))
		return

	if(SEND_SIGNAL(src, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, A, modifiers) & COMPONENT_NO_ATTACK_HAND)
		return

	var/override = 0
	for(var/datum/mutation/human/HM in dna.mutations)
		override = HM.on_attack_hand(A, proximity)
	if(override)
		return

	SEND_SIGNAL(src, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, A)
	if(modifiers[RIGHT_CLICK])
		var/secondary_result = A.attack_hand_secondary(src, modifiers)
		if(secondary_result == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || secondary_result == SECONDARY_ATTACK_CONTINUE_CHAIN)
			return
		else if(secondary_result != SECONDARY_ATTACK_CALL_NORMAL)
			CRASH("attack_hand_secondary did not return a SECONDARY_ATTACK_* define.")

	A.attack_hand(src, modifiers)

//Return TRUE to cancel other attack hand effects that respect it.
/atom/proc/attack_hand(mob/user, modifiers)
	. = FALSE
	if(!(interaction_flags_atom & INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND))
		add_fingerprint(user)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_HAND, user, modifiers) & COMPONENT_NO_ATTACK_HAND)
		. = TRUE
	if(interaction_flags_atom & INTERACT_ATOM_ATTACK_HAND)
		. = _try_interact(user, modifiers)

/// When the user uses their hand on an item while holding right-click
/// Returns a SECONDARY_ATTACK_* value.
/atom/proc/attack_hand_secondary(mob/user, modifiers)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_HAND_SECONDARY, user, modifiers) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return SECONDARY_ATTACK_CALL_NORMAL

//Return a non FALSE value to cancel whatever called this from propagating, if it respects it.
/atom/proc/_try_interact(mob/user, modifiers)
	if(IsAdminGhost(user))		//admin abuse
		return interact(user)
	if(can_interact(user))
		return interact(user)
	return FALSE

/atom/proc/can_interact(mob/user)
	if(!user.can_interact_with(src))
		return FALSE
	if((interaction_flags_atom & INTERACT_ATOM_REQUIRES_DEXTERITY) && !user.IsAdvancedToolUser())
		to_chat(user, span_warning("You don't have the dexterity to do this!"))
		return FALSE
	if(!(interaction_flags_atom & INTERACT_ATOM_IGNORE_INCAPACITATED) && user.incapacitated((interaction_flags_atom & INTERACT_ATOM_IGNORE_RESTRAINED), !(interaction_flags_atom & INTERACT_ATOM_CHECK_GRAB)))
		return FALSE
	if(HAS_TRAIT(user, TRAIT_NOINTERACT))
		to_chat(user, span_notice("You can't touch things!"))
		return FALSE
	return TRUE

/atom/ui_status(mob/user)
	. = ..()
	if(!can_interact(user))
		. = min(., UI_UPDATE)

/atom/movable/can_interact(mob/user)
	. = ..()
	if(!.)
		return
	if(!anchored && (interaction_flags_atom & INTERACT_ATOM_REQUIRES_ANCHORED))
		return FALSE

/atom/proc/interact(mob/user)
	if(interaction_flags_atom & INTERACT_ATOM_NO_FINGERPRINT_INTERACT)
		add_hiddenprint(user)
		add_scent(user)
	else
		add_fingerprint(user)
	if(interaction_flags_atom & INTERACT_ATOM_UI_INTERACT)
		return ui_interact(user)
	return FALSE

/mob/living/carbon/human/RangedAttack(atom/A, mouseparams)
	. = ..()
	if(gloves)
		var/obj/item/clothing/gloves/G = gloves
		var/list/modifiers = params2list(mouseparams)
		if(istype(G) && G.Touch(A, 0, modifiers)) // for magic gloves
			return

	for(var/datum/mutation/human/HM in dna.mutations)
		HM.on_ranged_attack(A, mouseparams)

	if(isturf(A) && get_dist(src,A) <= 1)
		Move_Pulled(A)
		return

/*
	Animals & All Unspecified
*/
/mob/living/UnarmedAttack(atom/A, proximity, modifiers)
	A.attack_animal(src, modifiers)

/atom/proc/attack_animal(mob/user, modifiers)
	return

/mob/living/RestrainedClickOn(atom/A)
	return

/*
	Monkeys
*/
/mob/living/carbon/monkey/UnarmedAttack(atom/A, proximity, modifiers)
	A.attack_paw(src, modifiers)

/atom/proc/attack_paw(mob/user, modifiers)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_PAW, user) & COMPONENT_NO_ATTACK_HAND)
		return TRUE
	return FALSE

/*
	Monkey RestrainedClickOn() was apparently the
	one and only use of all of the restrained click code
	(except to stop you from doing things while handcuffed);
	moving it here instead of various hand_p's has simplified
	things considerably
*/
/mob/living/carbon/monkey/RestrainedClickOn(atom/A)
	if(..())
		return
	if(!combat_mode || !ismob(A))
		return
	if(is_muzzled())
		return
	var/mob/living/carbon/ML = A
	if(istype(ML))
		var/dam_zone = pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
		var/obj/item/bodypart/affecting = null
		if(ishuman(ML))
			var/mob/living/carbon/human/H = ML
			affecting = H.get_bodypart(ran_zone(dam_zone))
		var/armor = ML.run_armor_check(affecting, MELEE)
		if(prob(75))
			ML.apply_damage(rand(1,3), BRUTE, affecting, armor)
			ML.visible_message(span_danger("[name] bites [ML]!"), \
							span_userdanger("[name] bites [ML]!"))
			if(armor >= 2)
				return
			for(var/thing in diseases)
				var/datum/disease/D = thing
				ML.ForceContractDisease(D)
		else
			ML.visible_message(span_danger("[src] has attempted to bite [ML]!"))

/*
	Aliens
	Defaults to same as monkey in most places
*/
/mob/living/carbon/alien/UnarmedAttack(atom/A, proximity, modifiers)
	A.attack_alien(src, modifiers)

/atom/proc/attack_alien(mob/living/carbon/alien/user, modifiers)
	attack_paw(user, modifiers)
	return

// Babby aliens
/mob/living/carbon/alien/larva/UnarmedAttack(atom/A, proximity, modifiers)
	A.attack_larva(src, modifiers)

/atom/proc/attack_larva(mob/user, modifiers)
	return


/*
	Slimes
	Nothing happening here
*/
/mob/living/simple_animal/slime/UnarmedAttack(atom/A, proximity, modifiers)
	if(isturf(A))
		return ..()
	A.attack_slime(src, proximity, modifiers)

/atom/proc/attack_slime(mob/user, proximity, modifiers)
	return


/*
	Drones
*/
/mob/living/simple_animal/drone/UnarmedAttack(atom/A, proximity, modifiers)
	A.attack_drone(src, modifiers)

/atom/proc/attack_drone(mob/living/simple_animal/drone/user, proximity, modifiers)
	attack_hand(user, modifiers) //defaults to attack_hand. Override it when you don't want drones to do same stuff as humans.

/*
	True Devil
*/

/mob/living/carbon/true_devil/UnarmedAttack(atom/A, proximity, modifiers)
	A.attack_hand(src, modifiers)

/*
	Brain
*/

/mob/living/brain/UnarmedAttack(atom/A, proximity, modifiers)//Stops runtimes due to attack_animal being the default
	return


/*
	pAI
*/

/mob/living/silicon/pai/UnarmedAttack(atom/A, proximity, modifiers)//Stops runtimes due to attack_animal being the default
	return


/*
	Simple animals
*/

/mob/living/simple_animal/UnarmedAttack(atom/A, proximity, modifiers)
	if(!dextrous)
		return ..()
	if(!ismob(A))
		A.attack_hand(src, modifiers)
		update_inv_hands()


/*
	Hostile animals
*/

/mob/living/simple_animal/hostile/UnarmedAttack(atom/A, proximity, modifiers)
	target = A
	if(dextrous && !ismob(A))
		return ..()
	else
		AttackingTarget()



/*
	New Players:
	Have no reason to click on anything at all.
*/
/mob/dead/new_player/ClickOn()
	return
