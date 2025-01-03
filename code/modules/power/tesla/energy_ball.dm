/obj/singularity/energy_ball
	name = "energy ball"
	desc = "An energy ball."
	icon = 'icons/obj/tesla_engine/energy_ball.dmi'
	icon_state = "energy_ball"
	pixel_x = -32
	pixel_y = -32
	current_size = STAGE_TWO
	light_range = 10
	light_power = 3
	light_on = FALSE
	light_color = "#EEEEFF"
	light_system = MOVABLE_LIGHT
	move_self = 1
	grav_pull = 0
	contained = 0
	density = TRUE
	energy = 50
	dissipate = 1
	dissipate_delay = 5
	dissipate_strength = 1
	var/miniball = FALSE
	var/produced_power
	var/energy_to_raise = 32
	var/energy_to_lower = -20
	var/max_balls = 10
	var/zap_range = 7
	var/zap_flags = TESLA_DEFAULT_FLAGS
	var/zap_power = TESLA_DEFAULT_POWER
	var/mini_type = /obj/singularity/energy_ball

	///List of all energy balls that's orbiting this one.
	var/list/obj/singularity/energy_ball/orbiting_balls = list()

/obj/singularity/energy_ball/Initialize(mapload, starting_energy = energy, is_miniball = FALSE)
	miniball = is_miniball
	. = ..()
	if(!is_miniball)
		set_light_on(TRUE)
	else if(energy < TESLA_DEFAULT_POWER)
		transform *= pick(0.3, 0.4, 0.5, 0.6, 0.7)

/obj/singularity/energy_ball/supermatter
	name = "hypercharged supermatter energy ball"
	desc = "The supermatter energy ball hovers ominously, a radiant orb of sheer power. Its brilliance is blinding, casting an intense glow that illuminates the surrounding area. The air crackles with the electric energy it exudes. The sheer intensity of its presence instills a sense of caution, reminding you of the untamed force contained within. Wisps of energy escape its surface, dissipating into the atmosphere with a sizzling sound. Sparks of energy occasionally arc between the crystal and the energy ball, crackling with a captivating yet dangerous allure."
	icon_state = "smenergy_ball"
	energy = 10000
	max_balls = 20
	dissipate = 0
	zap_range = 7
	zap_flags = TESLA_DEFAULT_FLAGS | TESLA_MOB_GIB
	zap_power = TESLA_HYPERCHARGED_POWER
	mini_type = /obj/singularity/energy_ball/supermatter/small_crystals

/obj/singularity/energy_ball/supermatter/small_crystals
	name = "floating hypercharged supermatter crystal"
	desc = "The crystal emanates an otherworldly radiance, casting a soft, ethereal glow that illuminates the space around it. It hovers around the supermatter energy ball in a precise orbit, defying gravity with an elegant, weightless dance. Sparks of energy occasionally arc between the crystal and the energy ball, crackling with a captivating yet dangerous allure."
	icon_state = "smcrystal1"
	zap_power = TESLA_DEFAULT_POWER

/obj/singularity/energy_ball/supermatter/small_crystals/Initialize(mapload, starting_energy, is_miniball)
	icon_state = "smcrystal[rand(1,3)]"
	return ..()

/obj/singularity/energy_ball/ex_act(severity, target)
	return

/obj/singularity/energy_ball/Destroy()
	if(orbiting && istype(orbiting.parent, /obj/singularity/energy_ball))
		var/obj/singularity/energy_ball/EB = orbiting.parent
		EB.orbiting_balls -= src

	QDEL_LIST(orbiting_balls)
	return ..()

/obj/singularity/energy_ball/admin_investigate_setup()
	if(miniball)
		return //don't annnounce miniballs
	return ..()


/obj/singularity/energy_ball/process()
	if(orbiting)
		energy = 0 // ensure we dont have miniballs of miniballs
		return

	handle_energy()
	move_the_basket_ball(4 + orbiting_balls.len * 1.5)
	playsound(loc, 'sound/magic/lightningbolt.ogg', 100, 1, extrarange = 30)

	pixel_x = 0
	pixel_y = 0

	tesla_zap(src, zap_range, zap_power, zap_flags)

	pixel_x = -32
	pixel_y = -32

	var/list/around_us = range(1, src)
	for(var/obj/singularity/energy_ball/E in around_us)
		if(!E.miniball && E != src)
			collide(E)

	for (var/obj/singularity/energy_ball/ball as anything in orbiting_balls)
		if(prob(80)) //tesla nerf/reducing lag, each miniball now has only 20% to trigger the zap
			continue
		tesla_zap(ball, zap_range, ball.zap_power, ball.zap_flags)

