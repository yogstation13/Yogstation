#define SPELLBOOK_CATEGORY_OFFENSIVE "Offensive"
/datum/spellbook_entry/summon_mjollnir //replacement for the majollnir item
	name = "Summon Mjollnir"
	desc = "Summons the mighty Mjollnir to you for a limited time."
	spell_type = /datum/action/cooldown/spell/conjure_item/summon_mjollnir
	category = SPELLBOOK_CATEGORY_OFFENSIVE
	cost = 2

/datum/spellbook_entry/smite
	name = "Smite"
	desc = "Allows you to call in a favor from the gods upon your foe."
	spell_type = /datum/action/cooldown/spell/pointed/smite
	category = SPELLBOOK_CATEGORY_OFFENSIVE

/datum/spellbook_entry/fire_ball
	name = "Fire Ball"
	desc = "Do you want that classic wizard zing but dont have the points to spare? This discount option provides (alomst) all the things you want out of a flaming orbular projectile!"
	spell_type = /datum/action/cooldown/spell/pointed/projectile/fireball/bouncy
	category = SPELLBOOK_CATEGORY_OFFENSIVE
	cost = 1
#undef SPELLBOOK_CATEGORY_OFFENSIVE
