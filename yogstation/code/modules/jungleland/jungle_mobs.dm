/mob/living/simple_animal/hostile/asteroid/yog_jungle //yog_jungle and not just jungle because TG has some mobs under /jungle/ that i dont want to fuck with and override (they are unused, but like whats the point..)
	icon = 'yogstation/icons/mob/jungle.dmi'
	mob_biotypes = MOB_BEAST | MOB_ORGANIC
	vision_range = 4
 
/mob/living/simple_animal/hostile/asteroid/yog_jungle/attacked_by(obj/item/I, mob/living/user)
	if(stat == CONSCIOUS && AIStatus != AI_OFF && !client && user)
		ADD_TRAIT(user,TRAIT_ENEMY_OF_THE_FOREST,JUNGLELAND_TRAIT)	
	return ..()

/mob/living/simple_animal/hostile/asteroid/yog_jungle/dryad
	name = "Jungle spirit"
	desc = "A spirit of the jungle, protector of the forest, heals the ones in need, and butchers the ones that plauge the forest."
	icon_state = "dryad"
	icon_living = "dryad"
	icon_dead = "dryad_dead"
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
	maxHealth = 60
	health = 60
	speed = 2
	spacewalk = TRUE
	ranged = TRUE
	loot = list(/obj/item/organ/regenerative_core/dryad)
	ranged_cooldown_time = 4 SECONDS
	retreat_distance = 1
	minimum_distance = 3
	projectiletype = /obj/projectile/jungle/damage_orb
	alpha_type = /mob/living/simple_animal/hostile/asteroid/yog_jungle/alpha/alpha_dryad
	var/alt_projectiletype = /obj/projectile/jungle/heal_orb
	var/alt_cooldown_time = 10 SECONDS

/mob/living/simple_animal/hostile/asteroid/yog_jungle/dryad/Shoot(atom/targeted_atom)
	if(HAS_TRAIT(targeted_atom,TRAIT_ENEMY_OF_THE_FOREST)) 
		projectiletype = initial(projectiletype)
		ranged_cooldown_time = alt_cooldown_time
	else 
		projectiletype = alt_projectiletype
		ranged_cooldown_time = initial(ranged_cooldown_time)	
	return ..()
	
/mob/living/simple_animal/hostile/asteroid/yog_jungle/corrupted_dryad
	name = "Cursed jungle spirit"
	desc = "A spirit of the jungle, once a protector, but now corrupted by forced beyond this world. It's essence it's twisted and it will attack everyone in sight"
	icon_state = "corrupted_dryad"
	icon_living = "corrupted_dryad"
	icon_dead = "corrupted_dryad_dead"
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
	speed = 2
	spacewalk = TRUE
	ranged = TRUE
	loot = list (/obj/item/organ/regenerative_core/dryad/corrupted)
	ranged_cooldown_time = 2 SECONDS
	retreat_distance = 1
	minimum_distance = 3
	projectiletype = /obj/projectile/jungle/damage_orb
	alpha_type = /mob/living/simple_animal/hostile/asteroid/yog_jungle/alpha/alpha_dryad/corrupted

/mob/living/simple_animal/hostile/asteroid/yog_jungle/meduracha
	name ="Meduracha aquatica"
	desc = "A predator of the toxic swamps, it's long tendrils cause very fast toxic buildup that after a while will cause varying degrees of incapacitation"
	icon_state = "meduracha"
	icon_living = "meduracha"
	icon_dead = "meduracha_dead"
	speak = list("hgrah!","blrp!","poasp!","ahkr!")
	speak_emote = list("bubbles", "vibrates")
	emote_hear = list("gazes.","bellows.","splashes.")
	emote_taunt = list("reverbs", "shakes")
	speak_chance = 1
	taunt_chance = 1
	turns_per_move = 1
	butcher_results = list(/obj/item/stack/sheet/meduracha = 1, /obj/item/stack/sheet/sinew = 2)
	response_help  = "gently pokes"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"
	maxHealth = 100
	health = 100
	speed = 2
	spacewalk = TRUE

	melee_damage_lower = 7.5
	melee_damage_upper = 10

	rapid_melee = 3
	
	alpha_type = /mob/living/simple_animal/hostile/asteroid/yog_jungle/alpha/alpha_meduracha

	var/sulking = FALSE 

