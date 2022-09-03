/datum/surgery/eye_surgery
	name = "Eye surgery"
	desc = "Fixes all damage done to eyes, though doesnt fix genetic blindness. Failing to fix the eyes will cause brain damage to the patient."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "eyeballs"
	steps = list(/datum/surgery_step/incise, 
				/datum/surgery_step/retract_skin, 
				/datum/surgery_step/clamp_bleeders, 
				/datum/surgery_step/fix_eyes, 
				/datum/surgery_step/close)
	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_PRECISE_EYES)

/datum/surgery/eye_surgery/mechanic
	steps = list(/datum/surgery_step/mechanic_open,
				/datum/surgery_step/open_hatch,
				/datum/surgery_step/mechanic_unwrench,
				/datum/surgery_step/fix_eyes, 
				/datum/surgery_step/mechanic_wrench,
				/datum/surgery_step/mechanic_close)
	requires_bodypart_type = BODYPART_ROBOTIC
	lying_required = FALSE
	self_operable = TRUE

//fix eyes
/datum/surgery_step/fix_eyes
	name = "fix eyes"
	implements = list(TOOL_HEMOSTAT = 100, TOOL_SCREWDRIVER = 45, /obj/item/pen = 25)
	time = 6.4 SECONDS

/datum/surgery/eye_surgery/can_start(mob/user, mob/living/carbon/target)
	var/obj/item/organ/eyes/E = target.getorganslot(ORGAN_SLOT_EYES)
	if(!E)
		to_chat(user, "It's hard to do surgery on someone's eyes when [target.p_they()] [target.p_do()]n't have any.")
		return FALSE
	return TRUE

/datum/surgery_step/fix_eyes/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You begin to fix [target]'s eyes..."),
		"[user] begins to fix [target]'s eyes.",
		"[user] begins to perform surgery on [target]'s eyes.")

/datum/surgery_step/fix_eyes/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/eyes/E = target.getorganslot(ORGAN_SLOT_EYES)
	user.visible_message("[user] successfully fixes [target]'s eyes!", span_notice("You succeed in fixing [target]'s eyes."))
	display_results(user, target, span_notice("You succeed in fixing [target]'s eyes."),
		"[user] successfully fixes [target]'s eyes!",
		"[user] completes the surgery on [target]'s eyes.")
	target.cure_blind(list(EYE_DAMAGE))
	target.set_blindness(0)
	target.cure_nearsighted(list(EYE_DAMAGE))
	target.blur_eyes(35)	//this will fix itself slowly.
	E.setOrganDamage(0)
	return TRUE

/datum/surgery_step/fix_eyes/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.getorgan(/obj/item/organ/brain))
		display_results(user, target, span_warning("You accidentally stab [target] right in the brain!"),
			span_warning("[user] accidentally stabs [target] right in the brain!"),
			span_warning("[user] accidentally stabs [target] right in the brain!"))
		target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 70)
	else
		display_results(user, target, span_warning("You accidentally stab [target] right in the brain! Or would have, if [target] had a brain."),
			span_warning("[user] accidentally stabs [target] right in the brain! Or would have, if [target] had a brain."),
			span_warning("[user] accidentally stabs [target] right in the brain!"))
	return FALSE
