//Visager's tracks 'Battle!' and 'Miniboss Fight' from the album 'Songs from an Unmade World 2' are available here
//http://freemusicarchive.org/music/Visager/Songs_From_An_Unmade_World_2/ and are made available under the CC BY 4.0 Attribution license,
//which is available for viewing here: https://creativecommons.org/licenses/by/4.0/legalcode


//the king and his court
/mob/living/simple_animal/hostile/retaliate/goat/king
	name = "king of goats"
	desc = "The oldest and wisest of goats; king of his race, peerless in dignity and power. His golden fleece radiates nobility."
	icon = 'yogstation/icons/mob/king_of_goats.dmi'
	icon_state = "king_goat"
	icon_living = "king_goat"
	icon_dead = "king_goat_dead"
	faction = list("goat_king")
	attack_same = FALSE
	speak_emote = list("brays in a booming voice")
	emote_hear = list("brays in a booming voice")
	emote_see = list("stamps a mighty foot, shaking the surroundings")
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 12)
	response_help  = "placates"
	response_harm   = "assaults"
	attacktext = "brutalized"
	health = 500
	a_intent = INTENT_HARM
	sentience_type = SENTIENCE_BOSS
	maxHealth = 500
	melee_damage_lower = 35
	melee_damage_upper = 55
	minbodytemp = 0
	maxbodytemp = INFINITY
	vision_range = 5
	aggro_vision_range = 18
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_LARGE
	//can_escape = 1
	move_to_delay = 3
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	//break_stuff_probability = 35



	var/stun_chance = 5 //chance per attack to Weaken target

/mob/living/simple_animal/hostile/retaliate/goat/king/phase2
	name = "emperor of goats"
	desc = "The King of Kings, God amongst men, and your superior in every way."
	icon_state = "king_goat2"
	icon_living = "king_goat2"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 36)
	health = 750
	maxHealth = 750
	melee_damage_lower = 40
	melee_damage_upper = 60
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	pixel_y = 5//default_pixel_y = 5
	//break_stuff_probability = 40

	var/spellscast = 0
	var/phase3 = FALSE
	var/sound_id = "goat"
	var/special_attacks = 0
	var/list/rangers = list()
	var/current_song = 'yogstation/sound/ambience/Visager-Battle.ogg'
	var/current_song_length = 1200
	stun_chance = 7

/mob/living/simple_animal/hostile/retaliate/goat/king/phase2/Initialize()
	. = ..()
	update_icon()