/obj/singularity/energy_ball/examine(mob/user)
	. = ..()
	if(orbiting_balls.len)
		. += "There are [orbiting_balls.len] mini-balls orbiting it."

/obj/singularity/energy_ball/proc/collide(obj/singularity/energy_ball/target)
	if(max_balls < target.max_balls) //we bow down against a stronger tesla
		return
	
	name = "[pick("hypercharged", "super", "powered", "glowing", "unstable", "anomalous", "massive")] [name]"
	max_balls += target.max_balls - 8 //default 2 more max balls per another tesla, respecting another consumed tesla
	zap_range += target.zap_range - 6 //also 1 more range for zapping, making it harder to contain
	add_atom_colour(rgb(255 - max_balls * 10, 255 - max_balls * 10, 255), ADMIN_COLOUR_PRIORITY) //gets more blue with more power
	playsound(src.loc, 'sound/magic/lightning_chargeup.ogg', 100, 1, extrarange = 30)
	qdel(target)


/obj/singularity/energy_ball/proc/move_the_basket_ball(move_amount)
	//we face the last thing we zapped, so this lets us favor that direction a bit
	var/move_bias = pick(GLOB.alldirs)
	for(var/i in 0 to move_amount)
		var/move_dir = pick(GLOB.alldirs + move_bias) //ensures large-ball teslas don't just sit around
		if(target && prob(10))
			move_dir = get_dir(src,target)
		var/turf/T = get_step(src, move_dir)
		if(can_move(T))
			forceMove(T)
			setDir(move_dir)
			for(var/mob/living/carbon/C in loc)
				dust_mobs(C)


/obj/singularity/energy_ball/proc/handle_energy()
	if((energy >= energy_to_raise) && (orbiting_balls.len < max_balls))
		energy_to_lower = energy_to_raise - 20
		energy_to_raise = energy_to_raise * 1.25

		playsound(loc, 'sound/magic/lightning_chargeup.ogg', 100, 1, extrarange = 30)
		addtimer(CALLBACK(src, PROC_REF(new_mini_ball)), 100)

	else if(energy < energy_to_lower && orbiting_balls.len)
		energy_to_raise = energy_to_raise / 1.25
		energy_to_lower = (energy_to_raise / 1.25) - 20

		var/Orchiectomy_target = pick(orbiting_balls)
		qdel(Orchiectomy_target)

	else if(orbiting_balls.len)
		dissipate() //sing code has a much better system.

/obj/singularity/energy_ball/proc/new_mini_ball()
	if(!loc)
		return
	// Timers can be added fast enough that the max_balls check in handle_energy will "fail".
	// Timers aren't accounted for in that check so it will add more timers to make more miniballs.
	if(orbiting_balls.len >= max_balls)
		return

	var/obj/singularity/energy_ball/EB = new mini_type(loc, 0, TRUE)
	var/icon/I = icon(icon,icon_state,dir)

	var/orbitsize = (I.Width() + I.Height()) * pick(0.4, 0.5, 0.6, 0.7, 0.8)
	orbitsize -= (orbitsize / world.icon_size) * (world.icon_size * 0.25)

	EB.orbit(src, orbitsize, pick(FALSE, TRUE), rand(10, 25), pick(3, 4, 5, 6, 36))

/obj/singularity/energy_ball/Bump(atom/A)
	dust_mobs(A)

/obj/singularity/energy_ball/Bumped(atom/movable/AM)
	dust_mobs(AM)

