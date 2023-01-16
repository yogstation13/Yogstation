/mob/living/simple_animal/hostile/yog_jungle //yog_jungle and not just jungle because TG has some mobs under /jungle/ that i dont want to fuck with and override (they are unused, but like whats the point..)
	icon = 'yogstation/icons/mob/jungle.dmi'
	stat_attack = UNCONSCIOUS
	weather_immunities = WEATHER_ACID
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	robust_searching = TRUE
	faction = list("mining", "skintwister_cloak")
	see_in_dark = 3
	vision_range = 4
	minbodytemp = 0
	maxbodytemp = INFINITY
	pressure_resistance = 100
	mob_size = MOB_SIZE_LARGE
	var/alpha_damage_boost = 1 //if a mob has really high damage it may be unfair to boost it further when making an alpha version.
	var/crusher_loot
	var/alpha_type = 0

/mob/living/simple_animal/hostile/yog_jungle/attacked_by(obj/item/I, mob/living/user)
	if(stat == CONSCIOUS && AIStatus != AI_OFF && !client && user)
		ADD_TRAIT(user,TRAIT_ENEMY_OF_THE_FOREST,JUNGLELAND_TRAIT)	
	return ..()

/mob/living/simple_animal/hostile/yog_jungle/death(gibbed)
	var/datum/status_effect/crusher_damage/C = has_status_effect(STATUS_EFFECT_CRUSHERDAMAGETRACKING)
	if(C && crusher_loot && C.total_damage >= maxHealth * 0.6 && crusher_loot)
		loot += crusher_loot
	. = ..()
/mob/living/simple_animal/hostile/yog_jungle/dryad
	name = "Jungle spirit"
	desc = "A spirit of the jungle, protector of the forest, heals the ones in need, and butchers the ones that plauge the forest."
	icon_state = "dryad"
	icon_living = "dryad"
	icon_dead = "dryad_dead"
	mob_biotypes = list(MOB_BEAST,MOB_ORGANIC)
	speak = list("eak!","sheik!","ahik!","keish!")
	speak_emote = list("shimmers", "vibrates")
	emote_hear = list("vibes.","sings.","shimmers.")
	emote_taunt = list("tremors", "shakes")
	speak_chance = 1
	taunt_chance = 1
	turns_per_move = 1
	butcher_results = list()
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"
	maxHealth = 60
	health = 60
	spacewalk = TRUE
	ranged = TRUE
	loot = list(/obj/item/organ/regenerative_core/dryad)
	ranged_cooldown_time = 4 SECONDS
	retreat_distance = 1
	minimum_distance = 3
	projectiletype = /obj/item/projectile/jungle/damage_orb
	var/alt_projectiletype = /obj/item/projectile/jungle/heal_orb
	var/alt_cooldown_time = 10 SECONDS

/mob/living/simple_animal/hostile/yog_jungle/dryad/Shoot(atom/targeted_atom)
	if(HAS_TRAIT(targeted_atom,TRAIT_ENEMY_OF_THE_FOREST)) 
		projectiletype = initial(projectiletype)
		ranged_cooldown_time = alt_cooldown_time
	else 
		projectiletype = alt_projectiletype
		ranged_cooldown_time = initial(ranged_cooldown_time)	
	return ..()
	
/mob/living/simple_animal/hostile/yog_jungle/corrupted_dryad
	name = "Cursed jungle spirit"
	desc = "A spirit of the jungle, once a protector, but now corrupted by forced beyond this world. It's essence it's twisted and it will attack everyone in sight"
	icon_state = "corrupted_dryad"
	icon_living = "corrupted_dryad"
	icon_dead = "corrupted_dryad_dead"
	mob_biotypes = list(MOB_BEAST,MOB_ORGANIC)
	speak = list("eak!","sheik!","ahik!","keish!")
	speak_emote = list("shimmers", "vibrates")
	emote_hear = list("vibes.","sings.","shimmers.")
	emote_taunt = list("tremors", "shakes")
	speak_chance = 1
	taunt_chance = 1
	turns_per_move = 1
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"
	maxHealth = 120
	health = 120
	spacewalk = TRUE
	ranged = TRUE
	loot = list (/obj/item/organ/regenerative_core/dryad/corrupted)
	ranged_cooldown_time = 2 SECONDS
	retreat_distance = 1
	minimum_distance = 3
	projectiletype = /obj/item/projectile/jungle/damage_orb

