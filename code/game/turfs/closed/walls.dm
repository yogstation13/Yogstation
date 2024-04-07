#define MAX_DENT_DECALS 15

/turf/closed/wall
	name = "wall"
	desc = "A huge chunk of metal used to separate rooms."
	icon = 'icons/turf/walls/wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	explosion_block = 1
	max_integrity = 300
	damage_deflection = 20 // big chunk of solid metal
	uses_integrity = TRUE

	armor = list(MELEE = 60, BULLET = 60, LASER = 60, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 90, ACID = 50) // very tough

	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 312500 //a little over 5 cm thick , 312500 for 1 m by 2.5 m by 0.25 m plasteel wall

	baseturfs = /turf/open/floor/plating

	FASTDMM_PROP(\
		pipe_astar_cost = 50 /* nich really doesn't like pipes that go through walls */\
	)

	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_WALLS
	
	///bool on whether this wall can be chiselled into
	var/can_engrave = TRUE
	///lower numbers are harder. Used to determine the probability of a hulk smashing through.
	var/hardness = 30 
	var/slicing_duration = 200  //default time taken to slice the wall
	var/sheet_type = /obj/item/stack/sheet/metal
	var/sheet_amount = 2
	var/girder_type = /obj/structure/girder
	var/smash_flags = ENVIRONMENT_SMASH_WALLS|ENVIRONMENT_SMASH_RWALLS
	/// A turf that will replace this turf when this turf is destroyed
	var/decon_type

	var/list/dent_decals

/turf/closed/wall/Initialize(mapload)
	. = ..()
	if(!can_engrave)
		ADD_TRAIT(src, TRAIT_NOT_ENGRAVABLE, INNATE_TRAIT)
	if(is_station_level(z))
		GLOB.station_turfs += src
	if(smoothing_flags & SMOOTH_DIAGONAL_CORNERS && fixed_underlay) //Set underlays for the diagonal walls.
		var/mutable_appearance/underlay_appearance = mutable_appearance(layer = TURF_LAYER, offset_spokesman = src, plane = FLOOR_PLANE)
		if(fixed_underlay["space"])
			generate_space_underlay(underlay_appearance, src)
		else
			underlay_appearance.icon = fixed_underlay["icon"]
			underlay_appearance.icon_state = fixed_underlay["icon_state"]
		fixed_underlay = string_assoc_list(fixed_underlay)
		underlays += underlay_appearance

/turf/closed/wall/Destroy()
	if(is_station_level(z))
		GLOB.station_turfs -= src
	..()

/turf/closed/wall/examine(mob/user)
	. += ..()
	. += deconstruction_hints(user)

/turf/closed/wall/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	. = ..()
	if(.) // add a dent if it took damage
		add_dent(WALL_DENT_HIT)

/turf/closed/wall/run_atom_armor(damage_amount, damage_type, damage_flag, attack_dir, armour_penetration)
	if(damage_amount < damage_deflection && (damage_flag in list(MELEE, BULLET, LASER, ENERGY)))
		return 0 // absolutely no bypassing damage deflection by using projectiles FOR REAL THIS TIME
	return ..()

/turf/closed/wall/atom_destruction(damage_flag)
	if(damage_flag == MELEE)
		playsound(src, 'sound/effects/meteorimpact.ogg', 50, TRUE) //Otherwise there's no sound for hitting the wall, since it's just dismantled
	dismantle_wall(TRUE, (damage_flag==BOMB))

/turf/closed/wall/proc/deconstruction_hints(mob/user)
	return span_notice("The outer plating is <b>welded</b> firmly in place.")

/turf/closed/wall/attack_tk()
	return

/turf/closed/wall/handle_ricochet(obj/projectile/P)			//A huge pile of shitcode!
	var/turf/p_turf = get_turf(P)
	var/face_direction = get_dir(src, p_turf)
	var/face_angle = dir2angle(face_direction)
	var/incidence_s = GET_ANGLE_OF_INCIDENCE(face_angle, (P.Angle + 180))
	if(abs(incidence_s) > 90 && abs(incidence_s) < 270)
		return FALSE
	var/new_angle_s = SIMPLIFY_DEGREES(face_angle + incidence_s)
	P.setAngle(new_angle_s)
	return TRUE

