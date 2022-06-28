/mob/living/simple_animal/hostile/free_god
	name = "<span class='cult'>GOD</span>"
	desc = "A powerfull bluespace entity, that managed to break into your plane. Uh-oh. It is time to run away."
	health = 5000
	maxHealth = 5000
	attacktext = "rips apart"
	attack_sound = 'yogstation/sound/creatures/progenitor_attack.ogg'
	friendly = "stares down"
	speak_emote = list("declares")
	armour_penetration = 75
	melee_damage_lower = 45
	melee_damage_upper = 45
	speed = 1
	sentience_type = SENTIENCE_BOSS
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	obj_damage = 100
	light_range = 15
	weather_immunities = list("lava", "ash")
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_LARGE
	layer = LARGE_MOB_LAYER
	movement_type = FLYING
	var/datum/team/hog_cult/cult

/mob/living/simple_animal/hostile/free_god/examine(mob/user)
	var/datum/antagonist/hog/cultie = IS_HOG_CULTIST(user)
	if(cultie && cultie.cult == src.cult)
		desc = "Your god and saviour!"
	else if (cultie)
		desc = "A heretical demon that defiles this world just with its presence. Strike it down!"
	else
		desc = initial(desc)
	. = ..()
	desc = initial(desc)

/mob/living/simple_animal/hostile/free_god/AttackingTarget()
	melee_damage_lower = initial(melee_damage_lower)
	melee_damage_upper = initial(melee_damage_upper)    
	attacktext = initial(attacktext)
	var/mob/living/L = target
	var/strike_down = FALSE
	if(L)
		if(istype(L, /mob/living/simple_animal/hostile/free_god))
			if(L == src)
				return ..()
			melee_damage_lower = 400
			melee_damage_upper = 400  
			attacktext = "tears into"              
		else
			var/datum/antagonist/hog/cultie = IS_HOG_CULTIST(target)
			if(cultie && cultie.cult == src.cult)
				if(prob(30))
					to_chat(src,span_warning("Probably, attacking your fellow servants isn't the best idea.")) 
				melee_damage_lower = 10
				melee_damage_upper = 15     
				attacktext = "punishes"
			else if(!cultie)
				strike_down = TRUE
				if(prob(50))
					attacktext = "strikes down"
	. = ..()
	if(strike_down && L)
		L.Knockdown(2 SECONDS)

/mob/living/simple_animal/hostile/free_god/say(message, bubble_type,var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	message = span_cultlarge(message)
	. = ..()

/mob/living/simple_animal/hostile/free_god/ex_act(severity)
	return FALSE

/mob/living/simple_animal/hostile/free_god/singularity_act()
	///user.say("ahahahaha fuck ya singulo")
	return FALSE

/mob/living/simple_animal/hostile/free_god/Process_Spacemove()
	return TRUE

/obj/effect/proc_holder/spell/pointed/kinetic_crush
	name = "Kinetic Crush"
	desc = "Attack the target with your psionic power, tearing it into pieces if it isn't protected."
	school = "conjuration"
	charge_type = "recharge"
	charge_max	= 20 SECONDS
	clothes_req = FALSE
	invocation = span_cultlarge("D I E!")
	invocation_type = "shout"
	range = 7
	cooldown_min = 20 SECONDS
	///ranged_mousepointer = 'icons/effects/mouse_pointers/mecha_mouse.dmi'
	action_icon_state = "kinetic_crush"
	active_msg = "You prepare to crush someone..."
	deactive_msg = "You relax..."

/obj/effect/proc_holder/spell/pointed/kinetic_crush/can_target(atom/target, mob/user, silent)
	. = ..()
	if(!.)
		return FALSE
	var/datum/antagonist/hog/cultie2 = IS_HOG_CULTIST(user)
	if(!cultie2)
		to_chat(user, "<span class='warning'>You are unable to cast this spell!</span>")
		return FALSE
	if(isliving(target))
		var/mob/living/L = target
		var/datum/antagonist/hog/cultie = IS_HOG_CULTIST(L)
		if(cultie && cultie.cult == cultie2.cult)
			to_chat(user, "<span class='warning'>Crushing your loyal servants isn't the best idea!</span>")
			return FALSE
	else if(ismecha(target))
		var/obj/mecha/M = target 
		if(M.occupant)
			var/mob/living/L = M.occupant
			var/datum/antagonist/hog/cultie = IS_HOG_CULTIST(L)
			if(cultie && cultie.cult == cultie2.cult)
				to_chat(user, "<span class='warning'>Crushing a mech occupied by your servant isn't a best idea!</span>")
				return FALSE
	return TRUE

/obj/effect/proc_holder/spell/pointed/kinetic_crush/cast(list/targets, mob/user)
	if(!targets.len)
		to_chat(user, "<span class='warning'>No target found in range!</span>")
		return FALSE
	if(!can_target(targets[1], user))
		return FALSE
	var/datum/antagonist/hog/cultie2 = IS_HOG_CULTIST(user)	
	if(isliving(targets[1]))
		var/mob/living/L = targets[1]
		var/datum/antagonist/hog/cultie = IS_HOG_CULTIST(L)
		if(cultie && cultie.cult == cultie2.cult)
			to_chat(user, "<span class='warning'>Crushing your loyal servants isn't the best idea!</span>")
			return FALSE
		else if(cultie)
			to_chat(user, "<span class='cult'>You crush [L] with your psionic power, but power of their heretical god protects them!</span>")
			L.Knockdown(5 SECONDS)
			L.adjustBruteLoss(35)



