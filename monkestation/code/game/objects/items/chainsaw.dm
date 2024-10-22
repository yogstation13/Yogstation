/obj/item/chainsaw/doomslayer
	var/list/nemesis_factions = list(FACTION_MINING, FACTION_BOSS)
	var/nemesis_damage_multiplier = 5 // Makes it deal 30 * 5 (150) damage to fauna.

/obj/item/chainsaw/doomslayer/attack_self(mob/user)
	if(on && user.has_status_effect(/datum/status_effect/mayhem))
		to_chat(user, span_warning("There is no escape. RIP. AND. TEAR."))
		return
	return ..()

/obj/item/chainsaw/doomslayer/attack(mob/living/target_mob, mob/living/user, params)
	if(target_mob == user) // Prevents you from hitting yourself with it. (as well as getting lifesteal from doing so)
		return

	var/bonus_applied = FALSE
	for(var/faction in target_mob.faction)
		if(faction in nemesis_factions)
			bonus_applied = TRUE
			force *= nemesis_damage_multiplier
			break

	. = ..()

	if(bonus_applied)
		force /= nemesis_damage_multiplier

	var/healing_amount = force / initial(force) * 3 // 3 healing per hit on people and 15 on fauna.
	user.heal_overall_damage(healing_amount, healing_amount)

/obj/item/chainsaw/doomslayer/equipped(mob/user, slot, initial)
	. = ..()
	if(slot != ITEM_SLOT_HANDS)
		return
	ADD_TRAIT(user, TRAIT_CANT_STRIP, REF(src)) // Pairs well with returning early when you try to attack yourself. LET THE SHUFFLEFEST COMMENCE!!

/obj/item/chainsaw/doomslayer/dropped(mob/user, silent)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_CANT_STRIP, REF(src))
