/datum/component/fishingbonus
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/fishing_bonus = 0

/datum/component/fishingbonus/Initialize(fishing_bonus = 0)
	if(!isclothing(parent))
		return COMPONENT_INCOMPATIBLE
	src.fishing_bonus = fishing_bonus
	RegisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED), .proc/equippedChanged)

/datum/component/fishingbonus/proc/equippedChanged(datum/source, mob/living/carbon/user, slot)

