/datum/hog_spell_preparation/empower
	name = "Empower"
	description = "Empowers your tome with power, allowing to deal stamina damage and stun people on disarm intent."
	cost = 40
	p_time = 4 SECONDS 
	poggy = null //No poggy

/datum/hog_spell_preparation/empower/on_prepared(mob/user, datum/antagonist/hog/antag_datum, obj/item/hog_item/book/tome)
	if(tome.charges >= 4)
		to_chat(user,span_warning("The [tome] is already charged!"))
		return
	..()
	tome.charges += 2
	if(tome.charges > 4)
		tome.charges = 4

/datum/hog_spell_preparation/empower/give_spell(mob/user, datum/antagonist/hog/antag_datum)
	return //We don't give any spells!!!!!!