
/datum/surgery/autopsy
	name = "Autopsy"
	desc = "Tells you what last damaged the patient."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scalpel"
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/autopsy)
	target_mobtypes = list(/mob/living)
	requires_bodypart_type = 0
	ignore_clothes = TRUE // just cut through the clothes
	possible_locs = list(BODY_ZONE_CHEST)

/datum/surgery/autopsy/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(iscyborg(user))
		return FALSE // this will greatly impact the siliconomy
	if(target.stat != DEAD)
		return FALSE // performing autopsy on the living is unethical

/datum/surgery_step/autopsy
	name = "perform autopsy with a sharp tool"
	implements = list(TOOL_SCALPEL = 75, /obj/item/kitchen/knife = 30, /obj/item/shard = 15)
	time = 15 SECONDS
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/scalpel2.ogg'

/datum/surgery_step/autopsy/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You begin to inspect [target]'s damage..."),
			"[user] begins to inspect [target]'s damage.",
			"[user] begins to perform surgery on [target]'s chest.")

/datum/surgery_step/autopsy/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	// Hold forensic scanner!!! Your eyes are not good at detectiving
	if(!istype(user.get_inactive_held_item(), /obj/item/detective_scanner) && prob(75)) // Small chance it works anyways though, love you doctors
		display_results(user, target, span_warning("You did not find any conclusive evidence regarding [target]'s death. Maybe you should hold a forensic scanner?"),
			span_warning("[user] did not find anything useful regarding [target]'s death. Maybe they should try again."),
			span_warning("[user] carves some holes into [target]'s chest."))
		return FALSE
	else
		display_results(user, target, span_notice("You succeed in inspecting [target]'s damage."),
			"[user] successfully inspects [target]'s damage!",
			"[user] completes the surgery on [target]'s chest.")
		to_chat(user, span_notice("It seems this dealt the killing blow to [target]: [target.last_damage]"))
		target.apply_damage(200, BRUTE, "[target_zone]") // you are a very bad doctor
		return TRUE

/datum/surgery_step/autopsy/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_warning("You did not find any conclusive evidence regarding [target]'s death. Maybe try again?"),
			span_warning("[user] did not find anything useful regarding [target]'s death. Maybe they should try again."),
			span_warning("[user] carves some holes into [target]'s chest."))
	return FALSE