/mob/living/simple_animal/hostile/yog_jungle/meduracha
	name ="Meduracha aquatica"
	desc = "A predator of the toxic swamps, it's long tendrils cause very fast toxic buildup that after a while will cause varying degrees of incapacitation"
	icon_state = "meduracha"
	icon_living = "meduracha"
	icon_dead = "meduracha_dead"
	mob_biotypes = list(MOB_BEAST,MOB_ORGANIC)
	speak = list("hgrah!","blrp!","poasp!","ahkr!")
	speak_emote = list("bubbles", "vibrates")
	emote_hear = list("gazes.","bellows.","splashes.")
	emote_taunt = list("reverbs", "shakes")
	speak_chance = 1
	taunt_chance = 1
	turns_per_move = 1
	butcher_results = list(/obj/item/stack/sheet/meduracha = 1)
	response_help  = "gently pokes"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"
	maxHealth = 100
	health = 100
	spacewalk = TRUE

	melee_damage_lower = 10
	melee_damage_upper = 15

	rapid_melee = 3
	
	alpha_type = /mob/living/simple_animal/hostile/yog_jungle/alpha_meduracha

	var/sulking = FALSE 

/mob/living/simple_animal/hostile/yog_jungle/meduracha/Initialize()
	. = ..()
	RegisterSignal(src,COMSIG_MOVABLE_MOVED,.proc/on_sulking)

/mob/living/simple_animal/hostile/yog_jungle/meduracha/AttackingTarget()
	. = ..()
	update_sulking(FALSE)
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/humie = target
	var/chance = ((humie.wear_suit ? 100 - humie.wear_suit.armor.bio : 100)  +  (humie.head ? 100 - humie.head.armor.bio : 100) )/2
	if(prob(max(10,chance * 0.66))) // higher chance than toxic water
		humie.apply_status_effect(/datum/status_effect/toxic_buildup)

/mob/living/simple_animal/hostile/yog_jungle/meduracha/Goto(target, delay, minimum_distance)
	update_sulking(TRUE)
	return ..()
	

/mob/living/simple_animal/hostile/yog_jungle/meduracha/LoseAggro()
	update_sulking(TRUE)
	return ..()

/mob/living/simple_animal/hostile/yog_jungle/meduracha/proc/update_sulking(bool)
	sulking = bool
	on_sulking()

/mob/living/simple_animal/hostile/yog_jungle/meduracha/proc/on_sulking()
	if(stat != CONSCIOUS)
		return
	if(istype(loc,/turf/open/water) && sulking)
		icon_state = "meduracha_sulking"
		move_to_delay = 1
		return
	move_to_delay = 3
	icon_state = "meduracha"

/mob/living/simple_animal/hostile/yog_jungle/skin_twister
	name = "Skin twister"
	desc = "The apex predator of this planet, kills everything and then steals the victim's skin, allowing it to lure it's prey and kill them with ease"
	icon_state = "skin_twister"
	icon_living = "skin_twister"
	icon_dead = "skin_twister_dead"
	mob_biotypes = list(MOB_BEAST,MOB_ORGANIC)
	speak = list("AGRH!","SAGH!","REAAH!","REEIK!")
	speak_emote = list("roars", "howls")
	emote_hear = list("stalks.","listens.","hears.")
	emote_taunt = list("defies", "roars")
	faction = list("skin_walkers") //hostile even to the jungle itself
	speak_chance = 1
	taunt_chance = 1
	turns_per_move = 1
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"
	maxHealth = 320
	health = 320
	spacewalk = TRUE
	melee_damage_lower = 30
	melee_damage_upper = 55 // ouch
	rapid_melee = 2
	butcher_results = list(/obj/item/stack/sheet/skin_twister = 2)
	alpha_damage_boost = 0 // 30-55 damage is too much to be boosts by 50%
	var/human_lure = FALSE
	var/obj/item/encryptionkey/lure_encryption_key
	var/victim_ref

