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
	maxHealth = 200
	health = 200
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
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 2, /obj/item/stack/sheet/sinew/wolf = 2, /obj/item/stack/sheet/bone = 2)
	loot = list()
	stat_attack = UNCONSCIOUS
	robust_searching = TRUE
	var/transformed = FALSE

/mob/living/simple_animal/hostile/asteroid/ambusher/Move(atom/newloc)
	if(newloc && newloc.z == z && (islava(newloc) || ischasm(newloc)))
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/asteroid/ambusher/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(health <= 100 && !transformed) //Reveal itself if damaged enough and if it hasn't already done so
		name = "white wolf?"
		desc = "Something isn't quite right with this wolf..."
		icon_state = "ambusher"
		icon_living = "ambusher"
		friendly = "gurgles at"
		speak_emote = list("gurgles")
		speed = 1.5
		melee_damage_lower = 15
		melee_damage_upper = 15
		dodging = FALSE
		attacktext = "lacerates"
		attack_sound = 'sound/effects/wounds/blood3.ogg'
		new /obj/effect/gibspawner/generic(get_turf(src))
		playsound(get_turf(src), 'sound/effects/reee.ogg', 60, TRUE, -1) //Play a spooky sound
		src.visible_message(span_warning("The white wolf's head rips itself apart, forming a ghastly maw!"))
		transformed = TRUE

/mob/living/simple_animal/hostile/asteroid/ambusher/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	. = ..()
	if(target == null)
		adjustHealth(-maxHealth*0.025)
