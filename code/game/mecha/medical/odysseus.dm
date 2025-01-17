/obj/mecha/medical/odysseus
	desc = "These exosuits are developed and produced by Vey-Med. (&copy; All rights reserved)."
	name = "\improper Odysseus"
	icon_state = "odysseus"
	step_in = 2
	armor = list(MELEE = 20, BULLET = 10, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 100, ELECTRIC = 75)
	max_temperature = 15000
	max_integrity = 240
	integrity_failure = 120
	internal_damage_threshold = 35
	deflect_chance = 15

/obj/mecha/medical/odysseus/moved_inside(mob/living/carbon/human/H)
	. = ..()
	if(.)
		var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
		hud.show_to(H)

/obj/mecha/medical/odysseus/go_out()
	if(isliving(occupant))
		var/mob/living/L = occupant
		var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
		hud.hide_from(L)
	..()

/obj/mecha/medical/odysseus/mmi_moved_inside(obj/item/mmi/mmi_as_oc, mob/user)
	. = ..()
	if(.)
		var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
		var/mob/living/brain/B = mmi_as_oc.brainmob
		hud.show_to(B)