/mob/living/simple_animal/hostile/asteroid/yog_jungle/meduracha/Initialize()
	. = ..()
	RegisterSignal(src,COMSIG_MOVABLE_MOVED,PROC_REF(on_sulking))

/mob/living/simple_animal/hostile/asteroid/yog_jungle/meduracha/AttackingTarget()
	. = ..()
	update_sulking(FALSE)
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/humie = target
	var/chance = 100 - humie.getarmor(null,BIO)
	if(prob(max(10,chance * 0.66))) // higher chance than toxic water
		humie.reagents.add_reagent(/datum/reagent/toxic_metabolites,2.5)

/mob/living/simple_animal/hostile/asteroid/yog_jungle/meduracha/Goto(target, delay, minimum_distance)
	update_sulking(TRUE)
	return ..()
	

/mob/living/simple_animal/hostile/asteroid/yog_jungle/meduracha/LoseAggro()
	update_sulking(TRUE)
	return ..()

/mob/living/simple_animal/hostile/asteroid/yog_jungle/meduracha/proc/update_sulking(bool)
	sulking = bool
	on_sulking()

/mob/living/simple_animal/hostile/asteroid/yog_jungle/meduracha/proc/on_sulking()
	if(stat != CONSCIOUS)
		return
	if(istype(loc,/turf/open/water) && sulking)
		icon_state = "meduracha_sulking"
		move_to_delay = 1.5
		return
	move_to_delay = 3
	icon_state = "meduracha"

////////////////////////////////////////////////////////////////////////////////////
//--------------------------------Skin twister------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/**
 * Disguises as a killed player, calling for help over comms to trick people into getting killed too
 */
/mob/living/simple_animal/hostile/asteroid/yog_jungle/skin_twister
	name = "Skin twister"
	desc = "The apex predator of this planet, kills everything and then steals the victim's skin, allowing it to lure it's prey and kill them with ease"
	icon_state = "skin_twister"
	icon_living = "skin_twister"
	icon_dead = "skin_twister_dead"
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
	maxHealth = 285
	health = 285
	speed = 2
	spacewalk = TRUE
	melee_damage_lower = 30
	melee_damage_upper = 30
	rapid_melee = 2
	butcher_results = list(/obj/item/stack/sheet/skin_twister = 2,/obj/item/stack/sheet/bone = 3, /obj/item/stack/sheet/sinew = 2)
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG
	var/human_lure = FALSE
	var/obj/item/encryptionkey/lure_encryption_key
	var/victim_ref

/mob/living/simple_animal/hostile/asteroid/yog_jungle/skin_twister/AttackingTarget()
	. = ..()
	if(victim_ref)
		reveal_true_form()
	if(isliving(target))
		var/mob/living/living_target = target
		
		if(!QDELETED(living_target) && living_target.stat > UNCONSCIOUS) //Unconcious or dead
			steal_identity(living_target)

/mob/living/simple_animal/hostile/asteroid/yog_jungle/skin_twister/Life()
	. = ..()
	if(!.) //dead 
		return
	
	if(human_lure && prob(5))
		lure()

/mob/living/simple_animal/hostile/asteroid/yog_jungle/skin_twister/proc/steal_identity(mob/living/victim)

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
	faction |= "mining"

/mob/living/simple_animal/hostile/asteroid/yog_jungle/skin_twister/proc/reveal_true_form()
	new /obj/effect/better_animated_temp_visual/skin_twister_out(get_turf(src))
	name = initial(name)
	desc = initial(desc)
	appearance = initial(appearance)
	cut_overlays()

	victim_ref = null

	speak_chance = initial(speak_chance)
	taunt_chance = initial(taunt_chance)
	human_lure = FALSE
	faction -= "mining"

