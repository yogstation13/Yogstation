/// Parent Type for arms, should not appear in game.
/obj/item/bodypart/arm
	name = "arm"
	desc = "Hey buddy give me a HAND and report this to the github because you shouldn't be seeing this."
	attack_verb_continuous = list("slaps", "punches")
	attack_verb_simple = list("slap", "punch")
	max_damage = 50
	aux_layer = BODYPARTS_HIGH_LAYER
	body_damage_coeff = 0.75
	can_be_disabled = TRUE
	unarmed_attack_verb = "punch" /// The classic punch, wonderfully classic and completely random
	unarmed_damage_low = 5
	unarmed_damage_high = 5
	unarmed_stun_threshold = 10
	body_zone = BODY_ZONE_L_ARM

	biological_state = BIO_STANDARD_JOINTED
	/// Basically, bodypart traits that ONLY apply when this arm is the active hand of the mob
	var/list/hand_traits

/obj/item/bodypart/arm/Destroy()
	return ..()

/obj/item/bodypart/arm/Destroy()
	return ..()

/obj/item/bodypart/arm/set_owner(new_owner)
	. = ..()
	if(. == FALSE)
		return

	if(owner)
		RegisterSignal(owner, COMSIG_MOB_SWAP_HANDS, PROC_REF(on_swap_hands))
		on_swap_hands(owner)

	if(.)
		var/mob/living/carbon/old_owner = .
		UnregisterSignal(old_owner, COMSIG_MOB_SWAP_HANDS)
		on_inactive_hand(old_owner)

/obj/item/bodypart/arm/set_disabled(new_disabled)
	. = ..()
	if(isnull(.) || !owner)
		return

	if(!.)
		if(bodypart_disabled)
			owner.set_usable_hands(owner.usable_hands - 1)
			if(owner.stat < UNCONSCIOUS)
				to_chat(owner, span_userdanger("You lose control of your [name]!"))
			if(held_index)
				owner.dropItemToGround(owner.get_item_for_held_index(held_index))
	else if(!bodypart_disabled)
		owner.set_usable_hands(owner.usable_hands + 1)

	if(owner.hud_used)
		var/atom/movable/screen/inventory/hand/hand_screen_object = owner.hud_used.hand_slots["[held_index]"]
		hand_screen_object?.update_appearance()

/obj/item/bodypart/arm/proc/on_swap_hands(mob/living/carbon/source)
	SIGNAL_HANDLER
	if(!length(hand_traits))
		return
	if(source.get_active_hand() == src)
		on_active_hand(source)
	else
		on_inactive_hand(source)

/obj/item/bodypart/arm/proc/on_active_hand(mob/living/carbon/source)
	SHOULD_CALL_PARENT(TRUE)
	if(!length(hand_traits))
		return
	source.add_traits(hand_traits, REF(src))

/obj/item/bodypart/arm/proc/on_inactive_hand(mob/living/carbon/source)
	SHOULD_CALL_PARENT(TRUE)
	if(!length(hand_traits))
		return
	source.remove_traits(hand_traits, REF(src))

/obj/item/bodypart/arm/left
	name = "left arm"
	desc = "Did you know that the word 'sinister' stems originally from the \
		Latin 'sinestra' (left hand), because the left hand was supposed to \
		be possessed by the devil? This arm appears to be possessed by no \
		one though."
	icon_state = "default_human_l_arm"
	body_zone = BODY_ZONE_L_ARM
	body_part = ARM_LEFT
	plaintext_zone = "left arm"
	aux_zone = BODY_ZONE_PRECISE_L_HAND
	held_index = 1
	px_x = -6
	px_y = 0
	bodypart_trait_source = LEFT_ARM_TRAIT

/obj/item/bodypart/arm/left/set_owner(new_owner)
	. = ..()
	if(. == FALSE)
		return

	if(owner)
		if(HAS_TRAIT(owner, TRAIT_PARALYSIS_L_ARM))
			ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_ARM)
			RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_ARM), PROC_REF(on_owner_paralysis_loss))
		else
			REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_ARM)
			RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_ARM), PROC_REF(on_owner_paralysis_gain))
	if(.)
		var/mob/living/carbon/old_owner = .
		if(HAS_TRAIT(old_owner, TRAIT_PARALYSIS_L_ARM))
			UnregisterSignal(old_owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_ARM))
			if(!owner || !HAS_TRAIT(owner, TRAIT_PARALYSIS_L_ARM))
				REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_ARM)
		else
			UnregisterSignal(old_owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_ARM))

///Proc to react to the owner gaining the TRAIT_PARALYSIS_L_ARM trait.
/obj/item/bodypart/arm/left/proc/on_owner_paralysis_gain(mob/living/carbon/source)
	SIGNAL_HANDLER
	ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_ARM)
	UnregisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_ARM))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_ARM), PROC_REF(on_owner_paralysis_loss))


///Proc to react to the owner losing the TRAIT_PARALYSIS_L_ARM trait.
/obj/item/bodypart/arm/left/proc/on_owner_paralysis_loss(mob/living/carbon/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_ARM)
	UnregisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_ARM))
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_ARM), PROC_REF(on_owner_paralysis_gain))

/obj/item/bodypart/arm/right
	name = "right arm"
	desc = "Over 87% of humans are right handed. That figure is much lower \
		among humans missing their right arm."
	body_zone = BODY_ZONE_R_ARM
	body_part = ARM_RIGHT
	icon_state = "default_human_r_arm"
	plaintext_zone = "right arm"
	aux_zone = BODY_ZONE_PRECISE_R_HAND
	held_index = 2
	px_x = 6
	px_y = 0
	bodypart_trait_source = RIGHT_ARM_TRAIT

/obj/item/bodypart/arm/right/set_owner(new_owner)
	. = ..()
	if(. == FALSE)
		return

	if(owner)
		if(HAS_TRAIT(owner, TRAIT_PARALYSIS_R_ARM))
			ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_ARM)
			RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_ARM), PROC_REF(on_owner_paralysis_loss))
		else
			REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_ARM)
			RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_ARM), PROC_REF(on_owner_paralysis_gain))
	if(.)
		var/mob/living/carbon/old_owner = .
		if(HAS_TRAIT(old_owner, TRAIT_PARALYSIS_R_ARM))
			UnregisterSignal(old_owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_ARM))
			if(!owner || !HAS_TRAIT(owner, TRAIT_PARALYSIS_R_ARM))
				REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_ARM)
		else
			UnregisterSignal(old_owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_ARM))

///Proc to react to the owner gaining the TRAIT_PARALYSIS_R_ARM trait.
/obj/item/bodypart/arm/right/proc/on_owner_paralysis_gain(mob/living/carbon/source)
	SIGNAL_HANDLER
	ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_ARM)
	UnregisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_ARM))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_ARM), PROC_REF(on_owner_paralysis_loss))


///Proc to react to the owner losing the TRAIT_PARALYSIS_R_ARM trait.
/obj/item/bodypart/arm/right/proc/on_owner_paralysis_loss(mob/living/carbon/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_ARM)
	UnregisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_ARM))
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_ARM), PROC_REF(on_owner_paralysis_gain))
