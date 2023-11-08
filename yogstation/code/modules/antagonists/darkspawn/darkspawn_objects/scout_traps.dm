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
//---------------------------Recharging trap----------------------------//
//////////////////////////////////////////////////////////////////////////
/obj/structure/trap/darkspawn
	name = "void rune"
	desc = "strange ephemeral shadows, knit together in the form of usual symbols."
	antimagic_flags = MAGIC_RESISTANCE_MIND
	max_integrity = 75
	time_between_triggers = 1 MINUTES
	sparks = FALSE
	can_reveal = FALSE
	var/examine_text

/obj/structure/trap/darkspawn/examine(mob/user)
	. = ..()
	if(examine_text && is_darkspawn_or_veil(user))
		. += span_velvet("The runes denote [examine_text].")

/obj/structure/trap/darkspawn/Initialize(mapload)
	. = ..()
	add_atom_colour(COLOR_VELVET, FIXED_COLOUR_PRIORITY)

/obj/structure/trap/darkspawn/Crossed(atom/movable/AM)
	if(isliving(AM))
		var/mob/living/target = AM
		if(is_darkspawn_or_veil(target))
			return
	. = ..()

/////////////////////////////Makes people sick////////////////////////////
/obj/structure/trap/darkspawn/nausea
	examine_text = "sickness"

/obj/structure/trap/darkspawn/nausea/flare()
	. = ..()
	playsound(get_turf(src), 'sound/effects/splat.ogg', 50, 1)
	playsound(get_turf(src), 'sound/magic/exit_blood.ogg', 50, TRUE)

/obj/structure/trap/darkspawn/nausea/trap_effect(mob/living/L)
	L.adjust_disgust(30)
	L.adjust_confusion(6 SECONDS)

///////////////////teleport somewhere random on the station////////////////
/obj/structure/trap/darkspawn/teleport
	charges = 1
	examine_text = "transposition"

/obj/structure/trap/darkspawn/teleport/flare()
	. = ..()
	playsound(get_turf(src), 'sound/effects/phasein.ogg', 60, 1)

/obj/structure/trap/darkspawn/teleport/trap_effect(mob/living/L)
	L.forceMove(get_safe_random_station_turf())
	playsound(get_turf(L), 'sound/effects/phasein.ogg', 60, 1)

///////////////////////basic damage trap///////////////////////////////////
/obj/structure/trap/darkspawn/damage
	max_integrity = 15
	time_between_triggers = 15 SECONDS
	examine_text = "injury"

/obj/structure/trap/darkspawn/damage/flare()
	. = ..()
	playsound(get_turf(src), 'sound/effects/snap.ogg', 40, TRUE, -1)
	playsound(get_turf(src), 'sound/weapons/bladeslice.ogg', 70, TRUE, -1)

/obj/structure/trap/darkspawn/damage/trap_effect(mob/living/L)
	L.apply_damage(30, BRUTE)
	L.Knockdown(2 SECONDS)

	