/client/proc/mark_datum(datum/D)
	if(!holder)
		return
	if(holder.marked_datum)
		holder.UnregisterSignal(holder.marked_datum, COMSIG_PARENT_QDELETING)
		vv_update_display(holder.marked_datum, "marked", "")
	holder.marked_datum = D
	holder.RegisterSignal(holder.marked_datum, COMSIG_PARENT_QDELETING, /datum/admins/proc/handle_marked_del)
	vv_update_display(D, "marked", VV_MSG_MARKED)

/datum/admins/proc/handle_marked_del(datum/source)
	UnregisterSignal(marked_datum, COMSIG_PARENT_QDELETING)
	marked_datum = null
