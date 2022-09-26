/*

KING OF GOATS

found in kinggoatarea.dmm

It has no ranged attacks but has the ability to summon guards, charge at its enemy and do an AOE explosion attack.
If defeated at stage three he will fall over dead on the ground and drop a ladder so you may now leave the arena. Will also drop loot.

The three stages of the king goat:
 Stage 1: Pretty much just a slightly more robust regular goat, the king will charge at you full force in the hopes of taking you out easily. Can easily be defeated.
 Stage 2: The king goat will become slightly larger and start doing special attacks, which range from summoning guards to stomping his hooves on the ground (causing the arena to shake and an AOE explosion to appear around him).
 Stage 3: The king goat will completely heal, grow slightly bigger and start glowing. It has the exact same attacks as stage 2 but is more aggressive overall.

The loot:
The king goat pelt: Gained by butchering the King Goat's corpse. When worn on your head grants complete bomb immunity. Has slightly better gun and laser protection than the drake helm at the cost of slightly reduced melee protection. Makes goats friendly towards you as long as you are wearing it.

Difficulty: Insanely Hard

*/

//Visager's tracks 'Battle!' and 'Miniboss Fight' from the album 'Songs from an Unmade World 2' are available here
//http://freemusicarchive.org/music/Visager/Songs_From_An_Unmade_World_2/ and are made available under the CC BY 4.0 Attribution license,
//which is available for viewing here: https://creativecommons.org/licenses/by/4.0/legalcode


//the king and his court
/mob/living/simple_animal/hostile/retaliate/goat/king
	name = "king of the goats"
	desc = "The oldest and wisest of the goats. King of his race, peerless in dignity and power. His golden fleece radiates nobility."
	icon = 'yogstation/icons/mob/king_of_goats.dmi'
	icon_state = "king_goat"
	icon_living = "king_goat"
	icon_dead = "king_goat_dead"
	faction = list("goat_king")
	attack_same = FALSE
	speak_emote = list("brays in a booming voice")
	emote_hear = list("brays in a booming voice")
	emote_see = list("stamps a mighty foot, shaking the surroundings")
	response_help  = "placates"
	response_harm   = "assaults"
	attacktext = "brutalized"
	health = 500
	a_intent = INTENT_HARM
	sentience_type = SENTIENCE_BOSS
	stat_attack = DEAD
	wander = FALSE
	maxHealth = 500
	armour_penetration = 35
	melee_damage_lower = 35
	melee_damage_upper = 55
	minbodytemp = 0
	maxbodytemp = INFINITY
	obj_damage = 400
	vision_range = 5
	aggro_vision_range = 18
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_LARGE
	robust_searching = TRUE
	//can_escape = 1
	move_to_delay = 3
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	//break_stuff_probability = 35



	var/stun_chance = 5 //chance per attack to Weaken target

/mob/living/simple_animal/hostile/retaliate/goat/king/ex_act(severity, target)
	switch (severity)
		if (1)
			adjustBruteLoss(100)

		if (2)
			adjustBruteLoss(50)

		if(3)
			adjustBruteLoss(25)

/mob/living/simple_animal/hostile/retaliate/goat/king/phase2
	name = "emperor of the goats"
	desc = "The King of Kings, God amongst men, and your superior in every way."
	icon_state = "king_goat2"
	icon_living = "king_goat2"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 36, /obj/item/clothing/head/yogs/goatpelt/king = 1)
	health = 750
	maxHealth = 750
	armour_penetration = 50
	melee_damage_lower = 40
	melee_damage_upper = 60
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	pixel_y = 5//default_pixel_y = 5
	//break_stuff_probability = 40
	music_component = /datum/component/music_player/battle
	music_path = /datum/music/sourced/battle/king_goat

	var/spellscast = 0
	var/phase3 = FALSE
	var/sound_id = "goat"
	var/special_attacks = 0
	stun_chance = 7

/mob/living/simple_animal/hostile/retaliate/goat/king/phase2/Initialize()
	. = ..()
	update_icon()

/mob/living/simple_animal/hostile/retaliate/goat/king/Found(atom/A)
	if(isliving(A))
		return A
	return ..()

