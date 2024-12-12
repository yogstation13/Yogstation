///////////////////////////////////
////////  Mecha wreckage   ////////
///////////////////////////////////

// Mapping helpers, real mechs no longer create a separate object when wrecked.
/obj/structure/mecha_wreckage
	name = "exosuit wreckage"
	desc = "Remains of some unfortunate mecha, damaged beyond repair."
	icon = 'icons/mecha/mecha.dmi'
	density = TRUE
	anchored = FALSE
	opacity = FALSE
	var/orig_mecha = /obj/mecha
	var/repairable = FALSE

/obj/structure/mecha_wreckage/Initialize(mapload, mob/living/silicon/ai/AI_pilot)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/mecha_wreckage/LateInitialize()
	. = ..()
	var/obj/mecha/new_mecha = new orig_mecha(loc)
	if(!repairable)
		new_mecha.name = name
		new_mecha.desc = desc
		if(new_mecha.capacitor)
			QDEL_NULL(new_mecha.capacitor)
	new_mecha.atom_break()
	qdel(src)

/obj/structure/mecha_wreckage/examine(mob/user)
	. = ..()
	var/damage_msg = "There was no capacitor to save this poor mecha from its doomed fate"
	if(user.skill_check(SKILL_MECHANICAL, EXP_GENIUS) || user.skill_check(SKILL_MECHANICAL, EXP_GENIUS))
		damage_msg = ", but you think you could get it working again..."
	else
		damage_msg = "! It cannot be repaired!"
	. += span_warning(damage_msg)

/obj/structure/mecha_wreckage/gygax
	name = "\improper Gygax wreckage"
	icon_state = "gygax-broken"
	orig_mecha = /obj/mecha/combat/gygax

/obj/structure/mecha_wreckage/gygax/dark
	name = "\improper Dark Gygax wreckage"
	icon_state = "darkgygax-broken"
	orig_mecha = /obj/mecha/combat/gygax/dark

/obj/structure/mecha_wreckage/marauder
	name = "\improper Marauder wreckage"
	icon_state = "marauder-broken"
	orig_mecha = /obj/mecha/combat/marauder

/obj/structure/mecha_wreckage/mauler
	name = "\improper Mauler wreckage"
	icon_state = "mauler-broken"
	desc = "The Syndicate won't be very happy about this..."
	orig_mecha = /obj/mecha/combat/marauder/mauler

/obj/structure/mecha_wreckage/seraph
	name = "\improper Seraph wreckage"
	icon_state = "seraph-broken"
	orig_mecha = /obj/mecha/combat/marauder/seraph

/obj/structure/mecha_wreckage/reticence
	name = "\improper Reticence wreckage"
	icon_state = "reticence-broken"
	color = "#87878715"
	desc = "..."
	orig_mecha = /obj/mecha/combat/reticence

/obj/structure/mecha_wreckage/ripley
	name = "\improper Ripley wreckage"
	icon_state = "ripley-broken"
	orig_mecha = /obj/mecha/working/ripley

/obj/structure/mecha_wreckage/ripley/firefighter
	name = "\improper Firefighter wreckage"
	icon_state = "firefighter-broken"
	orig_mecha = /obj/mecha/working/ripley/firefighter
	
/obj/structure/mecha_wreckage/clarke
	name = "\improper Clarke wreckage"
	icon_state = "clarke-broken"
	orig_mecha = /obj/mecha/working/clarke

/obj/structure/mecha_wreckage/ripley/deathripley
	name = "\improper Death-Ripley wreckage"
	icon_state = "deathripley-broken"
	orig_mecha = /obj/mecha/working/ripley/deathripley

/obj/structure/mecha_wreckage/honker
	name = "\improper H.O.N.K wreckage"
	icon_state = "honker-broken"
	desc = "All is right in the universe."
	orig_mecha = /obj/mecha/combat/honker

/obj/structure/mecha_wreckage/durand
	name = "\improper Durand wreckage"
	icon_state = "durand-broken"
	orig_mecha = /obj/mecha/combat/durand

/obj/structure/mecha_wreckage/phazon
	name = "\improper Phazon wreckage"
	icon_state = "phazon-broken"
	orig_mecha = /obj/mecha/combat/phazon

/obj/structure/mecha_wreckage/odysseus
	name = "\improper Odysseus wreckage"
	icon_state = "odysseus-broken"
	orig_mecha = /obj/mecha/medical/odysseus

/obj/structure/mecha_wreckage/sidewinder
	name = "\improper Sidewinder wreckage"
	icon_state = "sidewinder-broken"
	desc = "It continues to twitch, as if barely alive."
	orig_mecha = /obj/mecha/combat/sidewinder

/obj/structure/mecha_wreckage/sidewinder/mamba
	name = "\improper mamba wreckage"
	icon_state = "mamba-broken"
	orig_mecha = /obj/mecha/combat/sidewinder/mamba