/mob/living/simple_animal/hostile/yog_jungle/skin_twister/AttackingTarget()
	. = ..()
	if(victim_ref)
		reveal_true_form()
	if(isliving(target))
		var/mob/living/living_target = target
		
		if(!QDELETED(living_target) && living_target.stat > UNCONSCIOUS) //Unconcious or dead
			steal_identity(living_target)

/mob/living/simple_animal/hostile/yog_jungle/skin_twister/Life()
	. = ..()
	if(!.) //dead 
		return 
	
	if(human_lure && prob(5))
		lure()

/mob/living/simple_animal/hostile/yog_jungle/skin_twister/proc/steal_identity(mob/living/victim)

	new /obj/effect/better_animated_temp_visual/skin_twister_in(get_turf(src))
	name = victim.name
	desc = victim.desc
	if(!ishostile(victim))
		appearance = victim.appearance
	else 
		appearance = initial(victim.appearance)
	transform = initial(victim.transform)

	victim_ref = WEAKREF(victim)

	if(length(victim.vis_contents))
		add_overlay(victim.vis_contents)

	if(ishuman(victim))
		human_lure = TRUE
		speak_chance = 0
		taunt_chance = 0
		var/mob/living/carbon/human/humie = victim
		var/obj/item/radio/headset/headphones = locate() in humie.get_all_gear() 
		if(!headphones)
			return
		lure_encryption_key = headphones.keyslot
	else 
		fully_heal()
	faction = list("mining")

/mob/living/simple_animal/hostile/yog_jungle/skin_twister/proc/reveal_true_form()
	new /obj/effect/better_animated_temp_visual/skin_twister_out(get_turf(src))
	name = initial(name)
	desc = initial(desc)
	appearance = initial(appearance)
	cut_overlays()

	QDEL_NULL(victim_ref)

	speak_chance = initial(speak_chance)
	taunt_chance = initial(taunt_chance)
	human_lure = FALSE
	faction = list("skin_walkers")

/mob/living/simple_animal/hostile/yog_jungle/skin_twister/proc/pick_lure()
	var/mob/living/picked = pick(subtypesof(/mob/living/simple_animal/hostile/yog_jungle))
	return pick(list("Help me!", "I'm stuck!", "Come quickly, I'm close to death!", "I'm dying!", "I won't make it unless someone comes here!", "Please don't leave me!", 
				"I'm so close to base!", "These fucking beasts got me", "I'm out of pens", "I'm running out of blood", "Please, I beg you", "I walked into the fucking water", 
				"[initial(picked.name)] nearly killed me, but I'm gonna bleed out", "Damned fauna", "Why fucking again?", "I have so many mats", 
				"This is fucking insane", "I cannot believe this is happening to me", "Out of meds, out of supplies, out of fucking everything", "I'm running out of air",
				"HELP", "MINING", "MINING BASE",
				"If someone finds my body take the loot [pick("mango", "alpha", "delta", "beta", "omega" , "olive", "tango", "fiesta", "carp")] [rand(0,9)][rand(0,9)][rand(0,9)]", "HELP [pick(generate_code_phrase(TRUE))]"))

/mob/living/simple_animal/hostile/yog_jungle/skin_twister/proc/lure()
	if(!human_lure)
		return
	
	var/lure = pick_lure()

	if(lure_encryption_key)
		var/obj/item/radio/radio = new /obj/item/radio(src)
		radio.keyslot = lure_encryption_key
		radio.name = name
		radio.talk_into(src,lure,pick(lure_encryption_key.channels))
		qdel(radio)

	say(lure)

/mob/living/simple_animal/hostile/yog_jungle/blobby
	name = "Blobby"
	desc = "A gelatinous creature of the swampy regions of the jungle. It's a big blob of goo, and it's not very friendly."
	icon_state = "blobby"
	icon_living = "blobby"
	icon_dead = "blobby_dead"
	mob_biotypes = list(MOB_BEAST,MOB_ORGANIC)
	speak = list("brbl","bop","pop","blsp")
	speak_emote = list("bops", "pops")
	emote_hear = list("vibrates.","listens.","hears.")
	emote_taunt = list("pops agressively")
	speak_chance = 1
	taunt_chance = 1
	turns_per_move = 1
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"
	maxHealth = 100
	health = 100
	spacewalk = TRUE
	loot  = list(/obj/item/stack/sheet/slime)
	melee_damage_lower = 4
	melee_damage_upper = 6
	
	alpha_type = /mob/living/simple_animal/hostile/yog_jungle/alpha_blobby

	var/current_size = 4


