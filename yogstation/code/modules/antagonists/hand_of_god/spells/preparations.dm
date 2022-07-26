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

/datum/hog_spell_preparation/feedback
	name = "Feedback"
	description = "Grants you a spell, that allows you to shoot projectiles into your enemies, that drain energy from hostile cultists and empulse everyone else."
	cost = 40
	p_time = 4 SECONDS 
	poggy = /datum/action/innate/hog_cult/feedback

/datum/hog_spell_preparation/chain_heal
	name = "Chain Heal"
	description = "Grants you a spell, that allows you to heal your allies with chains of light."
	cost = 60
	p_time = 6 SECONDS 
	poggy = /datum/action/innate/hog_cult/chain_heal

/datum/hog_spell_preparation/berserker
	name = "Berserker"
	description = "Grants you a spell, that allows you to become immune to stuns and resistant to slowdowns, at the cost of being unable to communicate and cast spells."
	cost = 55
	p_time = 5 SECONDS 
	poggy = /datum/action/innate/hog_cult/berserker

/datum/hog_spell_preparation/lifeforce
	name = "Lifeforce Trade"
	description = "Grants you a spell, that allows you to make you absorb stuns and other immobility effects of your allied cultist."
	cost = 40
	p_time = 4 SECONDS 
	poggy = /datum/action/innate/hog_cult/lifeforce

/datum/hog_spell_preparation/cleave
	name = "Cleave"
	description = "Grants you a spell, that allows you to deal area damage with high armor penetration and cause bleeding on targets."
	cost = 35
	p_time = 4 SECONDS 
	poggy = /datum/action/innate/hog_cult/cleave

/datum/hog_spell_preparation/lifesteal
	name = "Lifesteal"
	description = "Grants you a spell, that allows you to enchant your blade attacks, making them heal you."
	cost = 35
	p_time = 4 SECONDS 
	poggy = /datum/action/innate/hog_cult/cleave
