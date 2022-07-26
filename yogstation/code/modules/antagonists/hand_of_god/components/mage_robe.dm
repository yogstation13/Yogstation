/datum/component/mage_robe
	var/datum/team/hog_cult/cult

/datum/component/mage_robe/Initialize()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/mage_robe/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/add_trait)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/remove_trait)

/datum/component/mage_robe/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED,COMSIG_ITEM_DROPPED))

/datum/component/mage_robe/proc/add_trait(obj/item/source, mob/user, slot)

	if(!(source.slot_flags & slot))
		return
	if(!IS_HOG_CULTIST(user))
		return

	ADD_TRAIT(user, TRAIT_CULTIST_ROBED, ELEMENT_TRAIT(source))

/datum/component/mage_robe/proc/remove_trait(obj/item/source, mob/user)
	REMOVE_TRAIT(user, TRAIT_CULTIST_ROBED, ELEMENT_TRAIT(source))