/mob/living/simple_animal/hostile/yog_jungle/blobby/Initialize(mapload,spawned_size = 4)
	. = ..()
	current_size = spawned_size > 0 ? spawned_size : current_size
	melee_damage_lower = melee_damage_lower * current_size
	melee_damage_upper = melee_damage_upper * current_size
	var/matrix/M = new
	M.Scale(current_size/2)
	transform = M
	maxHealth = maxHealth * (current_size/4)
	health = health * (current_size/4)

/mob/living/simple_animal/hostile/yog_jungle/blobby/death(gibbed)
	if(current_size > 1  && !gibbed)
		del_on_death = TRUE
		var/list/possible_spawns = list()
		for(var/turf/T in RANGE_TURFS(1,src))
			if(isclosedturf(T))
				continue 
			possible_spawns += T
		var/mob/living/simple_animal/hostile/A =  new /mob/living/simple_animal/hostile/yog_jungle/blobby(pick(possible_spawns),current_size - 1)
		var/mob/living/simple_animal/hostile/B = new /mob/living/simple_animal/hostile/yog_jungle/blobby(pick(possible_spawns),current_size - 1)
		if(target)
			A.FindTarget(list(target))
			B.FindTarget(list(target))
	return ..()

/mob/living/simple_animal/hostile/yog_jungle/mosquito
	name = "Giant Mosquito"
	desc = "Massively overgrown bug, how did it get so big?"
	icon_state = "mosquito"
	icon_living = "mosquito"
	icon_dead = "mosquito_dead"
	mob_biotypes = list(MOB_BEAST,MOB_ORGANIC)
	speak = list("bzzzzz")
	speak_emote = list("buzzes")
	emote_hear = list("buzzes")
	emote_taunt = list("buzzes")
	speak_chance = 0
	taunt_chance = 0
	turns_per_move = 0
	butcher_results = list(/obj/item/stinger = 1)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"
	maxHealth = 60
	health = 60
	spacewalk = TRUE
	melee_damage_lower = 10
	melee_damage_upper = 40 

	var/can_charge = TRUE
	var/cooldown = 15 SECONDS
	var/charge_ramp_up = 2 SECONDS
	var/charging = FALSE

	var/has_blood = FALSE
	var/overshoot_dist = 5

	var/awoke = TRUE

/mob/living/simple_animal/hostile/yog_jungle/mosquito/Initialize()
	. = ..()
	RegisterSignal(SSdcs,COMSIG_GLOB_JUNGLELAND_DAYNIGHT_NEXT_PHASE,.proc/react_to_daynight_change)

/mob/living/simple_animal/hostile/yog_jungle/mosquito/Aggro()
	. = ..()
	prepare_charge()

/mob/living/simple_animal/hostile/yog_jungle/mosquito/Goto(target, delay, minimum_distance)
	if (iscarbon(target) && get_dist(src,target) > 4 && get_charge())
		prepare_charge()
		return

	if(!charging)
		return ..()

/mob/living/simple_animal/hostile/yog_jungle/mosquito/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	charging = FALSE
	if(!ishuman(hit_atom))
		animate(src,color = initial(color),time = charge_ramp_up/2)
		return 
	
	var/mob/living/carbon/human/humie = hit_atom
	humie.blood_volume -= 100 // ouch!
	var/malaria_chance = ((humie.wear_suit ? 100 - humie.wear_suit.armor.bio : 100)  +  (humie.head ? 100 - humie.head.armor.bio : 100) )/2
	if(prob(malaria_chance * 0.25))
		var/datum/disease/malaria/infection = new() 
		humie.ForceContractDisease(infection,FALSE,TRUE)
	has_blood = TRUE 
	rapid_melee = TRUE
	melee_damage_lower = 30 
	melee_damage_upper = 50
	icon_state = "mosquito_blood"
	animate(src,color = initial(color),time = charge_ramp_up*2)

