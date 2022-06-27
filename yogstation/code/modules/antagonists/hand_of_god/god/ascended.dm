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
        if(L)
            var/datum/antagonist/hog/cultie = IS_HOG_CULTIST(target)
            var/strike_down = FALSE
            if(cultie && cultie.cult == src.cult)
                if(prob(30))
                    to_chat(user,span_warning("Probably, attacking your fellow servants isn't the best idea.")) 
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
    message = span_colossus(message)
	. = ..()