/mob/living/simple_animal/hostile/retaliate/goat/king/Found(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		if(L.stat != DEAD)
			return L
		else
			enemies -= L
			return
	return ..()

/mob/living/simple_animal/hostile/retaliate/goat/guard/Found(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		if(L.stat != DEAD)
			return L
		else
			enemies -= L
			return
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
	health = 125
	maxHealth = 125
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
	melee_damage_lower = 15
	melee_damage_upper = 20
	move_to_delay = 3

/mob/living/simple_animal/hostile/retaliate/goat/king/Retaliate()
	..()
	if(stat == CONSCIOUS && prob(5))
		visible_message("<span class='warning'>\The [src] bellows indignantly, with a judgemental gleam in his eye.</span>")

/mob/living/simple_animal/hostile/retaliate/goat/king/phase2/Retaliate()
	set waitfor = FALSE
	..()
	if(spellscast < 5)
		if(prob(5) && move_to_delay != 1) //speed buff
			spellscast++
			visible_message("<span class='cult'>\The [src] shimmers and seems to phase in and out of reality itself!</span>")
			move_to_delay = 1

		else if(prob(5) && melee_damage_lower != 50) //damage buff
			spellscast++
			visible_message("<span class='cult'>\The [src]' horns grow larger and more menacing!</span>")
			melee_damage_lower = 50

		else if(prob(5)) //stun move
			spellscast++
			visible_message("<span class='cult'>\The [src]' fleece flashes with blinding light!</span>")
			var/obj/item/grenade/flashbang/F = new(src.loc)
			F.prime()

		else if(prob(5)) //spawn adds
			spellscast++
			visible_message("<span class='cult'>\The [src] summons the imperial guard to his aid, and they appear in a flash!</span>")
			var/mob/living/simple_animal/hostile/retaliate/goat/guard/master/M = new(get_step(src,pick(GLOB.cardinals)))
			M.enemies |= enemies
			var/mob/living/simple_animal/hostile/retaliate/goat/guard/G = new(get_step(src,pick(GLOB.cardinals)))
			G.enemies |= enemies
			G = new(get_step(src,pick(GLOB.cardinals)))
			G.enemies |= enemies

		else if(prob(5)) //EMP blast
			spellscast++
			visible_message("<span class='cult'>\The [src] disrupts nearby electrical equipment!</span>")
			empulse(get_turf(src), 5, 2, 0)

		else if(prob(5) && melee_damage_type == BRUTE && !special_attacks) //elemental attacks
			spellscast++
			//if(prob(50))
			visible_message("<span class='cult'>\The [src]' horns flicker with holy white flame!</span>")
			melee_damage_type = BURN
			//else
			//	visible_message("<span class='cult'>\The [src]' horns glimmer, electricity arcing between them!</span>")
			//	melee_damage_type = BURN // meh too lazy

		else if(prob(5)) //earthquake spell
			visible_message("<span class='danger'>\The [src]' eyes begin to glow ominously as dust and debris in the area is kicked up in a light breeze.</span>")
			stop_automated_movement = TRUE
			if(do_after(src, 6 SECONDS, src))
				var/health_holder = health
				visible_message("<span class='cult'>\The [src] raises its fore-hooves and stomps them into the ground with incredible force!</span>")
				explosion(get_step(src,pick(GLOB.cardinals)), -1, 2, 2, 3, 6)
				explosion(get_step(src,pick(GLOB.cardinals)), -1, 1, 4, 4, 6)
				explosion(get_step(src,pick(GLOB.cardinals)), -1, 3, 4, 3, 6)
				stop_automated_movement = FALSE
				spellscast += 2
				if(!health < health_holder)
					health = health_holder //our own magicks cannot harm us
			else
				visible_message("<span class='notice'>\The [src] loses concentration and huffs haughtily.</span>")
				stop_automated_movement = FALSE

		else return

/mob/living/simple_animal/hostile/retaliate/goat/king/phase2/proc/phase3_transition()
	phase3 = TRUE
	spellscast = 0
	health = 750
	revive()
	current_song = 'yogstation/sound/ambience/Visager-Miniboss_Fight.ogg'
	current_song_length = 1759
	var/sound/song_played = sound(current_song)
	for(var/mob/M in rangers)
		if(!M.client || !(M.client.prefs.toggles & SOUND_INSTRUMENTS))
			continue
		M.stop_sound_channel(CHANNEL_JUKEBOX)
		rangers[M] = world.time + current_song_length
		M.playsound_local(null, null, 30, channel = CHANNEL_JUKEBOX, S = song_played)
	stun_chance = 10
	update_icon()
	visible_message("<span class='cult'>\The [src]' wounds close with a flash, and when he emerges, he's even larger than before!</span>")
	var/obj/item/grenade/flashbang/F = new(src.loc)
	F.prime()


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
	if(stat != DEAD)
		var/sound/song_played = sound(current_song)

		for(var/mob/M in range(10, src))
			if(!M.client || !(M.client.prefs.toggles & SOUND_INSTRUMENTS))
				continue
			if(!(M in rangers) || world.time > rangers[M])
				M.stop_sound_channel(CHANNEL_JUKEBOX)
				rangers[M] = world.time + current_song_length
				M.playsound_local(null, null, 30, channel = CHANNEL_JUKEBOX, S = song_played)
		for(var/mob/L in rangers)
			if(get_dist(src, L) > 10)
				rangers -= L
				if(!L || !L.client)
					continue
				L.stop_sound_channel(CHANNEL_JUKEBOX)
	else
		for(var/mob/L in rangers)
			rangers -= L
			if(!L || !L.client)
				continue
			L.stop_sound_channel(CHANNEL_JUKEBOX)
	if((health <= 150 && !phase3 && spellscast == 5) || (stat == DEAD && !phase3)) //begin phase 3, reset spell limit and heal
		phase3_transition()

	if(!.)
		return FALSE
	if(special_attacks >= 6 && melee_damage_type != BRUTE)
		visible_message("<span class='cult'>The energy surrounding \the [src]'s horns dissipates.</span>")
		melee_damage_type = BRUTE

/mob/living/simple_animal/hostile/retaliate/goat/king/proc/OnDeath()
	visible_message("<span class='cult'>\The [src] lets loose a terrific wail as its wounds close shut with a flash of light, and its eyes glow even brighter than before!</span>")
	var/mob/living/simple_animal/hostile/retaliate/goat/king/phase2/nextgoat = new(src.loc)
	nextgoat.enemies |= enemies
	qdel(src);

/mob/living/simple_animal/hostile/retaliate/goat/king/phase2/OnDeath()
	for(var/mob/L in rangers)
		rangers -= L
		if(!L || !L.client)
			continue
		L.stop_sound_channel(CHANNEL_JUKEBOX)
	if(phase3)
		visible_message("<span class='cult'>\The [src] shrieks as the seal on his power breaks and his wool sheds off!</span>")
		//new /obj/item/towel/fleece(src.loc)

/mob/living/simple_animal/hostile/retaliate/goat/king/death()
	..()
	OnDeath()

/mob/living/simple_animal/hostile/retaliate/goat/king/phase2/Destroy()
	for(var/mob/L in rangers)
		rangers -= L
		if(!L || !L.client)
			continue
		L.stop_sound_channel(CHANNEL_JUKEBOX)
	. = ..()

/mob/living/simple_animal/hostile/retaliate/goat/king/AttackingTarget(atom/A)
	. = ..()
	if(isliving(A))
		var/mob/living/L = A
		if(prob(stun_chance))
			L.Paralyze(5)
			L.confused += 1
			visible_message("<span class='warning'>\The [L] is bowled over by the impact of [src]'s attack!</span>")

/mob/living/simple_animal/hostile/retaliate/goat/king/phase2/AttackingTarget(atom/A)
	. = ..()
	if(isliving(A))
		var/mob/living/L = A
		if(L.stat == DEAD)
			L.gib()
		if(melee_damage_type != BRUTE)
			special_attacks++