/mob/living/simple_animal/hostile/asteroid/yog_jungle/skin_twister/proc/pick_lure()
	var/mob/living/picked = pick(subtypesof(/mob/living/simple_animal/hostile/asteroid/yog_jungle))
	return pick(list("Help me!", "I'm stuck!", "Come quickly, I'm close to death!", "I'm dying!", "I won't make it unless someone comes here!", "Please don't leave me!", 
				"I'm so close to base!", "These fucking beasts got me", "I'm out of pens", "I'm running out of blood", "Please, I beg you", "I walked into the fucking water", 
				"[initial(picked.name)] nearly killed me, but I'm gonna bleed out", "Damned fauna", "Why fucking again?", "I have so many mats", 
				"This is fucking insane", "I cannot believe this is happening to me", "Out of meds, out of supplies, out of fucking everything", "I'm running out of air",
				"HELP", "MINING", "MINING BASE",
				"If someone finds my body take the loot [pick(GLOB.phonetic_alphabet)] [rand(0,9)][rand(0,9)][rand(0,9)]", "HELP [pick(generate_code_phrase(TRUE))]"))

/mob/living/simple_animal/hostile/asteroid/yog_jungle/skin_twister/proc/lure()
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

/mob/living/simple_animal/hostile/asteroid/yog_jungle/skin_twister/death(gibbed)
	move_force = MOVE_FORCE_DEFAULT
	move_resist = MOVE_RESIST_DEFAULT
	pull_force = PULL_FORCE_DEFAULT
	reveal_true_form()
	return ..(gibbed)
	
////////////////////////////////////////////////////////////////////////////////////
//-----------------------------------Blobby---------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/**
 * Splits upon death, summoning two smaller versions of itself
 */
/mob/living/simple_animal/hostile/asteroid/yog_jungle/blobby
	name = "Blobby"
	desc = "A gelatinous creature of the swampy regions of the jungle. It's a big blob of goo, and it's not very friendly."
	icon_state = "blobby"
	icon_living = "blobby"
	icon_dead = "blobby_dead"
	speak = list("brbl","bop","pop","blsp")
	speak_emote = list("bops", "pops")
	emote_hear = list("vibrates.","listens.","hears.")
	emote_taunt = list("pops agressively")
	move_to_delay = 6
	speak_chance = 1
	taunt_chance = 1
	turns_per_move = 1
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"
	maxHealth = 120
	health = 120
	speed = 1 // size (1-3) is added on top of this during initialize()
	spacewalk = TRUE
	loot  = list(/obj/item/stack/sheet/slime)
	melee_damage_lower = 5
	melee_damage_upper = 5
	
	alpha_type = /mob/living/simple_animal/hostile/asteroid/yog_jungle/alpha/alpha_blobby

	var/current_size = 3


/mob/living/simple_animal/hostile/asteroid/yog_jungle/blobby/Initialize(mapload,spawned_size = 3)
	. = ..()
	current_size = clamp(spawned_size, 1, current_size)
	speed += current_size
	melee_damage_lower = melee_damage_lower * current_size
	melee_damage_upper = melee_damage_upper * current_size
	var/matrix/M = new
	M.Scale(current_size/1.5)
	transform = M
	maxHealth = maxHealth * (current_size/3)
	health = health * (current_size/3)

/mob/living/simple_animal/hostile/asteroid/yog_jungle/blobby/death(gibbed)
	if(current_size > 1  && !gibbed)
		del_on_death = TRUE
		var/list/possible_spawns = list()
		for(var/turf/T in RANGE_TURFS(1,src))
			if(isclosedturf(T))
				continue 
			possible_spawns += T
		var/mob/living/simple_animal/hostile/A =  new /mob/living/simple_animal/hostile/asteroid/yog_jungle/blobby(pick(possible_spawns),current_size - 1)
		var/mob/living/simple_animal/hostile/B = new /mob/living/simple_animal/hostile/asteroid/yog_jungle/blobby(pick(possible_spawns),current_size - 1)
		if(target)
			A.FindTarget(list(target))
			B.FindTarget(list(target))
	return ..()

////////////////////////////////////////////////////////////////////////////////////
//------------------------------------Wasps---------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/**
 * jungle version of the wasp. Slightly weaker and faster, with different loot. Renamed to avoid confusion. Credit to original creator.
 */
/mob/living/simple_animal/hostile/asteroid/wasp/yellowjacket
	name = "yellow jacket"
	desc = "A large and aggressive creature with a massive stinger."
	move_to_delay = 6
	maxHealth = 160
	health = 160
	butcher_results = list(/obj/item/stinger = 1,/obj/item/stack/sheet/animalhide/weaver_chitin = 1, /obj/item/stack/sheet/sinew = 1, /obj/item/stack/sheet/bone = 1)
	alpha_type = /mob/living/simple_animal/hostile/asteroid/yog_jungle/alpha/alpha_yellowjacket

