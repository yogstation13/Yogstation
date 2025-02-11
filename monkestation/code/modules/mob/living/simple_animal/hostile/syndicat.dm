/mob/living/simple_animal/hostile/syndicat
	name = "Syndie Cat"
	desc = "OH GOD! RUN!! IT CAN SMELL THE DISK!"
	icon = 'icons/mob/simple/pets.dmi'
	icon_state = "syndicat"
	icon_living = "syndicat"
	icon_dead = "syndicat_dead"
	held_state = "syndicat"
	speak = list("Meow!", "Esp!", "Purr!", "HSSSSS")
	speak_emote = list("purrs", "meows")
	emote_hear = list("meows.", "mews.")
	emote_see = list("shakes their head.", "shivers.")
	speak_chance = 1
	turns_per_move = 5
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	bodytemp_cold_damage_limit = TCMB
	bodytemp_heat_damage_limit = T0C + 40
	unsuitable_atmos_damage = 0
	animal_species = /mob/living/simple_animal/pet/cat
	childtype = list(/mob/living/simple_animal/pet/cat/kitten = 1)
	butcher_results = list(/obj/item/food/meat/slab = 1, /obj/item/organ/internal/ears/cat = 1, /obj/item/organ/external/tail/cat = 1, /obj/item/stack/sheet/animalhide/cat = 1)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	health = 80
	maxHealth = 80
	melee_damage_lower = 20
	melee_damage_upper = 35
	faction = list(FACTION_CAT, ROLE_SYNDICATE)
	can_be_held = TRUE
	attack_verb_continuous = "claws"
	attack_verb_simple = "claw"
	attack_sound = 'sound/weapons/slash.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
	footstep_type = FOOTSTEP_MOB_CLAW
	lighting_cutoff_red = LIGHTING_CUTOFF_FELINE_RED
	lighting_cutoff_green = LIGHTING_CUTOFF_FELINE_GREEN
	lighting_cutoff_blue = LIGHTING_CUTOFF_FELINE_RED

/mob/living/simple_animal/hostile/syndicat/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	var/obj/item/implant/toinstall = list(/obj/item/implant/weapons_auth, /obj/item/implant/explosive)
	for(var/obj/item/implant/original_implants as anything in toinstall)
		var/obj/item/implant/copied_implant = new original_implants.type
		copied_implant.implant(src, silent = TRUE, force = TRUE)
