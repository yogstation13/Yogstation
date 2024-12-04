/obj/machinery/door/firedoor/try_to_crowbar(obj/item/acting_object, mob/user)
	if(apply_feeble_delay(user, density ? "open" : "close"))
		return
	. = ..()

/obj/machinery/door/firedoor/try_to_crowbar_secondary(obj/item/acting_object, mob/user)
	if(apply_feeble_delay(user, density ? "open" : "close"))
		return
	. = ..()

/obj/machinery/door/firedoor/proc/apply_feeble_delay(mob/user, action)
	if(!HAS_TRAIT(user, TRAIT_FEEBLE))
		return FALSE
	if(!feeble_callback())
		return TRUE
	user.visible_message(span_notice("[user] struggles to [action] the firelock."), \
		span_notice("You struggle to [action] the firelock."))
	return !do_after(user, 4 SECONDS, target = src, extra_checks = CALLBACK(src, TYPE_PROC_REF(/obj/machinery/door/firedoor, feeble_callback)))

/obj/machinery/door/firedoor/proc/feeble_callback()
	if(welded || operating)
		return FALSE
	return TRUE
