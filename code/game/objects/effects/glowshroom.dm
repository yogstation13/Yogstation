//separate dm since hydro is getting bloated already

#define MAX_GENERATION 6 // The maximum number of generations before glowshroom stop reproducing.
#define MAX_GLOWSHROOM 1024 // Maximum number of glowshrooms that can exist in-game at the same time
// There are about ~11,000 open floor tiles on Boxstation, so having 1024 means 10% of the station is covered in the crap.
#define OVERGROWTH_CHANCE 60 // Probability (out of 100) that this glowshroom can attempt to reproduce into a tile which already has (or is adjacent to) a glowshroom, per reproduction attempt.

#define FLOOR_DIR 16 // Used as a 5th direction when determining what directions have/haven't been planted here

/obj/structure/glowshroom
	name = "glowshroom"
	desc = "Mycena Bregprox, a species of mushroom that glows in the dark."
	anchored = TRUE
	opacity = 0
	density = FALSE
	icon = 'icons/obj/lighting.dmi'
	icon_state = "glowshroom" //replaced in New
	layer = ABOVE_NORMAL_TURF_LAYER
	max_integrity = 30
	var/delay = 1200
	var/floor = 0
	var/generation = 1
	var/static/glowshroom_count = 0 // The current amount of glowshrooms known to exist. Used to help cap their population.
	var/seeds_to_spread = 0 // Marks how many times more we can reproduce.
	var/list/dirs_planted = list() // The directional areas that've already been planted on on this tile by this glowshroom colony, including perhaps FLOOR_DIR.
	var/obj/item/seeds/myseed = /obj/item/seeds/glowshroom
	var/static/list/blacklisted_glowshroom_turfs = typecacheof(list(
	/turf/open/lava,
	/turf/open/floor/plating/beach/water))

/obj/structure/glowshroom/glowcap
	name = "glowcap"
	desc = "Mycena Ruthenia, a species of mushroom that, while it does glow in the dark, is not actually bioluminescent."
	icon_state = "glowcap"
	myseed = /obj/item/seeds/glowshroom/glowcap

/obj/structure/glowshroom/shadowshroom
	name = "shadowshroom"
	desc = "Mycena Umbra, a species of mushroom that emits shadow instead of light."
	icon_state = "shadowshroom"
	myseed = /obj/item/seeds/glowshroom/shadowshroom

/obj/structure/glowshroom/single/Spread()
	return

/obj/structure/glowshroom/examine(mob/user)
	. = ..()
	. += "This is a [generation]\th generation [name]!"

/obj/structure/glowshroom/Destroy()
	if(myseed)
		QDEL_NULL(myseed)
	--glowshroom_count
	return ..()

/obj/structure/glowshroom/New(loc, obj/item/seeds/newseed, mutate_stats, ourgen)
	..()
	++glowshroom_count
	if(newseed)
		myseed = newseed.Copy()
		myseed.forceMove(src)
	else
		myseed = new myseed(src)
	if(mutate_stats) //baby mushrooms have different stats :3
		myseed.adjust_potency(rand(-3,6))
		myseed.adjust_yield(rand(-2,1)) // The yield naturally decreases as it spreads, on average
		myseed.adjust_production(rand(-3,6))
		myseed.adjust_endurance(rand(-3,6))
	delay = delay - myseed.production * 100 //So the delay goes DOWN with better stats instead of up. :I
	obj_integrity = myseed.endurance
	max_integrity = myseed.endurance
	seeds_to_spread = myseed.yield // It used to be that Glowshrooms would use their seed's yield var on-the-fly for marking how many seeds they had left. I want you to sit back and appreciate how stupid that was.
	var/datum/plant_gene/trait/glow/G = myseed.get_gene(/datum/plant_gene/trait/glow)
	if(ispath(G)) // Seeds were ported to initialize so their genes are still typepaths here, luckily their initializer is smart enough to handle us doing this
		myseed.genes -= G
		G = new G
		myseed.genes += G
	set_light(G.glow_range(myseed), G.glow_power(myseed), G.glow_color)
	//We happen to know with some certainty that we are the only glowshroom object on the tile, so we can handle our directionality however.
	var/our_dir = pick(list(NORTH, SOUTH, EAST, WEST, FLOOR_DIR))
	dirs_planted += our_dir
	switch(our_dir) //offset to make it be on the wall rather than on the floor
		if(NORTH)
			pixel_y = 32
			icon_state = "[initial(icon_state)][rand(1,3)]"
		if(SOUTH)
			pixel_y = -32
			icon_state = "[initial(icon_state)][rand(1,3)]"
		if(EAST)
			pixel_x = 32
			icon_state = "[initial(icon_state)][rand(1,3)]"
		if(WEST)
			pixel_x = -32
			icon_state = "[initial(icon_state)][rand(1,3)]"
		if(FLOOR_DIR)
			icon_state = initial(icon_state)
	if(ourgen)
		generation = ourgen
	if(generation < MAX_GENERATION && glowshroom_count < MAX_GLOWSHROOM && seeds_to_spread > 0)
		addtimer(CALLBACK(src, .proc/Spread), delay)

