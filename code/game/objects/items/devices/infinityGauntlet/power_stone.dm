/obj/item/infinity_stone/power
	name = "Power Stone"
	desc = "A stone that allows the wielder unlimited strength."
	icon = 'icons/obj/gauntlet.dmi'
	icon_state = "gem_3"
	item_state = "gem_3"

/datum/action/cooldown/spell/apply_mutations/mutate/power_stone
	spell_requirements = NONE

/obj/item/infinity_stone/power/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_HANDS)
		var/datum/action/cooldown/spell/apply_mutations/mutate/power_stone/power = new(user)
		power.Grant(user)

/obj/item/infinity_stone/power/dropped(mob/user)
	. = ..()
	var/datum/action/cooldown/spell/apply_mutations/mutate/power_stone/power = locate(/datum/action/cooldown/spell/apply_mutations/mutate/power_stone) in user.actions
	if(power)
		power.Remove(user)
	return ..()
