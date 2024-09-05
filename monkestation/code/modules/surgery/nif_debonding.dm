/datum/surgery/nif_debonding
	name = "NIF debonding"
	desc = "Permanently removes a bonded NIF from the patient. Requires the patient to mentally prepare for debonding."
	possible_locs = list(BODY_ZONE_HEAD)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/debond_nif,
		/datum/surgery_step/close,
	)

/datum/surgery/nif_debonding/can_start(mob/user, mob/living/patient)
	if(!..())
		return FALSE

	var/obj/item/organ/internal/cyberimp/brain/nif/nif = patient.get_organ_slot(ORGAN_SLOT_BRAIN_NIF)

	return nif?.is_calibrated && patient.stat != DEAD && patient.client && patient.get_organ_slot(ORGAN_SLOT_BRAIN)

/datum/surgery_step/debond_nif
	name = "debond NIF (scalpel)"
	time = 5 SECONDS
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/scalpel2.ogg'
	implements = list(
		TOOL_SCALPEL = 100,
		/obj/item/melee/energy/sword = 75,
		/obj/item/knife = 65,
		/obj/item/shard = 45,
		/obj/item = 30,
	)

/datum/surgery_step/debond_nif/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(tgui_alert(target, "Would you like to have your NIF debonded from you by [user]?", "NIF Debonding", list("Yes", "No"), timeout = 5 SECONDS) != "Yes")
		if(user && target)
			target.balloon_alert(user, "unwilling!")
		return SURGERY_STEP_FAIL

	display_results(
		user,
		target,
		span_notice("You begin to <i>carefully</i> cut the threads of the NIF in [target]..."),
		span_notice("[user] begins to <i>carefully</i> cut the threads of the NIF in [target]."),
		span_notice("[user] begins to <i>carefully</i> cut something in [target]'s head."),
	)
	display_pain(target, "You feel painful zaps in your head!")

/datum/surgery_step/debond_nif/success(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results)
	if(target.stat == DEAD)
		to_chat(user, span_warning("They need to be alive to perform this surgery!"))
		return FALSE

	var/obj/item/organ/internal/brain/brain = target.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(!istype(brain))
		to_chat(user, span_warning("They need a brain, dingus!"))
		return FALSE

	var/obj/item/organ/internal/cyberimp/brain/nif/nif = target.get_organ_slot(ORGAN_SLOT_BRAIN_NIF)
	if(!nif)
		to_chat(user, span_warning("They need an NIF, dingus!"))
		return FALSE

	if(!brain.modular_persistence)
		to_chat(user, span_cultlarge("The ethereal forces of reality forbid debonding the NIF! Okay seriously, tell an admin lmao."))
		CRASH("[user.ckey] attempted NIF debonding for [target.ckey], but no modular persistence datum was found. This shouldn't happen.")

	nif.Remove(target)
	user.put_in_hands(nif)

	target.save_nif_data(brain.modular_persistence, remove_nif = TRUE)
	target.save_individual_persistence()

	return ..()

/datum/surgery_step/debond_nif/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, fail_prob)
	display_results(
		user,
		target,
		span_notice("You mess up, damaging the NIF and brain!"),
		span_notice("[user] messes up, damaging the NIF and brain!"),
		span_notice("[user] messes up!"),
	)
	display_pain(user, "You feel a horrible spike of pain in your head!")

	target.adjustOrganLoss(ORGAN_SLOT_BRAIN, rand(30, 50))

	var/obj/item/organ/internal/cyberimp/brain/nif/nif = target.get_organ_slot(ORGAN_SLOT_BRAIN_NIF)
	nif?.adjust_durability(-rand(10, 20))

	return FALSE

/datum/surgery_step/debond_nif/tool_check(mob/user, obj/item/tool)
	return implement_type != /obj/item || tool.get_sharpness() > 0
