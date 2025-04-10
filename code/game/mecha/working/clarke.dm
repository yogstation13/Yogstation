///Lavaproof, fireproof, fast mech with low armor and higher energy consumption, cannot strafe and has an internal ore box.
/obj/mecha/working/clarke
	desc = "Combining man and machine for a better, stronger engineer. Can even resist lava!"
	name = "\improper Clarke"
	icon_state = "clarke"
	max_temperature = 65000
	max_integrity = 400
	integrity_failure = 200
	step_in = 2
	fast_pressure_step_in = 1.5
	slow_pressure_step_in = 2
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	weather_protection = WEATHER_LAVA|WEATHER_STORM
	facing_modifiers = list(FRONT_ARMOUR = 1.2, SIDE_ARMOUR = 1, BACK_ARMOUR = 0.8) // omnidirectional, less significant difference between attack directions
	light_power = 7
	deflect_chance = 10
	flags_1 = HEAR_1 | RAD_PROTECT_CONTENTS_1 | RAD_NO_CONTAMINATE_1
	armor = list(MELEE = 25, BULLET = 10, LASER = 20, ENERGY = 0, BOMB = 60, BIO = 0, RAD = 100, FIRE = 100, ACID = 100, ELECTRIC = 50)
	max_equip = 7
	enter_delay = 40
	pivot_step = TRUE
	/// Handles an internal ore box for Clarke
	var/obj/structure/ore_box/box
	omnidirectional_attacks = TRUE

/obj/mecha/working/clarke/Initialize(mapload)
	. = ..()
	box = new /obj/structure/ore_box(src)
	var/obj/item/mecha_parts/mecha_equipment/orebox_manager/ME = new(src)
	ME.attach(src)
	AddComponent(/datum/component/armor_plate, 5, /obj/item/stack/sheet/animalhide/weaver_chitin, list(MELEE = 5, BULLET = 2, LASER = 2))

/obj/mecha/working/clarke/Destroy()
	box.dump_box_contents()
	return ..()

/obj/mecha/working/clarke/moved_inside(mob/living/carbon/human/H)
	. = ..()
	if(.)
		var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_DIAGNOSTIC_ADVANCED]
		hud.show_to(H)

/obj/mecha/working/clarke/go_out()
	if(isliving(occupant))
		var/mob/living/L = occupant
		var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_DIAGNOSTIC_ADVANCED]
		hud.hide_from(L)
	return ..()

/obj/mecha/working/clarke/mmi_moved_inside(obj/item/mmi/M, mob/user)
	. = ..()
	if(.)
		var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_DIAGNOSTIC_ADVANCED]
		var/mob/living/brain/B = M.brainmob
		hud.show_to(B)

/obj/mecha/working/clarke/domove(direction)
	if(ISDIAGONALDIR(direction) && strafe)
		if(EWCOMPONENT(dir))
			direction &= ~(NORTH|SOUTH)
		else if(NSCOMPONENT(dir))
			direction &= ~(EAST|WEST)
	return ..(direction)

//Ore Box Controls

///Special equipment for the Clarke mech, handles moving ore without giving the mech a hydraulic clamp and cargo compartment.
/obj/item/mecha_parts/mecha_equipment/orebox_manager
	name = "ore storage module"
	desc = "An automated ore box management device."
	icon_state = "mecha_clamp" //None of this should matter, this shouldn't ever exist outside a mech anyway.
	selectable = FALSE
	salvageable = FALSE
	/// Var to avoid istype checking every time the topic button is pressed. This will only work inside Clarke mechs.
	var/obj/mecha/working/clarke/hostmech

/obj/item/mecha_parts/mecha_equipment/orebox_manager/attach(obj/mecha/M)
	. = ..()
	if(istype(M, /obj/mecha/working/clarke))
		hostmech = M

/obj/item/mecha_parts/mecha_equipment/orebox_manager/detach()
	return //can't detach

/obj/item/mecha_parts/mecha_equipment/orebox_manager/Topic(href,href_list)
	. = ..()
	if(!hostmech || !hostmech.box)
		return
	hostmech.box.dump_box_contents()

/obj/item/mecha_parts/mecha_equipment/orebox_manager/get_equip_info()
	return "[..()] [hostmech?.box ? "<a href='byond://?src=[REF(src)];mode=0'>Unload Cargo</a>" : "Error"]"