/mob/living/simple_animal/hostile/yog_jungle/mosquito/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if(!awoke && stat != DEAD)
		toggle_ai(AI_ON) 
		awoke = TRUE 
		icon_state = icon_living
		FindTarget(user)

/mob/living/simple_animal/hostile/yog_jungle/mosquito/proc/prepare_charge()
	if(!get_charge())
		return FALSE 

	var/dir = Get_Angle(src.loc,target.loc)
	
	//i actually fucking hate this utility function, for whatever reason Get_Angle returns the angle assuming that [0;-1] is 0 degrees rather than [1;0] like any sane being.
	var/tx = clamp(0,round(target.loc.x + sin(dir) * overshoot_dist),255)
	var/ty = clamp(0,round(target.loc.y + cos(dir) * overshoot_dist),255)

	var/turf/found_turf = locate(tx,ty,loc.z)

	if(found_turf == null)
		return FALSE 
	
	var/dist = get_dist(src,found_turf)

	charging = TRUE
	animate(src,color = rgb(163, 0, 0),time = charge_ramp_up)
	sleep(charge_ramp_up)
	if(stat == DEAD)
		animate(src,color = initial(color),time = charge_ramp_up)
		return

	throw_at(found_turf,dist + overshoot_dist,4,spin = FALSE)

/mob/living/simple_animal/hostile/yog_jungle/mosquito/proc/reset_charge()
	can_charge = TRUE

/mob/living/simple_animal/hostile/yog_jungle/mosquito/proc/use_charge()
	can_charge = FALSE 
	addtimer(CALLBACK(src,.proc/reset_charge),cooldown,TIMER_UNIQUE)

/mob/living/simple_animal/hostile/yog_jungle/mosquito/proc/get_charge()
	return can_charge 

/mob/living/simple_animal/hostile/yog_jungle/mosquito/proc/react_to_daynight_change(updates,luminosity)
	if(stat == DEAD)
		return 

	if(luminosity > 0.6 && awoke && !target)
		toggle_ai(AI_OFF)
		awoke = FALSE 
		icon_state = "mosquito_sleeping"
	
	if(luminosity <= 0.6 && !awoke)
		toggle_ai(AI_ON) 
		awoke = TRUE 
		icon_state = has_blood ? "mosquito_blood" : icon_living

//jungle version of the wasp. Slightly weaker and faster, with different loot. Renamed to avoid confusion. Credit to original creator.
/mob/living/simple_animal/hostile/yog_jungle/yellowjacket
	name = "yellow jacket"
	desc = "A large and aggressive creature with a massive stinger."
	icon = 'icons/mob/jungle/wasp.dmi'
	icon_state = "wasp"
	icon_living = "wasp"
	icon_dead = "wasp_dead"
	icon_gib = "syndicate_gib"
	move_to_delay = 6
	movement_type = FLYING
	ranged = 1
	ranged_cooldown_time = 120
	speak_emote = list("buzzes")
	vision_range = 5
	aggro_vision_range = 9
	see_in_dark = 7
	speed = 2
	maxHealth = 160
	health = 160
	environment_smash = ENVIRONMENT_SMASH_NONE //held off by walls and windows, stupid oversized bee
	melee_damage_lower = 10  //not that lethal, but it'll catch up to you easily
	melee_damage_upper = 10
	attacktext = "stings"
	attack_sound = 'sound/voice/moth/scream_moth.ogg'
	deathmessage = "rolls over, falling to the ground."
	gold_core_spawnable = HOSTILE_SPAWN
	butcher_results = list(/obj/item/stinger = 1)
	loot = list()
	var/charging = FALSE
	var/revving_charge = FALSE
	var/poison_type = /datum/reagent/toxin
	var/poison_per_attack = 5

/mob/living/simple_animal/hostile/yog_jungle/yellowjacket/AttackingTarget()
	..()
	if(isliving(target))
		var/mob/living/L = target
		if(target.reagents)
			L.reagents.add_reagent(poison_type, poison_per_attack)

/mob/living/simple_animal/hostile/yog_jungle/yellowjacket/OpenFire()
	if(charging)
		return
	var/tturf = get_turf(target)
	if(!isturf(tturf))
		return
	if(get_dist(src, target) <= 7)
		charge()
		ranged_cooldown = world.time + ranged_cooldown_time

