/datum/action/cooldown/spell/touch/null_charge
	name = "Null Charge"
	desc = "Empties an APC, preventing it from recharging until fixed."
	button_icon = 'yogstation/icons/mob/actions.dmi'
	button_icon_state = "null_charge"

	cooldown_time = 30 SECONDS
	antimagic_flags = NONE
	panel = null
	check_flags =  AB_CHECK_IMMOBILE|AB_CHECK_CONSCIOUS | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_DARKSPAWN
	psi_cost = 15
	hand_path = /obj/item/melee/touch_attack/null_charge

/datum/action/cooldown/spell/touch/null_charge/is_valid_target(atom/cast_on)
	return istype(cast_on, /obj/machinery/power/apc)

/datum/action/cooldown/spell/touch/null_charge/cast_on_hand_hit(obj/item/melee/touch_attack/hand, /obj/machinery/power/apc/target, mob/living/carbon/human/caster)
	if(!target || !istype(target))//sanity check
		return FALSE

	//Turn it off for the time being
	target.set_light(0)
	target.visible_message(span_warning("The [target] flickers and begins to grow dark."))

	to_chat(caster, span_velvet("You dim the APC's screen and carefully begin siphoning its power into the void."))
	if(!do_after(caster, 5 SECONDS, target))
		//Whoops!  The APC's light turns back on
		to_chat(caster, span_velvet("Your concentration breaks and the APC suddenly repowers!"))
		target.set_light(2)
		target.visible_message(span_warning("The [target] begins glowing brightly!"))
	else
		//We did it
		to_chat(caster, span_velvet("You return the APC's power to the void, disabling it."))
		target.cell?.charge = 0	//Sent to the shadow realm
		target.chargemode = 0 //Won't recharge either until an engineer hits the button
		target.charging = 0
		target.update_appearance(UPDATE_ICON)

/obj/item/melee/touch_attack/null_charge
	name = "null charge"
	desc = "Succ that power boi."
	icon_state = "flagellation"
	item_state = "hivemind"
