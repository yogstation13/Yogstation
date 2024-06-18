/**
 * ai control examine; which gives the pawn of the parent the noticeable organs depending on AI status!
 *
 * Used for monkeys to have PRIMAL eyes
 */
/datum/element/ai_control_examine
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// These organ slots on the parent's pawn, if filled, will get a special ai-specific examine
	/// Apply the element to ORGAN_SLOT_BRAIN if you don't want it to be hideable behind clothing.
	var/list/noticeable_organ_examines

/datum/element/ai_control_examine/Attach(datum/target, noticeable_organ_examines = list(ORGAN_SLOT_BRAIN = span_deadsay("doesn't appear to be themself.")))
	. = ..()

	if(!istype(target, /datum/ai_controller))
		return ELEMENT_INCOMPATIBLE
	var/datum/ai_controller/target_controller = target
	src.noticeable_organ_examines = noticeable_organ_examines
	RegisterSignal(target_controller, COMSIG_AI_CONTROLLER_POSSESSED_PAWN, PROC_REF(on_ai_controller_possessed_pawn))

/datum/element/ai_control_examine/Detach(datum/ai_controller/target_controller)
	. = ..()
	UnregisterSignal(target_controller, COMSIG_AI_CONTROLLER_POSSESSED_PAWN)
	if(target_controller.pawn && ishuman(target_controller.pawn))
		UnregisterSignal(target_controller.pawn, COMSIG_ORGAN_IMPLANTED)

/// Signal when the ai controller possesses a pawn
/datum/element/ai_control_examine/proc/on_ai_controller_possessed_pawn(datum/ai_controller/source_controller)
	SIGNAL_HANDLER

	if(!ishuman(source_controller.pawn))
		return //not supported
	var/mob/living/carbon/human/human_pawn = source_controller.pawn
	//make current organs noticeable
	for(var/organ_slot_key in noticeable_organ_examines)
		var/obj/item/organ/found = human_pawn.get_organ_slot(organ_slot_key)
		if(!found)
			continue
		make_organ_noticeable(organ_slot_key, found, human_pawn)
	//listen for future insertions (the element removes itself on removal, so we can ignore organ removal)
	RegisterSignal(human_pawn, COMSIG_ORGAN_IMPLANTED, PROC_REF(on_organ_implanted))

/datum/element/ai_control_examine/proc/on_organ_implanted(obj/item/organ/possibly_noticeable, mob/living/carbon/receiver)
	SIGNAL_HANDLER
	if(noticeable_organ_examines[possibly_noticeable.slot])
		make_organ_noticeable(possibly_noticeable.slot, possibly_noticeable)

/datum/element/ai_control_examine/proc/make_organ_noticeable(organ_slot, obj/item/organ/noticeable_organ)
	var/examine_text = noticeable_organ_examines[organ_slot]
	var/body_zone = organ_slot != ORGAN_SLOT_BRAIN ? noticeable_organ.zone : null
	noticeable_organ.AddElement(/datum/element/noticeable_organ/ai_control, examine_text, body_zone)
