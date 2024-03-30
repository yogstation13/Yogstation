/turf/closed/wall/mineral/cult
	name = "runed metal wall"
	desc = "A cold metal wall engraved with indecipherable symbols. Studying them causes your head to pound."
	icon = 'icons/turf/walls/cult_wall.dmi'
	icon_state = "cult_wall-0"
	base_icon_state = "cult_wall"
	smoothing_flags = SMOOTH_BITMASK
	canSmoothWith = null
	sheet_type = /obj/item/stack/sheet/runed_metal
	sheet_amount = 1
	girder_type = /obj/structure/girder/cult

/turf/closed/wall/mineral/cult/Initialize(mapload)
	new /obj/effect/temp_visual/cult/turf(src)
	. = ..()

/turf/closed/wall/mineral/cult/devastate_wall()
	new sheet_type(get_turf(src), sheet_amount)

/turf/closed/wall/mineral/cult/Exited(atom/movable/AM, atom/newloc)
	. = ..()
	if(istype(AM, /mob/living/simple_animal/hostile/construct/harvester)) //harvesters can go through cult walls, dragging something with
		var/mob/living/simple_animal/hostile/construct/harvester/H = AM
		var/atom/movable/stored_pulling = H.pulling
		if(stored_pulling)
			stored_pulling.setDir(get_dir(stored_pulling.loc, newloc))
			stored_pulling.forceMove(src)
			H.start_pulling(stored_pulling, supress_message = TRUE)

/turf/closed/wall/mineral/cult/ratvar_act()
	. = ..()
	if(istype(src, /turf/closed/wall/mineral/cult)) //if we haven't changed type
		var/previouscolor = color
		color = "#FAE48C"
		animate(src, color = previouscolor, time = 0.8 SECONDS)
		addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 0.8 SECONDS)

/turf/closed/wall/mineral/cult/artificer
	name = "runed stone wall"
	desc = "A cold stone wall engraved with indecipherable symbols. Studying them causes your head to pound."

/turf/closed/wall/mineral/cult/artificer/break_wall()
	new /obj/effect/temp_visual/cult/turf(get_turf(src))
	return null //excuse me we want no runed metal here

/turf/closed/wall/mineral/cult/artificer/devastate_wall()
	new /obj/effect/temp_visual/cult/turf(get_turf(src))

//Clockwork wall: Causes nearby tinkerer's caches to generate components.
/turf/closed/wall/clockwork
	name = "clockwork wall"
	desc = "A huge chunk of warm metal. The clanging of machinery emanates from within."
	icon = 'icons/turf/walls/clockwork_wall.dmi'
	icon_state = "clockwork_wall-0"
	base_icon_state = "clockwork_wall"
	explosion_block = 3
	hardness = 5
	slicing_duration = 150
	sheet_type = /obj/item/stack/tile/brass
	sheet_amount = 1
	girder_type = /obj/structure/destructible/clockwork/wall_gear
	baseturfs = /turf/open/floor/clockwork/reebe
	smoothing_flags = SMOOTH_BITMASK

	var/heated
	var/obj/effect/clockwork/overlay/wall/realappearance

/turf/closed/wall/clockwork/Initialize(mapload)
	. = ..()
	new /obj/effect/temp_visual/ratvar/wall(src)
	new /obj/effect/temp_visual/ratvar/beam(src)
	realappearance = new /obj/effect/clockwork/overlay/wall(src)
	realappearance.linked = src

/turf/closed/wall/clockwork/Destroy()
	if(realappearance)
		qdel(realappearance)
		realappearance = null
	if(heated)
		var/mob/camera/eminence/E = get_eminence()
		if(E)
			E.superheated_walls--

	return ..()

/turf/closed/wall/clockwork/attempt_lattice_replacement()
	..()
	for(var/obj/structure/lattice/L in src)
		L.ratvar_act()

/turf/closed/wall/clockwork/narsie_act()
	..()
	if(istype(src, /turf/closed/wall/clockwork)) //if we haven't changed type
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 0.8 SECONDS)
		addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 0.8 SECONDS)

/turf/closed/wall/clockwork/rcd_act(mob/user, obj/item/construction/rcd/the_rcd)
	return FALSE

/turf/closed/wall/clockwork/devastate_wall()
	for(var/i in 1 to 2)
		new/obj/item/clockwork/alloy_shards/large(src)
	for(var/i in 1 to 2)
		new/obj/item/clockwork/alloy_shards/medium(src)
	for(var/i in 1 to 3)
		new/obj/item/clockwork/alloy_shards/small(src)

