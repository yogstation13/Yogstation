/datum/spellbook_entry/item/magical_chemsprayer
	name = "Magic Chem Sprayer"
	desc = "A magic chemical sprayer that will fill itself with unlimited random chemicals. Now with protective gear!"
	item_path = /obj/item/reagent_containers/spray/chemsprayer/magical
	category = "Defensive"
	cost = 1

//if still too weak I could also give galoshes
/datum/spellbook_entry/item/magical_chemsprayer/try_equip_item(mob/living/carbon/human/user, obj/item/to_equip)
	. = ..()
	var/turf/user_turf = get_turf(user)
	if(!user_turf)
		return

	for(var/obj/item/thing as anything in list(/obj/item/clothing/gloves/combat/wizard, /obj/item/clothing/head/wizard/bio_suit, /obj/item/clothing/suit/wizrobe/bio_suit))
		thing = new thing(user_turf)
		user.equip_to_appropriate_slot(thing)

/datum/spellbook_entry/item/reactive_talisman
	name = "Reactive Talisman"
	desc = "An enchanted talisman that has a chance to cast a spell if it's wearer is hit."
	item_path = /obj/item/clothing/neck/neckless/wizard_reactive
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/item/mirror_shield
	name = "Mirror Shield"
	desc = "A mirror that will absorb projectiles shot into it to later be shot back out at your convenience."
	item_path = /obj/item/gun/magic/mirror_shield
	category = "Defensive"
	cost = 2

/datum/spellbook_entry/item/armor
	cost = 1
