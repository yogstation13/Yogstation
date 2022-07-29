/datum/surgery/implant_manipulation
	name = "implant manipulation"
	desc = "Manipulate implants in the patient. If you don't have an empty implant case in your other hand, the implant will be ruined on extraction."
	icon = 'icons/obj/implants.dmi'
	icon_state = "implantcase-b"
	steps = list(/datum/surgery_step/incise, 
				/datum/surgery_step/clamp_bleeders, 
				/datum/surgery_step/retract_skin, 
				/datum/surgery_step/manipulate_implant, 
				/datum/surgery_step/close)
	target_mobtypes = list(/mob/living)
	possible_locs = list(BODY_ZONE_CHEST)

/datum/surgery/implant_manipulation/mechanical
	steps = list(/datum/surgery_step/mechanic_open, 
				/datum/surgery_step/open_hatch, 
				/datum/surgery_step/prepare_electronics, 
				/datum/surgery_step/manipulate_implant, 
				/datum/surgery_step/mechanic_close)
	possible_locs = list(BODY_ZONE_CHEST)
	requires_bodypart_type = BODYPART_ROBOTIC
	lying_required = FALSE
	self_operable = TRUE

//manipulate implant
/datum/surgery_step/manipulate_implant
	name = "manipulate implant"
	implements = list(TOOL_HEMOSTAT = 100, TOOL_CROWBAR = 65, /obj/item/implantcase = 100)
	time = 6.4 SECONDS
	repeatable = TRUE
	success_sound = 'sound/surgery/hemostat1.ogg'
	var/obj/item/implant/I = null
	var/implanting = TRUE

/datum/surgery_step/manipulate_implant/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(istype(tool, /obj/item/implantcase))
		var/obj/item/implantcase/case = tool
		if(!case.imp)
			to_chat(user, span_warning("There is no implant inside of \the [case] to insert into [target]'s [target_zone]!"))
			return -1
		I = case.imp
		display_results(user, target, span_notice("You begin to insert [I] into [target]'s [target_zone]..."),
			"[user] begins to extract [I] from [target]'s [target_zone].",
			"[user] begins to extract something from [target]'s [target_zone].")
	else
		if(target.implants?.len)
			var/list/radial_menu = list()
			for(var/obj/item/implant/O in target.implants)
				radial_menu[O] = image('icons/obj/implants.dmi', icon_state = "implantcase-[O.implant_color]")
			var/choice = show_radial_menu(user, target, radial_menu, tooltips = TRUE)
			if(!choice)
				return -1
			I = choice
			implanting = FALSE
			display_results(user, target, span_notice("You begin to extract [I] from [target]'s [target_zone]..."),
				"[user] begins to extract [I] from [target]'s [target_zone].",
				"[user] begins to extract something from [target]'s [target_zone].")
		else
			display_results(user, target, span_notice("You look for an implant in [target]'s [target_zone]..."),
				"[user] looks for an implant in [target]'s [target_zone].",
				"[user] looks for something in [target]'s [target_zone].")

/datum/surgery_step/manipulate_implant/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(implanting)
		var/obj/item/implantcase/case = tool
		if(!istype(case) || !case.imp)
			to_chat(user, span_warning("There is no implant inside of \the [case] to insert into [target]'s [target_zone]!"))
			return TRUE
		case.imp.implant(target, user)
		case.imp = null
		case.update_icon()
		display_results(user, target, span_notice("You implant \the [I] into [target]'s [parse_zone(target_zone)]."),
			"[user] implants \the [I] into [target]'s [parse_zone(target_zone)]!",
			"[user] inserts something into [target]'s [parse_zone(target_zone)]!")
	else
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
	return TRUE
