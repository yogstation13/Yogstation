/datum/surgery/embedded_removal
	name = "Removal of embedded objects"
	desc = "Extracts objects stuck in the body such as throwing stars or spears."
	icon_state = "embedded_removal"
	steps = list(/datum/surgery_step/incise, 
				/datum/surgery_step/remove_object, 
				/datum/surgery_step/close)
	possible_locs = list(BODY_ZONE_R_ARM,BODY_ZONE_L_ARM,BODY_ZONE_R_LEG,BODY_ZONE_L_LEG,BODY_ZONE_CHEST,BODY_ZONE_HEAD)
	self_operable = TRUE

/datum/surgery/embedded_removal/can_start(mob/living/user, mob/living/carbon/target)
	if(!istype(target))
		return FALSE
	if(..())
		var/obj/item/bodypart/targeted_bodypart = target.get_bodypart(user.zone_selected)
		return(targeted_bodypart.embedded_objects?.len)

/datum/surgery/embedded_removal/mechanic
	steps = list(/datum/surgery_step/mechanic_open,
				/datum/surgery_step/open_hatch,
				/datum/surgery_step/remove_object,
				/datum/surgery_step/mechanic_close)
	requires_bodypart_type = BODYPART_ROBOTIC
	lying_required = FALSE
	self_operable = TRUE

/datum/surgery_step/remove_object
	name = "remove embedded objects"
	time = 1.5 SECONDS
	accept_hand = TRUE
	fuckup_damage = 0
	repeatable = TRUE
	preop_sound = 'sound/surgery/hemostat1.ogg'
	var/obj/item/target_item = null
	var/obj/item/bodypart/L = null

/datum/surgery_step/remove_object/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	L = surgery.operated_bodypart
	if(L)
		user.visible_message("[user] looks for objects embedded in [target]'s [parse_zone(user.zone_selected)].", span_notice("You look for objects embedded in [target]'s [parse_zone(user.zone_selected)]..."))
		display_results(user, target, span_notice("You look for objects embedded in [target]'s [parse_zone(user.zone_selected)]..."),
			"[user] looks for objects embedded in [target]'s [parse_zone(user.zone_selected)].",
			"[user] looks for something in [target]'s [parse_zone(user.zone_selected)].")
	else
		user.visible_message("[user] looks for [target]'s [parse_zone(user.zone_selected)].", span_notice("You look for [target]'s [parse_zone(user.zone_selected)]..."))


/datum/surgery_step/remove_object/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(L)
		if(iscarbon(target))
			if(L.embedded_objects)
				var/mob/living/carbon/C = target
				var/obj/item/I = pick(L.embedded_objects)
				if(C.remove_embedded_object(I, C.drop_location(), TRUE))
					display_results(user, target, span_notice("You successfully remove \the [I] from [C]'s [L.name]."),
						"[user] successfully removes \the [I] from [C]'s [L]!",
						"[user] successfully removes \the [I] from [C]'s [L]!")
				else
					to_chat(user, span_warning("You fail to remove \the [I] from [C]'s [L.name]!"))
			else
				to_chat(user, span_warning("You find no objects embedded in [target]'s [L]!"))

	else
		to_chat(user, span_warning("You can't find [target]'s [parse_zone(user.zone_selected)], let alone any objects embedded in it!"))

	return FALSE
