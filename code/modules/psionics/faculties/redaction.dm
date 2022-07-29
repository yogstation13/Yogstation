/datum/psionic_faculty/redaction
	id = PSI_REDACTION
	name = "Redaction"
	associated_intent = INTENT_HELP
	armour_types = list("bio", "rad")

/datum/psionic_power/redaction
	faculty = PSI_REDACTION
	admin_log = FALSE

/datum/psionic_power/redaction/proc/check_dead(var/mob/living/target)
	if(!istype(target))
		return FALSE
	if(target.stat == DEAD || HAS_TRAIT(target, TRAIT_FAKEDEATH))
		return TRUE
	return FALSE

/datum/psionic_power/redaction/invoke(var/mob/living/user, var/mob/living/target)
	if(check_dead(target))
		return FALSE
	. = ..()

/datum/psionic_power/redaction/skinsight
	name =            "Skinsight"
	cost =            3
	cooldown =        30
	use_grab =        TRUE
	min_rank =        PSI_RANK_OPERANT
	use_description = "Grab a patient, target the chest, then switch to help intent and use the grab on them to perform a check for wounds and damage."

/datum/psionic_power/redaction/skinsight/invoke(var/mob/living/user, var/mob/living/target)
	if(user.zone_selected != BODY_ZONE_CHEST)
		return FALSE
	. = ..()
	if(.)
		user.visible_message(span_notice("\The [user] rests a hand on \the [target]."))
		healthscan(target, user, TRUE)
		return TRUE

/datum/psionic_power/redaction/mend
	name =            "Mend"
	cost =            7
	cooldown =        50
	use_melee =       TRUE
	min_rank =        PSI_RANK_OPERANT
	use_description = "Target a patient while on help intent at melee range to mend a variety of maladies, such as bleeding or broken bones. Higher ranks in this faculty allow you to mend a wider range of problems."

/datum/psionic_power/redaction/mend/invoke(var/mob/living/user, var/mob/living/carbon/human/target)
	if(!istype(user) || !istype(target) || user.zone_selected != BODY_ZONE_CHEST)
		return FALSE
	. = ..()
	if(.)
		var/obj/item/bodypart/E = target.get_bodypart(user.zone_selected)

		if(!E)
			to_chat(user, span_warning("They are missing that limb."))
			return TRUE

		if(E.status == BODYPART_ROBOTIC)
			to_chat(user, span_warning("That limb is prosthetic."))
			return TRUE

		user.visible_message(span_notice("<i>\The [user] rests a hand on \the [target]'s [E.name]...</i>"))
		to_chat(target, span_notice("A healing warmth suffuses you."))

		var/redaction_rank = user.psi.get_rank(PSI_REDACTION)
		var/pk_rank = user.psi.get_rank(PSI_PSYCHOKINESIS)
		if(pk_rank >= PSI_RANK_LATENT && redaction_rank >= PSI_RANK_MASTER)
			var/removal_size = clamp(5-pk_rank, 0, 5)
			var/valid_objects = list()
			for(var/obj/item/thing in E.embedded_objects)
				if(thing.w_class >= removal_size)
					valid_objects += thing
			if(LAZYLEN(valid_objects))
				var/removing = pick(valid_objects)
				target.remove_embedded_object(removing)
				to_chat(user, span_notice("You extend a tendril of psychokinetic-redactive power and carefully tease \the [removing] free of \the [E]."))
				return TRUE
