/datum/surgery/implant_removal
	name = "implant removal"
	desc = "Extracts implants from the patient. If you don't have an empty implant case in your other hand, the implant will be ruined on extraction."
	icon = 'icons/obj/implants.dmi'
	icon_state = "implantcase-b"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/extract_implant, /datum/surgery_step/close)
	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_CHEST)

/datum/surgery/implant_removal/mechanical
	name = "Prosthesis implant removal"
	steps = list(/datum/surgery_step/mechanic_open, /datum/surgery_step/open_hatch, /datum/surgery_step/prepare_electronics, /datum/surgery_step/extract_implant, /datum/surgery_step/mechanic_close)
	possible_locs = list(BODY_ZONE_CHEST)
	requires_bodypart_type = BODYPART_ROBOTIC
	lying_required = FALSE
	self_operable = TRUE

//extract implant
/datum/surgery_step/extract_implant
	name = "extract implant"
	implements = list(TOOL_HEMOSTAT = 100, TOOL_CROWBAR = 65)
	time = 6.4 SECONDS
	success_sound = 'sound/surgery/hemostat1.ogg'
	var/obj/item/implant/I = null

/datum/surgery_step/extract_implant/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	for(var/obj/item/O in target.implants)
		I = O
		break
	if(I)
		display_results(user, target, span_notice("You begin to extract [I] from [target]'s [target_zone]..."),
			"[user] begins to extract [I] from [target]'s [target_zone].",
			"[user] begins to extract something from [target]'s [target_zone].")
	else
		display_results(user, target, span_notice("You look for an implant in [target]'s [target_zone]..."),
			"[user] looks for an implant in [target]'s [target_zone].",
			"[user] looks for something in [target]'s [target_zone].")

/datum/surgery_step/extract_implant/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(I)
		I.removed(target)
		if (QDELETED(I)) // yogs: properly handle self-deleting implants
			display_results(user, target, span_notice("You remove [I] from [target]'s [target_zone], destroying it in the process!"),
				"[user] removes [I] from [target]'s [target_zone], destroying it in the process!",
				"[user] removes something from [target]'s [target_zone], destroying it in the process!")
		else
			display_results(user, target, span_notice("You successfully remove [I] from [target]'s [target_zone]."),
				"[user] successfully removes [I] from [target]'s [target_zone]!",
				"[user] successfully removes something from [target]'s [target_zone]!")
			var/obj/item/implantcase/case
			for(var/obj/item/implantcase/ic in user.held_items)
				case = ic
				break
			if(!case)
				case = locate(/obj/item/implantcase) in get_turf(target)
			if(case && !case.imp)
				case.imp = I
				I.forceMove(case)
				case.update_icon()
				display_results(user, target, span_notice("You place [I] into [case]."),
					"[user] places [I] into [case]!",
					"[user] places it into [case]!")
			else
				qdel(I)

	else
		to_chat(user, span_warning("You can't find anything in [target]'s [target_zone]!"))
	return 1

/datum/surgery/implant_removal/mechanic
	name = "implant removal"
	requires_bodypart_type = BODYPART_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/extract_implant,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close)
