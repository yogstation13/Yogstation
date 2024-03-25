//Most of these are defined at this level to reduce on checks elsewhere in the code.
//Having them here also makes for a nice reference list of the various overlay-updating procs available

///Redraws the entire mob. For carbons, this is rather expensive, please use the individual update_X procs.
/mob/proc/regenerate_icons() //TODO: phase this out completely if possible
	return

///Updates every item slot passed into it.
/mob/proc/update_clothing(slot_flags)
	return

/mob/proc/update_icons()
	return

/mob/proc/update_transform()
	return

/mob/proc/update_inv_handcuffed()
	return

/mob/proc/update_inv_legcuffed()
	return

/mob/proc/update_inv_back()
	return

///Updates the held items overlay(s) & HUD element.
/mob/proc/update_inv_hands()
	//SHOULD_CALL_PARENT(TRUE)
	//SEND_SIGNAL(src, COMSIG_MOB_UPDATE_HELD_ITEMS)
	return

/mob/proc/update_inv_wear_mask()
	return

/mob/proc/update_inv_neck()
	return

/mob/proc/update_inv_wear_suit()
	return

/mob/proc/update_inv_w_uniform()
	return

/mob/proc/update_inv_belt()
	return

/mob/proc/update_inv_head()
	return

/mob/proc/update_body()
	return

/mob/proc/update_hair()
	return

/mob/proc/update_fire()
	return

/mob/proc/update_inv_gloves()
	return

/mob/proc/update_inv_wear_id()
	return

/mob/proc/update_inv_shoes()
	return

/mob/proc/update_inv_glasses()
	return

/mob/proc/update_inv_s_store()
	return

/mob/proc/update_inv_pockets()
	return

/mob/proc/update_inv_ears()
	return