//the same thing, but with malaria instead of toxins
/mob/living/simple_animal/hostile/asteroid/wasp/mosquito
	name = "Giant Mosquito"
	desc = "Massively overgrown bug, how did it get so big?"
	icon = 'yogstation/icons/mob/jungle.dmi'
	icon_state = "mosquito"
	icon_living = "mosquito"
	icon_dead = "mosquito_dead"
	maxHealth = 60 //swat it once and it dies
	health = 60
	melee_damage_lower = 20 //hits harder
	melee_damage_upper = 20
	move_to_delay = 4 //moves faster
	turns_per_move = 0
	ranged_cooldown_time = 3 SECONDS //dashes faster

	butcher_results = list(/obj/item/stinger = 1,/obj/item/stack/sheet/animalhide/weaver_chitin = 1, /obj/item/stack/sheet/sinew = 2)
	speed = 2
	spacewalk = TRUE
	alpha_type = /mob/living/simple_animal/hostile/asteroid/yog_jungle/alpha/alpha_yellowjacket/mosquito
	poison_per_attack = 0
	dash_speed = 0.8
	attack_sound = null

/mob/living/simple_animal/hostile/asteroid/wasp/mosquito/AttackingTarget()
	..()
	if(!ishuman(target))
		return

	var/mob/living/carbon/human/humie = target
	humie.blood_volume -= 10 // ouch!
	var/malaria_chance = 125 - humie.getarmor(null,BIO)
	if(prob(malaria_chance * 0.25))
		var/datum/disease/malaria/infection = new() 
		humie.ForceContractDisease(infection,FALSE,TRUE)
	icon_state = "mosquito_blood"

////////////////////////////////////////////////////////////////////////////////////
//------------------------------------spider--------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/**
 * basically shoots bolas as the target
 */
/mob/living/simple_animal/hostile/asteroid/yog_jungle/emeraldspider
	name = "emerald spider"
	desc = "A big, angry, venomous spider. Flings webs at prey to slow them down, before closing in on them."
	icon_state = "emeraldspider"
	icon_living = "emeraldspider"
	icon_dead = "emeraldspider_dead"
	butcher_results = list(/obj/item/stack/sheet/bone = 4, /obj/item/stack/sheet/sinew = 2, /obj/item/stack/sheet/animalhide/weaver_chitin = 4, /obj/item/reagent_containers/food/snacks/meat/slab/spider = 2)
	attacktext = "bites"
	gold_core_spawnable = HOSTILE_SPAWN
	health = 240
	maxHealth = 240
	vision_range = 8
	move_to_delay = 12
	speed = 3
	ranged = 1
	melee_damage_lower = 10
	melee_damage_upper = 10
	stat_attack = 1
	robust_searching = 1
	see_in_dark = 7
	ventcrawler = 2
	ranged_cooldown_time = 80
	projectiletype = /obj/projectile/websling
	projectilesound = 'sound/weapons/pierce.ogg'
	pass_flags = PASSTABLE
	attack_sound = 'sound/weapons/bite.ogg'
	deathmessage = "rolls over, frothing at the mouth before stilling."
	var/poison_type = /datum/reagent/toxin
	var/poison_per_bite = 4

/obj/projectile/websling
	name = "web"
	icon = 'yogstation/icons/obj/jungle.dmi'
	nodamage = TRUE
	damage = 0
	speed = 3 //you can dodge it from far away
	icon_state = "websling"

/obj/projectile/websling/on_hit(atom/target, blocked = FALSE)
	if(iscarbon(target) && blocked < 100)
		var/obj/item/restraints/legcuffs/beartrap/emeraldspider/B = new /obj/item/restraints/legcuffs/beartrap/emeraldspider(get_turf(target))
		B.Crossed(target)
	..()

