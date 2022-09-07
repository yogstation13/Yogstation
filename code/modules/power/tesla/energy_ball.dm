/obj/singularity/energy_ball
	name = "energy ball"
	desc = "An energy ball."
	icon = 'icons/obj/tesla_engine/energy_ball.dmi'
	icon_state = "energy_ball"
	pixel_x = -32
	pixel_y = -32
	current_size = STAGE_TWO
	move_self = 1
	grav_pull = 0
	contained = 0
	density = TRUE
	energy = 0
	dissipate = 1
	dissipate_delay = 5
	dissipate_strength = 1
	var/list/orbiting_balls = list()
	var/miniball = FALSE
	var/produced_power
	var/energy_to_raise = 32
	var/energy_to_lower = -20
	var/max_balls = 10
	var/zap_range = 7

/obj/singularity/energy_ball/Initialize(mapload, starting_energy = 50, is_miniball = FALSE)
	miniball = is_miniball
	. = ..()
	if(!is_miniball)
		set_light(10, 7, "#EEEEFF")

/obj/singularity/energy_ball/ex_act(severity, target)
	return

/obj/singularity/energy_ball/Destroy()
	if(orbiting && istype(orbiting.parent, /obj/singularity/energy_ball))
		var/obj/singularity/energy_ball/EB = orbiting.parent
		EB.orbiting_balls -= src

	for(var/ball in orbiting_balls)
		var/obj/singularity/energy_ball/EB = ball
		qdel(EB)

	. = ..()

/obj/singularity/energy_ball/admin_investigate_setup()
	if(miniball)
		return //don't annnounce miniballs
	..()


/obj/singularity/energy_ball/process()
	if(!orbiting)
		handle_energy()

		move_the_basket_ball(4 + orbiting_balls.len * 1.5)

		playsound(src.loc, 'sound/magic/lightningbolt.ogg', 100, 1, extrarange = 30)

		pixel_x = 0
		pixel_y = 0

		tesla_zap(src, zap_range, TESLA_DEFAULT_POWER)

		pixel_x = -32
		pixel_y = -32

		var/list/RG = range(1, src)
		for(var/obj/singularity/energy_ball/E in RG)
			if(!E.miniball && E != src)
				collide(E)

		for (var/ball in orbiting_balls)
			if(prob(80))  //tesla nerf/reducing lag, each miniball now has only 20% to trigger the zap
				continue
			tesla_zap(ball, rand(2, zap_range), TESLA_MINI_POWER)
	else
		energy = 0 // ensure we dont have miniballs of miniballs

/obj/singularity/energy_ball/examine(mob/user)
	. = ..()
	if(orbiting_balls.len)
		. += "There are [orbiting_balls.len] mini-balls orbiting it."

/obj/singularity/energy_ball/proc/collide(var/obj/singularity/energy_ball/target)
	if(max_balls < target.max_balls) //we bow down against a stronger tesla
		return
	
	name = "[pick("hypercharged", "super", "powered", "glowing", "unstable", "anomalous", "massive")] [name]"
	max_balls += target.max_balls - 8 //default 2 more max balls per another tesla, respecting another consumed tesla
	zap_range += target.zap_range - 6 //also 1 more range for zapping, making it harder to contain
	add_atom_colour(rgb(255 - max_balls * 10, 255 - max_balls * 10, 255), ADMIN_COLOUR_PRIORITY) //gets more blue with more power
	playsound(src.loc, 'sound/magic/lightning_chargeup.ogg', 100, 1, extrarange = 30)
	qdel(target)


/obj/singularity/energy_ball/proc/move_the_basket_ball(var/move_amount)
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

		playsound(src.loc, 'sound/magic/lightning_chargeup.ogg', 100, 1, extrarange = 30)
		addtimer(CALLBACK(src, .proc/new_mini_ball), 100)

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

	var/obj/singularity/energy_ball/EB = new(loc, 0, TRUE)

	EB.transform *= pick(0.3, 0.4, 0.5, 0.6, 0.7)
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
		C.()
		
/obj/singularity/energy_ball/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/golfclub))
		var/turf/throw_at = get_ranged_target_turf(src, get_dir(user, src), 2)
		throw_at(throw_at, 2, 1)
		user.changeNext_move(CLICK_CD_RANGE)

/obj/singularity/energy_ball/orbit(obj/singularity/energy_ball/target)
	if (istype(target))
		target.orbiting_balls += src
		GLOB.poi_list -= src
		target.dissipate_strength = target.orbiting_balls.len

	. = ..()
