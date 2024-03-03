/obj/item/infinity_stone
	desc = "you shouldn't have this"
	var/ability_type
	var/datum/action/ability

/obj/item/infinity_stone/proc/install(obj/item/clothing/gloves/infinity/gauntlets, mob/user)
	if(!istype(gauntlets))
		return FALSE
	if(locate(ability_type) in gauntlets.abilities) //if they already have that infinity gem somehow
		return FALSE
	if(!user.transferItemToLoc(src, gauntlets))
		return FALSE

	to_chat(user, span_narsie("ligma balls"))
	if(!ability)
		ability = new ability_type()
	gauntlets.abilities |= ability
	gauntlets.update_abilities(user)
		
/obj/item/infinity_stone/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_HANDS && ability_type)
		if(!ability)
			ability = new ability_type()
		ability.Grant(user)

/obj/item/infinity_stone/dropped(mob/user)
	. = ..()
	if(ability)
		ability.Remove(user)
		qdel(ability)
	return ..()

///////////////////////////////////////////////////////////////////////////
//-------------------------Specific Stones-------------------------------//
///////////////////////////////////////////////////////////////////////////
//number 1 - space
/obj/item/infinity_stone/space
	name = "Space Stone"
	desc = "A stone that allows the wielder to control all of space."
	icon = 'icons/obj/gauntlet.dmi'
	icon_state = "gem_1"
	item_state = "gem_1"
	ability_type = /datum/action/cooldown/spell/jaunt/ethereal_jaunt/space_stone

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/space_stone
	spell_requirements = NONE

//number 2 - mind
/obj/item/infinity_stone/mind
	name = "Mind Stone"
	desc = "A stone that allows the wielder to affect the minds of those around them by telepathically blasting them away."
	icon = 'icons/obj/gauntlet.dmi'
	icon_state = "gem_2"
	item_state = "gem_2"
	ability_type = /datum/action/cooldown/spell/aoe/repulse/wizard/mind_stone

/datum/action/cooldown/spell/aoe/repulse/wizard/mind_stone
	spell_requirements = NONE

//number 3 - power
/obj/item/infinity_stone/power
	name = "Power Stone"
	desc = "A stone that allows the wielder unlimited strength."
	icon = 'icons/obj/gauntlet.dmi'
	icon_state = "gem_3"
	item_state = "gem_3"
	ability_type = /datum/action/cooldown/spell/apply_mutations/mutate/power_stone

/datum/action/cooldown/spell/apply_mutations/mutate/power_stone
	spell_requirements = NONE

//number 4 - time
/obj/item/infinity_stone/time
	name = "Time Stone"
	desc = "A stone that allows the wielder to control time itself."
	icon = 'icons/obj/gauntlet.dmi'
	icon_state = "gem_4"
	item_state = "gem_4"
	ability_type = /datum/action/cooldown/spell/timestop/time_stone

/datum/action/cooldown/spell/timestop/time_stone
	spell_requirements = NONE

//number 5 - soul
/obj/item/infinity_stone/soul
	name = "Soul Stone"
	desc = "A stone that allows the wielder to swap souls with another."
	icon = 'icons/obj/gauntlet.dmi'
	icon_state = "gem_5"
	item_state = "gem_5"
	ability_type = /datum/action/cooldown/spell/pointed/mind_transfer/soul_stone

/datum/action/cooldown/spell/pointed/mind_transfer/soul_stone
	spell_requirements = NONE
	unconscious_amount_victim = 2 SECONDS

//number 6 - reality
/obj/item/infinity_stone/reality
	name = "Reality Stone"
	desc = "A stone that allows the wielder to control the fabric of reality."
	icon = 'icons/obj/gauntlet.dmi'
	icon_state = "gem_6"
	item_state = "gem_6"
	ability_type = /datum/action/cooldown/spell/spacetime_dist/reality_stone

/datum/action/cooldown/spell/spacetime_dist/reality_stone
	spell_requirements = NONE
