/datum/action/cooldown/spell/touch/pacifism
	name = "Pacify"
	desc = "This spell charges your hand with pure pacifism, alows to pacify your targets and turn them into gondolas. Also temporary mutes them."
	hand_path = /obj/item/melee/touch_attack/pacifism
	button_icon_state = "gondola"
	sound = 'sound/magic/wandodeath.ogg'
	cooldown_time = 1 MINUTES
	cooldown_reduction_per_rank = 12.5 SECONDS
	invocation = "PAC'FY"
	school = SCHOOL_EVOCATION

	button_icon = 'icons/mob/gondolas.dmi'

/datum/action/cooldown/spell/touch/pacifism/is_valid_target(atom/cast_on)
	return iscarbon(cast_on)

/datum/action/cooldown/spell/touch/pacifism/cast_on_hand_hit(obj/item/melee/touch_attack/hand, mob/living/carbon/victim, mob/living/carbon/caster)
	victim.reagents.add_reagent(/datum/reagent/pax, 5)
	victim.reagents.add_reagent(/datum/reagent/toxin/mutetoxin, 5)
	victim.ForceContractDisease(new /datum/disease/transformation/gondola(), FALSE, TRUE)
	return TRUE

/obj/item/melee/touch_attack/pacifism
	name = "\improper pacifism touch"
	desc = "Yes"
	icon_state = "flagellation"
	item_state = "hivehand"
	color = "#FF0000"

/datum/spellbook_entry/pacify
	name = "Pacify"
	desc = "Charges your hand with the bower to infect victims with a beaceful virus."
	spell_type = /datum/action/cooldown/spell/touch/pacifism
	category = "Offensive"
