/mob/living/simple_animal/hostile/hog/free_god
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
	cultist_desc = "Your god and saviour!"
	heretic_desc = "An ascended heretical demon that defiles this world just with its presence. Strike it down!"
	var/e = FALSE

/mob/living/simple_animal/hostile/hog/free_god/Initialize()
	. = ..()
	var/obj/effect/proc_holder/spell/pointed/kinetic_crush/crush = new
	AddSpell(crush)
	var/obj/effect/proc_holder/spell/pointed/enslave_mind/mental_attack = new
	AddSpell(mental_attack)
	ADD_TRAIT(src, TRAIT_SMIMMUNE, INNATE_TRAIT)   ///It is always stupid when a powerfull god dies just because he contacts with a funny crystal. 
	ADD_TRAIT(src, TRAIT_ANTIMAGIC, INNATE_TRAIT)

/mob/living/simple_animal/hostile/hog/free_god/AttackingTarget()
	melee_damage_lower = initial(melee_damage_lower)
	melee_damage_upper = initial(melee_damage_upper)    
	attacktext = initial(attacktext)
	var/mob/living/L = target
	var/strike_down = FALSE
	if(L)
		if(istype(L, /mob/living/simple_animal/hostile/hog/free_god))
			if(L == src)
				return ..()
			melee_damage_lower = 400
			melee_damage_upper = 400  
			attacktext = "tears into"              
		else
			var/datum/antagonist/hog/cultie = IS_HOG_CULTIST(L)
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

