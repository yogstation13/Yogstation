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
	gender = FEMALE //lol examine text? (this actually matters, don't change it)
	trap_damage = 5

/obj/item/restraints/legcuffs/beartrap/dark/Initialize(mapload)
	. = ..()
	add_atom_colour(COLOR_VELVET, FIXED_COLOUR_PRIORITY)

/obj/item/restraints/legcuffs/beartrap/dark/attack_hand(mob/user)
	spring_trap(user) //no picking it up

/obj/item/restraints/legcuffs/beartrap/dark/spring_trap(AM as mob|obj)
	if(isliving(AM))
		var/mob/living/target = AM
		if(is_darkspawn_or_thrall(target))
			return
	return ..()
	
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
	mouse_opacity = MOUSE_OPACITY_OPAQUE //nothing draws under them and they really SHOULD be easier to click
	var/examine_text

/obj/structure/trap/darkspawn/examine(mob/user)
	. = ..()
	if(examine_text && is_darkspawn_or_thrall(user))
		. += span_velvet("The runes denote [examine_text].")

/obj/structure/trap/darkspawn/Initialize(mapload)
	. = ..()
	add_atom_colour(COLOR_VELVET, FIXED_COLOUR_PRIORITY)

/obj/structure/trap/darkspawn/on_trap_entered(datum/source, atom/movable/AM, ...)
	if(isliving(AM))
		var/mob/living/target = AM
		if(is_darkspawn_or_thrall(target))
			return
	if(isprojectile(AM)) //if it's flying above the trap, don't trigger it
		return
	return ..()

/////////////////////////////Makes people sick////////////////////////////
/obj/structure/trap/darkspawn/nausea
	time_between_triggers = 15 SECONDS
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
	playsound(get_turf(src), 'sound/effects/snap.ogg', 30, TRUE, -1)
	playsound(get_turf(src), 'sound/weapons/bladeslice.ogg', 60, TRUE, -1)

/obj/structure/trap/darkspawn/damage/trap_effect(mob/living/L)
	L.apply_damage(30, BRUTE)
	L.Knockdown(2 SECONDS)

///////////////////////bear traps target///////////////////////////////////
/obj/structure/trap/darkspawn/legcuff
	charges = 1
	examine_text = "restrain"

/obj/structure/trap/darkspawn/legcuff/flare()
	. = ..()
	playsound(get_turf(src), 'sound/effects/snap.ogg', 50, TRUE)

/obj/structure/trap/darkspawn/legcuff/trap_effect(mob/living/L)
	var/obj/item/restraints/legcuffs/beartrap/dark/trap = new(get_turf(src))
	trap.spring_trap(L)
