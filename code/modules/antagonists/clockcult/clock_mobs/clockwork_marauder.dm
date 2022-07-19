#define MARAUDER_SLOWDOWN_PERCENTAGE 0.40 //Below this percentage of health, marauders will become slower
#define MARAUDER_WELDER_PENALTY 10 SECONDS //How long it takes to return welder healing speed to normall

//Clockwork marauder: A well-rounded frontline construct. Only one can exist for every two human servants.
/mob/living/simple_animal/hostile/clockwork/marauder
	name = "clockwork marauder"
	desc = "The stalwart apparition of a soldier, blazing with crimson flames. It's armed with a gladius and shield."
	icon_state = "clockwork_marauder"
	mob_biotypes = list(MOB_INORGANIC, MOB_HUMANOID)
	health = 150
	maxHealth = 150
	force_threshold = 8
	speed = 0
	obj_damage = 40
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	weather_immunities = list("lava")
	movement_type = FLYING
	a_intent = INTENT_HARM
	loot = list(/obj/item/clockwork/component/geis_capacitor/fallen_armor)
	light_range = 2
	light_power = 1.1
	playstyle_string = "<span class='big bold'><span class='neovgre'>You are a clockwork marauder,</span></span><b> a well-rounded frontline construct of Ratvar. Although you have no \
	unique abilities, you're a fearsome fighter in one-on-one combat, and your shield protects from projectiles!<br><br>Obey the Servants and do as they \
	tell you. Your primary goal is to defend the Ark from destruction; they are your allies in this, and should be protected from harm.</b>"
	empower_string = span_neovgre("The Anima Bulwark's power flows through you! Your weapon will strike harder, your armor is sturdier, and your shield is more durable.")
	var/max_shield_health = 4
	var/shield_health = 4 //Amount of projectiles that can be deflected within
	COOLDOWN_DECLARE(last_time_deflected)
	var/is_welded = FALSE

/mob/living/simple_animal/hostile/clockwork/marauder/examine_info()
	if(!shield_health)
		return span_warning("Its shield has been destroyed!")

/mob/living/simple_animal/hostile/clockwork/marauder/Life()
	..()
	if(!GLOB.ratvar_awakens && health / maxHealth <= MARAUDER_SLOWDOWN_PERCENTAGE)
		speed = initial(speed) + 1 //Yes, this slows them down
	else
		speed = initial(speed)

/mob/living/simple_animal/hostile/clockwork/marauder/update_values()
	if(GLOB.ratvar_awakens) //Massive attack damage bonuses and health increase, because Ratvar
		health = 300
		maxHealth = 300
		melee_damage_upper = 25
		melee_damage_lower = 25
		attacktext = "devastates"
		speed = -1
		obj_damage = 100
		max_shield_health = INFINITY
	else if(GLOB.ratvar_approaches) //Hefty health bonus and slight attack damage increase
		melee_damage_upper = 18
		melee_damage_lower = 18
		attacktext = "carves"
		obj_damage = 50
		max_shield_health = 5

/mob/living/simple_animal/hostile/clockwork/marauder/death(gibbed)
	visible_message(span_danger("[src]'s equipment clatters lifelessly to the ground as the red flames within dissipate."), \
	span_userdanger("Dented and scratched, your armor falls away, and your fragile form breaks apart without its protection."))
	. = ..()

/mob/living/simple_animal/hostile/clockwork/marauder/Process_Spacemove(movement_dir = 0)
	return TRUE

/mob/living/simple_animal/hostile/clockwork/marauder/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(amount > 0)
		for(var/mob/living/L in view(2, src))
			if(L.is_holding_item_of_type(/obj/item/nullrod))
				to_chat(src, span_userdanger("The presence of a brandished holy artifact weakens your armor!"))
				amount *= 4 //if a wielded null rod is nearby, it takes four times the health damage
				break
	. = ..()

/mob/living/simple_animal/hostile/clockwork/marauder/bullet_act(obj/item/projectile/P)
	if(deflect_projectile(P))
		return BULLET_ACT_BLOCK
	return ..()

/mob/living/simple_animal/hostile/clockwork/marauder/proc/deflect_projectile(obj/item/projectile/P)
	if(!shield_health)
		return
	var/energy_projectile = istype(P, /obj/item/projectile/energy) || istype(P, /obj/item/projectile/beam)
	visible_message(span_danger("[src] deflects [P] with [p_their()] shield!"), \
	span_danger("You block [P] with your shield! <i>Blocks left:</i> <b>[shield_health - 1]</b>"))
	last_time_deflected = world.time
	if(energy_projectile)
		playsound(src, 'sound/weapons/effects/searwall.ogg', 50, TRUE)
	else
		playsound(src, "ricochet", 50, TRUE)
	shield_health--
	if(!shield_health)
		visible_message(span_warning("[src]'s shield breaks from deflecting the attack!"), span_boldwarning("Your shield breaks! One of your fellow servants can repair it with a welder..."))
		playsound(src, "shatter", 100, TRUE)
	return TRUE

/mob/living/simple_animal/hostile/clockwork/marauder/welder_act(mob/living/user, obj/item/I)
	if(!is_servant_of_ratvar(user))
		return
	if(shield_health >= max_shield_health)
		to_chat(user, span_warning("[src]'s shield is already in good condition!"))
		return
	if(is_welded)
		to_chat(user, span_warning("[src]'s shield is already getting fixed by someone else!"))
		return
	weld(user)

/mob/living/simple_animal/hostile/clockwork/marauder/proc/weld(mob/living/user)
	if(shield_health >= max_shield_health)
		to_chat(user, span_notice("You finish repairing [src]'s shield."))
		to_chat(src, span_notice("[user] finishes reapiring your shield."))
		is_welded = FALSE
		return
	is_welded = TRUE
	var/welding_time = 2 SECONDS
	if(GLOB.ratvar_awakens)
		welding_time = 1 SECONDS  //??? Ratvar powered welder
	else if(last_time_deflected + MARAUDER_WELDER_PENALTY > world.time)   //More if attacked recently
		welding_time = 4 SECONDS
	if(!do_mob(user, src, welding_time))
		is_welded = FALSE
		return
	if(shield_health >= max_shield_health)  //Just check if everything is OK
		is_welded = FALSE
		return
	to_chat(user, span_notice("You fix some dents on [src]'s shield."))
	shield_health++
	weld(user)

#undef MARAUDER_SLOWDOWN_PERCENTAGE
#undef MARAUDER_WELDER_PENALTY