/obj/singularity/energy_ball/stop_orbit()
	if (orbiting && istype(orbiting.parent, /obj/singularity/energy_ball))
		var/obj/singularity/energy_ball/orbitingball = orbiting.parent
		orbitingball.orbiting_balls -= src
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

	var/closest_dist = 0
	var/closest_atom
	var/obj/machinery/power/tesla_coil/closest_tesla_coil
	var/obj/machinery/power/grounding_rod/closest_grounding_rod
	var/mob/living/closest_mob
	var/obj/machinery/closest_machine
	var/obj/structure/closest_structure
	var/obj/structure/blob/closest_blob
	var/static/things_to_shock = typecacheof(list(/obj/machinery, /mob/living, /obj/structure))
	var/static/blacklisted_tesla_types = typecacheof(list(/obj/machinery/atmospherics,
										/obj/machinery/power/emitter,
										/obj/machinery/field/generator,
										/mob/living/simple_animal,
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
										/obj/structure/grille,
										/obj/machinery/the_singularitygen/tesla,
										/obj/structure/frame/machine))

	// +3 to range specifically to include grounding rods that are zap_range+3 away
	for(var/A in typecache_filter_multi_list_exclusion(oview(source, zap_range+3), things_to_shock, blacklisted_tesla_types))
		if(!(tesla_flags & TESLA_ALLOW_DUPLICATES) && LAZYACCESS(shocked_targets, A))
			continue

		var/dist = get_dist(source, A)

		if(istype(A, /obj/machinery/power/tesla_coil))
			var/obj/machinery/power/tesla_coil/C = A
			if(dist <= zap_range && (dist < closest_dist || !closest_tesla_coil) && !(C.obj_flags & BEING_SHOCKED))
				closest_dist = dist

				//we use both of these to save on istype and typecasting overhead later on
				//while still allowing common code to run before hand
				closest_tesla_coil = C
				closest_atom = C

		else if(closest_tesla_coil)
			continue //no need checking these other things

		else if(istype(A, /obj/machinery/power/grounding_rod))
			if(dist < closest_dist || !closest_grounding_rod)
				closest_grounding_rod = A
				closest_atom = A
				closest_dist = dist

		else if(closest_grounding_rod)
			continue

		else if(isliving(A))
			var/mob/living/L = A
			if(dist <= zap_range && (dist < closest_dist || !closest_mob) && L.stat != DEAD && !(L.flags_1 & TESLA_IGNORE_1))
				closest_mob = L
				closest_atom = A
				closest_dist = dist

		else if(closest_mob)
			continue

		else if(ismachinery(A))
			var/obj/machinery/M = A
			if(dist <= zap_range && (dist < closest_dist || !closest_machine) && !(M.obj_flags & BEING_SHOCKED))
				closest_machine = M
				closest_atom = A
				closest_dist = dist

		else if(closest_mob)
			continue

		else if(istype(A, /obj/structure/blob))
			var/obj/structure/blob/B = A
			if(dist <= zap_range && (dist < closest_dist || !closest_tesla_coil) && !(B.obj_flags & BEING_SHOCKED))
				closest_blob = B
				closest_atom = A
				closest_dist = dist

		else if(closest_blob)
			continue

		else if(isstructure(A))
			var/obj/structure/S = A
			if(dist <= zap_range && (dist < closest_dist || !closest_tesla_coil) && !(S.obj_flags & BEING_SHOCKED))
				closest_structure = S
				closest_atom = A
				closest_dist = dist

	//Alright, we've done our loop, now lets see if was anything interesting in range
	if(closest_atom)
		//common stuff
		source.Beam(closest_atom, icon_state="lightning[rand(1,12)]", time=5, maxdistance = INFINITY)
		if(!(tesla_flags & TESLA_ALLOW_DUPLICATES))
			LAZYSET(shocked_targets, closest_atom, TRUE)
		var/zapdir = get_dir(source, closest_atom)
		if(zapdir)
			. = zapdir

	//per type stuff:
	if(closest_tesla_coil)
		closest_tesla_coil.tesla_act(power, tesla_flags, shocked_targets)

	else if(closest_grounding_rod)
		closest_grounding_rod.tesla_act(power, tesla_flags, shocked_targets)

	else if(closest_mob)
		var/shock_damage = (tesla_flags & TESLA_MOB_DAMAGE)? (min(round(power/600), 90) + rand(-5, 5)) : 0
		closest_mob.electrocute_act(shock_damage, source, 1, tesla_shock = 1, stun = (tesla_flags & TESLA_MOB_STUN))
		if(issilicon(closest_mob))
			var/mob/living/silicon/S = closest_mob
			if((tesla_flags & TESLA_MOB_STUN) && (tesla_flags & TESLA_MOB_DAMAGE))
				S.emp_act(EMP_LIGHT)
			tesla_zap(S, 7, power / 1.5, tesla_flags, shocked_targets) // metallic folks bounce it further
		else
			tesla_zap(closest_mob, 5, power / 1.5, tesla_flags, shocked_targets)

	else if(closest_machine)
		closest_machine.tesla_act(power, tesla_flags, shocked_targets)

	else if(closest_blob)
		closest_blob.tesla_act(power, tesla_flags, shocked_targets)

	else if(closest_structure)
		closest_structure.tesla_act(power, tesla_flags, shocked_targets)