/turf/closed/wall/clockwork/attack_hulk(mob/living/user, does_attack_animation = 0)
	..()
	if(heated)
		to_chat(user, span_userdanger("The wall is searing hot to the touch!"))
		user.adjustFireLoss(5)
		playsound(src, 'sound/machines/fryer/deep_fryer_emerge.ogg', 50, TRUE)

/turf/closed/wall/clockwork/mech_melee_attack(obj/mecha/M, punch_force, equip_allowed = TRUE)
	. = ..()
	if(heated)
		to_chat(M.occupant, span_userdanger("The wall's intense heat completely reflects your [M.name]'s attack!"))
		M.take_damage(20, BURN)

/turf/closed/wall/clockwork/attack_eminence(mob/camera/eminence/user, params)
	var/list/modifiers = params2list(params)
	if(modifiers["alt"] && istype(user))
		user.superheat_wall(src)
		return

/turf/closed/wall/clockwork/proc/turn_up_the_heat()
	if(!heated)
		name = "superheated [name]"
		visible_message(span_warning("[src] sizzles with heat!"))
		playsound(src, 'sound/machines/fryer/deep_fryer_emerge.ogg', 50, TRUE)
		heated = TRUE
		hardness = -100 //Lower numbers are tougher, so this makes the wall essentially impervious to smashing
		slicing_duration = 170
		animate(realappearance, color = "#FFC3C3", time = 0.5 SECONDS)
	else
		name = initial(name)
		visible_message(span_notice("[src] cools down."))
		heated = FALSE
		hardness = initial(hardness)
		slicing_duration = initial(slicing_duration)
		animate(realappearance, color = initial(realappearance.color), time = 2.5 SECONDS)


/turf/closed/wall/vault
	icon = 'icons/turf/walls.dmi'
	icon_state = "rockvault"

/turf/closed/wall/ice
	icon = 'icons/turf/walls/icedmetal_wall.dmi'
	icon_state = "iced"
	desc = "A wall covered in a thick sheet of ice."
	canSmoothWith = null
	hardness = 35
	slicing_duration = 150 //welding through the ice+metal
	bullet_sizzle = TRUE

/turf/closed/wall/rust
	//SDMM supports colors, this is simply for easier mapping
	//and should be removed on initialize
	color = COLOR_ORANGE_BROWN

/turf/closed/wall/rust/Initialize(mapload)
	. = ..()
	color = null
	AddElement(/datum/element/rust)

/turf/closed/wall/r_wall/rust
	//SDMM supports colors, this is simply for easier mapping
	//and should be removed on initialize
	color = COLOR_ORANGE_BROWN

/turf/closed/wall/r_wall/rust/Initialize(mapload)
	. = ..()
	color = null
	AddElement(/datum/element/rust)

/turf/closed/wall/mineral/bronze
	name = "clockwork wall"
	desc = "A huge chunk of bronze, decorated like gears and cogs."
	icon = 'icons/turf/walls/clockwork_wall.dmi'
	icon_state = "clockwork_wall-0"
	base_icon_state = "clockwork_wall"
	turf_flags = IS_SOLID
	smoothing_flags = SMOOTH_BITMASK
	sheet_type = /obj/item/stack/tile/bronze
	sheet_amount = 2
	girder_type = /obj/structure/girder/bronze

/turf/closed/wall/explosive
	desc = "A huge chunk of metal used to seperate rooms. This one smells of gunpowder."

/turf/closed/wall/explosive/ex_act(severity)
	var/obj/item/bombcore/large/bombcore = new(get_turf(src))
	bombcore.detonate()
	..()

/turf/closed/wall/rock
	name = "reinforced rock"
	desc = "It has metal struts that need to be welded away before it can be mined."
	icon = 'icons/turf/walls/reinforced_rock.dmi'
	icon_state = "porous_rock-0"
	base_icon_state = "porous_rock"
	turf_flags = NO_RUST
	flags_1 = RAD_PROTECT_CONTENTS_1 | RAD_NO_CONTAMINATE_1
	sheet_amount = 1
	hardness = 50
	girder_type = null
	decon_type = /turf/closed/mineral/asteroid

/turf/closed/wall/rock/porous
	name = "reinforced porous rock"
	desc = "This rock is filled with pockets of breathable air. It has metal struts to protect it from mining."
	decon_type = /turf/closed/mineral/asteroid/porous
