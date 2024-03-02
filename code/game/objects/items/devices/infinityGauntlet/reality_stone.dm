/obj/item/infinity_reality_stone
	name = "Reality Stone"
	desc = "A stone that allows the wielder to control the fabric of reality."
	icon = 'icons/obj/gauntlet.dmi'
	icon_state = "gem_6"
	item_state = "gem_6"


/datum/action/cooldown/spell/spacetime_dist/reality_stone
	spell_requirements = NONE

/obj/item/infinity_reality_stone/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_HANDS)
		var/datum/action/cooldown/spell/spacetime_dist/reality_stone/reality = new(user)
		reality.Grant(user)

/obj/item/infinity_reality_stone/dropped(mob/user)
	. = ..()
	var/datum/action/cooldown/spell/spacetime_dist/reality_stone/reality = locate(/datum/action/cooldown/spell/spacetime_dist/reality_stone) in user.actions
	if(reality)
		reality.Remove(user)
	return ..()