/mob/living/simple_animal/hostile/hog/free_god/say(message, bubble_type,var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	message = span_cultlarge(message)
	. = ..()

/mob/living/simple_animal/hostile/hog/free_god/ex_act(severity)
	return FALSE

/mob/living/simple_animal/hostile/hog/free_god/singularity_act()
	///user.say("ahahahaha fuck ya singulo")
	return FALSE

/mob/living/simple_animal/hostile/hog/free_god/Process_Spacemove()
	return TRUE

/mob/living/simple_animal/hostile/hog/free_god/wabbajack_act()
	return

/mob/living/simple_animal/hostile/hog/free_god/death(gibbed) // Go kill myself
	if(!e)
		to_chat(src, "<span class='cultlarge>NO NO NO I CAN'T DIE LIKE THIS</span>")
		send_to_playing_players(span_cult("<b>\"<font size=6>YOU CAN'T STOP ME</font> <font size=5>I am </font> <font size=4>immortall </font> <font size=3>i will not die...</font> <font size=2>like this</font>\""))
		sound_to_playing_players('sound/machines/clockcult/ark_scream.ogg')
		cult.die()
		e = TRUE
		dust()
	. = ..()

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
		if(L == user)
			to_chat(user, "<span class='warning'>Crushing yourself isn't the best idea!</span>")
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
		else if(cultie || L.anti_magic_check() || istype(L, /mob/living/simple_animal/hostile/hog)) ///Do you really think that just being a chaplain with a nullrod will save you from an angry god?
			to_chat(user, "<span class='cult'>You crush [L] with your psionic power, but power of their heretical god lowers the damage!</span>")
			to_chat(L, "<span class='userdanger'>You feel a powerfull psionic wave crushing you into the floor!</span>")
			L.emote("scream")
			var/dablage = 35

			if(iscarbon(L))
				L.Knockdown(5 SECONDS)
			else if(istype(L, /mob/living/simple_animal/hostile/hog/free_god))
				dablage = 525
			else
				dablage = 50  ///More damage if not a carbon
			L.adjustBruteLoss(dablage)
			return TRUE
		else
			to_chat(user, "<span class='cult'>You crush [L] with your psionic power!</span>")
			to_chat(L, "<span class='userdanger'>You feel a powerfull psionic wave tearing you into pieces!</span>")
			L.emote("scream")	
			L.gib()
			return TRUE
	else if(ismecha(targets[1]))
		var/obj/mecha/M = targets[1]
		if(M.occupant)
			var/mob/living/L = M.occupant
			var/datum/antagonist/hog/cultie = IS_HOG_CULTIST(L)
			if(cultie && cultie.cult == cultie2.cult)
				to_chat(user, "<span class='warning'>Crushing a mech piloted by your servant isn't the best idea!</span>")
				return FALSE
		var/damage_to_deal = 100 + M.max_integrity*0.25
		damage_to_deal = min(damage_to_deal, M.max_integrity*0.8)
		M.take_damage(damage_to_deal, BRUTE, ENERGY, 1)
		return TRUE

/obj/effect/proc_holder/spell/pointed/enslave_mind
	name = "Enslave Mind"
	desc = "Instantly convert the target if it's mind isn't protected, otherwise deconverts from heretical cults or breaks mindshields."
	school = "conjuration"
	charge_type = "recharge"
	charge_max	= 30 SECONDS
	clothes_req = FALSE
	invocation = span_cultlarge("OBEY")
	invocation_type = "shout"
	range = 7
	cooldown_min = 30 SECONDS
	///ranged_mousepointer = 'icons/effects/mouse_pointers/mecha_mouse.dmi'
	action_icon_state = "enslave_mind"
	active_msg = "You prepare your mental attack..."
	deactive_msg = "You relax..."

/obj/effect/proc_holder/spell/pointed/enslave_mind/can_target(atom/target, mob/user, silent)
	. = ..()
	if(!.)
		return FALSE
	var/datum/antagonist/hog/cultie2 = IS_HOG_CULTIST(user)
	if(!cultie2)
		to_chat(user, "<span class='warning'>You are unable to cast this spell!</span>")
		return FALSE
	if(isliving(target))
		var/mob/living/L = target
		if(!L.mind)
			to_chat(user, "<span class='warning'>You don't need a braindead servant!</span>")
			return FALSE
		var/datum/antagonist/hog/cultie = IS_HOG_CULTIST(L)
		if(cultie && cultie.cult == cultie2.cult)
			to_chat(user, "<span class='warning'>[target] already serves you!</span>")
			return FALSE
		if(L == user)
			//to_chat(user, "<span class='warning'>You can't enslave yourself, dumbfuck</span>")
			to_chat(user, "<span class='warning'>You can't enslave yourself</span>")
			return FALSE
	else 
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/pointed/enslave_mind/cast(list/targets, mob/user)
	if(!targets.len)
		to_chat(user, "<span class='warning'>No target found in range!</span>")
		return FALSE
	if(!can_target(targets[1], user))
		return FALSE
	var/datum/antagonist/hog/cultie2 = IS_HOG_CULTIST(user)	
	if(isliving(targets[1]))
		var/mob/living/L = targets[1]
		if(istype(L, /mob/living/simple_animal/hostile/hog))
			var/message = "<span class='warning'>[L] is too different to serve you!</span>"
			if(istype(L, /mob/living/simple_animal/hostile/hog/free_god))
				message = "<span class='warning'>[L] is too powerfull to be enslaved. They should die.</span>"
			to_chat(user, message)
			return FALSE
		var/datum/antagonist/hog/cultie = IS_HOG_CULTIST(L)
		if(cultie && cultie.cult == cultie2.cult)
			to_chat(user, "<span class='warning'>[L] already serves you!</span>")
			return FALSE
		else if(HAS_TRAIT(L, TRAIT_MINDSHIELD)) ///Kinda yes
			to_chat(user, "<span class='notice'>You inflitrate [L]'s mind, destroying all their mindshield implants!</span>")
			to_chat(L, "<span class='userdanger'>A powerull mental attack crushes your mind, destroying all mindshield implants in your brain!</span>")
			for(var/obj/item/implant/mindshield/I in L)
				if(I)
					qdel(I)
			L.Knockdown(2 SECONDS)
			return TRUE
		else if(cultie)
			to_chat(user, "<span class='notice'>You inflitrate [L]'s mind, purging the presence of a heretical god from their mind!</span>")
			to_chat(L, "<span class='userdanger'>A powerull mental attack crushes your mind, purging your god presence from it!</span>")
			L.mind.remove_antag_datum(/datum/antagonist/hog)
			L.AdjustSleeping(30)
			return TRUE
		if(is_servant_of_ratvar(L))
			to_chat(user, "<span class='notice'>You inflitrate [L]'s mind, purging the presence of a heretical god from their mind!</span>")
			to_chat(L, "<span class='userdanger'>Unholy tendrils of darkness spread through your mind, purging the Justiciar's light!</span>")  ///Poor dude
			L.mind.remove_antag_datum(/datum/antagonist/clockcult)
			L.AdjustSleeping(30)
			return TRUE
		if(iscultist(L))
			to_chat(user, "<span class='notice'>You inflitrate [L]'s mind, purging the presence of a heretical god from their mind!</span>")
			to_chat(L, "<span class='userdanger'>A powerull mental attack crushes your mind, purging the presence of Nar'Sie from it!</span>")
			L.mind.remove_antag_datum(/datum/antagonist/cult)
			L.AdjustSleeping(30)
			return TRUE
		to_chat(user, "<span class='notice'>You enslave [L]'s will, converting them to your cult!</span>")
		to_chat(L, "<span class='userdanger'>A powerfull mental attack crushes your mind, enslaving you to [user]'s cult!</span>")
		add_hog_cultist(user, cultie2.cult, L.mind)
		return TRUE
	return FALSE
		
		






