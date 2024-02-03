/obj/item/pen/fountain/survival
	name = "survival pen"
	desc = "The latest in portable survival technology, this pen was designed as a miniature hardlight shovel. Watchers find them very desirable for their diamond exterior."
	icon = 'modular_dripstation/icons/obj/bureaucracy.dmi'
	icon_state = "digging_pen"
	item_state = "pen"
	force = 8 //hard light beats hard, still weaker than the kitchen knife
	throwforce = 0 //ineffective at long range
	sharpness = SHARP_EDGED // Sharp shovel
	resistance_flags = FIRE_PROOF //lavaland is dangerous
	attack_verb = list("robusted", "slashed", "stabbed", "sliced", "thrashed", "whacked")
	custom_materials = list(/datum/material/iron = 100, /datum/material/diamond = 200, /datum/material/titanium = 100)
	pressure_resistance = 2 * ONE_ATMOSPHERE
	grind_results = list(/datum/reagent/iron = 2, /datum/reagent/iodine = 1)
	tool_behaviour = TOOL_MINING //For the classic "digging out of prison with a spoon but you're in space so this analogy doesn't work" situation.
	toolspeed = 2 //You will never willingly choose to use one of these over a shovel.
	hitsound = 'sound/weapons/blade1.ogg'

/obj/item/pen/fountain/survival/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 60, 100, 0, 'sound/weapons/blade1.ogg') //it's a strange hardlight tech