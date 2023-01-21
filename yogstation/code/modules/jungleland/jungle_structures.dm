/obj/structure/flora/tree/dead/jungle
	icon = 'icons/obj/flora/deadtrees.dmi'
	desc = "A dead tree. How it died, you know not."
	icon_state = "nwtree_1"

/obj/structure/flora/tree/dead/jungle/Initialize()
	. = ..()
	icon_state = "nwtree_[rand(1, 6)]"

/obj/effect/better_animated_temp_visual/skin_twister_in
	layer = BELOW_MOB_LAYER
	duration = 8
	icon = 'yogstation/icons/effects/64x64.dmi'
	animated_icon_state = "skin_twister_in"
	pixel_y = -16
	pixel_x = -16

/obj/effect/better_animated_temp_visual/skin_twister_out
	layer = BELOW_MOB_LAYER
	duration = 8
	icon = 'yogstation/icons/effects/64x64.dmi'
	animated_icon_state = "skin_twister_out"
	pixel_y = -16
	pixel_x = -16

/obj/effect/tar_king
	layer = BELOW_MOB_LAYER
	icon_state = ""

//For some reason Initialize() doesnt want to get properly overloaded, so I'm forced to use this
/obj/effect/tar_king/New(loc, datum/following, direction)
	. = ..()
	RegisterSignal(following,COMSIG_MOVABLE_MOVED,.proc/follow)
	setDir(direction)

/obj/effect/tar_king/proc/follow(datum/source)
	forceMove(get_turf(source))

/obj/effect/tar_king/rune_attack
	icon = 'yogstation/icons/effects/160x160.dmi'
	pixel_x = -64 
	pixel_y = -64

/obj/effect/tar_king/rune_attack/New(loc, ...)
	. = ..()
	flick("rune_attack",src)
	QDEL_IN(src,13)

/obj/effect/tar_king/slash 
	icon = 'yogstation/icons/effects/160x160.dmi'
	pixel_x = -64
	pixel_y = -64

/obj/effect/tar_king/slash/New(loc, datum/following, direction)
	. = ..()
	flick("slash",src)	 
	QDEL_IN(src,4)

/obj/effect/tar_king/impale
	icon = 'yogstation/icons/effects/160x160.dmi'
	pixel_x = -64
	pixel_y = -64

/obj/effect/tar_king/impale/New(loc, ...)
	. = ..()
	flick("stab",src)	 
	QDEL_IN(src,4)

/obj/effect/tar_king/orb_out	
	pixel_x = -16
	pixel_y = -16
	icon = 'yogstation/icons/effects/64x64.dmi'

/obj/effect/tar_king/orb_out/New(loc, ...)
	. = ..()
	flick("ability1",src)	 
	QDEL_IN(src,4)

/obj/effect/tar_king/orb_in
	pixel_x = -16
	pixel_y = -16
	icon = 'yogstation/icons/effects/64x64.dmi'

/obj/effect/tar_king/orb_in/New(loc, ...)
	. = ..()
	flick("ability0",src)	 
	QDEL_IN(src,4)

/obj/structure/tar_pit
	name = "Tar pit"
	desc = "A pit filled with viscious substance resembling tar, every so often a bubble rises to the top."
	icon = 'yogstation/icons/obj/jungle.dmi'
	icon_state = "tar_pit"
	layer = SIGIL_LAYER
	anchored = TRUE 
	density = FALSE

/obj/structure/tar_pit/Initialize()
	. = ..()
	GLOB.tar_pits += src

/obj/structure/tar_pit/Destroy()
	GLOB.tar_pits -= src
	return ..()


/obj/effect/timed_attack
	var/replace_icon_state = ""
	var/animation_length = 0

/obj/effect/timed_attack/New(loc, ...)
	. = ..()
	flick(replace_icon_state,src)	 
	addtimer(CALLBACK(src,.proc/finish_attack),animation_length)

/obj/effect/timed_attack/proc/finish_attack()
	qdel(src)

/obj/effect/timed_attack/tar_priest 
	icon = 'yogstation/icons/effects/jungle.dmi'
	animation_length = 13

/obj/effect/timed_attack/tar_priest/curse 
	replace_icon_state = "tar_shade_curse"


