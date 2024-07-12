/datum/psionic_faculty/redaction
	id = PSI_REDACTION
	name = "Redaction"
	armour_types = list(BIO, RAD, ACID)

/datum/psionic_power/redaction
	faculty = PSI_REDACTION
	admin_log = FALSE

/datum/psionic_power/redaction/proc/check_dead(mob/living/target)
	if(!istype(target))
		return FALSE
	if(target.stat == DEAD || HAS_TRAIT(target, TRAIT_FAKEDEATH))
		return TRUE
	return FALSE

/datum/psionic_power/redaction/invoke(mob/living/user, mob/living/target, proximity, parameters)
	if(HAS_TRAIT(target, TRAIT_PSIONICALLY_IMMUNE))
		to_chat(user, span_warning("[target]'s unnatural anatomy refuses the psionic tampering"))
		return FALSE
	if(check_dead(target))
		return FALSE
	. = ..()

/datum/psionic_power/redaction/skinsight
	name =            "Skinsight"
	cost =            3
	heat =            1
	cooldown =        3 SECONDS
	min_rank =        PSI_RANK_OPERANT
	icon_state = "redac_skinsight"
	use_description = "Activate the power with z, then target the mob you wish to scan with combat mode off. Higher psi levels provide more information."

/datum/psionic_power/redaction/skinsight/invoke(mob/living/user, mob/living/target, proximity, parameters)
	if(user.combat_mode || !istype(target) || !proximity)
		return FALSE
	. = ..()
	if(.)
		user.visible_message(span_notice("\The [user] rests a hand on \the [target]."))
		healthscan(user, target, user.psi.get_rank(PSI_REDACTION) >= PSI_RANK_GRANDMASTER)
		return TRUE

/datum/psionic_power/redaction/mend
	name =            "Mend"
	cost =            7
	heat =            10
	cooldown =        5 SECONDS
	min_rank =        PSI_RANK_OPERANT
	icon_state = "redac_mend"
	use_description = "Activate the power with z, then target the mob you wish to heal with combat mode off. Higher psi levels provide further healing."

/datum/psionic_power/redaction/mend/invoke(mob/living/user, mob/living/carbon/human/target, proximity, parameters)
	if(user.combat_mode || !istype(target) || !proximity || !..())
		return FALSE

	user.visible_message(span_notice("<i>\The [user] rests a hand on \the [target]...</i>"))
	to_chat(target, span_notice("A healing warmth suffuses you."))
	new /obj/effect/temp_visual/heal(get_turf(target), "#33cc33")

	var/pk_rank = user.psi.get_rank(PSI_PSYCHOKINESIS)
	var/redaction_rank = user.psi.get_rank(PSI_REDACTION)


	if(pk_rank >= PSI_RANK_LATENT && redaction_rank >= PSI_RANK_MASTER) //realistically, not likely to happen, and not even that powerful
		var/removal_size = clamp(5-pk_rank, 0, 5)
		var/list/embedded_list = list()
		var/obj/item/bodypart/body_part
		for(var/obj/item/bodypart/part in target.bodyparts)
			for(var/obj/item/embedded in part.embedded_objects)
				if(embedded.w_class >= removal_size)
					embedded_list += embedded
		if(LAZYLEN(embedded_list))
			var/removed_item = pick(embedded_list)
			body_part = target.get_embedded_part(removed_item)
			target.remove_embedded_object(removed_item, get_turf(target))
			to_chat(user, span_notice("You extend a tendril of psychokinetic-redactive power and carefully tease \the [removed_item] free of [target]'s [body_part]."))
			return TRUE

	if(target.heal_ordered_damage(redaction_rank * 10, list(BRUTE, BURN)) > 0) //this returns a number greater than 0 if it does any healing, we've already spent the psi, so we can afford to do this
		to_chat(user, span_notice("You patch up some of the damage to [target]."))
		return TRUE

	if(redaction_rank >= PSI_RANK_GRANDMASTER)
		// Repair wounds
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			for(var/datum/wound/W in H.all_wounds)
				if(W.blood_flow)
					W.blood_flow -= (redaction_rank * 0.5)
					if(prob(25))
						to_chat(user, span_notice("You stem the flow of blood streaming from [target]'s [W.limb]."))
					return TRUE

				if(istype(W, /datum/wound/burn))
					var/datum/wound/burn/degree = W
					degree.sanitization += (redaction_rank * 0.5)
					degree.flesh_healing += (redaction_rank * 0.5)
					if(prob(25))
						to_chat(user, span_notice("You clean and mend the burns on [target]'s [W.limb]."))
					return TRUE

				if(istype(W, /datum/wound/blunt))
					qdel(W)
					playsound(H, 'sound/surgery/bone3.ogg', 25)
					to_chat(user, span_notice("You snap the bones in [target]'s [W.limb] back into place."))
					return TRUE

		// Repair internal organs
		for(var/obj/item/organ/O in target.internal_organs)
			if(O.damage > 0)
				var/heal = redaction_rank * 10
				to_chat(user, span_notice("You encourage the damaged tissues of \the [O] to repair itself."))
				O.applyOrganDamage(-rand(heal, heal * 2))
				return TRUE

	to_chat(user, span_notice("You can find nothing within \the [target] to mend."))
	return FALSE