/mob/living/simple_animal/hostile/retaliate/goat/guard/Found(atom/A)
	if(isliving(A))
		return A
	return ..()

/mob/living/simple_animal/hostile/retaliate/goat/guard
	name = "honour guard"
	desc = "A very handsome and noble beast."
	icon = 'yogstation/icons/mob/king_of_goats.dmi'
	icon_state = "goat_guard"
	icon_living = "goat_guard"
	icon_dead = "goat_guard_dead"
	faction = list("goat_king")
	attack_same = FALSE
	sentience_type = SENTIENCE_BOSS
	stat_attack = DEAD
	wander = FALSE
	robust_searching = TRUE
	health = 125
	maxHealth = 125
	minbodytemp = 0
	maxbodytemp = INFINITY
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	armour_penetration = 10
	melee_damage_lower = 10
	melee_damage_upper = 15

/mob/living/simple_animal/hostile/retaliate/goat/guard/master
	name = "master of the guard"
	desc = "A very handsome and noble beast - the most trusted of all the king's men."
	icon_state = "goat_guard_m"
	icon_living = "goat_guard_m"
	icon_dead = "goat_guard_m_dead"
	health = 200
	maxHealth = 200
	armour_penetration = 15
	melee_damage_lower = 15
	melee_damage_upper = 20
	move_to_delay = 3

/mob/living/simple_animal/hostile/retaliate/goat/guard/pope
	name = "Goat Pope"
	desc = "For what is a God without a pope to spread their holy words"
	icon_state = "goat_pope"
	icon_living = "goat_pope"
	icon_dead = "goat_pope_dead"
	health = 1
	maxHealth = 1
	armour_penetration = 25
	melee_damage_lower = 25
	melee_damage_upper = 30
	move_to_delay = 3
	loot = list(/obj/item/clothing/head/yogs/goatpope)

/mob/living/simple_animal/hostile/retaliate/goat/guard/harem
	name = "goat with a wig"
	desc = "A very... handsome beast?"
	icon_state = "goat_harem"
	icon_living = "goat_harem"
	icon_dead = "goat_harem_dead"
	faction = list("goat_king")
	attack_same = FALSE
	minimum_distance = 5
	retreat_distance = 7

/mob/living/simple_animal/hostile/retaliate/goat/king/Retaliate()
	..()
	if(stat == CONSCIOUS && prob(5))
		visible_message(span_warning("\The [src] bellows indignantly, with a judgemental gleam in his eye."))

