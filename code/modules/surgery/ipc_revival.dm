/datum/surgery/ipc_revival
	name = "Posibrain Reactivation"
	desc = "This procedure repairs and reactivates a positronic brain inside a mechanical body, restoring it to a functional state."
	icon_state = "revival_posi"
	possible_locs = list(BODY_ZONE_CHEST)
	requires_bodypart_type = BODYPART_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/revive_ipc,
		/datum/surgery_step/mechanic_close
	)

/datum/surgery/ipc_revival/can_start(mob/user, mob/living/target)
	if(target.stat != DEAD)
		return FALSE // they're already activated
	var/obj/item/organ/brain/B = target.getorganslot(ORGAN_SLOT_BRAIN)
	if(!B) // you can't reactivate a brain that DOESN'T EXIST
		return FALSE
	return istype(target.getorganslot(ORGAN_SLOT_BRAIN), /obj/item/organ/brain/positron)

/datum/surgery_step/revive_ipc
	name = "reactivate brain"
	time = 5 SECONDS
	repeatable = TRUE // so you don't have to restart the whole thing if it fails
	implements = list(TOOL_MULTITOOL = 100, TOOL_WIRECUTTER = 50)
	preop_sound = 'sound/items/tape_flip.ogg'
	success_sound = 'sound/items/taperecorder_close.ogg'
	failure_sound = 'sound/machines/defib_zap.ogg'

/datum/surgery_step/revive_ipc/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.stat != DEAD)
		to_chat(user, span_warning("[target] is already alive!"))
		return -1 // if they're alive don't bother
	if(target.health < 0)
		to_chat(user, span_warning("[target] is too damaged to be reactivated, repair them first!"))
		return -1 // if they're too damaged, then you can't revive them
	display_results(user, target, span_notice("You begin to reactivate [target]'s brain..."),
		"[user] begins to reactivate [target]'s brain.",
		"[user] begins to reactivate [target]'s brain.")

/datum/surgery_step/revive_ipc/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/brain/positron/B = target.getorganslot(ORGAN_SLOT_BRAIN)
	if(!B)
		to_chat(user, span_warning("[target] has no brain to reactivate!"))
		return TRUE
	if(!istype(B))
		to_chat(user, span_warning("[target] does not have a positronic brain!"))
		return TRUE
	if(target.stat != DEAD)
		to_chat(user, span_warning("[target] is already alive!"))
		return TRUE
	if(target.health < 0)
		to_chat(user, span_warning("[target] is too damaged to be reactivated, repair them first!"))
		return TRUE
	if(B.suicided || B.brainmob?.suiciding)
		to_chat(user, span_warning("[target]'s personality matrix is gone. Reactivation is impossible."))
		return TRUE
	if(target.mind)
		target.mind.grab_ghost()
	target.setOrganLoss(ORGAN_SLOT_BRAIN, 0)
	target.revive()
	display_results(user, target, span_warning("You successfully reactivate [target]!"),\
		span_warning("[user] successfully reactivates [target]!"),\
		"[user] completes [target]'s reactivation.")
	to_chat(target, span_danger("ERROR: Due to sudden system shutdown, this units Random Access Memory has been corrupted."))
	to_chat(target, span_userdanger("You do not remember your death, how you died, or who killed you. <a href='https://forums.yogstation.net/help/rules/#rule-1_6'>See rule 1.6</a>."))
	log_combat(user, target, "was revived with memory loss", tool)
	return TRUE

/datum/surgery_step/revive_ipc/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.getorganslot(ORGAN_SLOT_BRAIN))
		display_results(user, target, span_warning("You screw up, causing more damage!"),
			span_warning("[user] screws up, causing damage to [target]'s brain!"),
			"[user] completes the surgery on [target]'s brain.")
		target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 60)
	else
		user.visible_message("<span class='warning'>[user] suddenly notices that the brain [user.p_they()] [user.p_were()] working on is not there anymore.", span_warning("You suddenly notice that the brain you were working on is not there anymore."))
	return FALSE

/obj/item/paper/guides/jobs/robotics/ipc_repair
	name = "paper- 'IPC Repair 101'"
	info = "<B>A quick guide to repairing a non-functional IPC</B><BR>\
	-Fix any external damage with a welding tool and coils of wire.<BR>\
	-Place the non-functional unit on an operating surface.<BR>\
	-Use a screwdriver to initiate posibrain reactivation and unscrew the maintenance panel located on the unit's chest.<BR>\
	-Open the panel with a free hand and use your multitool to begin the reboot process.<BR>\
	-After reactivation, use a screwdriver to screw the panel back into place.<BR>\
	-If the unit breaks down shortly after reactivation, replace any missing internal components and reboot again if necessary.<BR>\
	Nanotrasen is not liable for any damages caused during the repair process."

/datum/surgery/synth_revival
	name = "Synthetic Reactivation"
	desc = "This procedure reactivates a positronic brain inside a synthetic body, restoring it to a functional state."
	icon_state = "revival_posi"
	possible_locs = list(BODY_ZONE_HEAD)
	ignore_clothes = TRUE
	requires_bodypart_type = BODYPART_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/revive_ipc,
		/datum/surgery_step/mechanic_close
	)

/datum/surgery/synth_revival/can_start(mob/user, mob/living/target)
	if(target.stat != DEAD)
		return FALSE // they're already activated
	if(!is_synth(target))
		return FALSE
	var/obj/item/organ/brain/B = target.getorganslot(ORGAN_SLOT_BRAIN)
	if(!B) // you can't reactivate a brain that DOESN'T EXIST
		return FALSE
	return istype(target.getorganslot(ORGAN_SLOT_BRAIN), /obj/item/organ/brain/positron)
