//Nuclear particle projectile - a deadly side effect of fusion just kidding fuck that shit rads shouldn`t be a vomit ICBM
/obj/item/projectile/energy/nuclear_particle
	name = "nuclear particle"
	icon_state = "nuclear_particle"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 5
	damage_type = BURN
	irradiate = 400
	speed = 0.4
	hitsound = 'sound/weapons/emitter2.ogg'
	impact_type = /obj/effect/projectile/impact/xray
	var/static/list/particle_colors = list(
		"red" = "#FF0000",
		"green" = "#00FF00",
		"blue" = "#0000FF",
		"yellow" = "#FFFF00",
		"cyan" = "#00FFFF",
		"purple" = "#FF00FF"
	)

/obj/item/projectile/energy/nuclear_particle/Initialize()
	. = ..()
	//Random color time!
	var/our_color = pick(particle_colors)
	add_atom_colour(particle_colors[our_color], FIXED_COLOUR_PRIORITY)
	set_light(4, 3, particle_colors[our_color]) //Range of 4, brightness of 3 - Same range as a flashlight

/obj/item/projectile/energy/nuclear_particle/Move(atom/newloc, dir)
	..()
	for(var/obj/item/projectile/energy/nuclear_particle/P in newloc.contents)
		if(istype(P) && MODULUS(Angle - P.Angle, 360) > 150 && MODULUS(Angle - P.Angle, 360) < 210 && prob(10))
			name = "high-energy " + name
			damage += P.damage
			irradiate += P.irradiate
			SSresearch.science_tech.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, (damage * 10) + (irradiate / 10))
			range = initial(range)
			setAngle(rand(0, 360))
			qdel(P)
			break

/atom/proc/fire_nuclear_particle(angle = rand(0,360)) //used by fusion to fire random nuclear particles. Fires one particle in a random direction.
	var/obj/item/projectile/energy/nuclear_particle/P = new /obj/item/projectile/energy/nuclear_particle(src)
	P.fire(angle)
