/obj/item/skill_injector
	name = "skilltrainer"
	desc = "A sophisticated-looking injector. Utilizes nanites to enhance skills of the user."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "mechserum0"
	item_state = "medipen"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	var/used = FALSE
	var/amount_to_give = EXP_MASTER

/obj/item/skill_injector/examine(mob/user)
	. = ..()
	if(used)
		. += span_notice("It is spent.")
	else
		. += span_notice("It is currently loaded.")

/obj/item/skill_injector/interact(mob/user)
	. = ..()
	start_injecting(user, user)

/obj/item/skill_injector/pre_attack(atom/target, mob/living/user, params)
	. = ..()
	if(.)
		return
	if(!ishuman(target))
		return
	start_injecting(target, user)
	return TRUE

/obj/item/skill_injector/proc/start_injecting(mob/living/target, mob/living/user)
	if(used)
		to_chat(user, span_warning("[src] is empty!"))
		return
	if(target == user)
		to_chat(target, span_warning("You begin to use [src]."))
	else
		to_chat(target, span_warning("You feel a tiny prick!"))
		to_chat(user, span_notice("You begin to inject [target] with [src]."))
	if(!do_after(user, 3 SECONDS, target))
		return
	if(target == user)
		target.visible_message(span_danger("[user] injects themselves with [src]!"), span_warning("You inject yourself with [src]."), vision_distance = COMBAT_MESSAGE_RANGE)
	else
		target.visible_message(span_danger("[user] injects [target] with [src]!"), span_userdanger("[user] injects you with [src]!"), vision_distance = COMBAT_MESSAGE_RANGE)
	playsound(src, 'sound/items/autoinjector.ogg', 25)
	target.add_skill_points(amount_to_give)
	used = TRUE

/obj/item/skill_injector/advanced
	amount_to_give = EXP_GENIUS + EXP_LOW
