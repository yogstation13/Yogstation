//////////////////////////////////////////////////////////////////////////
/obj/structure/dark_sticks
	name = "dark sticks" //basicaly punji sticks
	desc = "Don't step on this."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "punji"
	resistance_flags = FLAMMABLE
	max_integrity = 30
	density = FALSE
	anchored = TRUE

/obj/structure/dark_sticks/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/caltrop, 20, 30, 100, CALTROP_BYPASS_SHOES, 0.2 SECONDS)//basically a microstun
	add_atom_colour(COLOR_VELVET, FIXED_COLOUR_PRIORITY)

/obj/structure/dark_sticks/Crossed(AM as mob|obj)
	if(isliving(AM))
		var/mob/living/target = AM
		if(is_darkspawn_or_veil(target))
			return
	. = ..()

//////////////////////////////////////////////////////////////////////////	
/obj/item/restraints/legcuffs/beartrap/dark
	name = "dark snare"
	armed = 1
	icon_state = "e_snare"
	trap_damage = 0
	breakouttime = 30
	item_flags = DROPDEL
	flags_1 = NONE
	break_strength = 2
	slowdown = 4

/obj/item/restraints/legcuffs/beartrap/dark/Initialize(mapload)
	. = ..()
	add_atom_colour(COLOR_VELVET, FIXED_COLOUR_PRIORITY)

/obj/item/restraints/legcuffs/beartrap/dark/attack_hand(mob/user)
	Crossed(user) //no picking it up

/obj/item/restraints/legcuffs/beartrap/dark/Crossed(AM as mob|obj)
	if(isliving(AM))
		var/mob/living/target = AM
		if(is_darkspawn_or_veil(target))
			return
	. = ..()
	
//////////////////////////////////////////////////////////////////////////
