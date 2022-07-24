/datum/component/fishingbonus
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/fishing_bonus = 0
	var/mob/living/carbon/wearer

/datum/component/fishingbonus/Initialize(fishing_bonus = 0)
	if(!isclothing(parent))
		return COMPONENT_INCOMPATIBLE
	src.fishing_bonus = fishing_bonus
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/OnEquip)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/OnUnequip)

/datum/component/fishingbonus/proc/OnEquip(datum/source, mob/living/carbon/equipper, slot)
	var/obj/item/parent_item = parent
	if(!parent_item)
		return
	if(parent_item.slot_flags == slotdefine2slotbit(slot))
		equipper.fishing_power += fishing_bonus
		wearer = equipper

/datum/component/fishingbonus/proc/OnUnequip(datum/source, mob/living/carbon/equipper, slot)
	if(wearer)
		equipper.fishing_power -= fishing_bonus
		wearer = null
