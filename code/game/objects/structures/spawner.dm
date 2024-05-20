/obj/structure/spawner
	name = "monster nest"
	icon = 'icons/mob/animal.dmi'
	icon_state = "hole"
	max_integrity = 100

	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	anchored = TRUE
	density = TRUE

	var/faction = list("hostile")
	
	var/max_mobs = 5
	var/spawn_time = 30 SECONDS
	var/mob_types = list(/mob/living/simple_animal/hostile/carp)
	var/spawn_text = "emerges from"
	var/spawner_type = /datum/component/spawner
	/// Is this spawner taggable with something?
	var/scanner_taggable = FALSE
	/// If this spawner's taggable, what can we tag it with?
	var/static/list/scanner_types = list(/obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner)
	/// If this spawner's taggable, what's the text we use to describe what we can tag it with?
	var/scanner_descriptor = "mining analyzer"
	/// Has this spawner been tagged/analyzed by a mining scanner?
	var/gps_tagged = FALSE
	/// A short identifier for the mob it spawns. Keep around 3 characters or less?
	var/mob_gps_id = "???"
	/// A short identifier for what kind of spawner it is, for use in putting together its GPS tag.
	var/spawner_gps_id = "Creature Nest"
	/// A complete identifier. Generated on tag (if tagged), used for its examine.
	var/assigned_tag

/obj/structure/spawner/examine(mob/user)
	. = ..()
	if(!scanner_taggable)
		return
	if(gps_tagged)
		. += span_notice("A holotag's been attached, projecting \"<b>[assigned_tag]</b>\".")
	else
		. += span_notice("It looks like you could probably scan and tag it with a <b>[scanner_descriptor]</b>.")

/obj/structure/spawner/attackby(obj/item/item, mob/user, params)
	. = ..()
	if(.)
		return TRUE
	if(scanner_taggable && is_type_in_list(item, scanner_types))
		gps_tag(user)
		return TRUE

/// Tag the spawner, prefixing its GPS entry with an identifier - or giving it one, if nonexistent.
/obj/structure/spawner/proc/gps_tag(mob/user)
	if(gps_tagged)
		to_chat(user, span_warning("[src] already has a holotag attached!"))
		return
	to_chat(user, span_notice("You affix a holotag to [src]."))
	playsound(src, 'sound/machines/twobeep.ogg', 100)
	gps_tagged = TRUE
	assigned_tag = "\[[mob_gps_id]-[rand(100,999)]\] " + spawner_gps_id
	var/datum/component/gps/our_gps = GetComponent(/datum/component/gps)
	if(our_gps)
		our_gps.gpstag = assigned_tag
		return
	AddComponent(/datum/component/gps, assigned_tag)

/obj/structure/spawner/Initialize(mapload)
	. = ..()
	AddComponent(\
		spawner_type, \
		spawn_types = mob_types, \
		spawn_time = spawn_time, \
		max_spawned = max_mobs, \
		faction = faction, \
		spawn_text = spawn_text, \
	)

/obj/structure/spawner/attack_animal(mob/living/simple_animal/M)
	if(faction_check(faction, M.faction, FALSE)&&!M.client)
		return
	..()


/obj/structure/spawner/syndicate
	name = "warp beacon"
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"
	spawn_text = "warps in from"
	mob_types = list(/mob/living/simple_animal/hostile/syndicate/ranged)
	faction = list(ROLE_SYNDICATE)

/obj/structure/spawner/skeleton
	name = "bone pit"
	desc = "A pit full of bones, and some still seem to be moving..."
	icon_state = "hole"
	icon = 'icons/mob/nest.dmi'
	max_integrity = 150
	max_mobs = 15
	spawn_time = 150
	mob_types = list(/mob/living/simple_animal/hostile/skeleton)
	spawn_text = "climbs out of"
	faction = list("skeleton")

/obj/structure/spawner/clown
	name = "Laughing Larry"
	desc = "A laughing, jovial figure. Something seems stuck in his throat."
	icon_state = "clownbeacon"
	icon = 'icons/obj/device.dmi'
	max_integrity = 200
	max_mobs = 15
	spawn_time = 150
	mob_types = list(/mob/living/simple_animal/hostile/retaliate/clown, /mob/living/simple_animal/hostile/retaliate/clown/fleshclown, /mob/living/simple_animal/hostile/retaliate/clown/clownhulk, /mob/living/simple_animal/hostile/retaliate/clown/longface, /mob/living/simple_animal/hostile/retaliate/clown/clownhulk/chlown, /mob/living/simple_animal/hostile/retaliate/clown/clownhulk/honcmunculus, /mob/living/simple_animal/hostile/retaliate/clown/mutant/blob, /mob/living/simple_animal/hostile/retaliate/clown/banana, /mob/living/simple_animal/hostile/retaliate/clown/honkling, /mob/living/simple_animal/hostile/retaliate/clown/lube, /mob/living/simple_animal/hostile/retaliate/clown/afro, /mob/living/simple_animal/hostile/retaliate/clown/thin, /mob/living/simple_animal/hostile/retaliate/clown/clownhulk/punisher, /mob/living/simple_animal/hostile/retaliate/clown/mutant/thicc)
	spawn_text = "climbs out of"
	faction = list("clown")

/obj/structure/spawner/mining
	name = "monster den"
	desc = "A hole dug into the ground, harboring all kinds of monsters found within most caves or mining asteroids."
	icon_state = "hole"
	max_integrity = 200
	max_mobs = 3
	icon = 'icons/mob/nest.dmi'
	spawn_text = "crawls out of"
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/goldgrub, /mob/living/simple_animal/hostile/asteroid/goliath, /mob/living/simple_animal/hostile/asteroid/hivelord, /mob/living/simple_animal/hostile/asteroid/basilisk, /mob/living/simple_animal/hostile/asteroid/fugu)
	faction = list("mining")

/obj/structure/spawner/mining/goldgrub
	name = "goldgrub den"
	desc = "A den housing a nest of goldgrubs, annoying but arguably much better than anything else you'll find in a nest."
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/goldgrub)

/obj/structure/spawner/mining/goliath
	name = "goliath den"
	desc = "A den housing a nest of goliaths, oh god why?"
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/goliath)

/obj/structure/spawner/mining/hivelord
	name = "hivelord den"
	desc = "A den housing a nest of hivelords."
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/hivelord)

/obj/structure/spawner/mining/basilisk
	name = "basilisk den"
	desc = "A den housing a nest of basilisks, bring a coat."
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/basilisk)

/obj/structure/spawner/mining/wumborian
	name = "wumborian fugu den"
	desc = "A den housing a nest of wumborian fugus, how do they all even fit in there?"
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/fugu)
