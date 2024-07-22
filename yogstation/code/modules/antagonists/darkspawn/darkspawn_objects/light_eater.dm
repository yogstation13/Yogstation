/obj/item/light_eater
	name = "light eater" //as opposed to heavy eater
	icon = 'yogstation/icons/obj/darkspawn_items.dmi'
	icon_state = "light_eater"
	item_state = "light_eater"
	force = 18
	lefthand_file = 'yogstation/icons/mob/inhands/antag/darkspawn_lefthand.dmi'
	righthand_file = 'yogstation/icons/mob/inhands/antag/darkspawn_righthand.dmi'
	hitsound = 'sound/weapons/bladeslice.ogg'
	item_flags = ABSTRACT
	w_class = WEIGHT_CLASS_HUGE
	sharpness = SHARP_EDGED
	wound_bonus = -40
	resistance_flags = ACID_PROOF

/obj/item/light_eater/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	AddComponent(/datum/component/butchering, 80, 70)
	AddComponent(/datum/component/light_eater)

/obj/item/light_eater/worn_overlays(mutable_appearance/standing, isinhands, icon_file) //this STILL doesn't work and i have no clue why
	. = ..()
	if(isinhands)
		. += emissive_appearance(icon_file, "[item_state]_emissive", src)
