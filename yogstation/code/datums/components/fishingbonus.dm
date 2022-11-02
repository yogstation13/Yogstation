/datum/component/fishingbonus
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/fishing_bonus = 0
	var/mob/living/carbon/user

/datum/component/fishingbonus/Initialize(fishing_bonus = 0)
	src.fishing_bonus = fishing_bonus
	if(isclothing(parent))
		RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/OnEquip)
		RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/OnUnequip)
	else if(ismovable(parent))
		RegisterSignal(parent, COMSIG_MOVABLE_BUCKLE, .proc/OnBuckle)
		RegisterSignal(parent, COMSIG_MOVABLE_UNBUCKLE, .proc/OnUnbuckle)
	else
		return COMPONENT_INCOMPATIBLE

/datum/component/fishingbonus/proc/OnEquip(datum/source, mob/living/carbon/equipper, slot)
	var/obj/item/parent_item = parent
	if(!parent_item)
		return
	if(parent_item.slot_flags == slotdefine2slotbit(slot))
		equipper.fishing_power += fishing_bonus
		user = equipper

/datum/component/fishingbonus/proc/OnUnequip(datum/source, mob/living/carbon/equipper, slot)
	if(user)
		equipper.fishing_power -= fishing_bonus
		user = null

/datum/component/fishingbonus/proc/OnBuckle(datum/source, mob/living/carbon/M, force = FALSE)
	var/obj/vehicle/ride = parent
	if(!ride)
		return
	if(M in ride.occupants)
		M.fishing_power += fishing_bonus
		user = M

/datum/component/fishingbonus/proc/OnUnbuckle(datum/source, mob/living/carbon/M, force = FALSE)
	if(user)
		M.fishing_power -= fishing_bonus
		user = null