/obj/effect/timed_attack/tar_priest/curse/finish_attack()
	var/turf/T = get_turf(src)
	for(var/mob/living/L in T.contents)
		L.apply_status_effect(/datum/status_effect/tar_curse)	
	return ..()
/obj/effect/timed_attack/tar_priest/shroud
	replace_icon_state = "tar_shade_shroud"

/obj/effect/timed_attack/tar_priest/shroud/finish_attack()
	var/turf/T = get_turf(src)
	for(var/mob/living/L in T.contents)
		if(L.has_status_effect(/datum/status_effect/tar_curse))
			L.set_blindness(20)
			SEND_SIGNAL(L,COMSIG_JUNGLELAND_TAR_CURSE_PROC)	
		else 
			L.set_blurriness(20)
	return ..()
/obj/effect/timed_attack/tar_priest/tendril 
	replace_icon_state = "tar_shade_tendril"

/obj/effect/timed_attack/tar_priest/tendril/finish_attack()
	var/turf/T = get_turf(src)
	for(var/mob/living/L in T.contents)
		if(L.has_status_effect(/datum/status_effect/tar_curse))
			L.Stun(5 SECONDS)
			SEND_SIGNAL(L,COMSIG_JUNGLELAND_TAR_CURSE_PROC)	
		else 
			L.adjustStaminaLoss(60)
	return ..()

/obj/structure/fluff/tarstatue
	name = "Tar Statue"
	desc = "A lifelike recreation of some...one? It seems damaged from years of neglect."
	icon = 'yogstation/icons/obj/jungle.dmi'
	icon_state = "damaged_tarstatue"
	deconstructible = FALSE
	density = TRUE

/obj/structure/tar_altar
	name = "Forgotten Altar"
	desc = "A might pillar of ivory, untouched by time and corrosion. There is a large hole on the top, it's missing a key ingridient..."
	icon = 'yogstation/icons/obj/jungle32x48.dmi'
	icon_state = "tar_altar"
	layer = ABOVE_ALL_MOB_LAYER
	resistance_flags = INDESTRUCTIBLE
	anchored = TRUE 
	density = TRUE
 
/obj/structure/tar_altar/attacked_by(obj/item/I, mob/living/user)
	if(!istype(I,/obj/item/full_tar_crystal))
		return ..()
	
	add_overlay(image(icon = src.icon, icon_state = "tar_altar_crystal"))
	qdel(I)
	INVOKE_ASYNC(src,.proc/summon)

/obj/structure/tar_altar/proc/summon()
	for(var/mob/living/L in range(7,src))
		shake_camera(L,1 SECONDS, 4)
	
	animate(src,time = 15 SECONDS, color = "#1f0010")
	sleep(20 SECONDS)
	visible_message(span_colossus("WHO DARES?"))
	
	for(var/mob/living/L in range(7,src))
		shake_camera(L,2 SECONDS, 2)
	sleep(2 SECONDS)	

	playsound(get_turf(src), 'sound/magic/exit_blood.ogg', 100, 1, -1)	
	new /mob/living/simple_animal/hostile/megafauna/tar_king(get_turf(src))

/obj/structure/herb
	icon = 'yogstation/icons/obj/jungle.dmi'
	anchored = TRUE 
	density = FALSE

	var/picked_result
	var/picked_amt

/obj/structure/herb/attack_hand(mob/user)
	. = ..()
	if(!do_after(user,10 SECONDS,src))
		return

	for(var/i in 1 to picked_amt)
		new picked_result(get_turf(src))
	
	qdel(src)

/obj/structure/herb/explosive_shrooms
	name = "Explosive Mushroom"
	desc = "Highly volatile mushrooms, they contain a high amount of volatile alkalines that will explode after a short delay if stepped on."
	icon = 'yogstation/icons/obj/jungle.dmi'
	icon_state = "explosive_shrooms"
	picked_amt = 1
	picked_result = /obj/item/explosive_shroom

/obj/structure/herb/explosive_shrooms/Cross(atom/movable/AM)
	. = ..()
	if(!isliving(AM))
		return 
	
	animate(src,time=2.49 SECONDS, color = "#e05a5a")
	addtimer(CALLBACK(src,.proc/explode),2.5 SECONDS)

