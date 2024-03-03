/obj/item/infinity_stone/mind
	name = "Mind Stone"
	desc = "A stone that allows the wielder to affect the minds of those around them by telepathically blasting them away."
	icon = 'icons/obj/gauntlet.dmi'
	icon_state = "gem_2"
	item_state = "gem_2"

/datum/action/cooldown/spell/aoe/repulse/wizard/mind_stone
	spell_requirements = NONE

/obj/item/infinity_stone/mind/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_HANDS)
		var/datum/action/cooldown/spell/aoe/repulse/wizard/mind_stone/repulse = new(user)
		repulse.Grant(user)

/obj/item/infinity_stone/mind/dropped(mob/user)
	. = ..()
	var/datum/action/cooldown/spell/aoe/repulse/wizard/mind_stone/repulse = locate(/datum/action/cooldown/spell/aoe/repulse/wizard/mind_stone) in user.actions
	if(repulse)
		repulse.Remove(user)
	return ..()