/mob/living/simple_animal/hostile/yog_jungle/yellowjacket/Aggro()
	vision_range = aggro_vision_range

/mob/living/simple_animal/hostile/yog_jungle/yellowjacket/proc/charge(var/atom/chargeat = target, var/delay = 5)
	if(!chargeat)
		return
	var/chargeturf = get_turf(chargeat)
	if(!chargeturf)
		return
	var/dir = get_dir(src, chargeturf)
	var/turf/T = get_ranged_target_turf(chargeturf, dir, 2)
	if(!T)
		return
	charging = TRUE
	revving_charge = TRUE
	do_alert_animation(src)
	walk(src, 0)
	setDir(dir)
	SLEEP_CHECK_DEATH(delay)
	revving_charge = FALSE
	var/movespeed = 1
	walk_towards(src, T, movespeed)
	SLEEP_CHECK_DEATH(get_dist(src, T) * movespeed)
	walk(src, 0) // cancel the movement
	charging = FALSE

/mob/living/simple_animal/hostile/yog_jungle/yellowjacket/Move()
	if(revving_charge)
		return FALSE
	if(charging)
		DestroySurroundings() //"Fred, were you feeding steroids to the wasp again?"
	..()

/mob/living/simple_animal/hostile/yog_jungle/emeraldspider
	name = "emerald spider"
	desc = "A big, angry, venomous spider. Flings webs at prey to slow them down, before closing in on them."
	icon_state = "emeraldspider"
	icon_living = "emeraldspider"
	icon_dead = "emeraldspider_dead"
	butcher_results = list(/obj/item/stack/sheet/bone = 3, /obj/item/stack/sheet/sinew = 2, /obj/item/stack/sheet/animalhide/weaver_chitin = 4, /obj/item/reagent_containers/food/snacks/meat/slab/spider = 2)
	loot = list()
	attacktext = "bites"
	gold_core_spawnable = HOSTILE_SPAWN
	health = 240
	maxHealth = 240
	vision_range = 8
	move_to_delay = 12
	speed = 3
	ranged = 1
	melee_damage_lower = 13
	melee_damage_upper = 16
	stat_attack = 1
	robust_searching = 1
	see_in_dark = 7
	ventcrawler = 2
	ranged_cooldown_time = 80
	projectiletype = /obj/item/projectile/websling
	projectilesound = 'sound/weapons/pierce.ogg'
	pass_flags = PASSTABLE
	attack_sound = 'sound/weapons/bite.ogg'
	deathmessage = "rolls over, frothing at the mouth before stilling."
	var/poison_type = /datum/reagent/toxin
	var/poison_per_bite = 4

/obj/item/projectile/websling
	name = "web"
	icon = 'yogstation/icons/obj/jungle.dmi'
	nodamage = TRUE
	damage = 0
	speed = 3 //you can dodge it from far away
	icon_state = "websling"

/obj/item/projectile/websling/on_hit(atom/target, blocked = FALSE)
	if(iscarbon(target) && blocked < 100)
		var/obj/item/restraints/legcuffs/beartrap/emeraldspider/B = new /obj/item/restraints/legcuffs/beartrap/emeraldspider(get_turf(target))
		B.Crossed(target)
	..()

/obj/item/restraints/legcuffs/beartrap/emeraldspider
	name = "silk restraints"
	desc = "A silky bundle of web that can entangle legs."
	icon = 'yogstation/icons/obj/jungle.dmi'
	armed = TRUE
	breakouttime = 30 //3 seconds. Long enough you'd rather not get hit, but not debilitating.
	item_flags = DROPDEL
	flags_1 = NONE
	trap_damage = 0
	icon_state = "websling"
	icon = 'yogstation/icons/mob/jungle.dmi'

