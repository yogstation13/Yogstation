/obj/item/hog_item/prismatic_lance/
	name = "prismatic lance"
	desc = "Overcharge and prismatic lance structure use this. Ideally you shouldn't see it."
	resistance_flags = FIRE_PROOF | ACID_PROOF
	icon_state = "none"
	original_icon = "none"
	var/atom/target
	var/attack_borgs = TRUE
	var/damage_per_shot = 15
	var/sight_range = 5
	var/coldown = 2 SECONDS
	var/last_process
	var/overcharged = FALSE

/obj/item/hog_item/prismatic_lance/Initialize()
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/obj/item/hog_item/prismatic_lance/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/item/hog_item/prismatic_lance/process()
	if(target)
		if(get_dist(get_turf(target), get_turf(src)) > sight_range)
			target = null
		else
			if(last_process + coldown < world.time)
				if(isliving(target))
					var/mob/living/L = target
					if(!L.anti_magic_check(chargecost = 0))
						if(isrevenant(L))
							var/mob/living/simple_animal/revenant/R = L
							if(R.revealed)
								R.unreveal_time += 2
							else
								R.reveal(10)
						if(prob(50))
							L.playsound_local(null,'sound/machines/clockcult/ocularwarden-dot1.ogg',75,1)
						else
							L.playsound_local(null,'sound/machines/clockcult/ocularwarden-dot2.ogg',75,1)
						L.adjustFireLoss(damage_per_shot) 
						Beam(L, icon_state = "warden_beam", time = 10)	
						last_process = world.time
				else if(ismecha(target))
					var/obj/mecha/M = target
					Beam(M, icon_state = "warden_beam", time = 10)	
					M.take_damage(damage_per_shot * 2, BURN, MELEE, 1, get_dir(src, M)) ///Mechas get fucked more hardly(because they are cringe(very cringe))
					last_process = world.time 
				else if(istype(/obj/structure/hog_structure))
					var/obj/structure/S = target
					Beam(S, icon_state = "warden_beam", time = 10)	
					S.take_damage(damage_per_shot, BURN, MELEE, 1, get_dir(src, S)) ///Enjoy cannon rush
					last_process = world.time 
	if(!target)
		get_target()

/obj/item/hog_item/prismatic_lance/proc/get_target()
	var/list/possible_targets = list()
	var/datum/antagonist/hog/cultie
	for(var/mob/living/L in viewers(sight_range, src)) 
		var/obj/item/storage/book/bible/B = L.bible_check()
		if(B)
			if(!(B.resistance_flags & ON_FIRE))
				to_chat(L, span_warning("Your [B.name] bursts into flames!"))
			for(var/obj/item/storage/book/bible/BI in L.GetAllContents())
				if(!(BI.resistance_flags & ON_FIRE))
					BI.fire_act()
			continue
		if((HAS_TRAIT(L, TRAIT_BLIND)) || L.anti_magic_check(TRUE, TRUE))
			continue
		cultie = IS_HOG_CULTIST(L)
		if(cultie && cultie.cult == src.cult)
			continue		
		if(L.stat || L.IsStun() || L.IsParalyzed())
			continue
		if(isslime(L))
			continue
		if(iscarbon(L))
			var/mob/living/carbon/c = L
			if(c.handcuffed)
				continue
		if(ishostile(L))
			var/mob/living/simple_animal/hostile/H = L
			if(!H.mind && ("neutral" in H.faction))              
				continue
			if(ismegafauna(H) || (H.status_flags & GODMODE) || (!H.mind && H.AIStatus == AI_OFF))
				continue
		else if(isrevenant(L))
			var/mob/living/simple_animal/revenant/R = L
			if(R.stasis) //Don't target any revenants that are respawning
				continue
		else if(!L.mind)
			continue
		possible_targets += L
	var/list/viewcache = list()
	for(var/N in GLOB.mechas_list)
		var/obj/mecha/M = N
		if(M.occupant)
			cultie = IS_HOG_CULTIST(M.occupant)
		if(get_dist(M, src) <= sight_range && M.occupant && !(cultie && cultie.cult == src.cult))
			if(!length(viewcache))
				for (var/obj/Z in view(sight_range, src))
					viewcache += Z
			if(M in viewcache)
				possible_targets += M
	for(var/N in GLOB.hog_structures)
		var/obj/structure/hog_structure/S = N
		if(get_dist(S, src) <= sight_range && S.cult != src.cult && S.cult)
			if(!length(viewcache))
				for(var/obj/Z in view(sight_range, src))
					viewcache += Z
			if(S in viewcache)
				possible_targets += S
	target = pick(possible_targets)
	
/obj/item/hog_item/prismatic_lance/
	name = "guardian lance"
	desc = "Prismatic lance structure uses this. Ideally you shouldn't see it. Isn't qdeleted when some shit happens."