/obj/item/restraints/legcuffs/beartrap/emeraldspider
	name = "silk restraints"
	desc = "A silky bundle of web that can entangle legs."
	icon = 'yogstation/icons/obj/jungle.dmi'
	armed = TRUE
	breakouttime = 3 SECONDS //Long enough you'd rather not get hit, but not debilitating.
	item_flags = DROPDEL
	flags_1 = NONE
	trap_damage = 0
	icon_state = "websling"
	icon = 'yogstation/icons/mob/jungle.dmi'

/mob/living/simple_animal/hostile/asteroid/yog_jungle/emeraldspider/AttackingTarget()
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

/mob/living/simple_animal/hostile/asteroid/yog_jungle/emeraldspider/CanAttack(atom/A)
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
	weather_immunities = WEATHER_STORM
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	robust_searching = TRUE
	see_in_dark = 5
	vision_range = 6
	minbodytemp = 0
	maxbodytemp = INFINITY
	speed = 3
	pressure_resistance = 100
	mob_size = MOB_SIZE_LARGE
	del_on_death = TRUE
	faction = list("tar")

/mob/living/simple_animal/hostile/tar/amalgamation
	name = "Tar Amalgamation"
	desc = "Tar amalgamate, it has blades for hands and crystalline plates cover it's body"
	icon_state = "tar_faithless"
	health = 200
	maxHealth = 200
	melee_damage_lower = 30
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

/mob/living/simple_animal/hostile/tar/amalgamation/convert
	name = "Tar Convert"
	desc = "The remains of a shaft miner which has fallen to the tar."
	icon_state = "tar_convert"
	health = 150
	maxHealth = 150
	melee_damage_lower = 15
	melee_damage_upper = 20
	var/mob/living/converted

/mob/living/simple_animal/hostile/tar/amalgamation/convert/New(loc, mob/living/new_convert, ...)
	if(new_convert)
		converted = new_convert
		new_convert.forceMove(src)
	return ..()

/mob/living/simple_animal/hostile/tar/amalgamation/convert/Destroy()
	if(converted)
		converted.forceMove(loc)
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
	projectiletype = /obj/projectile/jungle/heal_orb

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

/mob/living/simple_animal/hostile/obsidian_demon 
	name = "True Abomination"
	desc = "Ancient evil unsealed from it's obsidian prison"
	icon = 'yogstation/icons/mob/jungle64x64.dmi'
	health = 500
	maxHealth = 500
	pixel_x = -16
	pixel_y = -16

/mob/living/simple_animal/hostile/obsidian_demon/Initialize()
	. = ..()
	icon_state = "demon-[rand(0,2)]" 

mob/living/simple_animal/hostile/asteroid/hivelord/tar
	name = "pillar of tar"
	desc = "A solid chunk of tar. You struggle to think that something like this could even be alive, but it seems to pulsate and even move at times..."
	icon = 'yogstation/icons/mob/jungle.dmi'
	stat_attack = DEAD
	weather_immunities = WEATHER_STORM
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	robust_searching = TRUE
	see_in_dark = 5
	vision_range = 6
	minbodytemp = 0
	maxbodytemp = INFINITY
	pressure_resistance = 100
	mob_size = MOB_SIZE_LARGE
	del_on_death = TRUE
	faction = list("tar")
	icon_state = "tar_pillar"
	icon_living = "tar_pillar"
	icon_aggro = "tar_pillar"
	icon_dead = "tar_pillar"
	mob_biotypes = MOB_INORGANIC
	move_to_delay = 20
	speed = 4
	maxHealth = 100
	health = 100
	attacktext = "flings tar at"
	throw_message = "falls into thick tar before falling through the"
	loot = list()
	brood_type = /mob/living/simple_animal/hostile/asteroid/hivelordbrood/tar

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/tar
	name = "tar aspect"
	desc = "A floating orb of tar animated through dark magic, ready to hunt down prey."
	icon = 'yogstation/icons/mob/jungle.dmi'
	icon_state = "tar_aspect"
	icon_living = "tar_aspect"
	icon_aggro = "tar_aspect"
	icon_dead = "tar_aspect"
	stat_attack = DEAD
	weather_immunities = WEATHER_STORM
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	robust_searching = TRUE
	see_in_dark = 5
	vision_range = 6
	minbodytemp = 0
	maxbodytemp = INFINITY
	pressure_resistance = 100
	mob_size = MOB_SIZE_LARGE
	del_on_death = TRUE
	faction = list("tar")
