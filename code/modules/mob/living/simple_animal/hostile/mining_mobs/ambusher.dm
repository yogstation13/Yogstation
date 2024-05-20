/mob/living/simple_animal/hostile/asteroid/ambusher
	name = "white wolf"
	desc = "A beast that survives by feasting on weaker opponents, they're much stronger with numbers."
	icon = 'icons/mob/icemoon/icemoon_monsters.dmi'
	icon_state = "whitewolf"
	icon_living = "whitewolf"
	icon_dead = "ambusher_dead"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	mouse_opacity = MOUSE_OPACITY_ICON
	friendly = "howls at"
	speak_emote = list("howls")
	speed = -1
	move_to_delay = 5
	maxHealth = 225
	health = 225
	obj_damage = 15
	melee_damage_lower = 7.5
	melee_damage_upper = 7.5
	attack_vis_effect = ATTACK_EFFECT_BITE
	rapid_melee = 2 // every second attack
	dodging = TRUE
	dodge_prob = 50
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'
	vision_range = 7
	aggro_vision_range = 7
	move_force = MOVE_FORCE_WEAK
	move_resist = MOVE_FORCE_WEAK
	pull_force = MOVE_FORCE_WEAK
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 2, /obj/item/stack/sheet/sinew/wolf = 2, /obj/item/stack/sheet/bone = 2, /obj/item/reagent_containers/food/snacks/ambusher_tounge = 1)
	loot = list()
	stat_attack = UNCONSCIOUS
	robust_searching = TRUE
	var/revealed = FALSE
	var/poison_type = /datum/reagent/toxin/ambusher_toxin
	var/poison_per_bite = 0

/mob/living/simple_animal/hostile/asteroid/ambusher/Move(atom/newloc)
	if(newloc && newloc.z == z && (islava(newloc) || ischasm(newloc)))
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/asteroid/ambusher/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	if(!revealed) //Make sure it doesn't twitch if already revealed
		if(prob(10)) //Randomly twitch to differentiate it from normal wolves
			icon_state = "ambusher_twitch"
			src.visible_message(span_warning("The white wolf twitches"))
			playsound(get_turf(src), 'sound/effects/wounds/crack1.ogg', 30, TRUE, -1)
		else
			icon_state = "whitewolf"

/mob/living/simple_animal/hostile/asteroid/ambusher/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(health <= 175 && !revealed) //Reveal itself if damaged enough and if it hasn't already done so
		name = "white wolf?"
		desc = "Something isn't quite right with this wolf..."
		icon_state = "ambusher"
		icon_living = "ambusher"
		color = "#ac0000" //Grrr angery
		friendly = "gurgles at"
		speak_emote = list("gurgles")
		speed = 2.5
		move_to_delay = 2 //Faster to help it land a hit and inject toxin
		melee_damage_lower = 2 //Less damage so player doesn't just immediatly eat rocks during rage
		melee_damage_upper = 2
		rapid_melee = 4 //More chances to attack and inject toxins
		poison_per_bite = 4
		dodging = FALSE
		attacktext = "lashes"
		new /obj/effect/gibspawner/generic(get_turf(src))
		playsound(get_turf(src), 'sound/effects/reee.ogg', 150, TRUE, -1) //Froeg
		src.visible_message(span_warning("The white wolf's head rips itself apart, forming a ghastly maw!"))
		addtimer(CALLBACK(src, PROC_REF(endRage)), 6 SECONDS) //Rage timer
		revealed = TRUE

/mob/living/simple_animal/hostile/asteroid/ambusher/AttackingTarget()
	..()
	if(isliving(target))
		var/mob/living/L = target
		if(target.reagents)
			L.reagents.add_reagent(poison_type, poison_per_bite)

/mob/living/simple_animal/hostile/asteroid/ambusher/proc/endRage()
	color = null //Remove the color
	move_to_delay = 4 //Slow down, toxin will let it keep up with player and if player did not get poisoned then ambusher skill issue
	melee_damage_lower = 12 //More damage to make up for less speed
	melee_damage_upper = 12
	rapid_melee = 1
	attacktext = "lacerates"
	attack_sound = 'sound/effects/wounds/blood3.ogg'
	src.visible_message(span_warning("The white wolf slows down as it focuses on you!"))

/mob/living/simple_animal/hostile/asteroid/ambusher/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	. = ..()
	if(target == null)
		adjustHealth(-maxHealth*0.025)

/obj/item/reagent_containers/food/snacks/ambusher_tounge
	name = "tounge?"
	desc = "An organ that appears to be an intestine with serated bone fragments jutting out of it. Something seems to be secreating from it."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "ambusher_tounge"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/toxin/ambusher_toxin = 15)
	filling_color = "#b971c8"
	tastes = list("meat" = 1)
	foodtype = MEAT | RAW