/datum/psionic_power/revive
	name =            "Revive"
	cost =            25
	heat =            100
	cooldown =        8 SECONDS
	min_rank =        PSI_RANK_OPERANT
	faculty =         PSI_REDACTION
	icon_state = "redac_revive"
	use_description = "Activate the power with z, then target the mob you wish to revive with combat mode off. Has several limiting factors. Higher psi levels upgrade the revive."
	admin_log = FALSE

/datum/psionic_power/revive/invoke(mob/living/user, mob/living/target, proximity, parameters)
	if(user.combat_mode || !istype(target) || !proximity || isipc(target))
		return FALSE
	. = ..()
	if(.)
		if(target.stat != DEAD && !HAS_TRAIT(target, TRAIT_FAKEDEATH))
			to_chat(user, span_warning("This person is already alive!"))
			return TRUE

		var/is_paramount = user.psi.get_rank(PSI_REDACTION) >= PSI_RANK_PARAMOUNT

		if(!is_paramount && (world.time - target.timeofdeath) > DEFIB_TIME_LIMIT)
			to_chat(user, span_warning("\The [target] has been dead for too long to revive."))
			return TRUE

		user.visible_message(span_notice("<i>\The [user] splays out their hands over \the [target]'s body...</i>"))
		target.notify_ghost_cloning("Your heart is being revived!")
		target.grab_ghost()
		if(!do_after(user, 10 SECONDS, target, FALSE))
			user.psi.backblast(rand(10,25))
			return TRUE

		to_chat(target, span_notice("Life floods back into your body!"))
		target.visible_message(span_notice("\The [target] shudders violently!"))
		target.adjustOxyLoss(-rand(15,20))
		target.revive(is_paramount)
		return TRUE

/datum/psionic_power/redaction/cleanse
	name =            "Cleanse"
	cost =            9
	heat =            15
	cooldown =        6 SECONDS
	min_rank =        PSI_RANK_MASTER
	icon_state = "redac_cleanse"
	use_description = "Activate the power with z, then target the mob you wish cleanse with combat mode off. Cleanses radiation, clone damage, and toxins. Higher psi levels provide further cleansing."

/datum/psionic_power/redaction/cleanse/invoke(mob/living/user, mob/living/carbon/human/target, proximity, parameters)
	if(user.combat_mode || !istype(target) || !proximity)
		return FALSE
	. = ..()
	if(.)
		var/removing = (user.psi.get_rank(PSI_REDACTION) - 1) * 10
		if(target.radiation)
			to_chat(user, span_notice("You repair some of the radiation-damaged tissue within \the [target]..."))
			target.radiation = max(target.radiation - removing, 0)
			return TRUE
		if(target.getCloneLoss())
			to_chat(user, span_notice("You stitch together some of the mangled DNA within \the [target]..."))
			target.adjustCloneLoss(-removing)
			return TRUE
		if(target.getToxLoss())
			to_chat(user, span_notice("You expunge some of the toxins within \the [target]..."))
			target.adjustToxLoss(-removing, TRUE, TRUE)
			return TRUE
		to_chat(user, span_notice("You can find no impurities to cleanse from \the [target]."))
		return TRUE
