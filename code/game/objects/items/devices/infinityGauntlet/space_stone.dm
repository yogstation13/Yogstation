/obj/item/infinity_stone_space
	name = "Space Stone"
	desc = "A stone that allows the wielder to control all of space."
	icon = 'icons/obj/gauntlet.dmi'
	icon_state = "gem_1"
	item_state = "gem_1"

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/space_stone
	spell_requirements = NONE

/obj/item/infinity_stone_space/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_HANDS)
		var/datum/action/cooldown/spell/jaunt/ethereal_jaunt/space_stone/jaunt = new(user)
		jaunt.Grant(user)

/obj/item/infinity_stone_space/dropped(mob/user)
	. = ..()
	var/datum/action/cooldown/spell/jaunt/ethereal_jaunt/space_stone/jaunt = locate(/datum/action/cooldown/spell/jaunt/ethereal_jaunt/space_stone) in user.actions
	if(jaunt)
		jaunt.Remove(user)
	return ..()

