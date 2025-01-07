/mob/living/basic/pet/cat/syndicat
	name = "Syndie Cat"
	desc = "OH GOD! RUN!! IT CAN SMELL THE DISK!"
	icon = 'icons/mob/simple/pets.dmi'
	icon_state = "syndicat"
	icon_living = "syndicat"
	icon_dead = "syndicat_dead"
	held_state = "syndicat"
	speak_emote = list("purrs", "meows")
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	bodytemp_cold_damage_limit = TCMB
	bodytemp_heat_damage_limit = T0C + 40
	unsuitable_atmos_damage = 0
	butcher_results = list(/obj/item/food/meat/slab = 1, /obj/item/organ/internal/ears/cat = 1, /obj/item/organ/external/tail/cat = 1, /obj/item/stack/sheet/animalhide/cat = 1)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	health = 90
	maxHealth = 90
	melee_damage_lower = 27
	melee_damage_upper = 35
	ai_controller = /datum/ai_controller/basic_controller/simple_hostile
	faction = list(FACTION_CAT, ROLE_SYNDICATE)
	can_be_held = TRUE
	attack_verb_continuous = "claws"
	attack_verb_simple = "claw"
	attack_sound = 'sound/weapons/slash.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW

/mob/living/basic/pet/cat/syndicat/Initialize(mapload)
	. = ..()
	var/obj/item/implant/toinstall = list(/obj/item/implant/weapons_auth, /obj/item/implant/explosive)
	for(var/obj/item/implant/original_implants as anything in toinstall)
		var/obj/item/implant/copied_implant = new original_implants.type
		copied_implant.implant(src, silent = TRUE, force = TRUE)
