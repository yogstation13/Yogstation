/*
 * Corporate Judo
 * An alternative method of dealing with tiders that isn't a stunbaton for security officers.
*/

#define DISCOMBOULATE_COMBO "DG"
#define EYEPOKE_COMBO "DH"
#define JUDOTHROW_COMBO "GD"
#define ARMBAR_COMBO "DDG"
#define WHEELTHROW_COMBO "GDH"

/datum/martial_art/corporate_judo
	name = "Corporate Judo"
	id = MARTIALART_CORPORATEJUDO
	/// Only allow use of this martial arts if in the main services areas (bar and kitchen).
	var/service_only = FALSE

/datum/martial_art/corporate_judo/can_use(mob/living/carbon/human/user) //this is used to make chef CQC only work in kitchen
	var/area/current_area = get_area(user)
	if(service_only)
		var/list/restricted_areas = list(/area/crew_quarters/kitchen, /area/crew_quarters/bar)
		for(var/area/restricted_area in restricted_areas)
			if(istype(current_area, restricted_area))
				return ..()
		return FALSE
	return ..()

/datum/martial_art/corporate_judo/disarm_act(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(!can_use(user) || !can_use(target))
		return FALSE
	add_to_streak("D", target)
	if(handle_combos(user, target))
		return TRUE
	return FALSE 

/datum/martial_art/corporate_judo/grab_act(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(!can_use(user) || !can_use(target))
		return FALSE
	add_to_streak("G", target)
	if(handle_combos(user, target))
		return TRUE
	return FALSE 

/// Split their punch damage in half by spreading it between brute and stamina.
/datum/martial_art/corporate_judo/harm_act(mob/living/carbon/human/user, mob/living/carbon/human/target)
	// For service only: make sure user and target are in their restricted area for martials to work.
	if(!can_use(user) || !can_use(target))
		return FALSE
	// Check if this streak leads into a combo moves. If so, do that combo instead.
	add_to_streak("H", target)
	if(handle_combos(user, target))
		return TRUE
	// Effects
	var/picked_hit_type = pick("chops", "slices", "strikes")
	log_combat(user, target, "attacked (Corporate Judo)")
	playsound(get_turf(target), 'sound/effects/hit_punch.ogg', 50, 1, -1)
	user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)
	target.visible_message(
		span_danger("[user] [picked_hit_type] [target]!"),
		span_userdanger("[user] [picked_hit_type] you!")
	)
	// Damage
	var/expected_damage = rand(user.get_punchdamagelow(), user.get_punchdamagehigh())
	if(ISODD(expected_damage)) // Easy number to split in half.
		expected_damage += 1
	target.apply_damage(expected_damage/2, BRUTE)
	target.apply_damage(expected_damage/2, STAMINA)
	// Logging
	log_combat(user, target, "attacked (Corporate Judo)")
	return TRUE

/datum/martial_art/corporate_judo/proc/handle_combos(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return FALSE // Continue on with the normal act.

/// Inflicts stamina damage and confuses the target.
/datum/martial_art/corporate_judo/proc/discomboulate(mob/living/carbon/human/user, mob/living/carbon/human/target)
	target.visible_message(
		span_warning("[user] strikes [target] in the head with [user.p_their()] palm!"),
		span_userdanger("[user] strikes you with [user.p_their()] palm!")
	)
	playsound(get_turf(user), 'sound/weapons/slap.ogg', 40, TRUE, -1)
	target.apply_damage(10, STAMINA)
	target.set_confusion_if_lower(5 SECONDS)
	log_combat(user, target, "discombobulated (Corporate Judo)")
	return TRUE

/// Inflicts brute/stamina damage and tries to temporarily blind/blur the target's vision.
/datum/martial_art/corporate_judo/proc/eyepoke(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/has_head = target.get_bodypart(BODY_ZONE_PRECISE_EYES)
	if(!has_head || !user.can_inject(target, FALSE, BODY_ZONE_PRECISE_EYES))
		var/msg = has_head ? "They do not have a head!" : "Their eyes are too protected!"
		to_chat(user, span_warning(msg))
		target.visible_message(
			span_warning("[user] tries to jabs [target] in [user.p_their()] eyes, but fails!"),
			span_userdanger("[user] tries to jab you in the eyes, but fails!")
		)
		playsound(get_turf(target), 'sound/weapons/whip.ogg', 40, TRUE, -1)

		user.apply_damage(5, BRUTE, user.get_active_hand()) // Owch, your fingers.
		target.apply_damage(5, STAMINA) // A small prize for trying anyways.
		log_combat(user, target, "eyepoked fail (Corporate Judo)")
		return TRUE

	// Your fingers function like a screwdriver that can bypass normal eye protection.
	// Protection reduce the damage and other effects. Lack of eyes increase damage, but completely negates other effects.
	target.visible_message(
		span_warning("[user] jabs [target] in [user.p_their()] eyes!"),
		span_userdanger("[user] jabs you in the eyes!")
	)
	playsound(get_turf(target), 'sound/weapons/whip.ogg', 40, TRUE, -1)

	var/eyes_protected = target.is_eyes_covered()
	var/obj/item/organ/eyes/eyes = target.getorganslot(ORGAN_SLOT_EYES)
	if(!eyes)
		var/damage = eyes_protected ? 20 : 30
		target.apply_damage(damage, STAMINA) // I do not want to imagine fingers in empty eye holes.
		log_combat(user, target, "eyepoked no-eye (Corporate Judo)")
		return TRUE

	var/blindness_duration = eyes_protected ? 2 SECONDS : 4 SECONDS
	var/blurriness_duration = eyes_protected ? 5 SECONDS : 10 SECONDS
	var/damage = eyes_protected ? 10 : 20
	target.adjust_blindness(blindness_duration)
	target.adjust_blurriness(blurriness_duration)
	target.apply_damage(damage, STAMINA)
	log_combat(user, target, "eyepoked (Corporate Judo)")
	return TRUE

/datum/martial_art/corporate_judo/proc/judo_throw(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if((user.mobility_flags & MOBILITY_STAND)) // User standing.
		return FALSE
	if((target.mobility_flags & MOBILITY_STAND)) // Target standing.
		return FALSE
	
	target.visible_message(
		span_warning("[user] judo throws [target] to ground!"),
		span_userdanger("[user] judo throws you to the ground!")
	)
	playsound(get_turf(target), 'sound/weapons/slam.ogg', 40, TRUE, -1)

	target.apply_damage(25, STAMINA)
	target.Knockdown(7 SECONDS)
	log_combat(user, target, "judothrow (Corporate Judo)")
	return TRUE

/datum/martial_art/corporate_judo/proc/armbar(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if((user.mobility_flags & MOBILITY_STAND)) // User standing.
		return FALSE
	if(!(target.mobility_flags & MOBILITY_STAND)) // Target not standing.
		return FALSE
	
	target.visible_message(
		span_warning("[user] puts [target] into an armbar!"),
		span_userdanger("[user] wrestles you into an armbar!")
	)
	playsound(get_turf(user), 'sound/weapons/slashmiss.ogg', 40, TRUE, -1)

	target.apply_damage(45, STAMINA)
	target.Immobilize(5 SECONDS)
	target.Knockdown(5 SECONDS)
	return TRUE

/datum/martial_art/corporate_judo/proc/wheelthrow(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if((user.mobility_flags & MOBILITY_STAND)) // User standing.
		return FALSE
	if(!(target.mobility_flags & MOBILITY_STAND) && target.IsImmobilized()) // Target not standing and is immobilized.
		return FALSE

	target.visible_message(
		span_warning("[user] raises [target] over [user.p_their()] shoulder, and slams [target.p_them()] into the ground!"),
		span_userdanger("[user] throws you over [user.p_their()] shoulder, slamming you into the ground!")
	)
	playsound(get_turf(user), 'sound/magic/tail_swing.ogg', 40, TRUE, -1)
	target.SpinAnimation(1 SECONDS, 1)
	target.apply_damage(100, STAMINA)
	target.Knockdown(15 SECONDS)
	target.set_confusion_if_lower(10 SECONDS)
	return TRUE

/mob/living/carbon/human/proc/corporate_judo_help()
	set name = "Remember Teachings" // Soo creative, wow.
	set desc = "You try to remember the teachings of Corporate Judo."
	set category = "Corporate Judo"
	var/list/combined_msg = list()

	combined_msg += "<b><i>You try to remember the teachings of Corporate Judo.</i></b>"
	combined_msg += span_notice("<b>All of your unarmed attacks deal half of its amount in stamina damage and half in brute damage.</b>")
	combined_msg += "[span_notice("Discomboulate")]: Disarm Grab. Deals 10 stamina damage and confuses them for 5 seconds."
	combined_msg += "[span_notice("Eye Poke")]: Disarm Harm. Deals 20 stamina damage, 4 seconds of blindness, and 10 seconds of blurriness. Effects are halved if they have eye protection."
	combined_msg += "[span_notice("Judo Throw")]: Grab Disarm. Deals 25 stamina damage and knockdowns for 7 seconds. Only works on standing targets."
	combined_msg += "[span_notice("Armbar")]: Disarm Disarm Grab. Deals 45 stamina damage, knockdowns, and immobilizes for 5 seconds. Only works on downed targets."
	combined_msg += "[span_notice("Wheel Throw")]: Grab Disarm Harm. Deals 100 stamina damage, knockdowns for 15 seconds, and confuses for 10 seconds. Only works on immobilized targets."
	to_chat(usr, examine_block(combined_msg.Join("\n")))

// Apparently, all belts are storage belts. Wrestling belt is the closet we're gonna get.
/obj/item/storage/belt/champion/wrestling
	name = "\improper Corporate Judo Belt"
	desc = "Teaches the wearer NT Corporate Judo."
	icon = 'icons/obj/clothing/belts.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/belt_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/belt_righthand.dmi'
	icon_state = "judobelt"
	item_state = "judo"
	w_class = WEIGHT_CLASS_BULKY
	var/datum/martial_art/corporate_judo/style = new


/obj/item/storage/belt/champion/wrestling/equipped(mob/user, slot)
	. = ..()
	if(!ishuman(user))
		return
	if(slot == ITEM_SLOT_BELT)
		var/mob/living/carbon/human/human_user = user
		style.teach(human_user, 1)

/obj/item/storage/belt/champion/wrestling/dropped(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	if(human_user.get_item_by_slot(ITEM_SLOT_BELT) == src)
		style.remove(human_user)