/*
		if(redaction_rank >= PSI_RANK_MASTER)
			if(E.status & ORGAN_ARTERY_CUT)
				to_chat(user, span_notice("You painstakingly mend the torn veins in \the [E], stemming the internal bleeding."))
				E.status &= ~ORGAN_ARTERY_CUT
				return TRUE
			if(E.status & ORGAN_TENDON_CUT)
				to_chat(user, span_notice("You interleave and repair the severed tendon in \the [E]."))
				E.status &= ~ORGAN_TENDON_CUT
				return TRUE
			if(E.status & ORGAN_BROKEN)
				to_chat(user, span_notice("You coax shattered bones to come together and fuse, mending the break."))
				E.status &= ~ORGAN_BROKEN
				E.stage = 0
				return TRUE

		for(var/datum/wound/W in E.wounds)
			if(W.bleeding())
				if(redaction_rank >= PSI_RANK_MASTER || W.wound_damage() < 30)
					to_chat(user, span_notice("You knit together severed veins and broken flesh, stemming the bleeding."))
					W.bleed_timer = 0
					W.clamped = TRUE
					E.status &= ~ORGAN_BLEEDING
					return TRUE
				else
					to_chat(user, span_notice("This [W.desc] is beyond your power to heal."))

		if(redaction_rank >= PSI_RANK_GRANDMASTER)
			for(var/obj/item/organ/internal/I in E.internal_organs)
				if(!BP_IS_ROBOTIC(I) && I.damage > 0)
					to_chat(user, span_notice("You encourage the damaged tissue of \the [I] to repair itself."))
					var/heal_rate = redaction_rank
					I.damage = max(0, I.damage - rand(heal_rate,heal_rate*2))
					return TRUE
*/
		to_chat(user, span_notice("You can find nothing within \the [target]'s [E.name] to mend."))
		return FALSE

/datum/psionic_power/redaction/cleanse
	name =            "Cleanse"
	cost =            9
	cooldown =        60
	use_melee =       TRUE
	min_rank =        PSI_RANK_GRANDMASTER
	use_description = "Target a patient while on help intent at melee range to cleanse radiation and genetic damage from a patient."

/datum/psionic_power/redaction/cleanse/invoke(var/mob/living/user, var/mob/living/carbon/human/target)
	if(!istype(user) || !istype(target))
		return FALSE
	. = ..()
	if(.)
		// No messages, as Mend procs them even if it fails to heal anything, and Cleanse is always checked after Mend.
		var/removing = rand(20,25)
		/*
		if(target.total_radiation)
			to_chat(user, span_notice("You repair some of the radiation-damaged tissue within \the [target]..."))
			if(target.total_radiation > removing)
				target.total_radiation -= removing
			else
				target.total_radiation = 0
			return TRUE
			*/
		if(target.getCloneLoss())
			to_chat(user, span_notice("You stitch together some of the mangled DNA within \the [target]..."))
			if(target.getCloneLoss() >= removing)
				target.adjustCloneLoss(-removing)
			else
				target.adjustCloneLoss(-(target.getCloneLoss()))
			return TRUE
		to_chat(user, span_notice("You can find no genetic damage or radiation to heal within \the [target]."))
		return TRUE

/datum/psionic_power/revive
	name =            "Revive"
	cost =            25
	cooldown =        80
	use_grab =        TRUE
	min_rank =        PSI_RANK_PARAMOUNT
	faculty =         PSI_REDACTION
	use_description = "Obtain a grab on a dead target, target the head, then select help intent and use the grab against them to attempt to bring them back to life. The process is lengthy and failure is punished harshly."
	admin_log = FALSE

/datum/psionic_power/revive/invoke(var/mob/living/user, var/mob/living/target)
	if(!isliving(target) || !istype(target) || user.zone_selected != BODY_ZONE_HEAD)
		return FALSE
	. = ..()
	if(.)
		if(target.stat != DEAD && !HAS_TRAIT(target, TRAIT_FAKEDEATH))
			to_chat(user, span_warning("This person is already alive!"))
			return TRUE

		if((world.time - target.timeofdeath) > 6000)
			to_chat(user, span_warning("\The [target] has been dead for too long to revive."))
			return TRUE

		user.visible_message(span_notice("<i>\The [user] splays out their hands over \the [target]'s body...</i>"))
		if(!do_after(user, 100, target, 0, 1))
			user.psi.backblast(rand(10,25))
			return TRUE
/*
		for(var/mob/abstract/observer/G in dead_mob_list)
			if(G.mind && G.mind.current == target && G.client)
				to_chat(G, span_notice("<font size = 3><b>Your body has been revived, <b>Re-Enter Corpse</b> to return to it.</b></font>"))
				break
*/
		to_chat(target, span_notice("<font size = 3><b>Life floods back into your body!</b></font>"))
		target.visible_message(span_notice("\The [target] shudders violently!"))
		target.adjustOxyLoss(-rand(15,20))
		target.revive()
		return TRUE
