/obj/item/infinity_stone/time
	name = "Time Stone"
	desc = "A stone that allows the wielder to control time itself."
	icon = 'icons/obj/gauntlet.dmi'
	icon_state = "gem_4"
	item_state = "gem_4"

/datum/action/cooldown/spell/timestop/time_stone
	spell_requirements = NONE

/obj/item/infinity_stone/time/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_HANDS)
		var/datum/action/cooldown/spell/timestop/time_stone/time = new(user)
		time.Grant(user)

/obj/item/infinity_stone/time/dropped(mob/user)
	. = ..()
	var/datum/action/cooldown/spell/timestop/time_stone/time = locate(/datum/action/cooldown/spell/timestop/time_stone) in user.actions
	if(time)
		time.Remove(user)
	return ..()
