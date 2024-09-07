/datum/component/garys_item
	///the gary that created us
	var/mob/living/basic/chicken/gary/gary

/datum/component/garys_item/Initialize(mob/living/basic/chicken/gary/gary)
	. = ..()
	if(!istype(gary) || QDELING(gary))
		return COMPONENT_INCOMPATIBLE
	src.gary = gary
	RegisterSignal(gary, COMSIG_QDELETING, PROC_REF(on_gary_del))
	SEND_SIGNAL(parent, COMSIG_ITEM_GARY_STASHED, gary)

/datum/component/garys_item/Destroy(force, silent)
	UnregisterSignal(gary, COMSIG_QDELETING)
	gary = null
	return ..()

/datum/component/garys_item/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_PICKUP, PROC_REF(looter))

/datum/component/garys_item/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_ITEM_PICKUP)

/datum/component/garys_item/proc/looter(datum/source, mob/taker)
	var/obj/item/source_item = parent
	gary.held_shinies -= source_item.type
	gary.hideout.remove_item(source_item)
	gary.adjust_happiness(-5, taker)
	SEND_SIGNAL(parent, COMSIG_ITEM_GARY_LOOTED, gary)
	SEND_SIGNAL(gary, COMSIG_FRIENDSHIP_CHANGE, taker, -50)// womp womp

/datum/component/garys_item/proc/on_gary_del(datum/source)
	SIGNAL_HANDLER
	qdel(src)
