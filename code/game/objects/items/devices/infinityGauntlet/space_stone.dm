/obj/item/infinity_stone_space
	name = "Space Stone"
	desc = "A stone that allows the weilder to control all of space."
	icon = 'icons/obj/gauntlet.dmi'
	icon_state = "gem_2"
	item_state = "gem_2"

/obj/item/infinity_stone_space/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_HANDS)
		var/datum/action/cooldown/spell/jaunt/ethereal_jaunt/jaunt = new(user)
		jaunt.Grant(user)

/obj/item/infinity_stone_space/dropped(mob/user)
	. = ..()
	if(user.get_item_by_slot(ITEM_SLOT_HANDS)==src)
		var/datum/action/cooldown/spell/jaunt/ethereal_jaunt/jaunt = locate(/datum/action/cooldown/spell/jaunt/ethereal_jaunt) in user.actions
		if(jaunt)
			jaunt.Remove(user)
	return ..()

