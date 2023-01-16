/mob/living/simple_animal/hostile/yog_jungle/alpha_meduracha
	name ="Meduracha majora"
	desc = "Collosal beast of tentacles, its deep eye look directly at you"
	icon_state = "alpha_meduracha"
	icon_living = "alpha_meduracha"
	icon_dead = "meduracha_dead"
	mob_biotypes = list(MOB_BEAST,MOB_ORGANIC)
	speak = list("hgrah!","blrp!","poasp!","ahkr!")
	speak_emote = list("bubbles", "vibrates")
	emote_hear = list("gazes.","bellows.","splashes.")
	emote_taunt = list("reverbs", "shakes")
	speak_chance = 1
	taunt_chance = 1
	move_to_delay = 7
	butcher_results = list(/obj/item/stack/sheet/meduracha = 5)
	faction = list("mining")
	response_help  = "gently pokes"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"
	maxHealth = 300
	health = 300
	spacewalk = TRUE
	crusher_loot = /obj/item/crusher_trophy/jungleland/meduracha_tentacles
	melee_damage_lower = 20
	melee_damage_upper = 25
	ranged = TRUE 
	ranged_cooldown = 5 SECONDS
	projectiletype = /obj/item/projectile/jungle/meduracha_spit

	var/list/anchors = list("SOUTH" = null, "NORTH" = null, "EAST" = null, "WEST" = null)
	
/mob/living/simple_animal/hostile/yog_jungle/alpha_meduracha/Initialize()
	. = ..()
	for(var/side in anchors)
		anchors[side] = get_beam()
	
/mob/living/simple_animal/hostile/yog_jungle/alpha_meduracha/Move(atom/newloc, dir, step_x, step_y)
	for(var/direction in list("NORTH","SOUTH","EAST","WEST"))
		var/datum/beam/B = anchors[direction]
		if(!B || QDELETED(B))
			anchors[direction] = get_beam()
			B = anchors[direction]
		if(get_dist(B.target,src) > 5)
			remake_beam(direction)
	. = ..() 
	
/mob/living/simple_animal/hostile/yog_jungle/alpha_meduracha/Shoot(atom/targeted_atom)
	. = ..()
	var/angle = Get_Angle(src,targeted_atom)
	var/list/to_shoot = list() 
	
	to_shoot += get_turf(targeted_atom)
	to_shoot += locate(round(x + sin(angle + 20) * 7),round(y + cos(angle + 15) * 7),z)
	to_shoot += locate(round(x + sin(angle - 20) * 7),round(y + cos(angle - 15) * 7),z)
	for(var/turf/T as anything in to_shoot)
		shoot_projectile(T)

/mob/living/simple_animal/hostile/yog_jungle/alpha_meduracha/proc/shoot_projectile(atom/targeted_atom)
	var/turf/startloc = get_turf(src)
	var/obj/item/projectile/P = new projectiletype(startloc)
	playsound(src, projectilesound, 100, 1)
	P.starting = startloc
	P.firer = src
	P.fired_from = src
	P.yo = targeted_atom.y - startloc.y
	P.xo = targeted_atom.x - startloc.x
	if(AIStatus != AI_ON)//Don't want mindless mobs to have their movement screwed up firing in space
		newtonian_move(get_dir(targeted_atom, targets_from))
	P.original = targeted_atom
	P.preparePixelProjectile(targeted_atom, src)
	P.fire()

/mob/living/simple_animal/hostile/yog_jungle/alpha_meduracha/proc/get_beam()
	var/list/turfs = spiral_range_turfs(4,src)
	var/turf/T = pick(turfs)
	return Beam(T,"meduracha",'yogstation/icons/effects/beam.dmi',INFINITY,8)

/mob/living/simple_animal/hostile/yog_jungle/alpha_meduracha/proc/remake_beam(side)
	var/datum/beam/B = anchors[side]
	anchors[side] = get_beam()
	qdel(B)
