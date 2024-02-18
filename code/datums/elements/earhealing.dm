/datum/element/earhealing
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY
	var/list/user_by_item = list()

/datum/element/earhealing/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignals(target, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED), PROC_REF(on_equip))

/datum/element/earhealing/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
	user_by_item -= target

/datum/element/earhealing/proc/on_equip(datum/source, mob/living/carbon/user, slot)
	SIGNAL_HANDLER

	if((slot & ITEM_SLOT_EARS) && istype(user))
		START_PROCESSING(SSdcs, src)
		user_by_item[source] = user
	else
		user_by_item -= source

/datum/element/earhealing/process(seconds_per_tick)
	for(var/i in user_by_item)
		var/mob/living/carbon/user = user_by_item[i]
		if(HAS_TRAIT(user, TRAIT_DEAF))
			continue
		var/obj/item/organ/ears/ears = user.getorganslot(ORGAN_SLOT_EARS)
		if(!ears)
			continue
		ears.deaf = max(ears.deaf - 0.25, (ears.damage < ears.maxHealth ? 0 : 1)) // Do not clear deafness if our ears are too damaged
		ears.damage = max(ears.damage - 0.025, 0)
		CHECK_TICK