/mob/living/simple_animal/hostile/yog_jungle/emeraldspider/AttackingTarget()
	..()
	if(isliving(target))
		var/mob/living/L = target
		if(target.reagents)
			L.reagents.add_reagent(poison_type, poison_per_bite)
		if((L.stat == DEAD) && (health < maxHealth) && ishuman(L))
			var/mob/living/carbon/human/H = L
			var/foundorgans = 0
			for(var/obj/item/organ/O in H.internal_organs)
				if(O.zone == "chest")
					foundorgans++
					qdel(O)
			if(foundorgans)
				src.visible_message(
					span_danger("[src] drools some toxic goo into [L]'s innards..."),
					span_danger("Before sucking out the slurry of bone marrow and flesh, healing itself!"),
					"<span class-'userdanger>You liquefy [L]'s innards with your venom and suck out the resulting slurry, revitalizing yourself.</span>")
				adjustBruteLoss(round(-H.maxHealth/2))
				for(var/obj/item/bodypart/B in H.bodyparts)
					if(B.body_zone == "chest")
						B.dismember()
			else
				to_chat(src, span_warning("There are no organs left in this corpse."))

/mob/living/simple_animal/hostile/yog_jungle/emeraldspider/CanAttack(atom/A)
	if(..())
		return TRUE
	if((health < maxHealth) && ishuman(A) && !faction_check_mob(A))
		var/mob/living/carbon/human/H = A
		for(var/obj/item/organ/O in H.internal_organs)
			if(O.zone == "chest")
				return TRUE
	return FALSE

/mob/living/simple_animal/hostile/tar 
	icon = 'yogstation/icons/mob/jungle.dmi'
	stat_attack = DEAD
	weather_immunities = WEATHER_ACID
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	robust_searching = TRUE
	see_in_dark = 5
	vision_range = 6
	minbodytemp = 0
	maxbodytemp = INFINITY
	pressure_resistance = 100
	faction = list("tar")

/mob/living/simple_animal/hostile/tar/amalgamation
	name = "Tar Amalgamation"
	desc = "Tar amalgamate, it has blades for hands and crystalline plates cover it's body"
	icon_state = "tar_faithless"
	health = 200
	maxHealth = 200
	melee_damage_lower = 25
	melee_damage_upper = 30

/mob/living/simple_animal/hostile/tar/amalgamation/AttackingTarget()
	if(isliving(target))
		var/mob/living/L = target 
		if(L.has_status_effect(/datum/status_effect/tar_curse))
			melee_damage_lower = initial(melee_damage_lower) * 1.5 
			melee_damage_upper = initial(melee_damage_upper) * 1.5
		else 
			melee_damage_lower = initial(melee_damage_lower)
			melee_damage_upper = initial(melee_damage_upper)
	return ..()

/mob/living/simple_animal/hostile/tar/dryad
	name = "Tar Dryad"
	desc = "Once a creature of the forest. It now belongs to the dominion of tar."
	icon_state = "tar_dryad"
	health = 100
	maxHealth = 100
	inverse_faction_check = TRUE
	ranged = TRUE
	ranged_cooldown_time = 5 SECONDS
	projectiletype = /obj/item/projectile/jungle/heal_orb

/mob/living/simple_animal/hostile/tar/dryad/PickTarget(list/Targets)
	if(!Targets.len)//We didnt find nothin!
		return

	var/lowest_hp = INFINITY
	for(var/pos_targ in Targets)
		if(isliving(pos_targ))
			var/mob/living/L = pos_targ 
			if( L.health > lowest_hp)
				continue
			. = L
	
	if(!.)
		return pick(Targets)

/mob/living/simple_animal/hostile/tar/shade
	name = "Tar Priest"
	desc = "A lingering spirit of a priest, he serves his lord in death as he did in life."
	icon_state = "tar_shade"
	health = 150
	maxHealth = 150
	minimum_distance = 5
	retreat_distance = 2
	ranged = TRUE 
	ranged_cooldown_time = 5 SECONDS

/mob/living/simple_animal/hostile/tar/shade/Shoot(atom/targeted_atom)
	if(!isliving(targeted_atom))
		return
	animate(src,0.5 SECONDS,color = "#280025")
	sleep(0.5 SECONDS)
	animate(src,0.5 SECONDS,color = initial(color))
	var/turf/loc = get_turf(targeted_atom)
	var/attack = pick(subtypesof(/obj/effect/timed_attack/tar_priest))
	new attack(loc)

/mob/living/simple_animal/hostile/carp/jungle
	faction = list("mining")

/mob/living/simple_animal/hostile/carp/ranged/chaos/jungle
	faction = list("mining")

	