/mob/living/simple_animal/hostile/retaliate/goat/king/phase2/Retaliate()
	set waitfor = FALSE
	..()
	if(spellscast < 5)
		if(prob(5) && move_to_delay >= 3) //speed buff
			spellscast++
			visible_message(span_cult("\The [src] shimmers and seems to phase in and out of reality itself!"))
			move_to_delay = 1

		else if(prob(5) && melee_damage_lower != 50) //damage buff
			spellscast++
			visible_message(span_cult("\The [src]' horns grow larger and more menacing!"))
			melee_damage_lower = 50

		else if(prob(5)) //spawn adds
			spellscast++
			visible_message(span_cult("\The [src] summons the imperial guard to his aid, and they appear in a flash!"))
			var/mob/living/simple_animal/hostile/retaliate/goat/guard/master/M = new(get_step(src,pick(GLOB.cardinals)))
			M.enemies |= enemies
			var/mob/living/simple_animal/hostile/retaliate/goat/guard/G = new(get_step(src,pick(GLOB.cardinals)))
			G.enemies |= enemies
			G = new(get_step(src,pick(GLOB.cardinals)))
			G.enemies |= enemies

		else if(prob(5)) //EMP blast
			spellscast++
			visible_message(span_cult("\The [src] disrupts nearby electrical equipment!"))
			empulse(get_turf(src), 5, 2, 0)

		else if(prob(5) && melee_damage_type == BRUTE && !special_attacks) //elemental attacks
			spellscast++
			//if(prob(50))
			visible_message(span_cult("\The [src]' horns flicker with holy white flames!"))
			melee_damage_type = BURN
			//else
			//	visible_message(span_cult("\The [src]' horns glimmer, electricity arcing between them!"))
			//	melee_damage_type = BURN // meh too lazy

		else if(prob(5)) //earthquake spell
			visible_message("<B>[span_danger("\The [src]' eyes begin to glow ominously as dust and debris in the area is kicked up in a light breeze!!")]</B>")
			stop_automated_movement = TRUE
			if(do_after(src, 6 SECONDS, src))
				var/health_holder = getBruteLoss()
				visible_message("<B>[span_cult("\The [src] raises its fore-hooves and stomps them into the ground with incredible force!!")]</B>")
				explosion(get_step(src,pick(GLOB.cardinals)), -1, 2, 2, 3, 6)
				explosion(get_step(src,pick(GLOB.cardinals)), -1, 1, 4, 4, 6)
				explosion(get_step(src,pick(GLOB.cardinals)), -1, 3, 4, 3, 6)
				stop_automated_movement = FALSE
				spellscast += 2
				if(!getBruteLoss() > health_holder)
					adjustBruteLoss(health_holder - getBruteLoss()) //our own magicks cannot harm us
			else
				visible_message(span_notice("\The [src] loses concentration and huffs haughtily."))
				stop_automated_movement = FALSE

		else return

/mob/living/simple_animal/hostile/retaliate/goat/king/phase2/proc/phase3_transition()
	phase3 = TRUE
	spellscast = 0
	maxHealth = 750
	revive(TRUE)
	var/datum/component/music_player/player = GetComponent(/datum/component/music_player)
	// Do a sudden transition of music
	player.stop_all(0)
	player.remove_all()
	player.music_path = /datum/music/sourced/battle/king_goat_2
	player.do_range_check(0)
	stun_chance = 10
	update_icon()
	visible_message(span_cult("\The [src]' wounds close with a flash, and when he emerges, he's even larger than before!"))


/mob/living/simple_animal/hostile/retaliate/goat/king/phase2/proc/update_icon()
	var/matrix/M = new
	if(phase3)
		icon_state = "king_goat3"
		icon_living = "king_goat3"
		M.Scale(1.5)
	else
		M.Scale(1.25)
	transform = M
	pixel_y = 10

/mob/living/simple_animal/hostile/retaliate/goat/king/phase2/Life()
	. = ..()
	if(move_to_delay < 3)
		move_to_delay += 0.1
	if((health <= 150 && !phase3 && spellscast == 5) || (stat == DEAD && !phase3)) //begin phase 3, reset spell limit and heal
		phase3_transition()
	if(!.)
		return FALSE
	if(special_attacks >= 6 && melee_damage_type != BRUTE)
		visible_message(span_cult("The energy surrounding \the [src]'s horns dissipates."))
		melee_damage_type = BRUTE

/mob/living/simple_animal/hostile/retaliate/goat/king/proc/OnDeath()
	visible_message(span_cult("\The [src] lets loose a terrific wail as its wounds close shut with a flash of light, and its eyes glow even brighter than before!"))
	var/mob/living/simple_animal/hostile/retaliate/goat/king/phase2/nextgoat = new(src.loc)
	nextgoat.enemies |= enemies
	qdel(src);

/mob/living/simple_animal/hostile/retaliate/goat/king/phase2/OnDeath()
	if(phase3)
		visible_message(span_cult("\The [src] shrieks as the seal on his power breaks and he starts to break apart!"))
		new /obj/structure/ladder/unbreakable/goat(loc)
		new /obj/item/toy/plush/goatplushie/angry/kinggoat(loc) //If someone dies from this after beating the king goat im going to laugh
		new /obj/item/t_scanner/adv_mining_scanner/goat_scanner(loc)
		new /obj/item/gem/dark(loc)
		
/mob/living/simple_animal/hostile/retaliate/goat/king/death()
	..()
	OnDeath()

/mob/living/simple_animal/hostile/retaliate/goat/king/AttackingTarget()
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		if(L.stat == DEAD)
			L.gib()
		if(prob(stun_chance))
			L.Paralyze(5)
			L.confused += 1
			visible_message(span_warning("\The [L] is bowled over by the impact of [src]'s attack!"))

/mob/living/simple_animal/hostile/retaliate/goat/king/phase2/AttackingTarget()
	. = ..()
	if(isliving(target))
		if(melee_damage_type != BRUTE)
			special_attacks++
