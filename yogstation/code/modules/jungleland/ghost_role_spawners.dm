
//Ivymen eggs: Spawns in ivymen dens on Jungleland. Ghosts become unique podpeople that wish to expand by sacrificing corpses to their carnivorous birth plant.

/obj/effect/mob_spawn/human/ivymen
	name = "ivymen egg"
	desc = "A man-sized wood colored egg covered in plant matter, spawned from some sort of tree perhaps. A humanoid silhouette lurks within, barely visible through the cracks."
	mob_name = "an ivyman"
	icon = 'yogstation/icons/mob/jungle.dmi'
	icon_state = "ivymen_egg"
	mob_species = /datum/species/pod/ivymen
	outfit = /datum/outfit/ivymen
	roundstart = FALSE
	death = FALSE
	anchored = FALSE
	move_resist = MOVE_FORCE_NORMAL
	density = FALSE
	short_desc = "You are an Ivyman. Your tribe is birthed from The Mother Tree, and worships it."
	flavour_text = "The jungle is a sacred, pure land full of wondrous creatures to hunt and befriend. \
	You have seen lights in the distance... they foreshadow the arrival of outsiders that seek to tear apart the Jungle and your home. Fresh sacrifices for your nest."
	assignedrole = "Ivyman"
	var/datum/team/ivymen/team

/obj/effect/mob_spawn/human/ivymen/special(mob/living/new_spawn)
	var/plant_name = pick("Thorn", "Spine", "Pitcher", "Belladonna", "Reed", "Ivy", "Kudzu", "Nettle", "Moss", "Hemlock", "Foxglove", "Root", "Bark", "Amanitin", "Hyacinth", "Leaf", \
	"Venus", "Snakeroot", "Pinyang", "Henbane", "Aconite", "Oak", "Cactus", "Pepper", "Juniper", "Cannabis") //many of the 'soft' names like Sprout have been replaced with poisonous plants. Metal, dude!
	new_spawn.fully_replace_character_name(null,plant_name)
	to_chat(new_spawn, "<b>Drag the corpses of men and beasts to your nest. It will absorb them to create more of your kind. Glory to the Mother Tree!</b>") //yogs - removed a sentence

	new_spawn.mind.add_antag_datum(/datum/antagonist/ivymen, team)

/obj/effect/mob_spawn/human/ivymen/Initialize(mapload, datum/team/ivymen/ivyteam)
	. = ..()
	var/area/A = get_area(src)
	team = ivyteam
	if(A)
		notify_ghosts("An ivyman egg is ready to hatch in \the [A.name].", source = src, action=NOTIFY_ATTACKORBIT, flashwindow = FALSE, ignore_key = POLL_IGNORE_ASHWALKER)

/datum/outfit/ivymen
	name = "Ivyman"
	uniform = /obj/item/clothing/under/ash_robe/hunter/jungle

/datum/outfit/ivymen/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	H.underwear = "Nude"
	H.update_body()