/obj/structure/glowshroom/proc/Spread()
	var/turf/ownturf = get_turf(src)
	//First lets build the list of turfs we could expand into.
	//We can do this w/o any defensive if's because we know there is at least *one* seed we can spread.
	var/list/openlocs = list()
	for(var/turf/open/floor/earth in oview(3,src)) // Using oview instead of view makes the spread a bit more distributed and makes this run a bit faster, hopefully.
		if(is_type_in_typecache(earth, blacklisted_glowshroom_turfs))
			continue
		if(!ownturf.CanAtmosPass(earth))
			continue
		openlocs += earth
	for(var/i in 1 to seeds_to_spread)
		if(rand() > 1/(generation * generation))//This formula gives you diminishing returns based on generation. 100% with 1st gen, decreasing to 25%, 11%, 6, 4, 2...
			--seeds_to_spread // Well, not actually *diminishing* returns. The result is a population that grows (worst-case) in accordance to a logistic curve: https://www.desmos.com/calculator/x9uws7zv98
			continue
		var/turf/newloc = pick(openlocs)
		if(!prob(OVERGROWTH_CHANCE)) // If we're refusing to overgrowth
			if(locate(/obj/structure/glowshroom in view(1,newloc))) // and there's a glowshroom nearby our target loc
				continue // then we ain't moving here
			// We know that there's no glowshroom here so we can just go ahead and plant
			var/obj/structure/glowshroom/child = new type(newLoc, myseed, TRUE, generation + 1)
			--seeds_to_spread
		else // if we're willing to overgrowth
			var/obj/structure/glowshroom/glowyboi = locate(/obj/structure/glowshroom) in newloc
			if(glowyboi) // If there's a glowyboi here
				var/list/possible_dirs = list(NORTH,SOUTH,EAST,WEST,FLOOR_DIR) - glowyboi.dirs_planted
				for(var/dir in possible_dirs)
					if(dir == FLOOR_DIR)
						continue
					var/turf/isWall = get_step(newloc,dir)
					if(!isWall.density)
						possible_dirs -= dir
				var/our_dir = pick(possible_dirs)
				glowyboi.Overgrowth(our_dir) // Does not actually create a new glowshroom object on the tile, just updates the sprite of the one already there!
				--seeds_to_spread
			else // If there's nobody in this tile we can just go ahead and plant
				var/obj/structure/glowshroom/child = new type(newLoc, myseed, TRUE, generation + 1)
				--seeds_to_spread
	if(seeds_to_spread)
		delay *= 1.1
		addtimer(CALLBACK(src, .proc/Spread), delay)

/obj/structure/glowshroom/proc/Overgrowth(newdir) // Adds a new sprite on top of the current one, of some more glowshroomage.
	dirs_planted += newdir
	if(newdir == FLOOR_DIR)
		underlays += image(icon, initial(icon_state))
	else
		overlays += image(icon, "[initial(icon_state)][rand(1,3)]", newdir)

/obj/structure/glowshroom/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	if(damage_type == BURN && damage_amount)
		playsound(src.loc, 'sound/items/welder.ogg', 100, 1)

/obj/structure/glowshroom/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		take_damage(5, BURN, 0, 0)

/obj/structure/glowshroom/acid_act(acidpwr, acid_volume)
	. = 1
	visible_message("<span class='danger'>[src] melts away!</span>")
	var/obj/effect/decal/cleanable/molten_object/I = new (get_turf(src))
	I.desc = "Looks like this was \an [src] some time ago."
	qdel(src)

#undef MAX_GENERATION
#undef MAX_GLOWSHROOM
#undef OVERGROWTH_CHANCE
#undef FLOOR_DIR