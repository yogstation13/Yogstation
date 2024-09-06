/datum/bounty/item/progression
	var/list/unlocked_crates = list()

/datum/bounty/progression/reward_string()
	return "[reward] Credits and clearance to order new crates"

/datum/bounty/item/progression/claim(mob/user)
	..()
	for(var/i in unlocked_crates)
		var/datum/supply_pack/to_unlock = SSshuttle.supply_packs[i]
		to_unlock.special_enabled = TRUE