/turf/closed/wall/proc/dismantle_wall(devastated = FALSE, explode = FALSE)
	if(devastated)
		devastate_wall()
	else
		playsound(src, 'sound/items/welder.ogg', 100, 1)
		var/newgirder = break_wall()
		if(newgirder) //maybe we don't /want/ a girder!
			transfer_fingerprints_to(newgirder)

	for(var/obj/O in src.contents) //Eject contents!
		if(istype(O, /obj/structure/sign/poster))
			var/obj/structure/sign/poster/P = O
			P.roll_and_drop(src)
	if(decon_type)
		ChangeTurf(decon_type, flags = CHANGETURF_INHERIT_AIR)
	else
		ScrapeAway()
	QUEUE_SMOOTH_NEIGHBORS(src)

/turf/closed/wall/proc/break_wall()
	new sheet_type(src, sheet_amount)
	return new girder_type(src)

/turf/closed/wall/proc/devastate_wall()
	new sheet_type(src, sheet_amount)
	if(girder_type)
		new /obj/item/stack/sheet/metal(src)

/turf/closed/wall/ex_act(severity, target)
	if(target == src)
		dismantle_wall(TRUE, TRUE)
		return
	switch(severity)
		if(EXPLODE_DEVASTATE)
			//SN src = null
			var/turf/NT = ScrapeAway()
			NT.contents_explosion(severity, target)
			return
		if(EXPLODE_HEAVY)
			dismantle_wall(pick(FALSE, TRUE), TRUE)
		if(EXPLODE_LIGHT)
			take_damage(150, BRUTE, BOMB) // less kaboom
	if(!density)
		..()
	
	return TRUE


/turf/closed/wall/blob_act(obj/structure/blob/B)
	take_damage(400, BRUTE, MELEE, FALSE)
	playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)

/turf/closed/wall/mech_melee_attack(obj/mecha/M, punch_force, equip_allowed = TRUE)
	return ..(M, punch_force * 5, equip_allowed)

/turf/closed/wall/attack_paw(mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	return attack_hand(user)


/turf/closed/wall/attack_animal(mob/living/simple_animal/M)
	M.changeNext_move(CLICK_CD_MELEE)
	M.do_attack_animation(src)
	if(!(M.environment_smash & smash_flags))
		playsound(src, 'sound/effects/bang.ogg', 50, 1)
		to_chat(M, span_warning("This wall is far too strong for you to destroy."))
		return
	take_damage(400, BRUTE, MELEE, FALSE)
	playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)

/turf/closed/wall/attack_hulk(mob/user, does_attack_animation = 0)
	..(user, 1)
	user.say(pick("RAAAAAAAARGH!", "HNNNNNNNNNGGGGGGH!", "GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", "AAAAAAARRRGH!" ), forced = "hulk")
	take_damage(400, BRUTE, MELEE, FALSE)
	playsound(src, 'sound/effects/bang.ogg', 50, 1)
	to_chat(user, span_notice("You punch the wall."))
	return TRUE

/turf/closed/wall/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	to_chat(user, span_notice("You push the wall but nothing happens!"))
	playsound(src, 'sound/weapons/genhit.ogg', 25, 1)
	add_fingerprint(user)