/obj/singularity/energy_ball/attack_tk(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		to_chat(C, span_userdanger("That was a shockingly dumb idea."))
		var/obj/item/organ/brain/rip_u = locate(/obj/item/organ/brain) in C.internal_organs
		C.ghostize(0)
		qdel(rip_u)
		C.death()
		
/obj/singularity/energy_ball/attackby(obj/item/hitby, mob/user, params)
	if(!istype(hitby, /obj/item/golfclub))
		return ..()
	var/turf/throw_at = get_ranged_target_turf(src, get_dir(user, src), 2)
	throw_at(throw_at, 2, 1)
	user.changeNext_move(CLICK_CD_RANGE)

/obj/singularity/energy_ball/orbit(obj/singularity/energy_ball/target)
	if (istype(target))
		target.orbiting_balls += src
		color = target.color
		GLOB.poi_list -= src
		target.dissipate_strength = target.orbiting_balls.len

	return ..()

/obj/singularity/energy_ball/stop_orbit()
	if (orbiting && istype(orbiting.parent, /obj/singularity/energy_ball))
		var/obj/singularity/energy_ball/orbitingball = orbiting.parent
		orbitingball.orbiting_balls -= src
		color = initial(color)
		orbitingball.dissipate_strength = orbitingball.orbiting_balls.len
	. = ..()
	if (!QDELETED(src))
		qdel(src)


/obj/singularity/energy_ball/proc/dust_mobs(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		if(L.incorporeal_move || L.status_flags & GODMODE)
			return
	if(!iscarbon(A))
		return
	for(var/obj/machinery/power/grounding_rod/GR in orange(src, 2))
		if(GR.anchored)
			return
	var/mob/living/carbon/C = A
	C.dust()

/proc/tesla_zap(atom/source, zap_range = 3, power, tesla_flags = TESLA_DEFAULT_FLAGS, list/shocked_targets)
	. = source.dir
	if(power < 1000)
		return

	var/static/things_to_shock = typecacheof(list(
		/obj/machinery,
		/mob/living,
		/obj/structure,
		/obj/mecha,
	))
	var/static/grounded_targets = typecacheof(list(
		/obj/machinery/power/tesla_coil,
		/obj/machinery/power/grounding_rod,
	))
	var/static/blacklisted_tesla_types = typecacheof(list(
		/obj/machinery/atmospherics/components,
		/obj/machinery/atmospherics/pipe,
		/obj/machinery/power/emitter,
		/obj/machinery/field/generator,
		/mob/living/simple_animal/slime,
		/obj/machinery/particle_accelerator/control_box,
		/obj/structure/particle_accelerator/fuel_chamber,
		/obj/structure/particle_accelerator/particle_emitter/center,
		/obj/structure/particle_accelerator/particle_emitter/left,
		/obj/structure/particle_accelerator/particle_emitter/right,
		/obj/structure/particle_accelerator/power_box,
		/obj/structure/particle_accelerator/end_cap,
		/obj/machinery/field/containment,
		/obj/structure/disposalpipe,
		/obj/structure/disposaloutlet,
		/obj/machinery/disposal/deliveryChute,
		/obj/machinery/camera,
		/obj/structure/sign,
		/obj/machinery/gateway,
		/obj/structure/lattice,
		/obj/machinery/the_singularitygen/tesla,
		/obj/structure/frame/machine,
		/obj/structure/cable,
		/obj/structure/window,
		/obj/structure/grille,
		/obj/structure/table,
		/obj/structure/table_frame,
	))

	var/list/targets_to_shock = typecache_filter_multi_list_exclusion(
		oview(zap_range + 3, source),
		things_to_shock,
		blacklisted_tesla_types,
	)

	var/list/targets = list()
	var/list/all_coils = list()
	var/grounded = FALSE
	for(var/atom/possible_target in targets_to_shock)
		if(istype(possible_target, /obj/machinery/power/grounding_rod) && !grounded)
			var/obj/machinery/power/grounding_rod/rod = possible_target
			if(rod.anchored && !rod.panel_open && get_dist(source, rod) <= zap_range + 3)
				grounded = TRUE
				tesla_flags |= TESLA_NO_CHAINING
				targets = list()
		if(HAS_TRAIT(possible_target, TRAIT_TESLA_IGNORE))
			continue
		if(istype(possible_target, /obj/machinery/power/tesla_coil))
			all_coils += possible_target
		if(grounded && !istype(possible_target, /obj/machinery/power/grounding_rod))
			continue
		if(!(tesla_flags & TESLA_ALLOW_DUPLICATES) && LAZYACCESS(shocked_targets, possible_target))	
			continue
		var/new_distance = get_dist(source, possible_target)
		if(new_distance > zap_range)
			continue
		LAZYSET(targets, possible_target, ((4 + zap_range - new_distance)**5) * (ismob(possible_target) ? 2 : 1))

	if(targets.len)
		var/atom/target = pickweight(targets)
		var/beam_icon = (tesla_flags & TESLA_MOB_GIB) ? "solar_beam" : "lightning[rand(1,12)]"
		if(!(tesla_flags & TESLA_ALLOW_DUPLICATES))
			LAZYSET(shocked_targets, target, TRUE)
		if(grounded && all_coils.len) // special beam behavior for grounding rods to pretend it's passing through the coils
			var/atom/intermediate_coil = get_closest_atom_to_group(/obj/machinery/power/tesla_coil, all_coils, list(source, target))
			source.Beam(intermediate_coil, icon_state = beam_icon, time = 5, maxdistance = INFINITY)
			intermediate_coil.Beam(target, icon_state = beam_icon, time = 5, maxdistance = INFINITY)
			intermediate_coil.tesla_act(source, power, zap_range, tesla_flags | TESLA_NO_CHAINING, shocked_targets)
		else
			source.Beam(target, icon_state = beam_icon, time = 5, maxdistance = INFINITY)
		target.tesla_act(source, power, zap_range, tesla_flags, shocked_targets)
