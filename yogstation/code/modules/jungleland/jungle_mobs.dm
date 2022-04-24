/mob/living/simple_animal/hostile/yog_jungle //yog_jungle and not just jungle because TG has some mobs under /jungle/ that i dont want to fuck with and override (they are unused, but like whats the point..)
	icon = 'yogstation/icons/mob/jungle.dmi'

/mob/living/simple_animal/hostile/yog_jungle/attacked_by(obj/item/I, mob/living/user)
	if(stat == CONSCIOUS && AIStatus != AI_OFF && !client && user)
		ADD_TRAIT(user,TRAIT_ENEMY_OF_THE_FOREST,JUNGLELAND_TRAIT)	
	return ..()

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
	see_in_dark = 3
	butcher_results = list()
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"
	maxHealth = 60
	health = 60
	spacewalk = TRUE
	ranged = TRUE

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
	see_in_dark = 3
	butcher_results = list()
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"
	maxHealth = 120
	health = 120
	spacewalk = TRUE
	ranged = TRUE

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
	see_in_dark = 3
	butcher_results = list()
	response_help  = "gently pokes"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"
	maxHealth = 120
	health = 120
	spacewalk = TRUE

	melee_damage_lower = 20
	melee_damage_upper = 30

	rapid_melee = 3

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
	speak_chance = 1
	taunt_chance = 1
	turns_per_move = 1
	see_in_dark = 5
	butcher_results = list()
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"
	maxHealth = 320
	health = 320
	spacewalk = TRUE
	
	var/human_lure = FALSE
	var/list/lure_encryption_keys = list()
	var/mob/living/current_victim

/mob/living/simple_animal/hostile/yog_jungle/skin_twister/proc/steal_identity(mob/living/victim)
	name = victim.name
	desc = victim.desc
	appearance = victim.appearance

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
		lure_encryption_keys += headphones.keyslot?.channels	
		lure_encryption_keys += headphones.keyslot2?.channels

/mob/living/simple_animal/hostile/yog_jungle/skin_twister/proc/reveal_true_form()
	name = initial(name)
	desc = initial(desc)
	appearance = initial(appearance)
	cut_overlays()

	speak_chance = initial(speak_chance)
	taunt_chance = initial(taunt_chance)
	human_lure = FALSE

/mob/living/simple_animal/hostile/yog_jungle/skin_twister/proc/pick_lure()
	return pick(list("Help me!", "I'm stuck!", "Come quickly, I'm close to death!", "I'm dying!", "I won't make it unless someone comes here!", "Please don't leave me!", 
				"I'm so close to base!", "These fucking beasts got me", "I'm out of pens", "I'm running out of blood", "Please, I beg you", "I walked into the fucking water", 
				"[initial(pick(subtypesof(/mob/living/simple_animal/hostile/yog_jungle)).name)] nearly killed me, but I'm gonna bleed out", "Damned fauna", "Why fucking again?", "I have so many mats", 
				"This is fucking insane", "I cannot believe this is happening to me", "Out of meds, out of supplies, out of fucking everything", "I'm running out of air", 
				"If someone finds my body take the loot, []", "HELP [pick(generate_code_phrase(TRUE))]"))

/mob/living/simple_animal/hostile/yog_jungle/skin_twister/proc/lure()
	if(!human_lure)
		return
	var/obj/item/radio/radio = new /obj/item/radio(src)
	radio.channels = lure_encryption_keys
	radio.name = name
	radio.talk_into(src,pick_lure(),pick(lure_encryption_keys))
	qdel(radio)