/obj/structure/herb/explosive_shrooms/proc/explode()
	dyn_explosion(get_turf(src),4)
	if(src && !QDELETED(src))
		qdel(src)

//haha you get the jokes, the shrooms that make you trip balls are called "liberal hats", pun being that there are shrooms that do that that are called "liberty caps" haha
/obj/structure/herb/liberal_hats
	name = "Liberal Hats"
	desc = "Liberate yourself from the chains of your flesh, consume and witness the world in new colors."
	icon = 'yogstation/icons/obj/jungle.dmi'
	icon_state = "liberal_hats"
	picked_amt = 3
	picked_result = /obj/item/reagent_containers/food/snacks/grown/jungle/liberal_hat

/obj/structure/herb/cinchona
	name = "Cinchona Exotica"
	desc = "A small shrubby tree with a very peculiar bark..."
	icon = 'yogstation/icons/obj/jungle.dmi'
	icon_state = "herb_5"
	picked_amt = 3
	picked_result = /obj/item/reagent_containers/food/snacks/grown/jungle/cinchona_bark

/obj/structure/herb/fruit
	desc = "Fruiting plant, i wonder how the berry tastes like?"
	icon = 'yogstation/icons/obj/jungle.dmi'
	picked_amt = 1

/obj/structure/herb/fruit/Initialize()
	. = ..()
	var/fruit = pick("kuku","bonji","bianco")
	switch(fruit)
		if("kuku")
			name = "Kuku bush"
			icon_state = "kuku_plant"
			picked_result = /obj/item/reagent_containers/food/snacks/grown/jungle/kuku
		if("bonji")
			name = "Bonji bush"
			icon_state = "bonji_plant"
			picked_result = /obj/item/reagent_containers/food/snacks/grown/jungle/bonji
		if("bianco")
			name = "Bianco bush"
			icon_state = "bianco_plant"
			picked_result = /obj/item/reagent_containers/food/snacks/grown/jungle/bianco

/obj/structure/flytrap //feed it a specific mob loot to get rare materials. Can rarely drop VERY rare minerals like bananium!
	name = "Mineral Rich Flytrap"
	desc = "The mouth doesn't look big enough to hurt you, but it does look very hungry."
	icon = 'yogstation/icons/obj/jungle.dmi'
	icon_state = "flytrap"
	anchored = TRUE 
	density = FALSE

	var/full = FALSE
	var/craving = /obj/item/stack/sheet/meduracha

/obj/structure/flytrap/Initialize()
	. = ..()
	var/outcome = rand(1,3)
	switch(outcome)
		if(1)
			craving = /obj/item/stack/sheet/meduracha
			desc = "The mouth doesn't look big enough to hurt you, but it does look very hungry. It seems peckish for some meduracha tentacles."
		if(2)
			craving = /obj/item/stack/sheet/skin_twister
			desc = "The mouth doesn't look big enough to hurt you, but it does look very hungry. It seems to have a specific appetite for skintwister hide."
		if(3)
			craving = /obj/item/stack/sheet/slime
			desc = "The mouth doesn't look big enough to hurt you, but it does look very hungry. Seems starving for some slime."

/obj/structure/flytrap/attackby(obj/item/W, mob/user, params)
	if(istype(W, craving) && full == FALSE )
		user.visible_message(span_notice("[user] feeds the [src], and watches as it spews out materials!"),span_notice("You place the [W] inside the mouth of the [src], watching as it devours it and shoots out minerals!"))
		full = TRUE
		var/lootoutcome = rand(1,25)
		switch(lootoutcome)
			if(1 to 8)
				for(var/i in 1 to 5)
					new /obj/item/stack/ore/dilithium_crystal(get_turf(src))
			if(9 to 14)
				for(var/i in 1 to 5)
					new /obj/item/stack/ore/diamond(get_turf(src))
			if(15 to 22)
				for(var/i in 1 to 5)
					new /obj/item/stack/ore/bluespace_crystal(get_turf(src))
			if(23)
				new /obj/item/stack/ore/bananium(get_turf(src))
			if(24)
				new /obj/item/stack/sheet/mineral/mythril(get_turf(src))
			if(25)
				new /obj/item/stack/sheet/mineral/adamantine(get_turf(src))		
		icon_state = "flytrap_closed"
		desc = "A relatively large venus fly trap. The mouthes seemed to be closed, doesn't look like they'll open any time soon."
		W.use(1)
	else
		return ..()