/turf/closed/wall/attackby(obj/item/attacking_item, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if (!user.IsAdvancedToolUser())
		to_chat(user, span_warning("You don't have the dexterity to do this!"))
		return

	//get the user's location
	if(!isturf(user.loc) && !ismecha(user.loc))
		return	//can't do this stuff whilst inside objects and such

	add_fingerprint(user)

	var/turf/T = user.loc	//get user's location for delay checks

	//the istype cascade has been spread among various procs for easy overriding
	if(try_clean(attacking_item, user, T) || try_wallmount(attacking_item, user, T) || try_decon(attacking_item, user, T))
		return

	return ..() || (attacking_item.attack_atom(src, user))

/turf/closed/wall/proc/try_clean(obj/item/W, mob/user, turf/T)
	if(user.a_intent == INTENT_HARM)
		return FALSE

	if(W.tool_behaviour == TOOL_WELDER)
		if(atom_integrity >= max_integrity)
			to_chat(user, span_warning("[src] is intact!"))
			return TRUE

		if(!W.tool_start_check(user, amount=0))
			to_chat(user, span_warning("You need more fuel to repair [src]!"))
			return TRUE

		to_chat(user, span_notice("You begin repairing [src]..."))
		if(W.use_tool(src, user, 3 SECONDS, volume=100))
			update_integrity(max_integrity)
			to_chat(user, span_notice("You repair [src]."))
			cut_overlay(dent_decals)
			dent_decals.Cut()
			return TRUE
		return TRUE

	return FALSE

/turf/closed/wall/proc/try_wallmount(obj/item/W, mob/user, turf/T)
	//check for wall mounted frames
	if(istype(W, /obj/item/wallframe))
		var/obj/item/wallframe/F = W
		if(F.try_build(src, user))
			F.attach(src, user)
		return TRUE
	//Poster stuff
	else if(istype(W, /obj/item/poster))
		place_poster(W,user)
		return TRUE
	//Borg Poster STuff
	else if(istype(W, /obj/item/wantedposterposter))
		place_borg_poster(W, user)

	return FALSE

/turf/closed/wall/proc/try_decon(obj/item/I, mob/user, turf/T)
	if(I.tool_behaviour == TOOL_WELDER)
		if(!I.tool_start_check(user, amount=0))
			return FALSE

		to_chat(user, span_notice("You begin slicing through the outer plating..."))
		if(I.use_tool(src, user, slicing_duration, volume=100))
			if(iswallturf(src))
				to_chat(user, span_notice("You remove the outer plating."))
				dismantle_wall()
			return TRUE

	return FALSE

/turf/closed/wall/singularity_pull(S, current_size)
	. = ..()
	if(current_size >= STAGE_FIVE)
		take_damage(250, armour_penetration=100) // LORD SINGULOTH CARES NOT FOR YOUR "ARMOR"
	else if(current_size == STAGE_FOUR)
		take_damage(150, armour_penetration=100)

/turf/closed/wall/narsie_act(force, ignore_mobs, probability = 20)
	. = ..()
	if(.)
		ChangeTurf(/turf/closed/wall/mineral/cult)

/turf/closed/wall/ratvar_act(force, ignore_mobs)
	. = ..()
	if(.)
		ChangeTurf(/turf/closed/wall/clockwork)

/turf/closed/wall/honk_act()
	ChangeTurf(/turf/closed/wall/mineral/bananium)

/turf/closed/wall/get_dumping_location(obj/item/storage/source, mob/user)
	return null

/turf/closed/wall/acid_act(acidpwr, acid_volume)
	if(explosion_block >= 2)
		acidpwr = min(acidpwr, 50) //we reduce the power so strong walls never get melted.
	. = ..()

/turf/closed/wall/acid_melt()
	dismantle_wall(1)

/turf/closed/wall/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.construction_mode)
		if(RCD_DECONSTRUCT)
			return list("mode" = RCD_DECONSTRUCT, "delay" = 40, "cost" = 26)
	return FALSE

/turf/closed/wall/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_DECONSTRUCT)
			to_chat(user, span_notice("You deconstruct the wall."))
			ScrapeAway()
			return TRUE
	return FALSE

/turf/proc/add_dent(denttype, x=rand(-8, 8), y=rand(-8, 8)) // this only exists because turf code is terrible
	return

/turf/closed/wall/add_dent(denttype, x=rand(-8, 8), y=rand(-8, 8))
	if(LAZYLEN(dent_decals) >= MAX_DENT_DECALS)
		return

	var/mutable_appearance/decal = mutable_appearance('icons/effects/effects.dmi', "", BULLET_HOLE_LAYER)
	switch(denttype)
		if(WALL_DENT_SHOT)
			decal.icon_state = "bullet_hole"
		if(WALL_DENT_HIT)
			decal.icon_state = "impact[rand(1, 3)]"

	decal.pixel_x = x
	decal.pixel_y = y

	if(LAZYLEN(dent_decals))
		cut_overlay(dent_decals)
		dent_decals += decal
	else
		dent_decals = list(decal)

	add_overlay(dent_decals)

/turf/closed/wall/rust_heretic_act()
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		ScrapeAway()
		return
	if(prob(70))
		new /obj/effect/glowing_rune(src)
	return ..()

#undef MAX_DENT_DECALS
