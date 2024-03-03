/obj/item/infinity_soul_stone
	name = "Soul Stone"
	desc = "A stone that allows the wielder to swap souls with another."
	icon = 'icons/obj/gauntlet.dmi'
	icon_state = "gem_5"
	item_state = "gem_5"

/datum/action/cooldown/spell/pointed/mind_transfer/soul_stone
	spell_requirements = NONE
	unconscious_amount_victim = 2 SECONDS

/obj/item/infinity_soul_stone/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_HANDS)
		var/datum/action/cooldown/spell/pointed/mind_transfer/soul_stone/soulswap = new(user)
		soulswap.Grant(user)

/obj/item/infinity_soul_stone/dropped(mob/user)
	. = ..()
	var/datum/action/cooldown/spell/pointed/mind_transfer/soul_stone/soulswap = locate(/datum/action/cooldown/spell/pointed/mind_transfer/soul_stone) in user.actions
	if(soulswap)
		soulswap.Remove(user)
	return ..()

