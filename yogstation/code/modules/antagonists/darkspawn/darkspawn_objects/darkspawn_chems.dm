//////////////////////////////////////////////////////////////////////////
//--------------------------Used for icy veins--------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/reagent/shadowfrost
	name = "Shadowfrost"
	description = "A dark liquid that seems to slow down anything that comes into contact with it."
	color = "#000000" //Complete black (RGB: 0, 0, 0)

/datum/reagent/shadowfrost/on_mob_metabolize(mob/living/L)
	..()
	L.add_movespeed_modifier(type, update=TRUE, priority=100, multiplicative_slowdown=2)

/datum/reagent/shadowfrost/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(type)
	..()

//////////////////////////////////////////////////////////////////////////
//-----------------------Used for darkness smoke------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/reagent/darkspawn_darkness_smoke
	name = "odd black liquid"
	description = "<::ERROR::> CANNOT ANALYZE REAGENT <::ERROR::>"
	color = "#000000" //Complete black (RGB: 0, 0, 0)

/datum/reagent/darkspawn_darkness_smoke/on_mob_add(mob/living/L)
	. = ..()
	ADD_TRAIT(L, TRAIT_DARKSPAWN_CREEP, type)

/datum/reagent/darkspawn_darkness_smoke/on_mob_delete(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_DARKSPAWN_CREEP, type)
	. = ..()

/datum/reagent/darkspawn_darkness_smoke/on_mob_life(mob/living/M)
	if(!is_darkspawn_or_veil(M))
		to_chat(M, span_warning("<b>The pitch black smoke irritates your eyes horribly!</b>"))
		M.blind_eyes(5)
		if(prob(25))
			M.visible_message("<b>[M]</b> claws at their eyes!")
			M.Stun(3, 0)
	else
		to_chat(M, span_velvet("<b>You breathe in the black smoke and feel revitalized!</b>"))
		M.adjustOxyLoss(-5, 0)
		M.adjustToxLoss(-2, 0)

	volume = clamp(volume, 0, 2)//have at most 2u at any time
	holder.remove_reagent(type, 1)//tick down at 1u at a time
