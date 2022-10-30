/datum/surgery/hepatectomy
	name = "Hepatectomy"	//not to be confused with lobotomy
	desc = "Restores the liver to a functional state if it is in a non-functional state, making it able to sustain life. Can only be performed once on an individual liver."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "liver"
	steps = list(/datum/surgery_step/incise, 
				/datum/surgery_step/retract_skin, 
				/datum/surgery_step/saw, 
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/hepatectomy, 
				/datum/surgery_step/close)
	possible_locs = list(BODY_ZONE_CHEST)

/datum/surgery/hepatectomy/can_start(mob/user, mob/living/carbon/target)
	var/obj/item/organ/liver/L = target.getorganslot(ORGAN_SLOT_LIVER)
	if(L)
		if(L.damage > 60 && !L.operated)
			return TRUE
	return FALSE

/datum/surgery/hepatectomy/mechanic
	steps = list(/datum/surgery_step/mechanic_open,
				/datum/surgery_step/open_hatch,
				/datum/surgery_step/mechanic_unwrench,
				/datum/surgery_step/prepare_electronics,
				/datum/surgery_step/hepatectomy,
				/datum/surgery_step/mechanic_wrench,
				/datum/surgery_step/mechanic_close)
	requires_bodypart_type = BODYPART_ROBOTIC
	lying_required = FALSE
	self_operable = TRUE

//lobectomy, removes the most damaged lung lobe with a 95% base success chance
/datum/surgery_step/hepatectomy
	name = "excise damaged lung node"
	implements = list(TOOL_SCALPEL = 95, /obj/item/melee/transforming/energy/sword = 65, /obj/item/kitchen/knife = 45,
		/obj/item/shard = 35)
	time = 4.2 SECONDS
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/organ1.ogg'
	failure_sound = 'sound/surgery/organ2.ogg'
	fuckup_damage = 20

/datum/surgery_step/hepatectomy/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You begin to make an incision in [target]'s liver..."),
		"[user] begins to make an incision in [target].",
		"[user] begins to make an incision in [target].")

/datum/surgery_step/hepatectomy/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/liver/L = H.getorganslot(ORGAN_SLOT_LIVER)
		L.operated = TRUE
		H.setOrganLoss(ORGAN_SLOT_LIVER, 60)
		display_results(user, target, span_notice("You successfully excise the most damaged parts of [H]'s liver."),
			"Successfully removes a piece of [H]'s liver.",
			"")
	return TRUE

/datum/surgery_step/hepatectomy/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/liver/L = H.getorganslot(ORGAN_SLOT_LUNGS)
		L.operated = TRUE
		H.adjustOrganLoss(ORGAN_SLOT_LIVER, 10)
		display_results(user, target, span_warning("You screw up, failing to excise the damaged parts of [H]'s liver!"),
			span_warning("[user] screws up!"),
			span_warning("[user] screws up!"))
	return FALSE
