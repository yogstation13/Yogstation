/obj/machinery/door/airlock/proc/apply_feeble_delay(mob/user, action)
	if(!HAS_TRAIT(user, TRAIT_FEEBLE))
		return FALSE
	if(!feeble_callback())
		return TRUE
	user.visible_message(span_notice("[user] struggles to [action] the airlock."), \
		span_notice("You struggle to [action] the airlock."))
	return !do_after(user, 4 SECONDS, target = src, extra_checks = CALLBACK(src, TYPE_PROC_REF(/obj/machinery/door/airlock, feeble_callback)))

/obj/machinery/door/airlock/proc/feeble_callback()
	if( operating || welded || locked || seal )
		return FALSE
	return TRUE