/obj/structure/tar_shrine
	name = "Tar shrine"
	desc = "Strangely translucent pool of tar"
	icon = 'yogstation/icons/obj/jungle32x48.dmi'
	icon_state = "shrine"
	resistance_flags = INDESTRUCTIBLE
	anchored = TRUE

/obj/structure/spawner/nest
	name = "Fauna nest"
	desc = "Breeding grounds for the fauna of the jungle"
	icon = 'yogstation/icons/obj/jungle.dmi'
	icon_state = "nest"
	faction = list("mining")
	max_mobs = 3
	max_integrity = 250
	move_resist = INFINITY
	anchored = TRUE
	density = FALSE 
	var/list/possible_mob_types = list()

GLOBAL_LIST_INIT(nests, list())
/obj/structure/spawner/nest/Initialize()
	for(var/obj/structure/flora/F in orange(3,src))
		qdel(F)
	GLOB.nests += src
	mob_types = list(pick(possible_mob_types))
	return ..()

/obj/structure/spawner/nest/deconstruct(disassembled, force)
	new /obj/structure/closet/crate/necropolis/tendril(loc)
	visible_message(span_boldannounce("You've awakened a sleeping monster from within the nest! Get back!"))
	playsound(loc,'sound/effects/tendril_destroyed.ogg', 200, 0, 50, 1, 1)
	spawn_mother_monster()
	return ..()

/obj/structure/spawner/nest/proc/spawn_mother_monster()
	var/mob/living/simple_animal/hostile/yog_jungle/type = pick(mob_types)
	if(initial(type.alpha_type) == 0)
		var/mob/living/simple_animal/hostile/yog_jungle/monster = new type(loc)
		monster.setMaxHealth(monster.maxHealth * 1.5)
		monster.health = monster.maxHealth * 1.5
		monster.move_to_delay = max(monster.move_to_delay / 2, 1)
		if(monster.alpha_damage_boost == 1) //mobs with really high damage amounts may be exempt from giant damage boosts
			monster.melee_damage_lower *= 1.5 
			monster.melee_damage_upper *= 1.5
		monster.faction = list("mining")
		var/matrix/M = matrix()
		M.Scale(1.5,1.5)
		monster.transform = M
		monster.color = "#c30505"
		return
	type = initial(type.alpha_type)
	new type(loc)
/obj/structure/spawner/nest/jungle
	possible_mob_types = list(/mob/living/simple_animal/hostile/yog_jungle/dryad, /mob/living/simple_animal/hostile/yog_jungle/yellowjacket)

/obj/structure/spawner/nest/swamp
	possible_mob_types = list(/mob/living/simple_animal/hostile/yog_jungle/mosquito,/mob/living/simple_animal/hostile/yog_jungle/meduracha, /mob/living/simple_animal/hostile/yog_jungle/blobby)

/obj/structure/spawner/nest/dying
	possible_mob_types = list(/mob/living/simple_animal/hostile/yog_jungle/corrupted_dryad,/mob/living/simple_animal/hostile/yog_jungle/mosquito)

/obj/effect/spawner/tendril_spawner

/obj/effect/spawner/tendril_spawner/Initialize()
	. = ..()
	var/type = pick(typesof(/obj/structure/spawner/lavaland))
	new type(loc)
	qdel(src)
	
/obj/effect/better_animated_temp_visual/tar_shield_pop
	layer = BELOW_MOB_LAYER
	duration = 5
	icon = 'yogstation/icons/effects/96x96.dmi'
	animated_icon_state = "tar_shield_pop"
	pixel_y = -32
	pixel_x = -32

/obj/effect/better_animated_temp_visual 
	var/animated_icon_state
	var/duration 

/obj/effect/better_animated_temp_visual/New(loc, ...)
	. = ..()
	flick(animated_icon_state,src) 
	QDEL_IN(src,duration)

/obj/machinery/advanced_airlock_controller/jungleland
	exterior_pressure = 276.56 
	depressurization_margin = 36.896
	depressurization_target = 20

