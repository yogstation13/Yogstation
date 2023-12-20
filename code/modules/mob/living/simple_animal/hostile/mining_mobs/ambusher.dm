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

/mob/living/simple_animal/hostile/asteroid/ambusher/Move(atom/newloc)
	if(newloc && newloc.z == z && (islava(newloc) || ischasm(newloc)))
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/asteroid/wolf/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(health <= 100) //Reveal itself if damaged enough
		icon_state = "ambusher"
		icon_living = "ambusher"
		friendly = "gurgles at"
		speak_emote = list("gurgles")
		speed = 1
		melee_damage_lower = 10
		melee_damage_upper = 10
		dodge_prob = 70
		/obj/effect/gibspawner/generic

/mob/living/simple_animal/hostile/asteroid/ambusher/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	. = ..()
	if(target == null)
		adjustHealth(-maxHealth*0.025)
		retreat_message_said = FALSE
